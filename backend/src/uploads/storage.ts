import { BadRequestException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { Request } from 'express';
import { existsSync, mkdirSync } from 'fs';
import { diskStorage } from 'multer';
import { extname, join } from 'path';

export const UPLOADS_ROOT = join(process.cwd(), 'uploads');

const IMAGE_MIME = /^image\/(jpe?g|png|webp|gif|heic|heif)$/;
const MEDIA_MIME = /^(image\/(jpe?g|png|webp|gif|heic|heif)|audio\/(aac|mp4|m4a|mpeg|ogg|webm|x-m4a)|video\/mp4|application\/pdf)$/;

function makeStorage(subdir: string) {
  return diskStorage({
    destination: (_req, _file, cb) => {
      const now = new Date();
      const dir = join(UPLOADS_ROOT, subdir, `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`);
      if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
      cb(null, dir);
    },
    filename: (_req, file, cb) => {
      const ext = extname(file.originalname).toLowerCase().slice(0, 10) || '.bin';
      cb(null, `${randomUUID()}${ext}`);
    },
  });
}

export const avatarStorage = makeStorage('avatars');
export const productStorage = makeStorage('products');
export const chatStorage = makeStorage('chat');

export const imageFilter = (_req: Request, file: Express.Multer.File, cb: (e: Error | null, ok: boolean) => void) =>
  IMAGE_MIME.test(file.mimetype) ? cb(null, true) : cb(new BadRequestException('Only images allowed'), false);

export const mediaFilter = (_req: Request, file: Express.Multer.File, cb: (e: Error | null, ok: boolean) => void) =>
  MEDIA_MIME.test(file.mimetype) ? cb(null, true) : cb(new BadRequestException('Unsupported file type'), false);

/** Public URL for a stored file (absolute, so the apps can use it directly). */
export function fileUrl(file: Express.Multer.File): string {
  const rel = file.path.substring(UPLOADS_ROOT.length).replace(/\\/g, '/');
  const base = (process.env.PUBLIC_BASE_URL ?? '').replace(/\/$/, '');
  return `${base}/uploads${rel}`;
}
