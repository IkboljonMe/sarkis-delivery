import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding test users...');
  
  const testUsers = Array.from({ length: 10 }).map((_, i) => ({
    phone: `+4917${i}1234567`,
    name: ['Klaus', 'Anna', 'Lukas', 'Mia', 'Leon', 'Emma', 'Finn', 'Hannah', 'Jonas', 'Lea'][i],
    lastName: ['Müller', 'Schmidt', 'Schneider', 'Fischer', 'Weber', 'Meyer', 'Wagner', 'Becker', 'Schulz', 'Hoffmann'][i],
    address: 'Alexanderplatz 1',
    city: 'Berlin',
    group: 'Berlin',
    language: 'de',
    isActive: true,
    isVerified: true,
  }));

  for (const u of testUsers) {
    await prisma.user.upsert({
      where: { phone: u.phone },
      update: {
        name: u.name,
        lastName: u.lastName,
        address: u.address,
        city: u.city,
        group: u.group,
        language: u.language,
        isActive: true,
        isVerified: true,
      },
      create: u,
    });
    console.log(`Upserted test user: ${u.name} ${u.lastName} (${u.phone})`);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
