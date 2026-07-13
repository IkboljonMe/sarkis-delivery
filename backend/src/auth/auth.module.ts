import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { smsProviderFactory } from './sms.provider';

@Module({
  controllers: [AuthController],
  providers: [AuthService, smsProviderFactory],
  exports: [AuthService],
})
export class AuthModule {}
