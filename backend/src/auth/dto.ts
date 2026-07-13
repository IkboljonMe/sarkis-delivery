import {
  IsBoolean,
  IsEmail,
  IsIn,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

const E164 = /^\+[1-9]\d{6,14}$/;

export class OtpRequestDto {
  @Matches(E164, { message: 'phone must be in E.164 format, e.g. +4915123456789' })
  phone!: string;
}

export class OtpVerifyDto {
  @Matches(E164)
  phone!: string;

  @IsString()
  @Length(6, 6)
  code!: string;
}

export class RegisterProfileDto {
  @IsOptional() @IsString() @MaxLength(100) name?: string;
  @IsOptional() @IsString() @MaxLength(100) lastName?: string;
  @IsOptional() @IsString() @MaxLength(300) address?: string;
  @IsOptional() @IsString() @MaxLength(100) city?: string;
  @IsOptional() @IsString() @MaxLength(20) postalCode?: string;
  @IsOptional() @IsString() @MaxLength(50) group?: string;
  @IsOptional() @IsNumber() lat?: number;
  @IsOptional() @IsNumber() lng?: number;
  @IsOptional() @IsIn(['en', 'hy', 'ru', 'tr', 'de']) language?: string;
  @IsOptional() @IsString() @MaxLength(100) referredBy?: string;
}

export class EmailRegisterDto extends RegisterProfileDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8, { message: 'password must be at least 8 characters' })
  @MaxLength(128)
  password!: string;

  @IsOptional()
  @Matches(E164)
  phone?: string;
}

export class EmailLoginDto {
  @IsEmail()
  email!: string;

  @IsString()
  @IsNotEmpty()
  password!: string;
}

export class GoogleLoginDto {
  @IsString()
  @IsNotEmpty()
  idToken!: string;
}

export class RefreshDto {
  @IsString()
  @IsNotEmpty()
  refreshToken!: string;
}

export class LogoutDto {
  @IsOptional()
  @IsString()
  refreshToken?: string;

  @IsOptional()
  @IsBoolean()
  allDevices?: boolean;
}
