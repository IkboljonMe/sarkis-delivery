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
} from '@nestjs/common';
import { RegionGroup, Role } from '@prisma/client';
import { IsInt, IsNumber, IsOptional, IsString, MinLength } from 'class-validator';
import { Public, Roles } from '../common/decorators';
import { PrismaService } from '../prisma/prisma.service';

type LatLng = { lat: number; lng: number };

export const toZoneJson = (z: RegionGroup) => ({
  id: z.id,
  name: z.name,
  colorValue: z.colorValue,
  polygons: z.polygons,
  createdAt: z.createdAt.toISOString(),
  updatedAt: z.updatedAt.toISOString(),
});

/** Ray-casting point-in-polygon. */
function pointInRing(p: LatLng, ring: LatLng[]): boolean {
  let inside = false;
  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const a = ring[i];
    const b = ring[j];
    if (
      a.lng > p.lng !== b.lng > p.lng &&
      p.lat < ((b.lat - a.lat) * (p.lng - a.lng)) / (b.lng - a.lng) + a.lat
    ) {
      inside = !inside;
    }
  }
  return inside;
}

class ZoneDto {
  @IsOptional() @IsString() @MinLength(2) name?: string;
  @IsOptional() @IsInt() colorValue?: number;
  @IsOptional() polygons?: LatLng[][];
}

class ResolveDto {
  @IsNumber() lat!: number;
  @IsNumber() lng!: number;
}

@Injectable()
export class ZonesService {
  constructor(private prisma: PrismaService) {}

  async resolveGroupName(lat: number, lng: number): Promise<string | null> {
    const zones = await this.prisma.regionGroup.findMany();
    for (const z of zones) {
      const polys = (z.polygons as unknown as any[]) ?? [];
      for (const rawRing of polys) {
        // Rings arrive either as plain [{lat,lng},...] or wrapped as
        // {points:[...]} (the Flutter admin app's Firestore-era format).
        const ring: LatLng[] = Array.isArray(rawRing) ? rawRing : rawRing?.points ?? [];
        if (ring.length >= 3 && pointInRing({ lat, lng }, ring)) {
          return z.name;
        }
      }
    }
    return null;
  }
}

@Controller()
export class ZonesController {
  constructor(private prisma: PrismaService, private zones: ZonesService) {}

  /** Public: registration screen needs the group list + polygon resolve before login. */
  @Public()
  @Get('zones')
  async list() {
    const rows = await this.prisma.regionGroup.findMany({ orderBy: { name: 'asc' } });
    return rows.map(toZoneJson);
  }

  @Public()
  @Post('zones/resolve')
  async resolve(@Body() dto: ResolveDto) {
    return { group: await this.zones.resolveGroupName(dto.lat, dto.lng) };
  }

  @Roles(Role.ADMIN)
  @Post('admin/zones')
  async create(@Body() dto: ZoneDto) {
    if (!dto.name) throw new BadRequestException('name is required');
    const row = await this.prisma.regionGroup.create({
      data: { name: dto.name, colorValue: dto.colorValue ?? 0, polygons: (dto.polygons ?? []) as any },
    });
    return toZoneJson(row);
  }

  @Roles(Role.ADMIN)
  @Patch('admin/zones/:id')
  async update(@Param('id') id: string, @Body() dto: ZoneDto) {
    const data: Record<string, any> = Object.fromEntries(
      Object.entries(dto).filter(([, v]) => v !== undefined),
    );
    const row = await this.prisma.regionGroup.update({ where: { id }, data }).catch(() => null);
    if (!row) throw new NotFoundException('Zone not found');
    return toZoneJson(row);
  }

  @Roles(Role.ADMIN)
  @Delete('admin/zones/:id')
  async remove(@Param('id') id: string) {
    await this.prisma.regionGroup.delete({ where: { id } }).catch(() => {
      throw new NotFoundException('Zone not found');
    });
    return { ok: true };
  }
}

@Module({
  controllers: [ZonesController],
  providers: [ZonesService],
  exports: [ZonesService],
})
export class ZonesModule {}
