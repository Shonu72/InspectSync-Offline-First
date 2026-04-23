const express = require('express');
const mediaController = require('../controllers/media.controller');
const auth = require('../middleware/auth');

const router = express.Router();

/**
 * @route   POST /api/media/presigned-url
 * @desc    Generate a presigned URL for S3 upload
 * @access  Private
 */
router.post('/presigned-url', auth, mediaController.getPresignedUrl);

module.exports = router;
