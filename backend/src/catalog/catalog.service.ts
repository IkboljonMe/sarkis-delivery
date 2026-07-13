import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { Category, Product } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CategoryDto, ProductDto } from './dto';

export const toCategoryJson = (c: Category) => ({
  id: c.id,
  name: c.name,
  imageUrl: c.imageUrl,
  sortOrder: c.sortOrder,
  isActive: c.isActive,
});

export const toProductJson = (p: Product) => ({
  id: p.id,
  categoryId: p.categoryId,
  name: p.name,
  description: p.description,
  price: p.price,
  unit: p.unit,
  maxQty: p.maxQty,
  imageUrl: p.imageUrl,
  images: p.images,
  photos: p.photos,
  isActive: p.isActive,
  sortOrder: p.sortOrder,
  discountType: p.discountType,
  discountValue: p.discountValue,
});

@Injectable()
export class CatalogService {
  constructor(private prisma: PrismaService) {}

  async categories(includeInactive: boolean) {
    const rows = await this.prisma.category.findMany({
      where: includeInactive ? {} : { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });
    return rows.map(toCategoryJson);
  }

  async products(categoryId?: string, includeInactive?: boolean) {
    const rows = await this.prisma.product.findMany({
      where: {
        ...(includeInactive ? {} : { isActive: true }),
        ...(categoryId ? { categoryId } : {}),
      },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    return rows.map(toProductJson);
  }

  async product(id: string) {
    const p = await this.prisma.product.findUnique({ where: { id } });
    if (!p) throw new NotFoundException('Product not found');
    return toProductJson(p);
  }

  async saveCategory(dto: CategoryDto, id?: string) {
    const data = {
      ...(dto.name !== undefined && { name: dto.name }),
      ...(dto.imageUrl !== undefined && { imageUrl: dto.imageUrl }),
      ...(dto.sortOrder !== undefined && { sortOrder: dto.sortOrder }),
      ...(dto.isActive !== undefined && { isActive: dto.isActive }),
    };
    const row = id
      ? await this.prisma.category.update({ where: { id }, data }).catch(() => null)
      : await this.prisma.category.create({ data: { name: dto.name ?? {}, ...data } });
    if (!row) throw new NotFoundException('Category not found');
    return toCategoryJson(row);
  }

  async deleteCategory(id: string) {
    await this.prisma.category.delete({ where: { id } }).catch(() => {
      throw new NotFoundException('Category not found');
    });
    return { ok: true };
  }

  async saveProduct(dto: ProductDto, id?: string) {
    const data: Record<string, any> = Object.fromEntries(
      Object.entries(dto).filter(([, v]) => v !== undefined),
    );
    let row: Product | null;
    if (id) {
      row = await this.prisma.product.update({ where: { id }, data }).catch(() => null);
      if (!row) throw new NotFoundException('Product not found');
    } else {
      if (!dto.categoryId || dto.price === undefined) {
        throw new BadRequestException('categoryId and price are required');
      }
      row = await this.prisma.product.create({
        data: { name: {}, ...data, categoryId: dto.categoryId, price: dto.price },
      });
    }
    return toProductJson(row);
  }

  async deleteProduct(id: string) {
    await this.prisma.product.delete({ where: { id } }).catch(() => {
      throw new NotFoundException('Product not found');
    });
    return { ok: true };
  }
}
