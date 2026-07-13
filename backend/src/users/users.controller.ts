import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Throttle } from '@nestjs/throttler';
import { Role, User } from '@prisma/client';
import { IsIn, IsNotEmpty, IsString } from 'class-validator';
import { ClientInfo, GetClientInfo } from '../common/client-info';
import { CurrentUser, Public, Roles } from '../common/decorators';
import { RegisterProfileDto } from '../auth/dto';
import { avatarStorage, fileUrl, imageFilter } from '../uploads/storage';
import { toUserJson } from './user.serializer';
import { UsersService } from './users.service';

class FcmTokenDto {
  @IsString() @IsNotEmpty() token!: string;
}

class AdminUpdateUserDto extends RegisterProfileDto {
  isVerified?: boolean;
  isActive?: boolean;
}

class SetLanguageDto {
  @IsIn(['en', 'hy', 'ru', 'tr', 'de']) language!: string;
}

@Controller()
export class UsersController {
  constructor(private users: UsersService) {}

  // ---------- self ----------

  @Get('users/me')
  me(@CurrentUser() user: User) {
    return toUserJson(user);
  }

  @Patch('users/me')
  updateMe(@CurrentUser() user: User, @Body() dto: RegisterProfileDto) {
    return this.users.updateProfile(user.id, dto);
  }

  @Patch('users/me/language')
  setLanguage(@CurrentUser() user: User, @Body() dto: SetLanguageDto) {
    return this.users.updateProfile(user.id, { language: dto.language });
  }

  @Post('users/me/fcm-token')
  fcmToken(
    @CurrentUser() user: User,
    @Body() dto: FcmTokenDto,
    @GetClientInfo() client: ClientInfo,
  ) {
    return this.users.registerFcmToken(user.id, dto.token, client);
  }

  @Post('users/me/avatar')
  @UseInterceptors(FileInterceptor('file', { storage: avatarStorage, fileFilter: imageFilter, limits: { fileSize: 5 * 1024 * 1024 } }))
  async avatar(@CurrentUser() user: User, @UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('file is required');
    const url = fileUrl(file);
    await this.users.updateProfile(user.id, { photoUrl: url } as any);
    return { url };
  }

  @Delete('users/me')
  deleteMe(@CurrentUser() user: User) {
    return this.users.deleteSelf(user.id);
  }

  /** Registration helper: "is this phone already registered?" */
  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Get('users/phone-exists')
  phoneExists(@Query('phone') phone: string) {
    return this.users.phoneExists(phone);
  }

  // ---------- staff ----------

  @Roles(Role.ADMIN)
  @Get('admin/users')
  list(@Query('search') search?: string, @Query('group') group?: string) {
    return this.users.list(search, group);
  }

  @Roles(Role.ADMIN)
  @Get('admin/users/:id')
  get(@Param('id') id: string) {
    return this.users.getById(id);
  }

  @Roles(Role.ADMIN)
  @Patch('admin/users/:id')
  update(@Param('id') id: string, @Body() dto: AdminUpdateUserDto) {
    return this.users.adminUpdate(id, dto);
  }
}
