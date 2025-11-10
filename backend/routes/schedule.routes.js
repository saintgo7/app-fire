const express = require('express');
const router = express.Router();
const { verifyToken } = require('../controllers/auth.controller');
const { pool } = require('../config/database');

router.use(verifyToken);

// 일정 목록 조회
router.get('/', async (req, res) => {
  try {
    const userId = req.user.userId;
    const [schedules] = await pool.query(
      `SELECT s.*, b.name as building_name, b.address as building_address
       FROM schedules s
       LEFT JOIN buildings b ON s.building_id = b.id
       WHERE s.user_id = ?
       ORDER BY s.scheduled_date DESC`,
      [userId]
    );

    res.json({ success: true, data: schedules });
  } catch (error) {
    res.status(500).json({ success: false, message: '일정 목록 조회 실패' });
  }
});

// 일정 생성
router.post('/', async (req, res) => {
  try {
    const userId = req.user.userId;
    const { buildingId, scheduledDate, scheduledTime, title, description, reminderEnabled } = req.body;

    const [result] = await pool.query(
      `INSERT INTO schedules (user_id, building_id, scheduled_date, scheduled_time, title, description, reminder_enabled)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [userId, buildingId, scheduledDate, scheduledTime, title, description, reminderEnabled]
    );

    res.status(201).json({
      success: true,
      message: '일정이 생성되었습니다.',
      data: { id: result.insertId }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: '일정 생성 실패' });
  }
});

// 일정 업데이트
router.put('/:id', async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status } = req.body;

    const [result] = await pool.query(
      'UPDATE schedules SET status = ?, updated_at = NOW() WHERE id = ? AND user_id = ?',
      [status, req.params.id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: '일정을 찾을 수 없습니다.' });
    }

    res.json({ success: true, message: '일정이 업데이트되었습니다.' });
  } catch (error) {
    res.status(500).json({ success: false, message: '일정 업데이트 실패' });
  }
});

module.exports = router;
