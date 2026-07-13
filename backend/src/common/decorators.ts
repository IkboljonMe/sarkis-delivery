import { SetMetadata, createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Role, User } from '@prisma/client';
import { Request } from 'express';
import { ClientPlatform } from './client-info';

export const IS_PUBLIC_KEY = 'isPublic';
/** Skip JWT auth for this route. */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

export const ROLES_KEY = 'roles';
/**
 * Minimum role(s) required. Role hierarchy applies:
 * CUSTOMER < DRIVER < ADMIN < SUPERADMIN — a higher role always passes.
 */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);

export const PLATFORMS_KEY = 'platforms';
/** Restrict a route to specific client platforms (android / ios / web). */
export const Platforms = (...platforms: ClientPlatform[]) => SetMetadata(PLATFORMS_KEY, platforms);

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): User =>
    ctx.switchToHttp().getRequest<Request>().user,
);
