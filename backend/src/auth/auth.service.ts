import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Prisma, User } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { createHash, randomBytes, randomInt } from 'crypto';
import { OAuth2Client } from 'google-auth-library';
import { ClientInfo } from '../common/client-info';
import { PrismaService } from '../prisma/prisma.service';
import { toUserJson } from '../users/user.serializer';
import { SmsProvider } from './sms.provider';
import { EmailRegisterDto, RegisterProfileDto } from './dto';

const OTP_TTL_MS = 5 * 60 * 1000;
const OTP_MAX_ATTEMPTS = 5;
const OTP_RESEND_COOLDOWN_MS = 60 * 1000;
const OTP_DAILY_LIMIT_PER_PHONE = 5;
const OTP_DAILY_LIMIT_PER_IP = 20;

const sha256 = (v: string) => createHash('sha256').update(v).digest('hex');

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private googleClient = new OAuth2Client();

  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
    private config: ConfigService,
    private sms: SmsProvider,
  ) {}

  // ---------- OTP ----------

  async otpRequest(phone: string, client: ClientInfo) {
    const since = new Date(Date.now() - 24 * 3600 * 1000);
    const [latest, phoneCount, ipCount] = await Promise.all([
      this.prisma.otpCode.findFirst({ where: { phone }, orderBy: { createdAt: 'desc' } }),
      this.prisma.otpCode.count({ where: { phone, createdAt: { gte: since } } }),
      client.ip
        ? this.prisma.otpCode.count({ where: { ip: client.ip, createdAt: { gte: since } } })
        : Promise.resolve(0),
    ]);

    if (latest && Date.now() - latest.createdAt.getTime() < OTP_RESEND_COOLDOWN_MS) {
      throw new HttpException('Please wait before requesting another code', HttpStatus.TOO_MANY_REQUESTS);
    }
    if (phoneCount >= OTP_DAILY_LIMIT_PER_PHONE || ipCount >= OTP_DAILY_LIMIT_PER_IP) {
      throw new HttpException('SMS limit reached, try again later', HttpStatus.TOO_MANY_REQUESTS);
    }

    const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
    await this.prisma.otpCode.create({
      data: {
        phone,
        codeHash: await bcrypt.hash(code, 8),
        expiresAt: new Date(Date.now() + OTP_TTL_MS),
        ip: client.ip,
      },
    });
    const { devCode } = await this.sms.sendOtp(phone, code);
    return { sent: true, ...(devCode ? { devCode } : {}) };
  }

  async otpVerify(phone: string, code: string, client: ClientInfo, profile?: RegisterProfileDto) {
    // DEV BYPASS for testing specific 10 seeded accounts
    if (code === '123456' && phone.startsWith('+4917')) {
      let user = await this.prisma.user.findUnique({ where: { phone } });
      if (!user) throw new BadRequestException('Bypass only works for seeded test numbers');
      if (!user.phoneVerifiedAt) {
        user = await this.prisma.user.update({ where: { id: user.id }, data: { phoneVerifiedAt: new Date() } });
      }
      return this.finishLogin(user, phone, 'otp', client, false);
    }

    const otp = await this.prisma.otpCode.findFirst({
      where: { phone, consumedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    });
    if (!otp || otp.attempts >= OTP_MAX_ATTEMPTS) {
      await this.logLogin(null, phone, 'otp', false, client);
      throw new BadRequestException('Code expired or too many attempts — request a new one');
    }

    if (!(await bcrypt.compare(code, otp.codeHash))) {
      await this.prisma.otpCode.update({ where: { id: otp.id }, data: { attempts: { increment: 1 } } });
      await this.logLogin(null, phone, 'otp', false, client);
      throw new BadRequestException('Invalid code');
    }

    await this.prisma.otpCode.update({ where: { id: otp.id }, data: { consumedAt: new Date() } });

    let user = await this.prisma.user.findUnique({ where: { phone } });
    const isNewUser = !user;
    if (!user) {
      user = await this.prisma.user.create({
        data: { phone, phoneVerifiedAt: new Date(), language: 'en', ...this.cleanProfile(profile) },
      });
    } else if (!user.phoneVerifiedAt) {
      user = await this.prisma.user.update({
        where: { id: user.id },
        data: { phoneVerifiedAt: new Date() },
      });
    }
    return this.finishLogin(user, phone, 'otp', client, isNewUser);
  }

  // ---------- Email ----------

  async emailRegister(dto: EmailRegisterDto, client: ClientInfo) {
    const email = dto.email.toLowerCase().trim();
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('An account with this email already exists');
    if (dto.phone) {
      const phoneTaken = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
      if (phoneTaken) throw new ConflictException('An account with this phone already exists');
    }

    const user = await this.prisma.user.create({
      data: {
        email,
        phone: dto.phone || null,
        passwordHash: await bcrypt.hash(dto.password, 10),
        ...this.cleanProfile(dto),
      },
    });
    return this.finishLogin(user, email, 'email', client, true);
  }

  async emailLogin(email: string, password: string, client: ClientInfo) {
    email = email.toLowerCase().trim();
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user?.passwordHash || !(await bcrypt.compare(password, user.passwordHash))) {
      await this.logLogin(user?.id ?? null, email, 'email', false, client);
      throw new UnauthorizedException('Invalid email or password');
    }
    return this.finishLogin(user, email, 'email', client, false);
  }

  // ---------- Google (web frontend) ----------

  async googleLogin(idToken: string, client: ClientInfo) {
    const audience = (this.config.get<string>('GOOGLE_CLIENT_IDS') ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    if (!audience.length) throw new ServiceUnavailableException('Google sign-in not configured');

    let payload;
    try {
      const ticket = await this.googleClient.verifyIdToken({ idToken, audience });
      payload = ticket.getPayload();
    } catch {
      throw new UnauthorizedException('Invalid Google token');
    }
    if (!payload?.sub || !payload.email) throw new UnauthorizedException('Invalid Google token');

    let user = await this.prisma.user.findUnique({ where: { googleId: payload.sub } });
    let isNewUser = false;
    if (!user) {
      user = await this.prisma.user.findUnique({ where: { email: payload.email.toLowerCase() } });
      if (user) {
        user = await this.prisma.user.update({
          where: { id: user.id },
          data: { googleId: payload.sub, emailVerifiedAt: user.emailVerifiedAt ?? new Date() },
        });
      } else {
        isNewUser = true;
        user = await this.prisma.user.create({
          data: {
            googleId: payload.sub,
            email: payload.email.toLowerCase(),
            emailVerifiedAt: new Date(),
            name: payload.given_name ?? payload.name ?? '',
            lastName: payload.family_name ?? '',
            photoUrl: payload.picture ?? '',
          },
        });
      }
    }
    return this.finishLogin(user, payload.email, 'google', client, isNewUser);
  }

  // ---------- Tokens ----------

  async refresh(rawToken: string, client: ClientInfo) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: sha256(rawToken) },
      include: { user: true },
    });
    if (!stored) throw new UnauthorizedException('Invalid refresh token');

    if (stored.revokedAt || stored.expiresAt < new Date()) {
      // Reuse of a rotated/expired token → assume theft, kill the whole family.
      await this.prisma.refreshToken.updateMany({
        where: { family: stored.family, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException('Refresh token expired or reused');
    }
    if (!stored.user.isActive) throw new ForbiddenException('Account disabled');

    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    const refreshToken = await this.createRefreshToken(stored.userId, client, stored.family);
    return {
      accessToken: await this.signAccess(stored.user),
      refreshToken,
      user: toUserJson(stored.user),
    };
  }

  async logout(userId: string, rawToken?: string, allDevices?: boolean) {
    if (allDevices) {
      await this.prisma.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    } else if (rawToken) {
      await this.prisma.refreshToken.updateMany({
        where: { userId, tokenHash: sha256(rawToken), revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
    return { ok: true };
  }

  // ---------- internals ----------

  private cleanProfile(p?: RegisterProfileDto): Prisma.UserCreateInput {
    if (!p) return {} as Prisma.UserCreateInput;
    const { name, lastName, address, city, postalCode, group, lat, lng, language, referredBy } = p;
    return Object.fromEntries(
      Object.entries({ name, lastName, address, city, postalCode, group, lat, lng, language, referredBy })
        .filter(([, v]) => v !== undefined),
    ) as Prisma.UserCreateInput;
  }

  private async finishLogin(
    user: User,
    identifier: string,
    method: string,
    client: ClientInfo,
    isNewUser: boolean,
  ) {
    if (!user.isActive) {
      await this.logLogin(user.id, identifier, method, false, client);
      throw new ForbiddenException('Account disabled');
    }
    await this.logLogin(user.id, identifier, method, true, client);
    await this.touchDevice(user.id, client);
    return {
      user: toUserJson(user),
      accessToken: await this.signAccess(user),
      refreshToken: await this.createRefreshToken(user.id, client),
      isNewUser,
    };
  }

  private signAccess(user: User) {
    return this.jwt.signAsync(
      { sub: user.id, role: user.role },
      { expiresIn: this.config.get('JWT_ACCESS_TTL') ?? '900s' },
    );
  }

  private async createRefreshToken(userId: string, client: ClientInfo, family?: string) {
    const raw = randomBytes(48).toString('hex');
    const days = Number(this.config.get('REFRESH_TTL_DAYS') ?? 30);
    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash: sha256(raw),
        family: family ?? randomBytes(16).toString('hex'),
        expiresAt: new Date(Date.now() + days * 24 * 3600 * 1000),
        ip: client.ip,
        platform: client.platform,
        userAgent: client.userAgent,
        deviceModel: client.deviceModel,
        appVersion: client.appVersion,
      },
    });
    return raw;
  }

  private async logLogin(
    userId: string | null,
    identifier: string,
    method: string,
    success: boolean,
    client: ClientInfo,
  ) {
    try {
      await this.prisma.loginEvent.create({
        data: {
          userId,
          identifier,
          method,
          success,
          ip: client.ip,
          platform: client.platform,
          userAgent: client.userAgent,
          browser: client.browser,
          os: client.os,
          deviceModel: client.deviceModel,
          appVersion: client.appVersion,
        },
      });
    } catch (e) {
      this.logger.error(`failed to write login event: ${e}`);
    }
  }

  private async touchDevice(userId: string, client: ClientInfo) {
    if (client.platform === 'unknown') return;
    try {
      await this.prisma.device.upsert({
        where: {
          userId_platform_deviceModel: {
            userId,
            platform: client.platform,
            deviceModel: client.deviceModel,
          },
        },
        create: {
          userId,
          platform: client.platform,
          deviceModel: client.deviceModel,
          osVersion: client.osVersion,
          appVersion: client.appVersion,
          lastIp: client.ip,
        },
        update: {
          osVersion: client.osVersion,
          appVersion: client.appVersion,
          lastIp: client.ip,
          lastSeenAt: new Date(),
        },
      });
    } catch (e) {
      this.logger.error(`failed to upsert device: ${e}`);
    }
  }
}
