import { Body, Controller, Get, HttpCode, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { User } from '@prisma/client';
import { ClientInfo, GetClientInfo } from '../common/client-info';
import { CurrentUser, Platforms, Public } from '../common/decorators';
import { toUserJson } from '../users/user.serializer';
import { AuthService } from './auth.service';
import {
  EmailLoginDto,
  EmailRegisterDto,
  GoogleLoginDto,
  LogoutDto,
  OtpRequestDto,
  OtpVerifyDto,
  RefreshDto,
} from './dto';

@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  /** Phone OTP is a mobile-app flow — web uses Google or email. */
  @Public()
  @Platforms('android', 'ios')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Post('otp/request')
  @HttpCode(200)
  otpRequest(@Body() dto: OtpRequestDto, @GetClientInfo() client: ClientInfo) {
    return this.auth.otpRequest(dto.phone, client);
  }

  @Public()
  @Platforms('android', 'ios')
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('otp/verify')
  @HttpCode(200)
  otpVerify(@Body() dto: OtpVerifyDto, @GetClientInfo() client: ClientInfo) {
    return this.auth.otpVerify(dto.phone, dto.code, client);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('email/register')
  emailRegister(@Body() dto: EmailRegisterDto, @GetClientInfo() client: ClientInfo) {
    return this.auth.emailRegister(dto, client);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('email/login')
  @HttpCode(200)
  emailLogin(@Body() dto: EmailLoginDto, @GetClientInfo() client: ClientInfo) {
    return this.auth.emailLogin(dto.email, dto.password, client);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('google')
  @HttpCode(200)
  google(@Body() dto: GoogleLoginDto, @GetClientInfo() client: ClientInfo) {
    return this.auth.googleLogin(dto.idToken, client);
  }

  @Public()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Post('refresh')
  @HttpCode(200)
  refresh(@Body() dto: RefreshDto, @GetClientInfo() client: ClientInfo) {
    return this.auth.refresh(dto.refreshToken, client);
  }

  @Post('logout')
  @HttpCode(200)
  logout(@CurrentUser() user: User, @Body() dto: LogoutDto) {
    return this.auth.logout(user.id, dto.refreshToken, dto.allDevices);
  }

  @Get('me')
  me(@CurrentUser() user: User) {
    return toUserJson(user);
  }
}
