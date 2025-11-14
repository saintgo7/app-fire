const jwt = require('jsonwebtoken');
const { query } = require('../config/database');

/**
 * JWT 토큰 생성
 */
function generateToken(user) {
  const payload = {
    id: user.id,
    email: user.email,
    role: user.role,
  };

  const token = jwt.sign(payload, process.env.JWT_SECRET || 'default_secret', {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });

  const refreshToken = jwt.sign(
    payload,
    process.env.JWT_SECRET || 'default_secret',
    {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
    }
  );

  return { token, refreshToken };
}

/**
 * JWT 토큰 검증 미들웨어
 */
async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: '인증 토큰이 필요합니다',
      });
    }

    const token = authHeader.substring(7);

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default_secret');

    // 사용자 정보 조회
    const users = await query(
      'SELECT id, email, name, role, organization, fire_station FROM users WHERE id = ? AND is_active = 1',
      [decoded.id]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: '유효하지 않은 사용자입니다',
      });
    }

    req.user = users[0];
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: '토큰이 만료되었습니다',
      });
    }

    if (err.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: '유효하지 않은 토큰입니다',
      });
    }

    return res.status(500).json({
      success: false,
      message: '인증 처리 중 오류가 발생했습니다',
    });
  }
}

/**
 * 권한 확인 미들웨어
 */
function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: '인증이 필요합니다',
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: '권한이 없습니다',
      });
    }

    next();
  };
}

/**
 * 선택적 인증 미들웨어 (토큰이 있으면 검증, 없어도 통과)
 */
async function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next();
  }

  try {
    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default_secret');

    const users = await query(
      'SELECT id, email, name, role FROM users WHERE id = ? AND is_active = 1',
      [decoded.id]
    );

    if (users.length > 0) {
      req.user = users[0];
    }
  } catch (err) {
    // 토큰이 유효하지 않아도 계속 진행
  }

  next();
}

module.exports = {
  generateToken,
  authenticate,
  authorize,
  optionalAuth,
};
