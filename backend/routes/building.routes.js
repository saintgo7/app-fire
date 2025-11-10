const express = require('express');
const router = express.Router();
const { verifyToken } = require('../controllers/auth.controller');
const { pool } = require('../config/database');

router.use(verifyToken);

// 건물 목록 조회
router.get('/', async (req, res) => {
  try {
    const [buildings] = await pool.query('SELECT * FROM buildings ORDER BY created_at DESC');
    res.json({ success: true, data: buildings });
  } catch (error) {
    res.status(500).json({ success: false, message: '건물 목록 조회 실패' });
  }
});

// 건물 생성
router.post('/', async (req, res) => {
  try {
    const { name, address, buildingType, totalFloors, totalArea, ownerName, ownerContact, latitude, longitude } = req.body;

    const [result] = await pool.query(
      `INSERT INTO buildings (name, address, building_type, total_floors, total_area, owner_name, owner_contact, latitude, longitude)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, address, buildingType, totalFloors, totalArea, ownerName, ownerContact, latitude, longitude]
    );

    res.status(201).json({
      success: true,
      message: '건물이 생성되었습니다.',
      data: { id: result.insertId }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: '건물 생성 실패' });
  }
});

// 건물 조회
router.get('/:id', async (req, res) => {
  try {
    const [buildings] = await pool.query('SELECT * FROM buildings WHERE id = ?', [req.params.id]);

    if (buildings.length === 0) {
      return res.status(404).json({ success: false, message: '건물을 찾을 수 없습니다.' });
    }

    res.json({ success: true, data: buildings[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: '건물 조회 실패' });
  }
});

module.exports = router;
