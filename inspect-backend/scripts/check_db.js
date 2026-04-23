const prisma = require('../src/config/db.js');

async function main() {
  try {
    const taskCount = await prisma.task.count();
    const tasks = await prisma.task.findMany({
      take: 5,
      orderBy: { createdAt: 'desc' }
    });
    console.log('Total Tasks:', taskCount);
    console.log('\nLast 5 Tasks:');
    tasks.forEach(t => console.log(`- [${t.id}] ${t.title} (v${t.version}) - Status: ${t.status}`));

    const syncLogCount = await prisma.syncLog.count();
    const syncLogs = await prisma.syncLog.findMany({
      take: 3,
      orderBy: { createdAt: 'desc' }
    });
    console.log('\nSync Logs (Last 3):', JSON.stringify(syncLogs, null, 2));

    const conflictCount = await prisma.conflict.count();
    console.log('\nTotal Conflicts:', conflictCount);
    
  } catch (error) {
    console.error('Diagnostic error:', error.message);
  }
}

main()
  .finally(async () => await prisma.$disconnect());
