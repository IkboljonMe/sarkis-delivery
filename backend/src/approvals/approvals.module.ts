import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  Injectable,
  Module,
  NotFoundException,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { Approval, Role, User } from '@prisma/client';
import { IsObject } from 'class-validator';
import { CurrentUser, Roles } from '../common/decorators';
import { NotificationsService } from '../notifications/notifications.module';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeGateway } from '../realtime/realtime.gateway';

const toApprovalJson = (a: Approval) => ({
  id: a.id,
  type: a.type,
  userId: a.userId,
  userName: a.userName,
  changes: a.changes,
  status: a.status,
  resolvedBy: a.resolvedBy,
  resolvedAt: a.resolvedAt?.toISOString() ?? null,
  createdAt: a.createdAt.toISOString(),
});

/** Fields a profile-change approval may touch when applied. */
const APPROVABLE_FIELDS = ['name', 'lastName', 'phone'];

class CreateApprovalDto {
  @IsObject() changes!: Record<string, any>;
}

@Injectable()
export class ApprovalsService {
  constructor(
    private prisma: PrismaService,
    private notifications: NotificationsService,
    private realtime: RealtimeGateway,
  ) {}

  async create(user: User, changes: Record<string, any>) {
    const filtered = Object.fromEntries(
      Object.entries(changes).filter(([k]) => APPROVABLE_FIELDS.includes(k)),
    );
    if (!Object.keys(filtered).length) {
      throw new BadRequestException(`changes must contain one of: ${APPROVABLE_FIELDS.join(', ')}`);
    }
    const row = await this.prisma.approval.create({
      data: {
        userId: user.id,
        userName: `${user.name} ${user.lastName}`.trim(),
        changes: filtered,
      },
    });
    void this.notifications.sendToStaff('Profile change request', row.userName, { type: 'approval' });
    const json = toApprovalJson(row);
    this.realtime.emitToStaff('approval:created', json);
    return json;
  }

  async list(status?: string) {
    const rows = await this.prisma.approval.findMany({
      where: status ? { status } : {},
      orderBy: { createdAt: 'desc' },
      take: 200,
    });
    return rows.map(toApprovalJson);
  }

  async resolve(actor: User, id: string, approve: boolean) {
    const approval = await this.prisma.approval.findUnique({ where: { id } });
    if (!approval) throw new NotFoundException('Approval not found');
    if (approval.status !== 'pending') throw new BadRequestException('Already resolved');

    if (approve) {
      const changes = Object.fromEntries(
        Object.entries(approval.changes as Record<string, any>).filter(([k]) =>
          APPROVABLE_FIELDS.includes(k),
        ),
      );
      if (changes.phone) {
        const taken = await this.prisma.user.findFirst({
          where: { phone: changes.phone, NOT: { id: approval.userId } },
        });
        if (taken) throw new BadRequestException('Phone already in use by another account');
      }
      await this.prisma.user.update({ where: { id: approval.userId }, data: changes });
    }

    const row = await this.prisma.approval.update({
      where: { id },
      data: {
        status: approve ? 'approved' : 'rejected',
        resolvedBy: actor.id,
        resolvedAt: new Date(),
      },
    });
    void this.notifications.sendToUser(
      approval.userId,
      approve ? 'Profile change approved' : 'Profile change rejected',
      '',
      { type: 'approval' },
    );
    const json = toApprovalJson(row);
    this.realtime.emitToStaff('approval:updated', json);
    return json;
  }
}

@Controller()
export class ApprovalsController {
  constructor(private approvals: ApprovalsService) {}

  @Post('approvals')
  create(@CurrentUser() user: User, @Body() dto: CreateApprovalDto) {
    return this.approvals.create(user, dto.changes);
  }

  @Get('approvals/mine')
  mine(@CurrentUser() user: User) {
    return this.approvals.list().then((rows) => rows.filter((r) => r.userId === user.id));
  }

  @Roles(Role.ADMIN)
  @Get('admin/approvals')
  list(@Query('status') status?: string) {
    return this.approvals.list(status);
  }

  @Roles(Role.ADMIN)
  @Post('admin/approvals/:id/approve')
  @HttpCode(200)
  approve(@CurrentUser() user: User, @Param('id') id: string) {
    return this.approvals.resolve(user, id, true);
  }

  @Roles(Role.ADMIN)
  @Post('admin/approvals/:id/reject')
  @HttpCode(200)
  reject(@CurrentUser() user: User, @Param('id') id: string) {
    return this.approvals.resolve(user, id, false);
  }
}

@Module({
  controllers: [ApprovalsController],
  providers: [ApprovalsService],
})
export class ApprovalsModule {}
