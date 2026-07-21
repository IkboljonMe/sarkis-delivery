import { Global, Injectable, Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeGateway } from '../realtime/realtime.gateway';

/**
 * In-app notifications: every call persists a `Notification` row and emits it
 * over the socket gateway (`notification:created`), so connected clients get
 * a live update and can build a syncable in-app inbox. There is no push
 * (FCM/APNs) delivery — notifications only reach clients that are connected
 * to the socket gateway or that later fetch their notification history.
 */
@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService, private realtime: RealtimeGateway) {}

  async sendToUser(userId: string, title: string, body: string, data: Record<string, string> = {}) {
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        type: data.type ?? 'system',
        title,
        body,
        data,
        orderId: data.orderId ?? '',
        topicId: data.topicId ?? '',
      },
    });
    this.realtime.emitToUser(userId, 'notification:created', notification);
  }

  async sendToStaff(title: string, body: string, data: Record<string, string> = {}) {
    const staff = await this.prisma.user.findMany({
      where: { role: { in: ['ADMIN', 'SUPERADMIN'] }, isActive: true },
      select: { id: true },
    });
    await Promise.all(staff.map((s) => this.sendToUser(s.id, title, body, data)));
  }
}

@Global()
@Module({
  providers: [NotificationsService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
