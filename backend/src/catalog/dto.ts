import {
  IsBoolean,
  IsIn,
  IsInt,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CategoryDto {
  @IsOptional() @IsObject() name?: Record<string, string>;
  @IsOptional() @IsString() imageUrl?: string;
  @IsOptional() @IsInt() sortOrder?: number;
  @IsOptional() @IsBoolean() isActive?: boolean;
}

export class ProductDto {
  @IsOptional() @IsString() categoryId?: string;
  @IsOptional() @IsObject() name?: Record<string, string>;
  @IsOptional() @IsObject() description?: Record<string, string>;
  @IsOptional() @IsNumber() @Min(0) price?: number;
  @IsOptional() @IsString() unit?: string;
  @IsOptional() @IsInt() @Min(0) maxQty?: number;
  @IsOptional() @IsString() imageUrl?: string;
  @IsOptional() images?: string[];
  @IsOptional() photos?: { url: string; title?: Record<string, string> }[];
  @IsOptional() @IsBoolean() isActive?: boolean;
  @IsOptional() @IsInt() sortOrder?: number;
  @IsOptional() @IsIn(['none', 'percent', 'fixed']) discountType?: string;
  @IsOptional() @IsNumber() @Min(0) discountValue?: number;
}
