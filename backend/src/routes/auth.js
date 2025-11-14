const express = require('express');
const router = express.Router();
const { query } = require('../config/database');

/**
 * POST /api/auth/login
 * 로그인 (간단 버전)
 */
router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // TODO: 실제 bcrypt 비밀번호 검증 구현
    const users = await query(
      'SELECT id, email, name, role, organization, fire_station FROM users WHERE email = ? AND is_active = 1',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다',
      });
    }

    const user = users[0];

    // 로그인 시간 업데이트
    await query('UPDATE users SET last_login_at = NOW() WHERE id = ?', [user.id]);

    // TODO: JWT 토큰 생성
    const token = 'dummy_token_' + user.id;

    res.json({
      success: true,
      data: {
        user,
        token,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/register
 * 회원가입 (간단 버전)
 */
router.post('/register', async (req, res, next) => {
  try {
    const { email, password, name, phone, organization, fire_station } = req.body;

    // TODO: 실제 bcrypt 비밀번호 해시 구현
    const passwordHash = password; // 임시

    const result = await query(
      `INSERT INTO users (email, password_hash, name, phone, organization, fire_station)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [email, passwordHash, name, phone, organization, fire_station]
    );

    res.status(201).json({
      success: true,
      data: {
        id: Number(result.insertId),
        email,
        name,
      },
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({
        success: false,
        message: '이미 등록된 이메일입니다',
      });
    }
    next(err);
  }
});

module.exports = router;
