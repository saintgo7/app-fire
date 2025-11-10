const express = require('express');
const router = express.Router();
const { verifyToken } = require('../controllers/auth.controller');

router.use(verifyToken);

// 사용자 프로필 조회
router.get('/profile', async (req, res) => {
  // auth.controller의 getCurrentUser 재사용 가능
  res.json({ success: true, message: 'User profile endpoint' });
});

// 사용자 프로필 업데이트
router.put('/profile', async (req, res) => {
  res.json({ success: true, message: 'Update profile endpoint' });
});

module.exports = router;
