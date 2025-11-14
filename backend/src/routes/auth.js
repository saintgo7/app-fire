const express = require('express');
const bcrypt = require('bcryptjs');
const router = express.Router();
const { query } = require('../config/database');
const { generateToken, authenticate } = require('../middlewares/auth');

/**
 * POST /api/auth/register
 * 회원가입
 */
router.post('/register', async (req, res, next) => {
  try {
    const { email, password, name, phone, organization, fire_station, role } = req.body;

    // 입력 검증
    if (!email || !password || !name) {
      return res.status(400).json({
        success: false,
        message: '이메일, 비밀번호, 이름은 필수입니다',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: '비밀번호는 최소 6자 이상이어야 합니다',
      });
    }

    // 비밀번호 해시
    const passwordHash = await bcrypt.hash(password, 10);

    const result = await query(
      `INSERT INTO users (email, password_hash, name, phone, organization, fire_station, role)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [email, passwordHash, name, phone, organization, fire_station, role || 'inspector']
    );

    const userId = Number(result.insertId);

    // 토큰 생성
    const user = {
      id: userId,
      email,
      name,
      role: role || 'inspector',
    };
    const { token, refreshToken } = generateToken(user);

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: userId,
          email,
          name,
          role: role || 'inspector',
        },
        token,
        refreshToken,
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

/**
 * POST /api/auth/login
 * 로그인
 */
router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: '이메일과 비밀번호를 입력해주세요',
      });
    }

    // 사용자 조회 (비밀번호 해시 포함)
    const users = await query(
      'SELECT id, email, password_hash, name, role, organization, fire_station FROM users WHERE email = ? AND is_active = 1',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다',
      });
    }

    const user = users[0];

    // 비밀번호 검증
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: '이메일 또는 비밀번호가 올바르지 않습니다',
      });
    }

    // 로그인 시간 업데이트
    await query('UPDATE users SET last_login_at = NOW() WHERE id = ?', [user.id]);

    // 토큰 생성
    const { token, refreshToken } = generateToken(user);

    // 비밀번호 해시 제거
    delete user.password_hash;

    res.json({
      success: true,
      data: {
        user,
        token,
        refreshToken,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/auth/refresh
 * 토큰 갱신
 */
router.post('/refresh', async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token이 필요합니다',
      });
    }

    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET || 'default_secret');

    // 사용자 조회
    const users = await query(
      'SELECT id, email, name, role FROM users WHERE id = ? AND is_active = 1',
      [decoded.id]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: '유효하지 않은 사용자입니다',
      });
    }

    const user = users[0];
    const { token, refreshToken: newRefreshToken } = generateToken(user);

    res.json({
      success: true,
      data: {
        token,
        refreshToken: newRefreshToken,
      },
    });
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: '유효하지 않은 refresh token입니다',
    });
  }
});

/**
 * GET /api/auth/me
 * 현재 로그인한 사용자 정보
 */
router.get('/me', authenticate, async (req, res) => {
  res.json({
    success: true,
    data: req.user,
  });
});

/**
 * PUT /api/auth/change-password
 * 비밀번호 변경
 */
router.put('/change-password', authenticate, async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: '현재 비밀번호와 새 비밀번호를 입력해주세요',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: '새 비밀번호는 최소 6자 이상이어야 합니다',
      });
    }

    // 현재 비밀번호 확인
    const users = await query(
      'SELECT password_hash FROM users WHERE id = ?',
      [req.user.id]
    );

    const isValid = await bcrypt.compare(currentPassword, users[0].password_hash);

    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: '현재 비밀번호가 올바르지 않습니다',
      });
    }

    // 새 비밀번호 해시
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    await query(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [newPasswordHash, req.user.id]
    );

    res.json({
      success: true,
      message: '비밀번호가 변경되었습니다',
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
