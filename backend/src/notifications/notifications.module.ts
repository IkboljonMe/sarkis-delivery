import { Global, Injectable, Logger, Module, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeGateway } from '../realtime/realtime.gateway';

/**
 * Push notifications via FCM. Enabled when FIREBASE_SERVICE_ACCOUNT points to a
 * service-account JSON file; otherwise sends are logged and dropped (no-op),
 * so the API works without any Firebase project at all.
 *
 * Every call also persists a `Notification` row and emits it over the socket
 * gateway (`notification:created`), so clients can build a syncable in-app
 * inbox instead of relying purely on ephemeral FCM tray messages.
 */
@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private messaging: any = null;

  constructor(private config: ConfigService, private prisma: PrismaService, private realtime: RealtimeGateway) {}

  async onModuleInit() {
    const credPath = this.config.get<string>('FIREBASE_SERVICE_ACCOUNT');
    if (!credPath) {
      this.logger.log('FCM disabled (FIREBASE_SERVICE_ACCOUNT not set)');
      return;
    }
    try {
      const admin = await import('firebase-admin');
      const app = admin.initializeApp({ credential: admin.credential.cert(credPath) });
      this.messaging = app.messaging();
      this.logger.log('FCM enabled');
    } catch (e) {
      this.logger.error(`FCM init failed: ${e}`);
    }
  }

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

    const devices = await this.prisma.device.findMany({
      where: { userId, fcmToken: { not: '' } },
    });
    if (!devices.length) return;
    if (!this.messaging) {
      this.logger.debug(`[noop push] to ${userId}: ${title} — ${body}`);
      return;
    }
    const tokens = devices.map((d) => d.fcmToken);
    try {
      const res = await this.messaging.sendEachForMulticast({
        tokens,
        notification: { title, body },
        data,
      });
      // Prune dead tokens so we stop paying for them.
      const dead: string[] = [];
      res.responses.forEach((r: any, i: number) => {
        if (!r.success && ['messaging/registration-token-not-registered', 'messaging/invalid-registration-token'].includes(r.error?.code)) {
          dead.push(tokens[i]);
        }
      });
      if (dead.length) {
        await this.prisma.device.updateMany({ where: { fcmToken: { in: dead } }, data: { fcmToken: '' } });
      }
    } catch (e) {
      this.logger.error(`push to ${userId} failed: ${e}`);
    }
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
