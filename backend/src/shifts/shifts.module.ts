import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Injectable,
  Module,
  NotFoundException,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { Role, Shift } from '@prisma/client';
import { IsBoolean, IsInt, IsISO8601, IsOptional, IsString, Min } from 'class-validator';
import { Roles } from '../common/decorators';
import { PrismaService } from '../prisma/prisma.service';

export const toShiftJson = (s: Shift) => ({
  id: s.id,
  group: s.group,
  date: s.date.toISOString(),
  label: s.label,
  isOpen: s.isOpen,
  cancelDaysBefore: s.cancelDaysBefore,
  editDaysBefore: s.editDaysBefore,
  createdAt: s.createdAt.toISOString(),
  updatedAt: s.updatedAt.toISOString(),
});

class ShiftDto {
  @IsOptional() @IsString() group?: string;
  @IsOptional() @IsISO8601() date?: string;
  @IsOptional() @IsString() label?: string;
  @IsOptional() @IsBoolean() isOpen?: boolean;
  @IsOptional() @IsInt() @Min(0) cancelDaysBefore?: number;
  @IsOptional() @IsInt() @Min(0) editDaysBefore?: number;
}

@Injectable()
export class ShiftsService {
  constructor(private prisma: PrismaService) {}

  getById(id: string) {
    return this.prisma.shift.findUnique({ where: { id } });
  }
}

@Controller()
export class ShiftsController {
  constructor(private prisma: PrismaService) {}

  /** Customers see shifts for their group; ?open=true filters to bookable ones. */
  @Get('shifts')
  async list(@Query('group') group?: string, @Query('open') open?: string, @Query('since') since?: string) {
    const rows = await this.prisma.shift.findMany({
      where: {
        ...(group ? { group } : {}),
        ...(open === 'true' ? { isOpen: true, date: { gte: new Date(new Date().setHours(0, 0, 0, 0)) } } : {}),
        ...(since ? { updatedAt: { gt: new Date(since) } } : {}),
      },
      orderBy: { date: 'asc' },
      take: 200,
    });
    return rows.map(toShiftJson);
  }

  @Roles(Role.ADMIN)
  @Post('admin/shifts')
  async create(@Body() dto: ShiftDto) {
    if (!dto.group || !dto.date) throw new BadRequestException('group and date are required');
    const row = await this.prisma.shift.create({
      data: {
        group: dto.group,
        date: new Date(dto.date),
        label: dto.label ?? '',
        isOpen: dto.isOpen ?? true,
        cancelDaysBefore: dto.cancelDaysBefore ?? 1,
        editDaysBefore: dto.editDaysBefore ?? 1,
      },
    });
    return toShiftJson(row);
  }

  @Roles(Role.ADMIN)
  @Patch('admin/shifts/:id')
  async update(@Param('id') id: string, @Body() dto: ShiftDto) {
    const data: Record<string, any> = Object.fromEntries(
      Object.entries(dto).filter(([, v]) => v !== undefined),
    );
    if (data.date) data.date = new Date(data.date);
    const row = await this.prisma.shift.update({ where: { id }, data }).catch(() => null);
    if (!row) throw new NotFoundException('Shift not found');
    return toShiftJson(row);
  }

  @Roles(Role.ADMIN)
  @Delete('admin/shifts/:id')
  async remove(@Param('id') id: string) {
    await this.prisma.shift.delete({ where: { id } }).catch(() => {
      throw new NotFoundException('Shift not found');
    });
    return { ok: true };
  }
}

@Module({
  controllers: [ShiftsController],
  providers: [ShiftsService],
  exports: [ShiftsService],
})
export class ShiftsModule {}
