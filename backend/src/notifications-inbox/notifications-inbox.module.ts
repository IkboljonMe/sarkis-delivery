import { Controller, Get, HttpCode, Injectable, Module, Param, Post, Query } from '@nestjs/common';
import { Notification, User } from '@prisma/client';
import { CurrentUser } from '../common/decorators';
import { PrismaService } from '../prisma/prisma.service';

const toNotificationJson = (n: Notification) => ({
  id: n.id,
  type: n.type,
  title: n.title,
  body: n.body,
  data: n.data,
  orderId: n.orderId,
  topicId: n.topicId,
  read: n.readAt !== null,
  createdAt: n.createdAt.toISOString(),
});

@Injectable()
export class NotificationsInboxService {
  constructor(private prisma: PrismaService) {}

  /** Delta-sync list, same `since` cursor shape as GET /messages/:topicId?after=. */
  async list(userId: string, since?: string, limit = 100) {
    const rows = await this.prisma.notification.findMany({
      where: {
        userId,
        ...(since ? { createdAt: { gt: new Date(since) } } : {}),
      },
      orderBy: { createdAt: since ? 'asc' : 'desc' },
      take: Math.min(limit, 200),
    });
    return (since ? rows : rows.reverse()).map(toNotificationJson);
  }

  async markRead(user: User, id: string) {
    const row = await this.prisma.notification.updateMany({
      where: { id, userId: user.id, readAt: null },
      data: { readAt: new Date() },
    });
    return { ok: row.count > 0 };
  }
}

@Controller('notifications')
export class NotificationsInboxController {
  constructor(private notifications: NotificationsInboxService) {}

  @Get()
  list(@CurrentUser() user: User, @Query('since') since?: string, @Query('limit') limit?: string) {
    return this.notifications.list(user.id, since, limit ? Number(limit) : undefined);
  }

  @Post(':id/read')
  @HttpCode(200)
  read(@CurrentUser() user: User, @Param('id') id: string) {
    return this.notifications.markRead(user, id);
  }
}

@Module({
  controllers: [NotificationsInboxController],
  providers: [NotificationsInboxService],
})
export class NotificationsInboxModule {}
