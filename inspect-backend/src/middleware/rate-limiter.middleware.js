const { rateLimit } = require('express-rate-limit');
const { RedisStore } = require('rate-limit-redis');
const redisClient = require('../config/redis');

/**
 * Sync Rate Limiter
 * Limits each device to 30 sync requests per minute.
 * Stores hit counts in Redis.
 */
const syncRateLimiter = rateLimit({
  // Redis store configuration
  store: new RedisStore({
    // @ts-expect-error - Known issue with type definitions
    sendCommand: (...args) => redisClient.call(...args),
  }),
  windowMs: 1 * 60 * 1000, // 1 minute window
  limit: 30, // Limit each IP/device to 30 requests per windowMs
  standardHeaders: 'draft-7', // combined `RateLimit` header
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  
  // Custom key generator: Use device_id if present, fallback to safe IP generator
  keyGenerator: (req) => {
    const deviceId = req.body?.device_id || req.body?.deviceId || req.headers['x-device-id'];
    if (deviceId) return `rate-limit:sync:${deviceId}`;
    
    // Use the built-in helper for IPv6-safe IP-based limiting as a fallback
    return ipKeyGenerator(req);
  },
  
  // Custom handler for when limit is reached
  handler: (req, res) => {
    res.status(429).json({
      success: false,
      message: 'Too many sync requests from this device. Please wait a minute before trying again.'
    });
  }
});

module.exports = {
  syncRateLimiter
};
