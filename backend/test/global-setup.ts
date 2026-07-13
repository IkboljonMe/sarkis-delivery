import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

/**
 * Prepares the disposable e2e database (DATABASE_URL_TEST, local docker
 * Postgres): syncs the schema, then empties all tables so every run starts
 * clean. Never point DATABASE_URL_TEST at a real database.
 */
export default async function globalSetup() {
  const envPath = join(__dirname, '..', '.env');
  let testUrl = process.env.DATABASE_URL_TEST;
  if (!testUrl && existsSync(envPath)) {
    const m = readFileSync(envPath, 'utf8').match(/^DATABASE_URL_TEST=(.*)$/m);
    testUrl = m?.[1];
  }
  if (!testUrl) throw new Error('DATABASE_URL_TEST is not set');

  execSync('npx prisma db push --skip-generate', {
    cwd: join(__dirname, '..'),
    env: { ...process.env, DATABASE_URL: testUrl },
    stdio: 'inherit',
  });

  const { PrismaClient } = await import('@prisma/client');
  const prisma = new PrismaClient({ datasources: { db: { url: testUrl } } });
  try {
    const tables = await prisma.$queryRaw<{ tablename: string }[]>`
      SELECT tablename FROM pg_tables WHERE schemaname = 'public'`;
    const names = tables
      .map((t) => `"public"."${t.tablename}"`)
      .filter((n) => !n.includes('_prisma'));
    if (names.length) {
      await prisma.$executeRawUnsafe(`TRUNCATE TABLE ${names.join(', ')} CASCADE`);
    }
  } finally {
    await prisma.$disconnect();
  }
}
