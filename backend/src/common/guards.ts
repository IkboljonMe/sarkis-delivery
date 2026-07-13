import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import { Request } from 'express';
import { PrismaService } from '../prisma/prisma.service';
import { IS_PUBLIC_KEY, PLATFORMS_KEY, ROLES_KEY } from './decorators';
import { ClientPlatform } from './client-info';

export const ROLE_LEVEL: Record<Role, number> = {
  CUSTOMER: 0,
  DRIVER: 1,
  ADMIN: 2,
  SUPERADMIN: 3,
};

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private jwt: JwtService,
    private prisma: PrismaService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (isPublic) return true;

    const req = ctx.switchToHttp().getRequest<Request>();
    const header = req.headers.authorization ?? '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new UnauthorizedException('Missing access token');

    let payload: { sub: string; role: Role };
    try {
      payload = await this.jwt.verifyAsync(token);
    } catch {
      throw new UnauthorizedException('Invalid or expired access token');
    }

    const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });
    if (!user || !user.isActive) throw new UnauthorizedException('Account not found or disabled');
    req.user = user;
    return true;
  }
}

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (!required?.length) return true;
    const { user } = ctx.switchToHttp().getRequest<Request>();
    if (!user) return false;
    const minLevel = Math.min(...required.map((r) => ROLE_LEVEL[r]));
    if (ROLE_LEVEL[user.role as Role] < minLevel) {
      throw new ForbiddenException('Insufficient role');
    }
    return true;
  }
}

@Injectable()
export class PlatformGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const allowed = this.reflector.getAllAndOverride<ClientPlatform[]>(PLATFORMS_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    if (!allowed?.length) return true;
    const req = ctx.switchToHttp().getRequest<Request>();
    const platform = req.clientInfo?.platform ?? 'unknown';
    if (!allowed.includes(platform)) {
      throw new ForbiddenException(`This endpoint is not available on "${platform}" devices`);
    }
    return true;
  }
}
