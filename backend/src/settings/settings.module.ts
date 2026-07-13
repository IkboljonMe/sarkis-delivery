import { Body, Controller, Get, HttpCode, Module, Put } from '@nestjs/common';
import { Role } from '@prisma/client';
import { Roles } from '../common/decorators';
import { PrismaService } from '../prisma/prisma.service';

/** Global app configuration (order limits, contact numbers, …) edited by staff. */
@Roles(Role.ADMIN)
@Controller('admin/settings')
export class SettingsController {
  constructor(private prisma: PrismaService) {}

  @Get()
  async get() {
    const row = await this.prisma.appSetting.findUnique({ where: { key: 'config' } });
    return (row?.value as Record<string, any>) ?? {};
  }

  @Put()
  @HttpCode(200)
  async save(@Body() body: Record<string, any>) {
    const row = await this.prisma.appSetting.upsert({
      where: { key: 'config' },
      create: { key: 'config', value: body },
      update: { value: body },
    });
    return row.value;
  }
}

@Module({ controllers: [SettingsController] })
export class SettingsModule {}
