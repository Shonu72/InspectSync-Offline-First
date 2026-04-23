require('dotenv').config();
const prisma = require('../src/config/db');
const bcrypt = require('bcryptjs');

async function main() {
  console.log('Seeding database...');

  // 1. Create a test user
  const hashedPassword = await bcrypt.hash('password123', 10);
  const user = await prisma.user.upsert({
    where: { email: 'engineer@inspectsync.com' },
    update: {},
    create: {
      email: 'engineer@inspectsync.com',
      password: hashedPassword,
      name: 'Field Engineer One',
      role: 'ENGINEER'
    },
  });

  console.log(`User created: ${user.email}`);

  // 2. Create some sample tasks
  const tasks = [
    {
      title: 'Infrastructure Audit: Sector 7',
      description: 'Perform a full structural audit of the main power grid substations in Sector 7.',
      priority: 'HIGH',
      category: 'Infrastructure Audit',
      status: 'pending',
      lat: 34.0522,
      lng: -118.2437,
      createdById: user.id,
      assignedToId: user.id,
      version: 1
    },
    {
      title: 'Sensor Calibration: Water Treatment',
      description: 'Recalibrate the flow sensors in the primary sedimentation tanks at the central water facility.',
      priority: 'MED',
      category: 'Sensor Calibration',
      status: 'pending',
      lat: 34.0722,
      lng: -118.2637,
      createdById: user.id,
      assignedToId: user.id,
      version: 1
    },
    {
      title: 'Emergency Repair: Substation B12',
      description: 'Repair the cooling system failure in Substation B12 reported by the remote monitoring system.',
      priority: 'HIGH',
      category: 'Emergency Repair',
      status: 'pending',
      lat: 34.0922,
      lng: -118.2837,
      createdById: user.id,
      assignedToId: user.id,
      version: 1
    }
  ];

  for (const task of tasks) {
    await prisma.task.create({ data: task });
  }

  console.log('Seeding complete!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
