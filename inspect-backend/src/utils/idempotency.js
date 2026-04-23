const redis = require('../config/redis');

/**
 * Checks if an idempotency key has been used before.
 * If not, sets it with an expiry.
 * 
 * @param {string} key - The idempotency key to check
 * @param {number} expiryInSeconds - How long to store the key (default 24h)
 * @returns {Promise<boolean>} - True if the key was already set (request is a duplicate)
 */
const isDuplicate = async (key, expiryInSeconds = 86400) => {
  if (!key) return false;

  const redisKey = `idempotency:${key}`;
  
  // setnx (SET if Not eXists) returns 1 if set, 0 if already exists
  const result = await redis.set(redisKey, 'processed', 'EX', expiryInSeconds, 'NX');
  
  // If result is null, it means the key already existed
  return result === null;
};

module.exports = {
  isDuplicate
};
