import {
  Body,
  Controller,
  Delete,
  ForbiddenException,
  Get,
  HttpCode,
  Injectable,
  Module,
  NotFoundException,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ChatTopic, Message, Prisma, Role, User } from '@prisma/client';
import { IsBoolean, IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { CurrentUser, Roles } from '../common/decorators';
import { NotificationsService } from '../notifications/notifications.module';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeGateway } from '../realtime/realtime.gateway';

const isStaff = (u: User) => u.role === Role.ADMIN || u.role === Role.SUPERADMIN;

const toTopicJson = (t: ChatTopic) => ({
  topicId: t.id,
  userName: t.userName,
  userGroup: t.userGroup,
  lastMessage: t.lastMessage,
  lastAt: t.lastAt?.toISOString() ?? null,
  lastFromAdmin: t.lastFromAdmin,
  unread: t.adminUnread, // staff-side unread; customer apps use /messages/unread
  customerUnread: t.customerUnread,
});

const toMessageJson = (m: Message) => {
  const extra = (m.extra as Record<string, any>) ?? {};
  return {
    id: m.id,
    senderId: m.senderId,
    senderName: m.senderName,
    text: m.deleted ? '' : m.text,
    isFromAdmin: m.isFromAdmin,
    isRead: m.isRead,
    delivered: m.delivered,
    createdAt: m.createdAt.toISOString(),
    type: m.type,
    deleted: m.deleted,
    replyToId: extra.replyToId ?? '',
    replyToText: extra.replyToText ?? '',
    replyToSender: extra.replyToSender ?? '',
    reactions: extra.reactions ?? {},
    mediaUrl: m.deleted ? '' : extra.mediaUrl ?? '',
    mediaUrls: m.deleted ? [] : extra.mediaUrls ?? [],
    durationMs: extra.durationMs ?? 0,
    orderId: extra.orderId ?? '',
    waveform: extra.waveform ?? [],
    sizeBytes: extra.sizeBytes ?? 0,
    uploading: false,
    uploadCount: extra.uploadCount ?? 0,
  };
};

class SendMessageDto {
  @IsOptional() @IsIn(['text', 'image', 'album', 'voice', 'file', 'order']) type?: string;
  @IsOptional() @IsString() @MaxLength(4000) text?: string;
  @IsOptional() @IsString() mediaUrl?: string;
  @IsOptional() mediaUrls?: string[];
  @IsOptional() @IsString() replyToId?: string;
  @IsOptional() @IsString() @MaxLength(1000) replyToText?: string;
  @IsOptional() @IsString() @MaxLength(200) replyToSender?: string;
  @IsOptional() durationMs?: number;
  @IsOptional() waveform?: number[];
  @IsOptional() sizeBytes?: number;
  @IsOptional() @IsString() orderId?: string;
}

class PatchMessageDto {
  @IsOptional() @IsString() @MaxLength(4000) text?: string;
  @IsOptional() @IsIn(['text', 'image', 'album', 'voice', 'file', 'order', 'video']) type?: string;
  @IsOptional() @IsString() mediaUrl?: string;
  @IsOptional() mediaUrls?: string[];
  @IsOptional() @IsString() appendMediaUrl?: string;
  @IsOptional() durationMs?: number;
  @IsOptional() waveform?: number[];
  @IsOptional() sizeBytes?: number;
  @IsOptional() uploadCount?: number;
}

class WelcomeDto {
  @IsString() @MaxLength(4000) text!: string;
  @IsOptional() @IsString() @MaxLength(200) senderName?: string;
}

class ReactionDto {
  @IsString() @MaxLength(16) emoji!: string;
}

class MarkReadDto {
  @IsOptional() @IsBoolean() asAdmin?: boolean;
}

@Injectable()
export class MessagesService {
  constructor(
    private prisma: PrismaService,
    private notifications: NotificationsService,
    private realtime: RealtimeGateway,
  ) {}

  private assertAccess(user: User, topicId: string) {
    if (!isStaff(user) && user.id !== topicId) throw new ForbiddenException();
  }

  async ensureTopic(user: User, topicId: string) {
    this.assertAccess(user, topicId);
    const customer =
      user.id === topicId ? user : await this.prisma.user.findUnique({ where: { id: topicId } });
    if (!customer) throw new NotFoundException('Topic not found');
    return this.prisma.chatTopic.upsert({
      where: { id: topicId },
      create: {
        id: topicId,
        userName: `${customer.name} ${customer.lastName}`.trim(),
        userGroup: customer.group,
      },
      update: {},
    });
  }

  async topics() {
    const rows = await this.prisma.chatTopic.findMany({ orderBy: [{ lastAt: { sort: 'desc', nulls: 'last' } }] });
    return rows.map(toTopicJson);
  }

  async topic(user: User, topicId: string) {
    const t = await this.ensureTopic(user, topicId);
    return toTopicJson(t);
  }

  async list(user: User, topicId: string, after?: string, limit = 50) {
    this.assertAccess(user, topicId);
    const rows = await this.prisma.message.findMany({
      where: {
        topicId,
        ...(after ? { createdAt: { gt: new Date(after) } } : {}),
      },
      orderBy: { createdAt: after ? 'asc' : 'desc' },
      take: Math.min(limit, 200),
    });
    const messages = after ? rows : rows.reverse();
    return messages.map(toMessageJson);
  }

  async send(user: User, topicId: string, dto: SendMessageDto) {
    const topic = await this.ensureTopic(user, topicId);
    const fromAdmin = isStaff(user);
    const extra: Record<string, any> = {};
    for (const k of ['mediaUrl', 'mediaUrls', 'replyToId', 'replyToText', 'replyToSender', 'durationMs', 'waveform', 'sizeBytes', 'orderId', 'uploadCount'] as const) {
      if ((dto as any)[k] !== undefined) extra[k] = (dto as any)[k];
    }

    const [message, updatedTopic] = await this.prisma.$transaction([
      this.prisma.message.create({
        data: {
          topicId: topic.id,
          senderId: user.id,
          senderName: `${user.name} ${user.lastName}`.trim(),
          isFromAdmin: fromAdmin,
          type: dto.type ?? 'text',
          text: dto.text ?? '',
          extra,
        },
      }),
      this.prisma.chatTopic.update({
        where: { id: topic.id },
        data: {
          lastMessage: dto.text || (dto.type ?? 'media'),
          lastAt: new Date(),
          lastFromAdmin: fromAdmin,
          ...(fromAdmin ? { customerUnread: { increment: 1 } } : { adminUnread: { increment: 1 } }),
        },
      }),
    ]);

    const messageJson = toMessageJson(message);
    this.realtime.emitToTopic(topic.id, 'message:created', messageJson);
    this.realtime.emitToStaff('topic:updated', toTopicJson(updatedTopic));

    const preview = dto.text?.slice(0, 100) || '📎 Attachment';
    if (fromAdmin) {
      void this.notifications.sendToUser(topicId, 'Sarko Delivery', preview, { type: 'chat' });
    } else {
      void this.notifications.sendToStaff(message.senderName || 'New message', preview, { type: 'chat', topicId });
    }
    return messageJson;
  }

  async patch(user: User, topicId: string, msgId: string, dto: PatchMessageDto) {
    const msg = await this.ownMessage(user, topicId, msgId);
    const extra = { ...((msg.extra as Record<string, any>) ?? {}) };
    for (const k of ['mediaUrl', 'mediaUrls', 'durationMs', 'waveform', 'sizeBytes', 'uploadCount'] as const) {
      if (dto[k] !== undefined) extra[k] = dto[k];
    }
    if (dto.appendMediaUrl) {
      extra.mediaUrls = [...(extra.mediaUrls ?? []), dto.appendMediaUrl];
    }
    const updated = await this.prisma.message.update({
      where: { id: msg.id },
      data: {
        extra,
        ...(dto.type !== undefined ? { type: dto.type } : {}),
        ...(dto.text !== undefined ? { text: dto.text, editedAt: new Date() } : {}),
      },
    });
    const json = toMessageJson(updated);
    this.realtime.emitToTopic(topicId, 'message:updated', json);
    return json;
  }

  /** One-time automated greeting, shown as coming from the shop. */
  async welcome(user: User, topicId: string, dto: WelcomeDto) {
    const topic = await this.ensureTopic(user, topicId);
    const count = await this.prisma.message.count({ where: { topicId: topic.id } });
    if (count > 0) return { ok: true, skipped: true };
    await this.prisma.$transaction([
      this.prisma.message.create({
        data: {
          topicId: topic.id,
          senderId: user.id,
          senderName: dto.senderName ?? 'Sarko Delivery',
          isFromAdmin: true,
          type: 'text',
          text: dto.text,
        },
      }),
      this.prisma.chatTopic.update({
        where: { id: topic.id },
        data: { lastMessage: dto.text, lastAt: new Date(), lastFromAdmin: true },
      }),
    ]);
    return { ok: true };
  }

  async delete(user: User, topicId: string, msgId: string) {
    const msg = await this.ownMessage(user, topicId, msgId);
    const updated = await this.prisma.message.update({
      where: { id: msg.id },
      data: { deleted: true },
    });
    const json = toMessageJson(updated);
    this.realtime.emitToTopic(topicId, 'message:updated', json);
    return json;
  }

  async toggleReaction(user: User, topicId: string, msgId: string, emoji: string) {
    this.assertAccess(user, topicId);
    const msg = await this.prisma.message.findFirst({ where: { id: msgId, topicId } });
    if (!msg) throw new NotFoundException('Message not found');
    const extra = (msg.extra as Record<string, any>) ?? {};
    const reactions: Record<string, string> = { ...(extra.reactions ?? {}) };
    if (reactions[user.id] === emoji) delete reactions[user.id];
    else reactions[user.id] = emoji;
    const updated = await this.prisma.message.update({
      where: { id: msg.id },
      data: { extra: { ...extra, reactions } },
    });
    const json = toMessageJson(updated);
    this.realtime.emitToTopic(topicId, 'message:updated', json);
    return json;
  }

  async markRead(user: User, topicId: string, asAdmin?: boolean) {
    this.assertAccess(user, topicId);
    const readingAsAdmin = isStaff(user) && asAdmin !== false;
    const [, topic] = await this.prisma.$transaction([
      this.prisma.message.updateMany({
        where: { topicId, isFromAdmin: !readingAsAdmin, isRead: false },
        data: { isRead: true },
      }),
      this.prisma.chatTopic.upsert({
        where: { id: topicId },
        create: { id: topicId },
        update: readingAsAdmin ? { adminUnread: 0 } : { customerUnread: 0 },
      }),
    ]);
    const topicJson = toTopicJson(topic);
    if (readingAsAdmin) this.realtime.emitToStaff('topic:updated', topicJson);
    else this.realtime.emitToUser(topicId, 'topic:updated', topicJson);
    return { ok: true };
  }

  async unreadCount(user: User) {
    const topic = await this.prisma.chatTopic.findUnique({ where: { id: user.id } });
    return { unread: topic?.customerUnread ?? 0 };
  }

  private async ownMessage(user: User, topicId: string, msgId: string) {
    this.assertAccess(user, topicId);
    const msg = await this.prisma.message.findFirst({ where: { id: msgId, topicId } });
    if (!msg) throw new NotFoundException('Message not found');
    if (msg.senderId !== user.id && !isStaff(user)) throw new ForbiddenException();
    return msg;
  }
}

@Controller('messages')
export class MessagesController {
  constructor(private messages: MessagesService) {}

  @Roles(Role.ADMIN)
  @Get('topics')
  topics() {
    return this.messages.topics();
  }

  /** Customer's own unread badge. */
  @Get('unread')
  unread(@CurrentUser() user: User) {
    return this.messages.unreadCount(user);
  }

  @Get('topics/:topicId')
  topic(@CurrentUser() user: User, @Param('topicId') topicId: string) {
    return this.messages.topic(user, topicId);
  }

  @Get(':topicId')
  list(
    @CurrentUser() user: User,
    @Param('topicId') topicId: string,
    @Query('after') after?: string,
    @Query('limit') limit?: string,
  ) {
    return this.messages.list(user, topicId, after, limit ? Number(limit) : undefined);
  }

  @Post(':topicId')
  send(@CurrentUser() user: User, @Param('topicId') topicId: string, @Body() dto: SendMessageDto) {
    return this.messages.send(user, topicId, dto);
  }

  @Post(':topicId/welcome')
  @HttpCode(200)
  welcome(@CurrentUser() user: User, @Param('topicId') topicId: string, @Body() dto: WelcomeDto) {
    return this.messages.welcome(user, topicId, dto);
  }

  @Post(':topicId/read')
  @HttpCode(200)
  read(@CurrentUser() user: User, @Param('topicId') topicId: string, @Body() dto: MarkReadDto) {
    return this.messages.markRead(user, topicId, dto.asAdmin);
  }

  @Patch(':topicId/:msgId')
  patch(
    @CurrentUser() user: User,
    @Param('topicId') topicId: string,
    @Param('msgId') msgId: string,
    @Body() dto: PatchMessageDto,
  ) {
    return this.messages.patch(user, topicId, msgId, dto);
  }

  @Delete(':topicId/:msgId')
  remove(@CurrentUser() user: User, @Param('topicId') topicId: string, @Param('msgId') msgId: string) {
    return this.messages.delete(user, topicId, msgId);
  }

  @Post(':topicId/:msgId/reactions')
  @HttpCode(200)
  react(
    @CurrentUser() user: User,
    @Param('topicId') topicId: string,
    @Param('msgId') msgId: string,
    @Body() dto: ReactionDto,
  ) {
    return this.messages.toggleReaction(user, topicId, msgId, dto.emoji);
  }
}

@Module({
  controllers: [MessagesController],
  providers: [MessagesService],
})
export class MessagesModule {}
