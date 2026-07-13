import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { Test } from '@nestjs/testing';
import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import request from 'supertest';
import { AppModule } from '../src/app.module';

const ANDROID = { 'X-Client-Platform': 'android', 'X-Device-Model': 'e2e-Pixel', 'X-App-Version': '1.0.0' };
const WEB = { 'User-Agent': 'Mozilla/5.0 (X11; Linux) Chrome/126.0 Safari/537.36' };

const SUPERADMIN = { email: 'superadmin@test.dev', password: 'SuperSecret123!' };

describe('Sarkis API (e2e)', () => {
  let app: NestExpressApplication;
  let http: any;
  let prisma: PrismaClient;

  let superToken = '';
  let customerToken = '';
  let customerId = '';
  let driverToken = '';
  let driverId = '';

  beforeAll(async () => {
    prisma = new PrismaClient();
    await prisma.user.create({
      data: {
        email: SUPERADMIN.email,
        passwordHash: await bcrypt.hash(SUPERADMIN.password, 10),
        role: Role.SUPERADMIN,
        name: 'Root',
      },
    });

    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication<NestExpressApplication>();
    app.setGlobalPrefix('v1', { exclude: ['health'] });
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
    await app.init();
    http = app.getHttpServer();
  });

  afterAll(async () => {
    await app?.close();
    await prisma?.$disconnect();
  });

  describe('auth', () => {
    it('health is public', async () => {
      await request(http).get('/health').expect(200);
    });

    it('rejects OTP request from web (platform guard)', async () => {
      await request(http)
        .post('/v1/auth/otp/request')
        .set(WEB)
        .send({ phone: '+4915100000001' })
        .expect(403);
    });

    it('rejects malformed phone numbers', async () => {
      await request(http)
        .post('/v1/auth/otp/request')
        .set(ANDROID)
        .send({ phone: '015112345' })
        .expect(400);
    });

    it('logs in a new customer via OTP (request → verify)', async () => {
      const phone = '+4915100000002';
      const req = await request(http)
        .post('/v1/auth/otp/request')
        .set(ANDROID)
        .send({ phone })
        .expect(200);
      expect(req.body.devCode).toHaveLength(6);

      const bad = await request(http)
        .post('/v1/auth/otp/verify')
        .set(ANDROID)
        .send({ phone, code: req.body.devCode === '000000' ? '000001' : '000000' })
        .expect(400);
      expect(bad.body.message).toMatch(/invalid/i);

      const ok = await request(http)
        .post('/v1/auth/otp/verify')
        .set(ANDROID)
        .send({ phone, code: req.body.devCode })
        .expect(200);
      expect(ok.body.isNewUser).toBe(true);
      expect(ok.body.user.phone).toBe(phone);
      expect(ok.body.accessToken).toBeTruthy();
      expect(ok.body.refreshToken).toBeTruthy();
      customerToken = ok.body.accessToken;
      customerId = ok.body.user.id;

      // login event + device were recorded with client info
      const events = await prisma.loginEvent.findMany({ where: { userId: customerId } });
      expect(events.some((e) => e.success && e.platform === 'android' && e.deviceModel === 'e2e-Pixel')).toBe(true);
      const devices = await prisma.device.findMany({ where: { userId: customerId } });
      expect(devices).toHaveLength(1);
    });

    it('enforces the per-phone resend cooldown', async () => {
      const phone = '+4915100000003';
      await request(http).post('/v1/auth/otp/request').set(ANDROID).send({ phone }).expect(200);
      await request(http).post('/v1/auth/otp/request').set(ANDROID).send({ phone }).expect(429);
    });

    it('registers and logs in with email, refresh rotation + reuse detection', async () => {
      const creds = { email: 'kunde@test.dev', password: 'Passwort123!', name: 'Kunde' };
      const reg = await request(http).post('/v1/auth/email/register').set(ANDROID).send(creds).expect(201);
      const refresh1 = reg.body.refreshToken;

      const rot = await request(http).post('/v1/auth/refresh').send({ refreshToken: refresh1 }).expect(200);
      expect(rot.body.accessToken).toBeTruthy();

      // Reusing the rotated token must fail and revoke the family.
      await request(http).post('/v1/auth/refresh').send({ refreshToken: refresh1 }).expect(401);
      await request(http).post('/v1/auth/refresh').send({ refreshToken: rot.body.refreshToken }).expect(401);

      const login = await request(http)
        .post('/v1/auth/email/login')
        .set(ANDROID)
        .send({ email: creds.email, password: creds.password })
        .expect(200);
      expect(login.body.user.email).toBe(creds.email);

      await request(http)
        .post('/v1/auth/email/login')
        .set(ANDROID)
        .send({ email: creds.email, password: 'wrong-password' })
        .expect(401);
    });

    it('superadmin logs in with seeded credentials', async () => {
      const res = await request(http)
        .post('/v1/auth/email/login')
        .set(WEB)
        .send(SUPERADMIN)
        .expect(200);
      expect(res.body.user.role).toBe('SUPERADMIN');
      expect(res.body.user.isAdmin).toBe(true);
      superToken = res.body.accessToken;
    });
  });

  describe('rbac', () => {
    it('customer cannot access admin or superadmin routes', async () => {
      await request(http).get('/v1/admin/orders').auth(customerToken, { type: 'bearer' }).expect(403);
      await request(http).get('/v1/superadmin/staff').auth(customerToken, { type: 'bearer' }).expect(403);
    });

    it('unauthenticated requests are rejected', async () => {
      await request(http).get('/v1/users/me').expect(401);
    });
  });

  describe('superadmin: driver management', () => {
    it('creates a driver with login credentials', async () => {
      const res = await request(http)
        .post('/v1/superadmin/staff')
        .auth(superToken, { type: 'bearer' })
        .send({ role: 'DRIVER', email: 'driver1@test.dev', password: 'Fahrer123!', name: 'Davit', group: 'Berlin' })
        .expect(201);
      expect(res.body.isDriver).toBe(true);
      driverId = res.body.id;

      const login = await request(http)
        .post('/v1/auth/email/login')
        .set(ANDROID)
        .send({ email: 'driver1@test.dev', password: 'Fahrer123!' })
        .expect(200);
      driverToken = login.body.accessToken;
      expect(login.body.user.role).toBe('DRIVER');
    });

    it('lists staff with device info', async () => {
      const res = await request(http)
        .get('/v1/superadmin/staff')
        .auth(superToken, { type: 'bearer' })
        .expect(200);
      const driver = res.body.find((u: any) => u.id === driverId);
      expect(driver).toBeTruthy();
      expect(driver.devices[0].platform).toBe('android');
    });

    it('deactivating a driver kills their access', async () => {
      const tmp = await request(http)
        .post('/v1/superadmin/staff')
        .auth(superToken, { type: 'bearer' })
        .send({ role: 'DRIVER', email: 'driver2@test.dev', password: 'Fahrer123!' })
        .expect(201);
      await request(http)
        .post(`/v1/superadmin/staff/${tmp.body.id}/deactivate`)
        .auth(superToken, { type: 'bearer' })
        .expect(200);
      await request(http)
        .post('/v1/auth/email/login')
        .set(ANDROID)
        .send({ email: 'driver2@test.dev', password: 'Fahrer123!' })
        .expect(403);
    });

    it('exposes login events with ip/platform for audit', async () => {
      const res = await request(http)
        .get('/v1/superadmin/login-events?limit=50')
        .auth(superToken, { type: 'bearer' })
        .expect(200);
      expect(res.body.length).toBeGreaterThan(0);
      expect(res.body[0]).toHaveProperty('ip');
      expect(res.body[0]).toHaveProperty('platform');
    });
  });

  describe('orders: full lifecycle', () => {
    let productId = '';
    let shiftId = '';
    let orderId = '';

    it('admin sets up catalog, shift and coupon', async () => {
      const cat = await request(http)
        .post('/v1/admin/categories')
        .auth(superToken, { type: 'bearer' })
        .send({ name: { en: 'Breads', hy: 'Հացեր' } })
        .expect(201);
      const prod = await request(http)
        .post('/v1/admin/products')
        .auth(superToken, { type: 'bearer' })
        .send({ categoryId: cat.body.id, name: { en: 'Armenian Matnakash' }, price: 4.5, maxQty: 10 })
        .expect(201);
      productId = prod.body.id;

      const shift = await request(http)
        .post('/v1/admin/shifts')
        .auth(superToken, { type: 'bearer' })
        .send({ group: 'Berlin', date: new Date(Date.now() + 7 * 86400e3).toISOString(), label: '20.07' })
        .expect(201);
      shiftId = shift.body.id;

      await request(http)
        .post('/v1/admin/coupons')
        .auth(superToken, { type: 'bearer' })
        .send({ code: 'welcome10', type: 'percent', value: 10, usageLimit: 5 })
        .expect(201);
    });

    it('customer places an order — prices computed server-side, coupon applied', async () => {
      await request(http)
        .patch('/v1/users/me')
        .auth(customerToken, { type: 'bearer' })
        .send({ group: 'Berlin', address: 'Teststr. 1', city: 'Berlin' })
        .expect(200);

      const res = await request(http)
        .post('/v1/orders')
        .auth(customerToken, { type: 'bearer' })
        .send({
          shiftId,
          couponCode: 'WELCOME10',
          // client-sent prices are ignored; only productId/qty matter
          items: [{ productId, qty: 2 }],
        })
        .expect(201);
      orderId = res.body.id;
      expect(res.body.subtotal).toBe(9);
      expect(res.body.discount).toBe(0.9);
      expect(res.body.totalPrice).toBe(8.1);
      expect(res.body.status).toBe('pending');
      expect(res.body.userGroup).toBe('Berlin');
    });

    it('rejects quantities above maxQty and unknown products', async () => {
      await request(http)
        .post('/v1/orders')
        .auth(customerToken, { type: 'bearer' })
        .send({ shiftId, items: [{ productId, qty: 11 }] })
        .expect(400);
      await request(http)
        .post('/v1/orders')
        .auth(customerToken, { type: 'bearer' })
        .send({ shiftId, items: [{ productId: 'nope', qty: 1 }] })
        .expect(400);
    });

    it('admin confirms and assigns the driver; driver delivers with cash collected', async () => {
      await request(http)
        .patch(`/v1/admin/orders/${orderId}`)
        .auth(superToken, { type: 'bearer' })
        .send({ status: 'confirmed' })
        .expect(200);
      await request(http)
        .post(`/v1/admin/orders/${orderId}/assign`)
        .auth(superToken, { type: 'bearer' })
        .send({ driverId })
        .expect(200);

      const mine = await request(http)
        .get('/v1/driver/orders')
        .auth(driverToken, { type: 'bearer' })
        .expect(200);
      expect(mine.body.some((o: any) => o.id === orderId)).toBe(true);

      await request(http)
        .patch(`/v1/driver/orders/${orderId}/status`)
        .auth(driverToken, { type: 'bearer' })
        .send({ status: 'on_the_way' })
        .expect(200);
      const done = await request(http)
        .patch(`/v1/driver/orders/${orderId}/status`)
        .auth(driverToken, { type: 'bearer' })
        .send({ status: 'delivered', cashCollected: true })
        .expect(200);
      expect(done.body.status).toBe('delivered');
      expect(done.body.cashCollected).toBe(true);
    });

    it('blocks illegal status transitions', async () => {
      await request(http)
        .patch(`/v1/admin/orders/${orderId}`)
        .auth(superToken, { type: 'bearer' })
        .send({ status: 'pending' })
        .expect(400);
    });

    it('another customer cannot read the order', async () => {
      const other = await request(http)
        .post('/v1/auth/email/register')
        .set(ANDROID)
        .send({ email: 'other@test.dev', password: 'Passwort123!' })
        .expect(201);
      await request(http)
        .get(`/v1/orders/${orderId}`)
        .auth(other.body.accessToken, { type: 'bearer' })
        .expect(403);
    });

    it('stats reflect the delivered order', async () => {
      const res = await request(http)
        .get('/v1/admin/stats')
        .auth(superToken, { type: 'bearer' })
        .expect(200);
      expect(res.body.byStatus.delivered).toBe(1);
      expect(res.body.revenue).toBe(8.1);
    });
  });

  describe('chat', () => {
    it('customer and admin exchange messages with unread tracking', async () => {
      await request(http)
        .post(`/v1/messages/${customerId}`)
        .auth(customerToken, { type: 'bearer' })
        .send({ text: 'Barev dzez! When is my bread coming?' })
        .expect(201);

      const topics = await request(http)
        .get('/v1/messages/topics')
        .auth(superToken, { type: 'bearer' })
        .expect(200);
      const topic = topics.body.find((t: any) => t.topicId === customerId);
      expect(topic.unread).toBe(1);

      await request(http)
        .post(`/v1/messages/${customerId}`)
        .auth(superToken, { type: 'bearer' })
        .send({ text: 'Tomorrow morning!' })
        .expect(201);

      const list = await request(http)
        .get(`/v1/messages/${customerId}`)
        .auth(customerToken, { type: 'bearer' })
        .expect(200);
      expect(list.body).toHaveLength(2);
      expect(list.body[1].isFromAdmin).toBe(true);

      const unread = await request(http)
        .get('/v1/messages/unread')
        .auth(customerToken, { type: 'bearer' })
        .expect(200);
      expect(unread.body.unread).toBe(1);

      await request(http)
        .post(`/v1/messages/${customerId}/read`)
        .auth(customerToken, { type: 'bearer' })
        .send({})
        .expect(200);
      const after = await request(http)
        .get('/v1/messages/unread')
        .auth(customerToken, { type: 'bearer' })
        .expect(200);
      expect(after.body.unread).toBe(0);
    });

    it('a customer cannot read another customer’s chat', async () => {
      const other = await request(http)
        .post('/v1/auth/email/login')
        .set(ANDROID)
        .send({ email: 'other@test.dev', password: 'Passwort123!' })
        .expect(200);
      await request(http)
        .get(`/v1/messages/${customerId}`)
        .auth(other.body.accessToken, { type: 'bearer' })
        .expect(403);
    });
  });

  describe('approvals', () => {
    it('profile change goes through admin approval', async () => {
      const created = await request(http)
        .post('/v1/approvals')
        .auth(customerToken, { type: 'bearer' })
        .send({ changes: { name: 'Aram', hack: 'ignored' } })
        .expect(201);
      expect(created.body.changes).toEqual({ name: 'Aram' });

      await request(http)
        .post(`/v1/admin/approvals/${created.body.id}/approve`)
        .auth(superToken, { type: 'bearer' })
        .expect(200);

      const me = await request(http)
        .get('/v1/users/me')
        .auth(customerToken, { type: 'bearer' })
        .expect(200);
      expect(me.body.name).toBe('Aram');
    });
  });

  describe('zones', () => {
    it('resolves a point inside a polygon to its group', async () => {
      await request(http)
        .post('/v1/admin/zones')
        .auth(superToken, { type: 'bearer' })
        .send({
          name: 'TestCity',
          polygons: [[{ lat: 52, lng: 13 }, { lat: 52, lng: 14 }, { lat: 53, lng: 14 }, { lat: 53, lng: 13 }]],
        })
        .expect(201);
      const inside = await request(http)
        .post('/v1/zones/resolve')
        .send({ lat: 52.5, lng: 13.5 })
        .expect(201);
      expect(inside.body.group).toBe('TestCity');
      const outside = await request(http)
        .post('/v1/zones/resolve')
        .send({ lat: 40, lng: 10 })
        .expect(201);
      expect(outside.body.group).toBeNull();
    });
  });
});
