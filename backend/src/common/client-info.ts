import { Injectable, NestMiddleware, createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { UAParser } from 'ua-parser-js';

export type ClientPlatform = 'android' | 'ios' | 'web' | 'unknown';

export interface ClientInfo {
  ip: string;
  platform: ClientPlatform;
  deviceModel: string;
  osVersion: string;
  appVersion: string;
  userAgent: string;
  browser: string;
  os: string;
}

declare module 'express' {
  interface Request {
    clientInfo?: ClientInfo;
    user?: any;
  }
}

/**
 * Attaches a ClientInfo object to every request.
 *
 * Mobile apps identify themselves with explicit headers:
 *   X-Client-Platform: android | ios
 *   X-App-Version:     1.2.3
 *   X-Device-Model:    Pixel 8
 *   X-OS-Version:      Android 15
 * Browsers are detected from the User-Agent. IP honours the reverse proxy
 * (Express `trust proxy` is configured in main.ts).
 */
@Injectable()
export class ClientInfoMiddleware implements NestMiddleware {
  use(req: Request, _res: Response, next: NextFunction) {
    const ua = req.headers['user-agent'] ?? '';
    const headerPlatform = String(req.headers['x-client-platform'] ?? '').toLowerCase();

    let platform: ClientPlatform = 'unknown';
    let browser = '';
    let os = '';
    let deviceModel = String(req.headers['x-device-model'] ?? '');

    if (headerPlatform === 'android' || headerPlatform === 'ios') {
      platform = headerPlatform;
      os = String(req.headers['x-os-version'] ?? '');
    } else if (ua) {
      const parsed = new UAParser(ua).getResult();
      browser = [parsed.browser.name, parsed.browser.version].filter(Boolean).join(' ');
      os = [parsed.os.name, parsed.os.version].filter(Boolean).join(' ');
      if (!deviceModel) deviceModel = parsed.device.model ?? '';
      if (parsed.browser.name) platform = 'web';
    }

    req.clientInfo = {
      ip: req.ip ?? '',
      platform,
      deviceModel,
      osVersion: String(req.headers['x-os-version'] ?? os),
      appVersion: String(req.headers['x-app-version'] ?? ''),
      userAgent: ua.slice(0, 512),
      browser,
      os,
    };
    next();
  }
}

export const GetClientInfo = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): ClientInfo =>
    ctx.switchToHttp().getRequest<Request>().clientInfo!,
);
