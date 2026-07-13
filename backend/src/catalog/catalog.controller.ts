import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { Public, Roles } from '../common/decorators';
import { CatalogService } from './catalog.service';
import { CategoryDto, ProductDto } from './dto';

@Controller()
export class CatalogController {
  constructor(private catalog: CatalogService) {}

  // ---------- public ----------

  @Public()
  @Get('categories')
  categories(@Query('all') all?: string, @Query('since') since?: string) {
    return this.catalog.categories(all === 'true', since);
  }

  @Public()
  @Get('products')
  products(@Query('categoryId') categoryId?: string, @Query('all') all?: string, @Query('since') since?: string) {
    return this.catalog.products(categoryId, all === 'true', since);
  }

  @Public()
  @Get('products/:id')
  product(@Param('id') id: string) {
    return this.catalog.product(id);
  }

  // ---------- staff ----------

  @Roles(Role.ADMIN)
  @Post('admin/categories')
  createCategory(@Body() dto: CategoryDto) {
    return this.catalog.saveCategory(dto);
  }

  @Roles(Role.ADMIN)
  @Patch('admin/categories/:id')
  updateCategory(@Param('id') id: string, @Body() dto: CategoryDto) {
    return this.catalog.saveCategory(dto, id);
  }

  @Roles(Role.ADMIN)
  @Delete('admin/categories/:id')
  deleteCategory(@Param('id') id: string) {
    return this.catalog.deleteCategory(id);
  }

  @Roles(Role.ADMIN)
  @Post('admin/products')
  createProduct(@Body() dto: ProductDto) {
    return this.catalog.saveProduct(dto);
  }

  @Roles(Role.ADMIN)
  @Patch('admin/products/:id')
  updateProduct(@Param('id') id: string, @Body() dto: ProductDto) {
    return this.catalog.saveProduct(dto, id);
  }

  @Roles(Role.ADMIN)
  @Delete('admin/products/:id')
  deleteProduct(@Param('id') id: string) {
    return this.catalog.deleteProduct(id);
  }
}
