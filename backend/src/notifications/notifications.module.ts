import { Global, Injectable, Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { PushService } from '../push/push.module';
import { RealtimeGateway } from '../realtime/realtime.gateway';

/**
 * In-app notifications: every call persists a `Notification` row, emits it over
 * the socket gateway (`notification:created`) for live in-app updates, and
 * fires an FCM/APNs push (via {@link PushService}) so backgrounded/closed apps
 * are still notified. Push is best-effort and never blocks the response.
 */
@Injectable()
export class NotificationsService {
  constructor(
    private prisma: PrismaService,
    private realtime: RealtimeGateway,
    private push: PushService,
  ) {}

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
    void this.push.sendToUser(userId, { title, body, data });
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
