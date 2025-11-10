const mysql = require('mysql2');
require('dotenv').config();

// MariaDB 연결 풀 생성
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'fire_safety_inspector',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  charset: 'utf8mb4'
});

// Promise 기반 API 사용
const promisePool = pool.promise();

// 연결 테스트
const testConnection = async () => {
  try {
    const [rows] = await promisePool.query('SELECT 1 + 1 AS result');
    console.log('✅ MariaDB 연결 성공:', rows[0].result);
    return true;
  } catch (error) {
    console.error('❌ MariaDB 연결 실패:', error.message);
    return false;
  }
};

module.exports = {
  pool: promisePool,
  testConnection
};
