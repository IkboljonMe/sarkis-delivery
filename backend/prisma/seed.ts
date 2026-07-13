import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const email = (process.env.SUPERADMIN_EMAIL ?? 'superadmin@sarkis.delivery').toLowerCase();
  const password = process.env.SUPERADMIN_PASSWORD ?? 'ChangeMe123!';

  const superadmin = await prisma.user.upsert({
    where: { email },
    create: {
      email,
      role: Role.SUPERADMIN,
      passwordHash: await bcrypt.hash(password, 10),
      name: 'Super',
      lastName: 'Admin',
      emailVerifiedAt: new Date(),
      isVerified: true,
    },
    // Keep the existing password on re-seed; only make sure role/flags are right.
    update: { role: Role.SUPERADMIN, isActive: true },
  });
  console.log(`superadmin ready: ${superadmin.email}`);

  for (const name of ['Berlin', 'Hamburg', 'Frankfurt', 'München']) {
    await prisma.regionGroup.upsert({
      where: { name },
      create: { name },
      update: {},
    });
  }
  console.log('region groups ready');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
