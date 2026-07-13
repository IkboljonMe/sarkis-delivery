import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Role } from '@prisma/client';
import { ClientInfo } from '../common/client-info';
import { PrismaService } from '../prisma/prisma.service';
import { toUserJson } from './user.serializer';

const PROFILE_FIELDS = [
  'name', 'lastName', 'address', 'city', 'postalCode', 'group',
  'lat', 'lng', 'language', 'referredBy', 'photoUrl',
] as const;

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async updateProfile(userId: string, dto: Record<string, any>) {
    const data = Object.fromEntries(
      Object.entries(dto).filter(([k, v]) => (PROFILE_FIELDS as readonly string[]).includes(k) && v !== undefined),
    );
    const user = await this.prisma.user.update({ where: { id: userId }, data });
    return toUserJson(user);
  }

  async adminUpdate(id: string, dto: Record<string, any>) {
    const data: Record<string, any> = Object.fromEntries(
      Object.entries(dto).filter(([k, v]) => (PROFILE_FIELDS as readonly string[]).includes(k) && v !== undefined),
    );
    if (typeof dto.isVerified === 'boolean') data.isVerified = dto.isVerified;
    if (typeof dto.isActive === 'boolean') data.isActive = dto.isActive;
    const user = await this.prisma.user.update({ where: { id }, data }).catch(() => null);
    if (!user) throw new NotFoundException('User not found');
    return toUserJson(user);
  }

  async registerFcmToken(userId: string, token: string, client: ClientInfo) {
    if (client.platform === 'unknown') throw new BadRequestException('X-Client-Platform header required');
    // A token can move between accounts on the same device — detach it elsewhere first.
    await this.prisma.device.updateMany({
      where: { fcmToken: token, NOT: { userId } },
      data: { fcmToken: '' },
    });
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
        fcmToken: token,
        lastIp: client.ip,
      },
      update: { fcmToken: token, lastIp: client.ip, lastSeenAt: new Date(), appVersion: client.appVersion },
    });
    return { ok: true };
  }

  async deleteSelf(userId: string) {
    // Keep order history rows (they reference snapshots) but anonymize the account.
    await this.prisma.$transaction([
      this.prisma.refreshToken.updateMany({ where: { userId }, data: { revokedAt: new Date() } }),
      this.prisma.device.deleteMany({ where: { userId } }),
      this.prisma.user.update({
        where: { id: userId },
        data: {
          isActive: false,
          phone: null,
          email: null,
          googleId: null,
          passwordHash: null,
          name: 'Deleted',
          lastName: 'User',
          address: '',
          photoUrl: '',
        },
      }),
    ]);
    return { ok: true };
  }

  async phoneExists(phone: string) {
    if (!/^\+[1-9]\d{6,14}$/.test(phone ?? '')) throw new BadRequestException('invalid phone');
    const user = await this.prisma.user.findUnique({ where: { phone }, select: { id: true } });
    return { exists: !!user };
  }

  async list(search?: string, group?: string) {
    const users = await this.prisma.user.findMany({
      where: {
        role: Role.CUSTOMER,
        ...(group ? { group } : {}),
        ...(search
          ? {
              OR: [
                { name: { contains: search, mode: 'insensitive' } },
                { lastName: { contains: search, mode: 'insensitive' } },
                { phone: { contains: search } },
                { email: { contains: search, mode: 'insensitive' } },
              ],
            }
          : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: 500,
    });
    return users.map(toUserJson);
  }

  async getById(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return toUserJson(user);
  }
}
