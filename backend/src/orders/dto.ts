import { Type } from 'class-transformer';
import {
  ArrayNotEmpty,
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

export class OrderItemDto {
  @IsString() @IsNotEmpty() productId!: string;
  @IsInt() @Min(1) @Max(999) qty!: number;
}

export class CreateOrderDto {
  @IsOptional() @IsString() shiftId?: string;

  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items!: OrderItemDto[];

  @IsOptional() @IsString() @MaxLength(50) couponCode?: string;
}

export class EditOrderDto {
  @IsOptional()
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items?: OrderItemDto[];

  @IsOptional() @IsString() shiftId?: string;
}

export class StaffUpdateOrderDto {
  @IsOptional() @IsIn(['pending', 'confirmed', 'on_the_way', 'delivered', 'cancelled']) status?: string;
  @IsOptional() @IsString() @MaxLength(1000) adminNote?: string;
  @IsOptional() @IsBoolean() pendingApproval?: boolean;
  @IsOptional() @IsBoolean() awaitingSchedule?: boolean;
  @IsOptional() @IsBoolean() cashCollected?: boolean;
  @IsOptional() @IsString() shiftId?: string;
}

export class AssignDriverDto {
  @IsString() @IsNotEmpty() driverId!: string;
}

export class DriverStatusDto {
  @IsIn(['on_the_way', 'delivered']) status!: string;
  @IsOptional() @IsBoolean() cashCollected?: boolean;
}
