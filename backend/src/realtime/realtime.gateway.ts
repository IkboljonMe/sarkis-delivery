import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Role, User } from '@prisma/client';
import { Server, Socket } from 'socket.io';
import { PrismaService } from '../prisma/prisma.service';

// Matches RolesGuard's @Roles(Role.ADMIN) on GET /admin/orders and
// GET /messages/topics — DRIVER is intentionally excluded from `staff`
// broadcasts since drivers can't fetch that data over REST either, only
// their own assignments (/driver/orders, scoped chat topics they're a party
// to). Broadening this would leak order/chat data to drivers beyond what
// their REST role already permits.
const isStaff = (u: Pick<User, 'role'>) => u.role === Role.ADMIN || u.role === Role.SUPERADMIN;

/**
 * Live push for orders/chat/notifications. Auth mirrors JwtAuthGuard (same
 * access token, passed as `auth.token` on the socket handshake instead of a
 * header) since there's no separate socket-session concept — a device is
 * "connected" for as long as its REST access token is valid.
 *
 * Rooms:
 *  - `user:<id>`   — the connected user's own channel (their orders/notifications,
 *                     and for a DRIVER, their assigned deliveries).
 *  - `staff`        — every connected ADMIN/SUPERADMIN (mirrors sendToStaff's
 *                      existing FCM targeting and the ADMIN-only REST guards).
 *  - `chat:<topicId>` — joined/left on demand as a chat screen opens/closes.
 */
@WebSocketGateway({ cors: { origin: true, credentials: true } })
export class RealtimeGateway implements OnGatewayConnection {
  private readonly logger = new Logger(RealtimeGateway.name);

  @WebSocketServer()
  server!: Server;

  constructor(private jwt: JwtService, private prisma: PrismaService) {}

  async handleConnection(client: Socket) {
    const token = client.handshake.auth?.token as string | undefined;
    if (!token) return client.disconnect();

    let payload: { sub: string };
    try {
      payload = await this.jwt.verifyAsync(token);
    } catch {
      return client.disconnect();
    }

    const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });
    if (!user || !user.isActive) return client.disconnect();

    client.data.userId = user.id;
    client.data.role = user.role;
    void client.join(`user:${user.id}`);
    if (isStaff(user)) void client.join('staff');
    this.logger.debug(`socket connected: ${user.id} (${user.role})`);
  }

  @SubscribeMessage('chat:join')
  async onChatJoin(@ConnectedSocket() client: Socket, @MessageBody() topicId: string) {
    const { userId, role } = client.data as { userId?: string; role?: Role };
    if (!userId || !topicId) return;
    if (!isStaff({ role: role! }) && userId !== topicId) return; // same access rule as MessagesService.assertAccess
    void client.join(`chat:${topicId}`);
  }

  @SubscribeMessage('chat:leave')
  onChatLeave(@ConnectedSocket() client: Socket, @MessageBody() topicId: string) {
    if (topicId) void client.leave(`chat:${topicId}`);
  }

  emitToUser(userId: string, event: string, payload: unknown) {
    this.server?.to(`user:${userId}`).emit(event, payload);
  }

  emitToStaff(event: string, payload: unknown) {
    this.server?.to('staff').emit(event, payload);
  }

  emitToTopic(topicId: string, event: string, payload: unknown) {
    this.server?.to(`chat:${topicId}`).emit(event, payload);
  }
}
