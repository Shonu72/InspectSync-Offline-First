const express = require('express');
const syncController = require('../controllers/sync.controller');
const auth = require('../middleware/auth');
const { syncRateLimiter } = require('../middleware/rate-limiter.middleware');

const router = express.Router();

router.use(auth); // All sync routes require authentication

router.get('/pull', syncController.pull);
router.post('/push', syncRateLimiter, syncController.push);

module.exports = router;
