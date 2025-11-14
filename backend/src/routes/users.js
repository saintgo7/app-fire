const express = require('express');
const router = express.Router();
const { query } = require('../config/database');

/**
 * GET /api/users
 * 사용자 목록 조회
 */
router.get('/', async (req, res, next) => {
  try {
    const users = await query(
      'SELECT id, email, name, phone, organization, fire_station, role, created_at FROM users WHERE is_active = 1'
    );

    res.json({
      success: true,
      data: users,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/users/:id
 * 사용자 상세 조회
 */
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const users = await query(
      'SELECT id, email, name, phone, organization, fire_station, role, created_at FROM users WHERE id = ? AND is_active = 1',
      [id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      data: users[0],
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
