const { Queue } = require('bullmq');
const redis = require('../config/redis');

/**
 * Sync Jobs Queue
 * Used for background processing tasks triggered by syncing,
 * such as image processing, notifications, and report generation.
 */
const syncQueue = new Queue('sync-jobs', {
  connection: redis,
  defaultJobOptions: {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 5000, // 5 seconds
    },
    removeOnComplete: true,
    removeOnFail: 1000,
  },
});

/**
 * Adds a background job to the queue.
 * 
 * @param {string} name - Job type (e.g., 'process-images')
 * @param {Object} data - Payload for the worker
 * @returns {Promise}
 */
const addSyncJob = async (name, data) => {
  return syncQueue.add(name, data);
};

module.exports = {
  syncQueue,
  addSyncJob
};
