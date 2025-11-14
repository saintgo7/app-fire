const express = require('express');
const router = express.Router();
const { uploadSingle, uploadMultiple, formatFileInfo } = require('../middlewares/upload');
const { authenticate } = require('../middlewares/auth');
const { query } = require('../config/database');

/**
 * POST /api/upload/photo
 * 단일 사진 업로드
 */
router.post('/photo', authenticate, (req, res, next) => {
  uploadSingle(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: '파일이 업로드되지 않았습니다',
      });
    }

    const fileInfo = formatFileInfo(req.file, req);

    res.json({
      success: true,
      data: fileInfo,
    });
  });
});

/**
 * POST /api/upload/photos
 * 다중 사진 업로드
 */
router.post('/photos', authenticate, (req, res, next) => {
  uploadMultiple(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: '파일이 업로드되지 않았습니다',
      });
    }

    const filesInfo = req.files.map((file) => formatFileInfo(file, req));

    res.json({
      success: true,
      data: filesInfo,
      count: filesInfo.length,
    });
  });
});

/**
 * POST /api/upload/inspection-photo
 * 점검 사진 업로드 및 DB 저장
 */
router.post('/inspection-photo', authenticate, (req, res, next) => {
  uploadSingle(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: '파일이 업로드되지 않았습니다',
      });
    }

    try {
      const { inspection_item_id } = req.body;

      if (!inspection_item_id) {
        return res.status(400).json({
          success: false,
          message: 'inspection_item_id가 필요합니다',
        });
      }

      const fileInfo = formatFileInfo(req.file, req);

      // DB에 사진 정보 저장
      const result = await query(
        `INSERT INTO inspection_photos (
          inspection_item_id, file_path, file_name, file_size, server_url, taken_at
        ) VALUES (?, ?, ?, ?, ?, NOW())`,
        [
          inspection_item_id,
          fileInfo.path,
          fileInfo.filename,
          fileInfo.size,
          fileInfo.url,
        ]
      );

      res.json({
        success: true,
        data: {
          id: Number(result.insertId),
          ...fileInfo,
        },
      });
    } catch (error) {
      next(error);
    }
  });
});

/**
 * POST /api/upload/inspection-photos
 * 점검 사진 다중 업로드 및 DB 저장
 */
router.post('/inspection-photos', authenticate, (req, res, next) => {
  uploadMultiple(req, res, async (err) => {
    if (err) {
      return res.status(400).json({
        success: false,
        message: err.message,
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: '파일이 업로드되지 않았습니다',
      });
    }

    try {
      const { inspection_item_id } = req.body;

      if (!inspection_item_id) {
        return res.status(400).json({
          success: false,
          message: 'inspection_item_id가 필요합니다',
        });
      }

      const uploadedPhotos = [];

      for (const file of req.files) {
        const fileInfo = formatFileInfo(file, req);

        const result = await query(
          `INSERT INTO inspection_photos (
            inspection_item_id, file_path, file_name, file_size, server_url, taken_at
          ) VALUES (?, ?, ?, ?, ?, NOW())`,
          [
            inspection_item_id,
            fileInfo.path,
            fileInfo.filename,
            fileInfo.size,
            fileInfo.url,
          ]
        );

        uploadedPhotos.push({
          id: Number(result.insertId),
          ...fileInfo,
        });
      }

      res.json({
        success: true,
        data: uploadedPhotos,
        count: uploadedPhotos.length,
      });
    } catch (error) {
      next(error);
    }
  });
});

module.exports = router;
