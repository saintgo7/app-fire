const mariadb = require('mariadb');

// MariaDB 연결 풀 생성
const pool = mariadb.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'fire_safety_db',
  connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT) || 10,
  timezone: '+09:00', // Asia/Seoul = UTC+9
  charset: 'utf8mb4',
  // 연결 옵션
  connectTimeout: 10000,
  acquireTimeout: 10000,
  // 재연결 설정
  reconnect: true,
  // 로깅
  trace: process.env.NODE_ENV === 'development',
});

/**
 * 데이터베이스 연결 테스트
 */
async function testConnection() {
  let conn;
  try {
    conn = await pool.getConnection();
    console.log('✅ MariaDB 연결 성공');
    console.log(`   Database: ${process.env.DB_NAME}`);
    console.log(`   Host: ${process.env.DB_HOST}:${process.env.DB_PORT}`);
    return true;
  } catch (err) {
    console.error('❌ MariaDB 연결 실패:', err.message);
    return false;
  } finally {
    if (conn) conn.release();
  }
}

/**
 * 쿼리 실행 헬퍼
 */
async function query(sql, params = []) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(sql, params);
    return rows;
  } catch (err) {
    console.error('Query Error:', err.message);
    console.error('SQL:', sql);
    throw err;
  } finally {
    if (conn) conn.release();
  }
}

/**
 * 트랜잭션 실행 헬퍼
 */
async function transaction(callback) {
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();

    const result = await callback(conn);

    await conn.commit();
    return result;
  } catch (err) {
    if (conn) await conn.rollback();
    console.error('Transaction Error:', err.message);
    throw err;
  } finally {
    if (conn) conn.release();
  }
}

/**
 * 페이지네이션 헬퍼
 */
function paginate(page = 1, limit = 20) {
  const offset = (page - 1) * limit;
  return {
    limit: parseInt(limit),
    offset: parseInt(offset),
    sql: `LIMIT ${parseInt(limit)} OFFSET ${parseInt(offset)}`,
  };
}

/**
 * 연결 풀 종료
 */
async function closePool() {
  try {
    await pool.end();
    console.log('✅ MariaDB 연결 풀 종료');
  } catch (err) {
    console.error('❌ 연결 풀 종료 실패:', err.message);
  }
}

module.exports = {
  pool,
  testConnection,
  query,
  transaction,
  paginate,
  closePool,
};
