import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { Roles } from '../common/decorators';
import { Role } from '@prisma/client';
import { chatStorage, fileUrl, imageFilter, mediaFilter, productStorage } from './storage';

@Controller('uploads')
export class UploadsController {
  /** Chat media (images, voice, files) — any authenticated user. */
  @Post('chat')
  @UseInterceptors(FilesInterceptor('files', 10, { storage: chatStorage, fileFilter: mediaFilter, limits: { fileSize: 25 * 1024 * 1024 } }))
  chat(@UploadedFiles() files?: Express.Multer.File[]) {
    if (!files?.length) throw new BadRequestException('files are required');
    return { urls: files.map(fileUrl) };
  }

  /** Product / category images — staff only. */
  @Roles(Role.ADMIN)
  @Post('product')
  @UseInterceptors(FileInterceptor('file', { storage: productStorage, fileFilter: imageFilter, limits: { fileSize: 10 * 1024 * 1024 } }))
  product(@UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('file is required');
    return { url: fileUrl(file) };
  }
}
