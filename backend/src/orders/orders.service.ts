import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Order, OrderItem, OrderStatus, Prisma, Role, Shift, User } from '@prisma/client';
import { couponDiscount, couponUsable, CouponsService } from '../coupons/coupons.module';
import { NotificationsService } from '../notifications/notifications.module';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeGateway } from '../realtime/realtime.gateway';
import { AssignDriverDto, CreateOrderDto, DriverStatusDto, EditOrderDto, StaffUpdateOrderDto } from './dto';

type OrderWithItems = Order & { items: OrderItem[] };

const round2 = (n: number) => Math.round(n * 100) / 100;

const ALLOWED_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  pending: ['confirmed', 'cancelled'],
  confirmed: ['on_the_way', 'cancelled', 'pending'],
  on_the_way: ['delivered', 'confirmed', 'cancelled'],
  delivered: [],
  cancelled: ['pending'],
};

export const toOrderJson = (o: OrderWithItems & { driver?: User | null }) => ({
  id: o.id,
  userId: o.userId,
  userName: o.userName,
  userPhone: o.userPhone,
  userAddress: o.userAddress,
  userCity: o.userCity,
  userGroup: o.userGroup,
  userLat: o.userLat,
  userLng: o.userLng,
  shiftId: o.shiftId ?? '',
  shiftDate: o.shiftDate?.toISOString() ?? null,
  shiftLabel: o.shiftLabel,
  driverId: o.driverId ?? '',
  driverName: o.driver ? `${o.driver.name} ${o.driver.lastName}`.trim() : '',
  items: o.items.map((i) => ({
    productId: i.productId,
    categoryId: i.categoryId,
    name: i.name,
    qty: i.qty,
    unitPrice: i.unitPrice,
  })),
  subtotal: o.subtotal,
  discount: o.discount,
  couponCode: o.couponCode,
  totalPrice: o.totalPrice,
  status: o.status,
  adminNote: o.adminNote,
  cancelDaysBefore: o.cancelDaysBefore,
  editDaysBefore: o.editDaysBefore,
  pendingApproval: o.pendingApproval,
  awaitingSchedule: o.awaitingSchedule,
  cashCollected: o.cashCollected,
  createdAt: o.createdAt.toISOString(),
  updatedAt: o.updatedAt.toISOString(),
});

@Injectable()
export class OrdersService {
  constructor(
    private prisma: PrismaService,
    private coupons: CouponsService,
    private notifications: NotificationsService,
    private realtime: RealtimeGateway,
  ) {}

  /** Pushes the current row to everyone who has it open: the owning customer,
   *  the assigned driver (if any), and connected admin staff. */
  private broadcastOrder(event: 'order:created' | 'order:updated', order: ReturnType<typeof toOrderJson>) {
    this.realtime.emitToUser(order.userId, event, order);
    if (order.driverId) this.realtime.emitToUser(order.driverId, event, order);
    this.realtime.emitToStaff(event, order);
  }

  // ---------- customer ----------

  async create(user: User, dto: CreateOrderDto) {
    const { items, subtotal } = await this.priceItems(dto.items);

    let shift: Shift | null = null;
    if (dto.shiftId) {
      shift = await this.prisma.shift.findUnique({ where: { id: dto.shiftId } });
      if (!shift || !shift.isOpen) throw new BadRequestException('Selected delivery day is not available');
      if (shift.group && user.group && shift.group !== user.group) {
        throw new BadRequestException('Delivery day belongs to a different city');
      }
    }

    let discount = 0;
    let couponCode = '';
    if (dto.couponCode) {
      const coupon = await this.coupons.byCode(dto.couponCode);
      if (!coupon) throw new BadRequestException('Coupon not found');
      const problem = couponUsable(coupon, subtotal);
      if (problem) throw new BadRequestException(problem);
      discount = couponDiscount(coupon, subtotal);
      couponCode = coupon.code;
    }

    const order = await this.prisma.$transaction(async (tx) => {
      if (couponCode) {
        // Atomic redemption: increment inside the transaction, then verify the
        // limit — a concurrent over-redemption rolls the whole order back.
        const redeemed = await tx.coupon.update({
          where: { code: couponCode },
          data: { usedCount: { increment: 1 } },
        });
        if (redeemed.usageLimit > 0 && redeemed.usedCount > redeemed.usageLimit) {
          throw new BadRequestException('Coupon usage limit reached');
        }
      }
      return tx.order.create({
        data: {
          userId: user.id,
          userName: `${user.name} ${user.lastName}`.trim(),
          userPhone: user.phone ?? '',
          userAddress: user.address,
          userCity: user.city,
          userGroup: user.group,
          userLat: user.lat,
          userLng: user.lng,
          shiftId: shift?.id ?? null,
          shiftDate: shift?.date ?? null,
          shiftLabel: shift?.label ?? '',
          cancelDaysBefore: shift?.cancelDaysBefore ?? 1,
          editDaysBefore: shift?.editDaysBefore ?? 1,
          awaitingSchedule: !shift,
          subtotal,
          discount,
          couponCode,
          totalPrice: round2(subtotal - discount),
          items: { create: items },
          events: { create: { status: 'pending', actorId: user.id } },
        },
        include: { items: true },
      });
    });

    void this.notifications.sendToStaff(
      'New order',
      `${order.userName} — ${order.totalPrice.toFixed(2)} € (${order.userGroup || 'no group'})`,
      { type: 'order', orderId: order.id },
    );
    const json = toOrderJson(order);
    this.broadcastOrder('order:created', json);
    return json;
  }

  async myOrders(userId: string, since?: string) {
    const rows = await this.prisma.order.findMany({
      where: { userId, ...(since ? { updatedAt: { gt: new Date(since) } } : {}) },
      include: { items: true, driver: true },
      orderBy: { createdAt: 'desc' },
      take: since ? undefined : 100,
    });
    return rows.map(toOrderJson);
  }

  async getOne(user: User, id: string) {
    const order = await this.prisma.order.findUnique({ where: { id }, include: { items: true, driver: true } });
    if (!order) throw new NotFoundException('Order not found');
    const isOwner = order.userId === user.id;
    const isStaff = user.role !== Role.CUSTOMER;
    const isAssignedDriver = order.driverId === user.id;
    if (!isOwner && !isStaff && !isAssignedDriver) throw new ForbiddenException();
    return toOrderJson(order);
  }

  async cancel(user: User, id: string) {
    const order = await this.ownedEditableOrder(user, id, 'cancelDaysBefore');
    const updated = await this.updateStatus(order, 'cancelled', user.id);
    return toOrderJson(updated);
  }

  async edit(user: User, id: string, dto: EditOrderDto) {
    const order = await this.ownedEditableOrder(user, id, 'editDaysBefore');

    const data: Prisma.OrderUpdateInput = { pendingApproval: true };
    if (dto.items) {
      const { items, subtotal } = await this.priceItems(dto.items);
      const discount = Math.min(order.discount, subtotal);
      Object.assign(data, {
        subtotal,
        discount,
        totalPrice: round2(subtotal - discount),
        items: { deleteMany: {}, create: items },
      });
    }
    if (dto.shiftId && dto.shiftId !== order.shiftId) {
      const shift = await this.prisma.shift.findUnique({ where: { id: dto.shiftId } });
      if (!shift || !shift.isOpen) throw new BadRequestException('Selected delivery day is not available');
      Object.assign(data, {
        shift: { connect: { id: shift.id } },
        shiftDate: shift.date,
        shiftLabel: shift.label,
        awaitingSchedule: false,
      });
    }

    const updated = await this.prisma.order.update({
      where: { id: order.id },
      data,
      include: { items: true, driver: true },
    });
    void this.notifications.sendToStaff('Order edited', `${updated.userName} changed order`, {
      type: 'order',
      orderId: updated.id,
    });
    const json = toOrderJson(updated);
    this.broadcastOrder('order:updated', json);
    return json;
  }

  // ---------- staff / driver ----------

  async staffList(filter: {
    group?: string;
    shiftId?: string;
    status?: string;
    driverId?: string;
    userId?: string;
    since?: string;
  }) {
    const rows = await this.prisma.order.findMany({
      where: {
        ...(filter.group ? { userGroup: filter.group } : {}),
        ...(filter.shiftId ? { shiftId: filter.shiftId } : {}),
        ...(filter.status ? { status: filter.status as OrderStatus } : {}),
        ...(filter.driverId ? { driverId: filter.driverId } : {}),
        ...(filter.userId ? { userId: filter.userId } : {}),
        ...(filter.since ? { updatedAt: { gt: new Date(filter.since) } } : {}),
      },
      include: { items: true, driver: true },
      orderBy: { createdAt: 'desc' },
      take: filter.since ? undefined : 500,
    });
    return rows.map(toOrderJson);
  }

  async staffUpdate(actor: User, id: string, dto: StaffUpdateOrderDto) {
    let order = await this.prisma.order.findUnique({ where: { id }, include: { items: true } });
    if (!order) throw new NotFoundException('Order not found');

    const data: Prisma.OrderUpdateInput = {};
    if (dto.adminNote !== undefined) data.adminNote = dto.adminNote;
    if (dto.pendingApproval !== undefined) data.pendingApproval = dto.pendingApproval;
    if (dto.awaitingSchedule !== undefined) data.awaitingSchedule = dto.awaitingSchedule;
    if (dto.cashCollected !== undefined) data.cashCollected = dto.cashCollected;
    if (dto.shiftId) {
      const shift = await this.prisma.shift.findUnique({ where: { id: dto.shiftId } });
      if (!shift) throw new BadRequestException('Shift not found');
      Object.assign(data, {
        shift: { connect: { id: shift.id } },
        shiftDate: shift.date,
        shiftLabel: shift.label,
        awaitingSchedule: false,
      });
    }
    let fieldsChanged = false;
    if (Object.keys(data).length) {
      order = await this.prisma.order.update({ where: { id }, data, include: { items: true } });
      fieldsChanged = true;
    }
    if (dto.status && dto.status !== order.status) {
      // updateStatus() broadcasts order:updated itself.
      order = await this.updateStatus(order, dto.status as OrderStatus, actor.id);
    } else if (fieldsChanged) {
      const withDriver = await this.prisma.order.findUnique({ where: { id: order.id }, include: { items: true, driver: true } });
      this.broadcastOrder('order:updated', toOrderJson(withDriver!));
    }
    return toOrderJson(order);
  }

  async assignDriver(actor: User, id: string, dto: AssignDriverDto) {
    const driver = await this.prisma.user.findUnique({ where: { id: dto.driverId } });
    if (!driver || driver.role !== Role.DRIVER || !driver.isActive) {
      throw new BadRequestException('driverId must be an active driver');
    }
    const order = await this.prisma.order.update({
      where: { id },
      data: {
        driver: { connect: { id: driver.id } },
        events: { create: { status: 'driver_assigned', actorId: actor.id, note: driver.id } },
      },
      include: { items: true, driver: true },
    }).catch(() => null);
    if (!order) throw new NotFoundException('Order not found');
    void this.notifications.sendToUser(driver.id, 'New delivery', `${order.userAddress}, ${order.userCity}`, {
      type: 'order',
      orderId: order.id,
    });
    const json = toOrderJson(order);
    this.broadcastOrder('order:updated', json);
    return json;
  }

  async driverOrders(driver: User, shiftId?: string, since?: string) {
    return this.staffList({ driverId: driver.id, shiftId, since });
  }

  async driverUpdateStatus(driver: User, id: string, dto: DriverStatusDto) {
    const order = await this.prisma.order.findUnique({ where: { id }, include: { items: true } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.driverId !== driver.id && driver.role === Role.DRIVER) {
      throw new ForbiddenException('Order is not assigned to you');
    }
    if (dto.cashCollected !== undefined) {
      await this.prisma.order.update({ where: { id }, data: { cashCollected: dto.cashCollected } });
      order.cashCollected = dto.cashCollected;
    }
    const updated = await this.updateStatus(order, dto.status as OrderStatus, driver.id);
    return toOrderJson(updated);
  }

  async stats(from?: string, to?: string, group?: string) {
    const where: Prisma.OrderWhereInput = {
      ...(group ? { userGroup: group } : {}),
      createdAt: {
        ...(from ? { gte: new Date(from) } : {}),
        ...(to ? { lte: new Date(to) } : {}),
      },
    };
    const [byStatus, delivered, customers] = await Promise.all([
      this.prisma.order.groupBy({ by: ['status'], where, _count: { _all: true } }),
      this.prisma.order.aggregate({
        where: { ...where, status: 'delivered' },
        _sum: { totalPrice: true },
        _count: { _all: true },
      }),
      this.prisma.user.count({ where: { role: Role.CUSTOMER } }),
    ]);
    return {
      byStatus: Object.fromEntries(byStatus.map((s) => [s.status, s._count._all])),
      deliveredCount: delivered._count._all,
      revenue: delivered._sum.totalPrice ?? 0,
      customers,
    };
  }

  // ---------- internals ----------

  private async priceItems(itemDtos: { productId: string; qty: number }[]) {
    const ids = itemDtos.map((i) => i.productId);
    const products = await this.prisma.product.findMany({ where: { id: { in: ids }, isActive: true } });
    const byId = new Map(products.map((p) => [p.id, p]));

    const items = itemDtos.map((i) => {
      const p = byId.get(i.productId);
      if (!p) throw new BadRequestException(`Product ${i.productId} is not available`);
      if (p.maxQty > 0 && i.qty > p.maxQty) {
        throw new BadRequestException(`Max ${p.maxQty} per order for this product`);
      }
      let unitPrice = p.price;
      if (p.discountType === 'percent') unitPrice = p.price * (1 - p.discountValue / 100);
      if (p.discountType === 'fixed') unitPrice = Math.max(0, p.price - p.discountValue);
      const name = (p.name as Record<string, string>) ?? {};
      return {
        productId: p.id,
        categoryId: p.categoryId,
        name: name['en'] || Object.values(name)[0] || '',
        qty: i.qty,
        unitPrice: round2(unitPrice),
      };
    });
    const subtotal = round2(items.reduce((s, i) => s + i.unitPrice * i.qty, 0));
    return { items, subtotal };
  }

  private async ownedEditableOrder(user: User, id: string, windowField: 'cancelDaysBefore' | 'editDaysBefore') {
    const order = await this.prisma.order.findUnique({ where: { id }, include: { items: true } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.userId !== user.id) throw new ForbiddenException();
    if (!(['pending', 'confirmed'] as OrderStatus[]).includes(order.status)) {
      throw new BadRequestException('Order can no longer be changed');
    }
    if (order.shiftDate) {
      const deadline = new Date(order.shiftDate);
      deadline.setDate(deadline.getDate() - order[windowField]);
      deadline.setHours(23, 59, 59, 999);
      if (new Date() > deadline) {
        throw new BadRequestException('The change window for this delivery day has closed');
      }
    }
    return order;
  }

  private async updateStatus(order: OrderWithItems, status: OrderStatus, actorId: string) {
    if (!ALLOWED_TRANSITIONS[order.status].includes(status)) {
      throw new BadRequestException(`Cannot change status from "${order.status}" to "${status}"`);
    }
    const timestamps: Prisma.OrderUpdateInput = {};
    if (status === 'confirmed') timestamps.confirmedAt = new Date();
    if (status === 'on_the_way') timestamps.onTheWayAt = new Date();
    if (status === 'delivered') timestamps.deliveredAt = new Date();
    if (status === 'cancelled') timestamps.cancelledAt = new Date();

    const updated = await this.prisma.order.update({
      where: { id: order.id },
      data: { status, ...timestamps, events: { create: { status, actorId } } },
      include: { items: true, driver: true },
    });

    const titles: Partial<Record<OrderStatus, string>> = {
      confirmed: 'Order confirmed',
      on_the_way: 'Your order is on the way',
      delivered: 'Order delivered',
      cancelled: 'Order cancelled',
    };
    if (titles[status] && actorId !== updated.userId) {
      void this.notifications.sendToUser(updated.userId, titles[status]!, `Total: ${updated.totalPrice.toFixed(2)} €`, {
        type: 'order',
        orderId: updated.id,
      });
    }
    this.broadcastOrder('order:updated', toOrderJson(updated));
    return updated;
  }
}
