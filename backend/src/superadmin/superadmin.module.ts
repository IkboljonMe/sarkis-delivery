import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  Injectable,
  Module,
  NotFoundException,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { Platform, Role } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import {
  IsBoolean,
  IsEmail,
  IsIn,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { Roles } from '../common/decorators';
import { PrismaService } from '../prisma/prisma.service';
import { toUserJson } from '../users/user.serializer';

class CreateStaffDto {
  @IsIn(['DRIVER', 'ADMIN']) role!: 'DRIVER' | 'ADMIN';
  @IsEmail() email!: string;
  @IsString() @MinLength(8) @MaxLength(128) password!: string;
  @IsOptional() @IsString() @MaxLength(100) name?: string;
  @IsOptional() @IsString() @MaxLength(100) lastName?: string;
  @IsOptional() @Matches(/^\+[1-9]\d{6,14}$/) phone?: string;
  @IsOptional() @IsString() @MaxLength(50) group?: string;
}

class UpdateStaffDto {
  @IsOptional() @IsBoolean() isActive?: boolean;
  @IsOptional() @IsString() @MinLength(8) @MaxLength(128) password?: string;
  @IsOptional() @IsString() @MaxLength(100) name?: string;
  @IsOptional() @IsString() @MaxLength(100) lastName?: string;
  @IsOptional() @Matches(/^\+[1-9]\d{6,14}$/) phone?: string;
  @IsOptional() @IsString() @MaxLength(50) group?: string;
  @IsOptional() @IsIn(['DRIVER', 'ADMIN']) role?: 'DRIVER' | 'ADMIN';
}

@Injectable()
export class SuperadminService {
  constructor(private prisma: PrismaService) {}

  async createStaff(dto: CreateStaffDto) {
    const email = dto.email.toLowerCase().trim();
    if (await this.prisma.user.findUnique({ where: { email } })) {
      throw new BadRequestException('Email already in use');
    }
    if (dto.phone && (await this.prisma.user.findUnique({ where: { phone: dto.phone } }))) {
      throw new BadRequestException('Phone already in use');
    }
    const user = await this.prisma.user.create({
      data: {
        role: dto.role as Role,
        email,
        passwordHash: await bcrypt.hash(dto.password, 10),
        emailVerifiedAt: new Date(),
        isVerified: true,
        name: dto.name ?? '',
        lastName: dto.lastName ?? '',
        phone: dto.phone ?? null,
        group: dto.group ?? '',
      },
    });
    return toUserJson(user);
  }

  async listStaff(role?: string) {
    const users = await this.prisma.user.findMany({
      where: { role: role ? (role as Role) : { in: [Role.DRIVER, Role.ADMIN] } },
      orderBy: { createdAt: 'desc' },
      include: { devices: true },
    });
    return users.map((u) => ({
      ...toUserJson(u),
      devices: u.devices.map((d) => ({
        platform: d.platform,
        deviceModel: d.deviceModel,
        appVersion: d.appVersion,
        lastIp: d.lastIp,
        lastSeenAt: d.lastSeenAt.toISOString(),
      })),
    }));
  }

  async updateStaff(id: string, dto: UpdateStaffDto) {
    const target = await this.prisma.user.findUnique({ where: { id } });
    if (!target || target.role === Role.CUSTOMER) throw new NotFoundException('Staff member not found');
    if (target.role === Role.SUPERADMIN) throw new BadRequestException('Cannot modify the superadmin');

    const data: Record<string, any> = {};
    for (const k of ['name', 'lastName', 'phone', 'group', 'role'] as const) {
      if (dto[k] !== undefined) data[k] = dto[k];
    }
    if (dto.isActive !== undefined) data.isActive = dto.isActive;
    if (dto.password) data.passwordHash = await bcrypt.hash(dto.password, 10);

    const user = await this.prisma.user.update({ where: { id }, data });
    if (dto.isActive === false || dto.password) {
      // Kicked or rotated credentials → kill sessions.
      await this.prisma.refreshToken.updateMany({
        where: { userId: id, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
    return toUserJson(user);
  }

  async loginEvents(userId?: string, limit = 100) {
    const rows = await this.prisma.loginEvent.findMany({
      where: userId ? { userId } : {},
      orderBy: { createdAt: 'desc' },
      take: Math.min(limit, 500),
    });
    return rows.map((e) => ({
      id: e.id,
      userId: e.userId,
      identifier: e.identifier,
      method: e.method,
      success: e.success,
      ip: e.ip,
      platform: e.platform,
      browser: e.browser,
      os: e.os,
      deviceModel: e.deviceModel,
      appVersion: e.appVersion,
      createdAt: e.createdAt.toISOString(),
    }));
  }

  async stats() {
    const [customers, drivers, admins, orders, revenue, devicesByPlatform, loginsByPlatform] =
      await Promise.all([
        this.prisma.user.count({ where: { role: Role.CUSTOMER } }),
        this.prisma.user.count({ where: { role: Role.DRIVER } }),
        this.prisma.user.count({ where: { role: Role.ADMIN } }),
        this.prisma.order.groupBy({ by: ['status'], _count: { _all: true } }),
        this.prisma.order.aggregate({ where: { status: 'delivered' }, _sum: { totalPrice: true } }),
        this.prisma.device.groupBy({ by: ['platform'], _count: { _all: true } }),
        this.prisma.loginEvent.groupBy({
          by: ['platform'],
          where: { success: true, createdAt: { gte: new Date(Date.now() - 30 * 24 * 3600 * 1000) } },
          _count: { _all: true },
        }),
      ]);
    return {
      users: { customers, drivers, admins },
      ordersByStatus: Object.fromEntries(orders.map((o) => [o.status, o._count._all])),
      revenue: revenue._sum.totalPrice ?? 0,
      devicesByPlatform: Object.fromEntries(devicesByPlatform.map((d) => [d.platform, d._count._all])) as Record<Platform, number>,
      loginsLast30dByPlatform: Object.fromEntries(loginsByPlatform.map((d) => [d.platform, d._count._all])),
    };
  }
}

@Roles(Role.SUPERADMIN)
@Controller('superadmin')
export class SuperadminController {
  constructor(private svc: SuperadminService) {}

  @Post('staff')
  create(@Body() dto: CreateStaffDto) {
    return this.svc.createStaff(dto);
  }

  @Get('staff')
  list(@Query('role') role?: string) {
    return this.svc.listStaff(role);
  }

  @Patch('staff/:id')
  update(@Param('id') id: string, @Body() dto: UpdateStaffDto) {
    return this.svc.updateStaff(id, dto);
  }

  @Post('staff/:id/deactivate')
  @HttpCode(200)
  deactivate(@Param('id') id: string) {
    return this.svc.updateStaff(id, { isActive: false });
  }

  @Get('login-events')
  loginEvents(@Query('userId') userId?: string, @Query('limit') limit?: string) {
    return this.svc.loginEvents(userId, limit ? Number(limit) : undefined);
  }

  @Get('stats')
  stats() {
    return this.svc.stats();
  }
}

@Module({
  controllers: [SuperadminController],
  providers: [SuperadminService],
})
export class SuperadminModule {}
