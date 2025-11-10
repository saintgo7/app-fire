const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// 소셜 로그인 (Google, Kakao, Naver)
router.post('/social-login', authController.socialLogin);

// 로그아웃
router.post('/logout', authController.logout);

// 토큰 갱신
router.post('/refresh', authController.refreshToken);

// 사용자 정보 확인
router.get('/me', authController.verifyToken, authController.getCurrentUser);

module.exports = router;
