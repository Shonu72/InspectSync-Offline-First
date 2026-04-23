const { PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const s3Client = require('../config/s3.config');
const crypto = require('crypto');

/**
 * Service for S3 operations
 */
class S3Service {
  /**
   * Generate a presigned URL for uploading a file
   * @param {string} fileName Original file name
   * @param {string} fileType MIME type
   * @param {number} expiresIn Expiration time in seconds (default 1 hour)
   */
  async generateUploadUrl(fileName, fileType, expiresIn = 3600) {
    try {
      const fileExtension = fileName.split('.').pop();
      
      // Fallback for randomUUID if running on older Node.js
      const uuid = crypto.randomUUID ? crypto.randomUUID() : crypto.randomBytes(16).toString('hex');
      
      const uniqueFileName = `${uuid}.${fileExtension}`;
      const dateFolder = new Date().toISOString().split('T')[0];
      const key = `uploads/${dateFolder}/${uniqueFileName}`;

      console.log(`[S3Service] Generating upload URL for key: ${key}`);

      const command = new PutObjectCommand({
        Bucket: process.env.AWS_BUCKET_NAME,
        Key: key,
        ContentType: fileType,
      });

      const uploadUrl = await getSignedUrl(s3Client, command, { expiresIn });
      
      // Construct the final static URL (used as a persistent identifier/key)
      const publicUrl = `https://${process.env.AWS_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;

      return {
        uploadUrl,
        key,
        publicUrl,
      };
    } catch (error) {
      console.error('[S3Service] Error generating upload URL:', error);
      throw error;
    }
  }

  /**
   * Extract S3 Key from a full fallback/public URL
   * @param {string} url Full S3 URL
   */
  extractKey(url) {
    try {
      if (!url) return null;
      // Handle format: https://bucket.s3.region.amazonaws.com/uploads/2026-04-04/uuid.jpg
      const urlParts = url.split('.amazonaws.com/');
      if (urlParts.length > 1) {
        return urlParts[1];
      }
      return url; // Return as is if already a key
    } catch (e) {
      return url;
    }
  }

  /**
   * Generate a presigned URL for viewing a file
   * @param {string} keyOrUrl S3 key or full URL
   * @param {number} expiresIn Expiration time in seconds (default 1 hour)
   */
  async generateViewUrl(keyOrUrl, expiresIn = 3600) {
    try {
      const key = this.extractKey(keyOrUrl);
      
      const command = new GetObjectCommand({
        Bucket: process.env.AWS_BUCKET_NAME,
        Key: key,
      });

      return await getSignedUrl(s3Client, command, { expiresIn });
    } catch (error) {
      console.error(`[S3Service] Error generating view URL for ${keyOrUrl}:`, error);
      return keyOrUrl; // Fallback to original URL on error
    }
  }
}

module.exports = new S3Service();
