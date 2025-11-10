const jwt = require('jsonwebtoken');
const { pool } = require('../config/database');

// JWT 토큰 생성
const generateToken = (userId, uid) => {
  return jwt.sign(
    { userId, uid },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
};

// 소셜 로그인 (Google, Kakao, Naver)
exports.socialLogin = async (req, res) => {
  try {
    const { uid, email, displayName, photoUrl, phoneNumber, loginProvider } = req.body;

    // 필수 필드 검증
    if (!uid || !loginProvider) {
      return res.status(400).json({
        success: false,
        message: 'uid와 loginProvider는 필수입니다.'
      });
    }

    // 사용자 조회 또는 생성
    const [existingUsers] = await pool.query(
      'SELECT * FROM users WHERE uid = ?',
      [uid]
    );

    let user;
    if (existingUsers.length > 0) {
      // 기존 사용자 - 정보 업데이트
      user = existingUsers[0];
      await pool.query(
        `UPDATE users
         SET email = ?, display_name = ?, photo_url = ?,
             phone_number = ?, last_login = NOW()
         WHERE uid = ?`,
        [email, displayName, photoUrl, phoneNumber, uid]
      );
    } else {
      // 신규 사용자 생성
      const [result] = await pool.query(
        `INSERT INTO users (uid, email, display_name, photo_url, phone_number, login_provider)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [uid, email, displayName, photoUrl, phoneNumber, loginProvider]
      );

      user = {
        id: result.insertId,
        uid,
        email,
        display_name: displayName,
        photo_url: photoUrl,
        phone_number: phoneNumber,
        login_provider: loginProvider
      };
    }

    // JWT 토큰 생성
    const token = generateToken(user.id, uid);

    res.json({
      success: true,
      message: '로그인 성공',
      data: {
        token,
        user: {
          id: user.id,
          uid: user.uid,
          email: user.email,
          displayName: user.display_name,
          photoUrl: user.photo_url,
          phoneNumber: user.phone_number,
          loginProvider: user.login_provider
        }
      }
    });
  } catch (error) {
    console.error('소셜 로그인 오류:', error);
    res.status(500).json({
      success: false,
      message: '로그인 처리 중 오류가 발생했습니다.'
    });
  }
};

// 로그아웃
exports.logout = async (req, res) => {
  // 클라이언트에서 토큰 삭제하면 됨
  res.json({
    success: true,
    message: '로그아웃 성공'
  });
};

// 토큰 갱신
exports.refreshToken = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: '토큰이 필요합니다.'
      });
    }

    // 토큰 검증 (만료된 토큰도 허용)
    const decoded = jwt.verify(token, process.env.JWT_SECRET, {
      ignoreExpiration: true
    });

    // 새 토큰 생성
    const newToken = generateToken(decoded.userId, decoded.uid);

    res.json({
      success: true,
      data: { token: newToken }
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: '유효하지 않은 토큰입니다.'
    });
  }
};

// 토큰 검증 미들웨어
exports.verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: '인증 토큰이 필요합니다.'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: '유효하지 않은 토큰입니다.'
    });
  }
};

// 현재 사용자 정보 조회
exports.getCurrentUser = async (req, res) => {
  try {
    const [users] = await pool.query(
      'SELECT id, uid, email, display_name, photo_url, phone_number, login_provider FROM users WHERE id = ?',
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: '사용자를 찾을 수 없습니다.'
      });
    }

    const user = users[0];
    res.json({
      success: true,
      data: {
        id: user.id,
        uid: user.uid,
        email: user.email,
        displayName: user.display_name,
        photoUrl: user.photo_url,
        phoneNumber: user.phone_number,
        loginProvider: user.login_provider
      }
    });
  } catch (error) {
    console.error('사용자 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '사용자 정보를 가져오는 중 오류가 발생했습니다.'
    });
  }
};
