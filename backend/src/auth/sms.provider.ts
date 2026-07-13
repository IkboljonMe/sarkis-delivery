import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface SmsResult {
  /** Only set by the dev provider (non-production) so login can be tested without SMS spend. */
  devCode?: string;
}

export abstract class SmsProvider {
  abstract sendOtp(phone: string, code: string): Promise<SmsResult>;
}

@Injectable()
export class DevSmsProvider extends SmsProvider {
  private readonly logger = new Logger('DevSms');

  async sendOtp(phone: string, code: string): Promise<SmsResult> {
    this.logger.warn(`[DEV ONLY] OTP for ${phone}: ${code}`);
    return process.env.NODE_ENV === 'production' ? {} : { devCode: code };
  }
}

/** GatewayAPI (https://gatewayapi.com) — EU SMS gateway, token auth. */
@Injectable()
export class GatewayApiSmsProvider extends SmsProvider {
  private readonly logger = new Logger('GatewayApiSms');

  constructor(private config: ConfigService) {
    super();
  }

  async sendOtp(phone: string, code: string): Promise<SmsResult> {
    const token = this.config.get<string>('GATEWAYAPI_TOKEN');
    if (!token) throw new ServiceUnavailableException('SMS gateway not configured');
    const res = await fetch('https://gatewayapi.eu/rest/mtsms', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        sender: this.config.get('GATEWAYAPI_SENDER') ?? 'Sarko',
        message: `${code} is your Sarko Delivery verification code.`,
        recipients: [{ msisdn: Number(phone.replace(/\D/g, '')) }],
        class: 'secret', // GatewayAPI hides message content in logs (OTP class)
      }),
    });
    if (!res.ok) {
      this.logger.error(`GatewayAPI error ${res.status}: ${await res.text()}`);
      throw new ServiceUnavailableException('Failed to send SMS');
    }
    return {};
  }
}

export const smsProviderFactory = {
  provide: SmsProvider,
  inject: [ConfigService],
  useFactory: (config: ConfigService) =>
    config.get('SMS_PROVIDER') === 'gatewayapi'
      ? new GatewayApiSmsProvider(config)
      : new DevSmsProvider(),
};
