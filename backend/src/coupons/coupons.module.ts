import { Module } from '@nestjs/common';
import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Injectable,
  NotFoundException,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { Coupon, Role } from '@prisma/client';
import { IsBoolean, IsIn, IsInt, IsISO8601, IsNumber, IsOptional, IsString, Min, MinLength } from 'class-validator';
import { Roles } from '../common/decorators';
import { PrismaService } from '../prisma/prisma.service';

export const toCouponJson = (c: Coupon) => ({
  id: c.id,
  code: c.code,
  type: c.type,
  value: c.value,
  minOrder: c.minOrder,
  isActive: c.isActive,
  expiresAt: c.expiresAt?.toISOString() ?? null,
  usageLimit: c.usageLimit,
  usedCount: c.usedCount,
  createdAt: c.createdAt.toISOString(),
});

export function couponUsable(c: Coupon, subtotal: number): string | null {
  if (!c.isActive) return 'Coupon is not active';
  if (c.expiresAt && c.expiresAt < new Date()) return 'Coupon expired';
  if (c.usageLimit > 0 && c.usedCount >= c.usageLimit) return 'Coupon usage limit reached';
  if (subtotal < c.minOrder) return `Minimum order of ${c.minOrder} EUR required`;
  return null;
}

export function couponDiscount(c: Coupon, subtotal: number): number {
  const raw = c.type === 'percent' ? (subtotal * c.value) / 100 : c.value;
  return Math.min(Math.round(raw * 100) / 100, subtotal);
}

class CouponDto {
  @IsOptional() @IsString() @MinLength(2) code?: string;
  @IsOptional() @IsIn(['percent', 'fixed']) type?: string;
  @IsOptional() @IsNumber() @Min(0) value?: number;
  @IsOptional() @IsNumber() @Min(0) minOrder?: number;
  @IsOptional() @IsBoolean() isActive?: boolean;
  @IsOptional() @IsISO8601() expiresAt?: string;
  @IsOptional() @IsInt() @Min(0) usageLimit?: number;
}

@Injectable()
export class CouponsService {
  constructor(private prisma: PrismaService) {}

  normalize(code: string) {
    return code.trim().toUpperCase();
  }

  async byCode(code: string) {
    return this.prisma.coupon.findUnique({ where: { code: this.normalize(code) } });
  }
}

@Controller()
export class CouponsController {
  constructor(private prisma: PrismaService, private coupons: CouponsService) {}

  /** Customer-side validation while typing a code in the cart. */
  @Get('coupons/:code')
  async check(@Param('code') code: string) {
    const c = await this.coupons.byCode(code);
    if (!c) throw new NotFoundException('Coupon not found');
    return toCouponJson(c);
  }

  @Roles(Role.ADMIN)
  @Get('admin/coupons')
  async list() {
    const rows = await this.prisma.coupon.findMany({ orderBy: { createdAt: 'desc' } });
    return rows.map(toCouponJson);
  }

  @Roles(Role.ADMIN)
  @Post('admin/coupons')
  async create(@Body() dto: CouponDto) {
    if (!dto.code || !dto.type || dto.value === undefined) {
      throw new BadRequestException('code, type and value are required');
    }
    const row = await this.prisma.coupon.create({
      data: {
        code: this.coupons.normalize(dto.code),
        type: dto.type,
        value: dto.value,
        minOrder: dto.minOrder ?? 0,
        isActive: dto.isActive ?? true,
        expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : null,
        usageLimit: dto.usageLimit ?? 0,
      },
    });
    return toCouponJson(row);
  }

  @Roles(Role.ADMIN)
  @Patch('admin/coupons/:id')
  async update(@Param('id') id: string, @Body() dto: CouponDto) {
    const data: Record<string, any> = Object.fromEntries(
      Object.entries(dto).filter(([, v]) => v !== undefined),
    );
    if (data.code) data.code = this.coupons.normalize(data.code);
    if (data.expiresAt) data.expiresAt = new Date(data.expiresAt);
    const row = await this.prisma.coupon.update({ where: { id }, data }).catch(() => null);
    if (!row) throw new NotFoundException('Coupon not found');
    return toCouponJson(row);
  }

  @Roles(Role.ADMIN)
  @Delete('admin/coupons/:id')
  async remove(@Param('id') id: string) {
    await this.prisma.coupon.delete({ where: { id } }).catch(() => {
      throw new NotFoundException('Coupon not found');
    });
    return { ok: true };
  }
}

@Module({
  controllers: [CouponsController],
  providers: [CouponsService],
  exports: [CouponsService],
})
export class CouponsModule {}
