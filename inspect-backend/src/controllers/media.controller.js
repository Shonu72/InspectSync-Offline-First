const s3Service = require('../services/s3.service');
const ApiError = require('../utils/ApiError');

/**
 * Controller for media management
 */
const getPresignedUrl = async (req, res, next) => {
  try {
    const { fileName, fileType } = req.body;

    if (!fileName || !fileType) {
      throw new ApiError(400, 'fileName and fileType are required');
    }

    // Allow only certain image/media types if needed
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf', 'video/mp4'];
    if (!allowedTypes.includes(fileType)) {
      throw new ApiError(400, `File type ${fileType} is not supported. Allowed types: ${allowedTypes.join(', ')}`);
    }

    const { uploadUrl, key, publicUrl } = await s3Service.generateUploadUrl(fileName, fileType);

    res.status(200).json({
      success: true,
      message: 'Presigned URL generated successfully',
      data: {
        uploadUrl,
        key,
        publicUrl,
      },
    });
  } catch (error) {
    console.error('[MediaController] Error in getPresignedUrl:', error);
    next(error);
  }
};

module.exports = {
  getPresignedUrl,
};
