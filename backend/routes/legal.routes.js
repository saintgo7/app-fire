const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');

// 법령 정보 조회 (인증 불필요 - 공개 정보)
router.get('/', async (req, res) => {
  try {
    const { category } = req.query;

    let query = 'SELECT * FROM legal_regulations';
    const params = [];

    if (category) {
      query += ' WHERE category = ?';
      params.push(category);
    }

    query += ' ORDER BY last_updated DESC';

    const [regulations] = await pool.query(query, params);

    res.json({ success: true, data: regulations });
  } catch (error) {
    res.status(500).json({ success: false, message: '법령 정보 조회 실패' });
  }
});

// 법령 상세 조회
router.get('/:id', async (req, res) => {
  try {
    const [regulations] = await pool.query(
      'SELECT * FROM legal_regulations WHERE id = ?',
      [req.params.id]
    );

    if (regulations.length === 0) {
      return res.status(404).json({ success: false, message: '법령을 찾을 수 없습니다.' });
    }

    res.json({ success: true, data: regulations[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: '법령 조회 실패' });
  }
});

module.exports = router;
