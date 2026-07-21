import { Body, Controller, Get, HttpCode, Param, Patch, Post, Query } from '@nestjs/common';
import { Role, User } from '@prisma/client';
import { CurrentUser, Roles } from '../common/decorators';
import { OrdersService } from './orders.service';
import { AssignDriverDto, CreateOrderDto, DriverStatusDto, EditOrderDto, StaffUpdateOrderDto } from './dto';

@Controller()
export class OrdersController {
  constructor(private orders: OrdersService) {}

  // ---------- customer ----------

  @Post('orders')
  create(@CurrentUser() user: User, @Body() dto: CreateOrderDto) {
    return this.orders.create(user, dto);
  }

  @Get('orders/mine')
  mine(@CurrentUser() user: User, @Query('since') since?: string) {
    return this.orders.myOrders(user.id, since);
  }

  @Get('orders/:id')
  one(@CurrentUser() user: User, @Param('id') id: string) {
    return this.orders.getOne(user, id);
  }

  @Post('orders/:id/cancel')
  @HttpCode(200)
  cancel(@CurrentUser() user: User, @Param('id') id: string) {
    return this.orders.cancel(user, id);
  }

  @Patch('orders/:id')
  edit(@CurrentUser() user: User, @Param('id') id: string, @Body() dto: EditOrderDto) {
    return this.orders.edit(user, id, dto);
  }

  // ---------- driver ----------

  @Roles(Role.DRIVER)
  @Get('driver/orders')
  driverOrders(@CurrentUser() user: User, @Query('shiftId') shiftId?: string, @Query('since') since?: string) {
    return this.orders.driverOrders(user, shiftId, since);
  }

  @Roles(Role.DRIVER)
  @Patch('driver/orders/:id/status')
  driverStatus(@CurrentUser() user: User, @Param('id') id: string, @Body() dto: DriverStatusDto) {
    return this.orders.driverUpdateStatus(user, id, dto);
  }

  // ---------- admin ----------

  @Roles(Role.ADMIN)
  @Get('admin/orders')
  list(
    @Query('group') group?: string,
    @Query('shiftId') shiftId?: string,
    @Query('status') status?: string,
    @Query('driverId') driverId?: string,
    @Query('userId') userId?: string,
    @Query('since') since?: string,
  ) {
    return this.orders.staffList({ group, shiftId, status, driverId, userId, since });
  }

  @Roles(Role.ADMIN)
  @Patch('admin/orders/:id')
  update(@CurrentUser() user: User, @Param('id') id: string, @Body() dto: StaffUpdateOrderDto) {
    return this.orders.staffUpdate(user, id, dto);
  }

  @Roles(Role.ADMIN)
  @Post('admin/orders/:id/assign')
  @HttpCode(200)
  assign(@CurrentUser() user: User, @Param('id') id: string, @Body() dto: AssignDriverDto) {
    return this.orders.assignDriver(user, id, dto);
  }

  @Roles(Role.ADMIN)
  @Get('admin/stats')
  stats(@Query('from') from?: string, @Query('to') to?: string, @Query('group') group?: string) {
    return this.orders.stats(from, to, group);
  }
}
