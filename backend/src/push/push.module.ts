import { Global, Injectable, Logger, Module } from '@nestjs/common';
import { Device, Platform } from '@prisma/client';
import { GoogleAuth } from 'google-auth-library';
import * as http2 from 'node:http2';
import * as jwt from 'jsonwebtoken';
import { PrismaService } from '../prisma/prisma.service';

export interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * Server-side push delivery for backgrounded/closed apps, so notifications
 * don't depend on a live socket connection. Sends via FCM HTTP v1 (Android)
 * and APNs over HTTP/2 (iOS) directly — no Firebase Admin SDK.
 *
 * Every channel is config-gated: with no credentials the service logs once and
 * no-ops, so dev/CI runs unaffected. Dead tokens (Unregistered / 410 / bad
 * token) are pruned so they aren't retried.
 *
 * Required env (all optional; a channel is simply skipped if unset):
 *  - FCM_SERVICE_ACCOUNT   inline service-account JSON (or GOOGLE_APPLICATION_CREDENTIALS path)
 *  - FCM_PROJECT_ID        overrides project_id from the service account
 *  - APNS_KEY              contents of the AuthKey_XXXX.p8 (ES256 private key)
 *  - APNS_KEY_ID           the .p8 key id
 *  - APNS_TEAM_ID          Apple developer team id
 *  - APNS_BUNDLE_ID        iOS app bundle id (apns-topic)
 *  - APNS_PRODUCTION       "true" for api.push.apple.com, else the sandbox host
 */
@Injectable()
export class PushService {
  private readonly logger = new Logger(PushService.name);

  // FCM
  private fcmAuth?: GoogleAuth;
  private fcmProjectId?: string;
  // APNs
  private readonly apnsKey = process.env.APNS_KEY;
  private readonly apnsKeyId = process.env.APNS_KEY_ID;
  private readonly apnsTeamId = process.env.APNS_TEAM_ID;
  private readonly apnsBundleId = process.env.APNS_BUNDLE_ID;
  private readonly apnsHost =
    process.env.APNS_PRODUCTION === 'true'
      ? 'https://api.push.apple.com'
      : 'https://api.sandbox.push.apple.com';
  private apnsJwt?: { token: string; at: number };

  private warnedFcm = false;
  private warnedApns = false;

  constructor(private prisma: PrismaService) {
    const sa = process.env.FCM_SERVICE_ACCOUNT;
    const saPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    if (sa || saPath) {
      try {
        const credentials = sa ? JSON.parse(sa) : undefined;
        this.fcmAuth = new GoogleAuth({
          credentials,
          keyFile: sa ? undefined : saPath,
          scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
        });
        this.fcmProjectId = process.env.FCM_PROJECT_ID ?? credentials?.project_id;
      } catch (e) {
        this.logger.error(`Invalid FCM_SERVICE_ACCOUNT: ${(e as Error).message}`);
      }
    }
  }

  /** Push a notification to every registered device of a user. */
  async sendToUser(userId: string, payload: PushPayload) {
    const devices = await this.prisma.device.findMany({
      where: { userId, NOT: { fcmToken: '' } },
    });
    await this.sendToDevices(devices, payload);
  }

  async sendToDevices(devices: Device[], payload: PushPayload) {
    await Promise.all(
      devices.map((d) =>
        d.platform === Platform.ios
          ? this.sendApns(d, payload)
          : this.sendFcm(d, payload),
      ),
    );
  }

  // ---------- FCM HTTP v1 (Android / web) ----------

  private async sendFcm(device: Device, payload: PushPayload) {
    if (!this.fcmAuth || !this.fcmProjectId) {
      if (!this.warnedFcm) {
        this.logger.warn('FCM not configured — skipping Android/web push');
        this.warnedFcm = true;
      }
      return;
    }
    try {
      const token = await this.fcmAuth.getAccessToken();
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${this.fcmProjectId}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token: device.fcmToken,
              notification: { title: payload.title, body: payload.body },
              data: payload.data ?? {},
              android: { priority: 'high' },
            },
          }),
        },
      );
      if (!res.ok) {
        const errText = await res.text();
        // UNREGISTERED / INVALID_ARGUMENT for the token => prune it.
        if (res.status === 404 || /UNREGISTERED|INVALID_ARGUMENT/.test(errText)) {
          await this.pruneToken(device.id);
        } else {
          this.logger.warn(`FCM send failed (${res.status}): ${errText}`);
        }
      }
    } catch (e) {
      this.logger.error(`FCM send error: ${(e as Error).message}`);
    }
  }

  // ---------- APNs over HTTP/2 (iOS) ----------

  private apnsToken(): string | undefined {
    if (!this.apnsKey || !this.apnsKeyId || !this.apnsTeamId) return undefined;
    // APNs tokens are valid up to 1h; refresh every ~50 min.
    const now = Math.floor(Date.now() / 1000);
    if (this.apnsJwt && now - this.apnsJwt.at < 3000) return this.apnsJwt.token;
    const token = jwt.sign({ iss: this.apnsTeamId, iat: now }, this.apnsKey, {
      algorithm: 'ES256',
      keyid: this.apnsKeyId,
    });
    this.apnsJwt = { token, at: now };
    return token;
  }

  private async sendApns(device: Device, payload: PushPayload) {
    const authToken = this.apnsToken();
    if (!authToken || !this.apnsBundleId) {
      if (!this.warnedApns) {
        this.logger.warn('APNs not configured — skipping iOS push');
        this.warnedApns = true;
      }
      return;
    }
    const body = JSON.stringify({
      aps: { alert: { title: payload.title, body: payload.body }, sound: 'default' },
      ...payload.data,
    });
    await new Promise<void>((resolve) => {
      const client = http2.connect(this.apnsHost);
      client.on('error', (e) => {
        this.logger.error(`APNs connect error: ${e.message}`);
        resolve();
      });
      const req = client.request({
        ':method': 'POST',
        ':path': `/3/device/${device.fcmToken}`,
        authorization: `bearer ${authToken}`,
        'apns-topic': this.apnsBundleId,
        'apns-push-type': 'alert',
        'content-type': 'application/json',
      });
      let status = 0;
      let resBody = '';
      req.on('response', (headers) => {
        status = Number(headers[':status']) || 0;
      });
      req.on('data', (chunk) => (resBody += chunk));
      req.on('end', async () => {
        if (status === 410 || /BadDeviceToken|Unregistered/.test(resBody)) {
          await this.pruneToken(device.id);
        } else if (status >= 400) {
          this.logger.warn(`APNs send failed (${status}): ${resBody}`);
        }
        client.close();
        resolve();
      });
      req.on('error', (e) => {
        this.logger.error(`APNs request error: ${e.message}`);
        client.close();
        resolve();
      });
      req.end(body);
    });
  }

  private async pruneToken(deviceId: string) {
    await this.prisma.device
      .update({ where: { id: deviceId }, data: { fcmToken: '' } })
      .catch(() => undefined);
  }
}

@Global()
@Module({
  providers: [PushService],
  exports: [PushService],
})
export class PushModule {}
