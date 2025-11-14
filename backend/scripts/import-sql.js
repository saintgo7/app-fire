#!/usr/bin/env node

/**
 * SQL 파일 import 스크립트
 *
 * 사용법:
 * node scripts/import-sql.js <sql-directory>
 *
 * 예시:
 * node scripts/import-sql.js ./sql-data/seoul
 */

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { pool, testConnection } = require('../src/config/database');

/**
 * SQL 파일에서 지역 정보 추출
 * 예: buildings_seoul_dobong_gu_banghagdong -> { sido: '서울특별시', sigungu: '도봉구', dong: '방학동' }
 */
function extractRegionFromTableName(tableName) {
  // buildings_seoul_dobong_gu_banghagdong 패턴
  const match = tableName.match(/buildings_(.+)_(.+)_gu_(.+)/);

  if (match) {
    const [, city, district, dong] = match;

    // 영문 -> 한글 변환 (예시)
    const cityMap = {
      seoul: '서울특별시',
      busan: '부산광역시',
      // ... 더 추가
    };

    const sido = cityMap[city] || city;
    const sigungu = district.replace(/_/g, '') + '구';
    const dongName = dong.replace(/_/g, '').replace(/dong$/, '동');

    return { sido, sigungu, dong: dongName };
  }

  return null;
}

/**
 * SQL 파일 파싱 및 INSERT 문 추출
 */
function parseSqlFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');

  // 테이블명 추출 (주석에서)
  const tableNameMatch = content.match(/Table: (buildings_\w+)/);
  const tableName = tableNameMatch ? tableNameMatch[1] : null;

  // 지역 정보 추출
  const region = tableName ? extractRegionFromTableName(tableName) : null;

  // INSERT 문 추출
  const insertMatches = content.match(/INSERT INTO .+? VALUES \(.+?\);/gs);

  return {
    tableName,
    region,
    inserts: insertMatches || [],
  };
}

/**
 * INSERT 문을 통합 테이블용으로 변환
 */
function transformInsertStatement(insertSql, region) {
  if (!region) return null;

  // 기존: INSERT INTO buildings_seoul_dobong_gu_banghagdong (대상물_구분명_참고, ...) VALUES (...)
  // 새로: INSERT INTO buildings (region_sido, region_sigungu, region_dong, building_name, ...) VALUES (...)

  // VALUES 부분 추출
  const valuesMatch = insertSql.match(/VALUES\s*\((.+)\);/s);
  if (!valuesMatch) return null;

  const values = valuesMatch[1];

  // 값 파싱 (간단 버전 - 실제로는 더 정교한 파서 필요)
  const valuesParts = values.split(',').map(v => v.trim());

  // 새로운 INSERT 문 생성
  const newInsert = `INSERT INTO buildings (
    region_sido, region_sigungu, region_dong,
    category, building_name, address_jibun, address_road,
    main_usage, is_apartment, total_area, household_count,
    has_sprinkler, has_smoke_control, has_water_spray,
    fire_station, approval_date, is_tunnel, grade_level,
    floor_above, floor_below, requires_self_inspection
  ) VALUES (
    '${region.sido}', '${region.sigungu}', '${region.dong}',
    ${valuesParts.slice(0, 18).join(', ')}
  );`;

  return newInsert;
}

/**
 * 디렉토리의 모든 SQL 파일 처리
 */
async function importSqlDirectory(dirPath) {
  const files = fs.readdirSync(dirPath).filter(f => f.endsWith('.sql'));

  console.log(`\n📁 디렉토리: ${dirPath}`);
  console.log(`📄 SQL 파일: ${files.length}개 발견\n`);

  let totalInserted = 0;
  let totalFailed = 0;

  for (const file of files) {
    const filePath = path.join(dirPath, file);
    console.log(`📝 처리 중: ${file}`);

    try {
      const { tableName, region, inserts } = parseSqlFile(filePath);

      if (!region) {
        console.log(`   ⚠️  지역 정보를 추출할 수 없습니다. 건너뜁니다.`);
        continue;
      }

      console.log(`   지역: ${region.sido} ${region.sigungu} ${region.dong}`);
      console.log(`   INSERT 문: ${inserts.length}개`);

      let conn;
      try {
        conn = await pool.getConnection();

        for (const insertSql of inserts) {
          try {
            const transformedSql = transformInsertStatement(insertSql, region);
            if (transformedSql) {
              await conn.query(transformedSql);
              totalInserted++;
            }
          } catch (err) {
            // 중복 키 등의 에러는 무시
            if (err.code !== 'ER_DUP_ENTRY') {
              console.log(`   ❌ INSERT 실패: ${err.message}`);
              totalFailed++;
            }
          }
        }

        console.log(`   ✅ 완료 (${inserts.length}개 처리)\n`);
      } finally {
        if (conn) conn.release();
      }
    } catch (err) {
      console.log(`   ❌ 파일 처리 실패: ${err.message}\n`);
      totalFailed++;
    }
  }

  console.log('\n=====================================');
  console.log(`✅ Import 완료`);
  console.log(`   성공: ${totalInserted}개`);
  console.log(`   실패: ${totalFailed}개`);
  console.log('=====================================\n');
}

/**
 * 메인 실행
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.error('사용법: node scripts/import-sql.js <sql-directory>');
    console.error('예시: node scripts/import-sql.js ./sql-data/seoul');
    process.exit(1);
  }

  const sqlDir = args[0];

  if (!fs.existsSync(sqlDir)) {
    console.error(`❌ 디렉토리를 찾을 수 없습니다: ${sqlDir}`);
    process.exit(1);
  }

  console.log('\n🔥 Fire Safety SQL Import Tool');
  console.log('=====================================\n');

  // DB 연결 테스트
  const connected = await testConnection();
  if (!connected) {
    console.error('❌ 데이터베이스 연결 실패');
    process.exit(1);
  }

  // SQL 파일 import
  await importSqlDirectory(sqlDir);

  // 연결 종료
  await pool.end();
  process.exit(0);
}

// 실행
main().catch((err) => {
  console.error('❌ 에러 발생:', err);
  process.exit(1);
});
