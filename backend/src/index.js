require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const { testConnection, closePool } = require('./config/database');

// 라우트 import
const buildingsRouter = require('./routes/buildings');
const inspectionsRouter = require('./routes/inspections');
const usersRouter = require('./routes/users');
const authRouter = require('./routes/auth');
const syncRouter = require('./routes/sync');

// Express 앱 생성
const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// ============================================================================
// 미들웨어 설정
// ============================================================================

// 보안 헤더
app.use(helmet());

// CORS 설정
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// 압축
app.use(compression());

// JSON 파싱
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 로깅 (개발 환경)
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// 정적 파일 (업로드된 사진)
app.use('/uploads', express.static('uploads'));

// ============================================================================
// 헬스체크
// ============================================================================

app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
  });
});

app.get('/', (req, res) => {
  res.json({
    name: 'Fire Safety Inspection API',
    version: '1.0.0',
    docs: '/api-docs',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      buildings: '/api/buildings',
      inspections: '/api/inspections',
      users: '/api/users',
      sync: '/api/sync',
    },
  });
});

// ============================================================================
// API 라우트
// ============================================================================

app.use('/api/auth', authRouter);
app.use('/api/buildings', buildingsRouter);
app.use('/api/inspections', inspectionsRouter);
app.use('/api/users', usersRouter);
app.use('/api/sync', syncRouter);

// ============================================================================
// 에러 핸들링
// ============================================================================

// 404 핸들러
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.path}`,
  });
});

// 전역 에러 핸들러
app.use((err, req, res, next) => {
  console.error('Error:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    error: err.name || 'Error',
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// ============================================================================
// 서버 시작
// ============================================================================

async function startServer() {
  try {
    // 데이터베이스 연결 테스트
    const dbConnected = await testConnection();
    if (!dbConnected) {
      console.error('⚠️  데이터베이스 연결 실패. 서버는 시작되지만 DB 작업이 불가능합니다.');
    }

    // 서버 시작
    app.listen(PORT, HOST, () => {
      console.log('');
      console.log('🔥 Fire Safety Inspection API Server');
      console.log('=====================================');
      console.log(`🚀 Server running at http://${HOST}:${PORT}`);
      console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`⏰ Started at: ${new Date().toLocaleString('ko-KR')}`);
      console.log('');
      console.log('Available endpoints:');
      console.log(`   GET  http://${HOST}:${PORT}/health`);
      console.log(`   POST http://${HOST}:${PORT}/api/auth/login`);
      console.log(`   GET  http://${HOST}:${PORT}/api/buildings`);
      console.log(`   GET  http://${HOST}:${PORT}/api/inspections`);
      console.log('=====================================');
      console.log('');
    });
  } catch (err) {
    console.error('❌ 서버 시작 실패:', err);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n⚠️  서버 종료 시작...');
  await closePool();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('\n⚠️  서버 종료 시작...');
  await closePool();
  process.exit(0);
});

// 서버 시작
startServer();

module.exports = app;
