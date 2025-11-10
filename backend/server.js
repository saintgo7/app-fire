const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const { testConnection } = require('./config/database');

// 라우터 import
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const inspectionRoutes = require('./routes/inspection.routes');
const buildingRoutes = require('./routes/building.routes');
const scheduleRoutes = require('./routes/schedule.routes');
const legalRoutes = require('./routes/legal.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어 설정
app.use(helmet()); // 보안 헤더
app.use(compression()); // 응답 압축
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 로깅
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.'
});
app.use('/api/', limiter);

// 정적 파일 제공 (업로드된 이미지 등)
app.use('/uploads', express.static('uploads'));

// 헬스체크 엔드포인트
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API 라우트
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/inspections', inspectionRoutes);
app.use('/api/buildings', buildingRoutes);
app.use('/api/schedules', scheduleRoutes);
app.use('/api/legal', legalRoutes);

// 404 핸들러
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: '요청하신 리소스를 찾을 수 없습니다.'
  });
});

// 에러 핸들러
app.use((err, req, res, next) => {
  console.error('Error:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || '서버 오류가 발생했습니다.';

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 서버 시작
const startServer = async () => {
  // 데이터베이스 연결 테스트
  const dbConnected = await testConnection();

  if (!dbConnected) {
    console.error('❌ 데이터베이스 연결에 실패하여 서버를 시작할 수 없습니다.');
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`🚀 서버가 포트 ${PORT}에서 실행 중입니다.`);
    console.log(`📝 환경: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🔗 API URL: http://localhost:${PORT}/api`);
  });
};

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM 신호를 받았습니다. 서버를 종료합니다...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('👋 SIGINT 신호를 받았습니다. 서버를 종료합니다...');
  process.exit(0);
});

startServer();

module.exports = app;
