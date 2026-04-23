const prisma = require('../config/db');
const taskService = require('./task.service');
const s3Service = require('./s3.service');
const { isDuplicate } = require('../utils/idempotency');
const { mergeFields } = require('../utils/field-level-merge');
const { addSyncJob } = require('../queues/sync-jobs.queue');

const pullChanges = async (sinceTimestamp, userId) => {
  const date = sinceTimestamp ? new Date(sinceTimestamp) : new Date(0);
  
  // 1. Fetch updated or created tasks
  const updatedTasks = await prisma.task.findMany({
    where: {
      updatedAt: { gt: date },
      deletedAt: null,
      OR: [
        { createdById: userId },
        { assignedToId: userId },
        { assignedToId: null }
      ]
    },
    include: {
      createdBy: { select: { id: true, name: true, email: true } },
      assignedTo: { select: { id: true, name: true, email: true } }
    }
  });

  // 2. Presign Image URLs for private bucket access
  // Using a long expiry (e.g. 24 hours) for better offline support
  const processedTasks = await Promise.all(updatedTasks.map(async (task) => {
    if (!task.images) return task;

    try {
      const imageUrls = task.images.split(',');
      const presignedUrls = await Promise.all(
        imageUrls.map(url => s3Service.generateViewUrl(url, 86400)) // 24 hours
      );
      
      return {
        ...task,
        images: presignedUrls.join(',')
      };
    } catch (e) {
      console.error(`[SyncService] Failed to presign images for task ${task.id}:`, e);
      return task;
    }
  }));

  // 3. Fetch IDs of tasks deleted since last sync
  const deletedTasks = await prisma.task.findMany({
    where: {
      updatedAt: { gt: date },
      deletedAt: { not: null },
      OR: [
        { createdById: userId },
        { assignedToId: userId }
      ]
    },
    select: { id: true }
  });

  return {
    tasks: processedTasks,
    deletedIds: deletedTasks.map(t => t.id),
    serverTime: new Date().toISOString()
  };
};

const pushChanges = async ({ device_id, last_synced_at, changes }, userId) => {
  const synced = [];
  const conflicts = []; // Not used in refined LWW logic but kept for return structure compatibility
  const failed = [];
  const jobsToEnqueue = [];

  // 1. Pre-process: Fast Redis Idempotency Check (before starting DB transaction)
  const pendingChanges = [];
  for (const item of changes) {
    if (await isDuplicate(item.idempotencyKey)) {
      synced.push({ entityId: item.entityId, status: 'SYNCED', note: 'already processed (redis)' });
    } else {
      pendingChanges.push(item);
    }
  }

  if (pendingChanges.length === 0) {
    return { synced, conflicts: [], failed };
  }

  // 2. Root atomic transaction for Database operations
  // We wrap this in a broader try-catch to handle transaction-level failures
  try {
    await prisma.$transaction(async (tx) => {
      for (const item of pendingChanges) {
        const { 
          entityId, 
          entityType, 
          operation, 
          payload, 
          idempotencyKey,
          clientVersion 
        } = item;
        
        try {
          // Secondary DB check for safety (persistent record)
          const existingLog = await tx.syncLog.findUnique({
            where: { idempotencyKey }
          });

          if (existingLog) {
            synced.push({ entityId, status: 'SYNCED', note: 'already processed (db)' });
            continue;
          }

          // 3. Process Task Entity
          if (entityType === 'task') {
            if (operation === 'create') {
              const newTask = await tx.task.create({
                data: {
                  id: entityId, // Map client entityId to database primary key
                  ...payload,
                  createdById: userId,
                  version: 1,
                }
              });

              // Prepare background jobs (will be enqueued after transaction success)
              if (newTask.images) {
                jobsToEnqueue.push({ name: 'process-images', data: { taskId: newTask.id, images: newTask.images } });
              }
              jobsToEnqueue.push({ name: 'send-notifications', data: { taskId: newTask.id, userId, type: 'TASK_CREATED' } });

              synced.push({ entityId, serverId: newTask.id, status: 'SYNCED', version: 1 });
            } else if (operation === 'update') {
              const serverTask = await tx.task.findUnique({ where: { id: entityId } });
              
              if (!serverTask) {
                failed.push({ entityId, error: 'Task not found' });
                continue;
              }

              // Conflict Check (LWW Merge)
              if (clientVersion < serverTask.version) {
                console.log(`[SyncService] Conflict detected for Task ${entityId}. Server: v${serverTask.version}, Client: v${clientVersion}`);
                
                const mergedData = mergeFields(serverTask, payload);
                console.log('[SyncService] Merged Data:', JSON.stringify(mergedData));

                try {
                  await tx.conflict.create({
                    data: {
                      entityId,
                      entityType,
                      localData: payload,
                      serverData: serverTask,
                      resolved: true,
                      resolvedBy: 'system (LWW)'
                    }
                  });
                  console.log('[SyncService] Conflict record created');
                } catch (ce) {
                  console.error('[SyncService] Failed to create conflict record:', ce.message);
                  // Continue anyway as LWW is more important
                }

                const updatedTask = await tx.task.update({
                  where: { id: entityId },
                  data: {
                    ...mergedData,
                    version: { increment: 1 }
                  }
                });
                console.log('[SyncService] Task updated with merged data');

                if (updatedTask.images) {
                  jobsToEnqueue.push({ name: 'process-images', data: { taskId: updatedTask.id, images: updatedTask.images } });
                }
                synced.push({ entityId, status: 'SYNCED', version: updatedTask.version, note: 'resolved via LWW merge' });
                continue;
              }

              // Perform Update (No Conflict)
              const updatedTask = await tx.task.update({
                where: { id: entityId },
                data: {
                  ...payload,
                  version: { increment: 1 }
                }
              });

              if (updatedTask.images) {
                jobsToEnqueue.push({ name: 'process-images', data: { taskId: updatedTask.id, images: updatedTask.images } });
              }
              synced.push({ entityId, status: 'SYNCED', version: updatedTask.version });
            } else if (operation === 'delete') {
              await tx.task.update({
                where: { id: entityId },
                data: { deletedAt: new Date() }
              });
              synced.push({ entityId, status: 'SYNCED' });
            }
          }
          
          // 4. Log successful sync for idempotency
          await tx.syncLog.create({
            data: {
              deviceId: device_id,
              userId,
              entityId,
              entityType,
              operation,
              payload: payload,
              idempotencyKey,
              status: synced.find(s => s.entityId === entityId)?.note?.includes('merge') ? 'CONFLICT' : 'SYNCED'
            }
          });

        } catch (error) {
          console.error(`[SyncService] ❌ CRITICAL item error for ${entityId}:`, error);
          failed.push({ entityId, error: error.message });
          
          // Log failed attempt
          await tx.syncLog.create({
            data: {
              deviceId: device_id,
              userId,
              entityId,
              entityType,
              operation,
              payload: payload,
              idempotencyKey,
              status: 'FAILED',
              errorMessage: error.message
            }
          }).catch(e => console.error('Failed to log sync error to DB:', e));
        }
      }
      
      // Update Device lastSyncedAt
      await tx.device.upsert({
        where: { deviceId: device_id },
        update: { lastSyncedAt: new Date() },
        create: { deviceId: device_id, userId: userId, lastSyncedAt: new Date() }
      });
    }, {
      maxWait: 5000,
      timeout: 15000 // Increased to 15s to handle database latency
    });

    // 5. Post-transaction: Enqueue background jobs to BullMQ (Safe now)
    for (const job of jobsToEnqueue) {
      addSyncJob(job.name, job.data).catch(err => {
        console.error(`[SyncService] Failed to enqueue background job ${job.name}:`, err);
      });
    }

  } catch (transactionError) {
    console.error('[SyncService] Transaction failed:', transactionError);
    // If the top-level transaction fails (e.g. connection timeout), 
    // we return a high-level error response
    throw transactionError;
  }

  return { synced, conflicts: [], failed };
};

module.exports = {
  pullChanges,
  pushChanges
};
