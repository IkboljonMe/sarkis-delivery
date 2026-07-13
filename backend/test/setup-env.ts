import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

// Load .env without overriding anything already set, then point the app at the
// test database. Must run before any module imports @prisma/client.
const envPath = join(__dirname, '..', '.env');
if (existsSync(envPath)) {
  for (const line of readFileSync(envPath, 'utf8').split('\n')) {
    const m = line.match(/^([A-Z0-9_]+)=(.*)$/);
    if (m && process.env[m[1]] === undefined) process.env[m[1]] = m[2];
  }
}

process.env.NODE_ENV = 'test';
process.env.SMS_PROVIDER = 'dev';
process.env.DATABASE_URL = process.env.DATABASE_URL_TEST!;
