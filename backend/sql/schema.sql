-- Fire Safety Inspection Database Schema for MariaDB
-- Created: 2025-11-14

CREATE DATABASE IF NOT EXISTS fire_safety_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE fire_safety_db;

-- ============================================================================
-- 1. buildings 테이블 (건물 정보)
-- ============================================================================
CREATE TABLE IF NOT EXISTS buildings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- 기본 정보
  building_name VARCHAR(255) NOT NULL,
  category VARCHAR(255),

  -- 위치 정보
  region_sido VARCHAR(50) NOT NULL,
  region_sigungu VARCHAR(50) NOT NULL,
  region_dong VARCHAR(50) NOT NULL,
  address_jibun TEXT,
  address_road TEXT,
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),

  -- 건물 상세
  main_usage VARCHAR(100),
  is_apartment CHAR(1) DEFAULT 'N',
  total_area DECIMAL(10, 2),
  household_count INT DEFAULT 0,
  floor_above INT DEFAULT 0,
  floor_below INT DEFAULT 0,
  approval_date VARCHAR(8),  -- YYYYMMDD

  -- 소방 설비
  has_sprinkler CHAR(1) DEFAULT 'N',
  has_smoke_control CHAR(1) DEFAULT 'N',
  has_water_spray CHAR(1) DEFAULT 'N',

  -- 관리 정보
  fire_station VARCHAR(100),
  is_tunnel CHAR(1) DEFAULT 'N',
  grade_level VARCHAR(20),
  requires_self_inspection CHAR(1) DEFAULT 'N',

  -- 메타 정보
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  synced_at TIMESTAMP NULL,
  is_deleted TINYINT(1) DEFAULT 0,

  -- 인덱스
  INDEX idx_region (region_sido, region_sigungu, region_dong),
  INDEX idx_building_name (building_name),
  INDEX idx_fire_station (fire_station),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. users 테이블 (사용자)
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- 기본 정보
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),

  -- 소속
  organization VARCHAR(100),
  fire_station VARCHAR(100),

  -- 권한
  role ENUM('admin', 'inspector', 'viewer') DEFAULT 'inspector',

  -- 메타
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP NULL,
  is_active TINYINT(1) DEFAULT 1,

  INDEX idx_email (email),
  INDEX idx_fire_station (fire_station)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. inspections 테이블 (점검 기록)
-- ============================================================================
CREATE TABLE IF NOT EXISTS inspections (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- 참조
  building_id BIGINT UNSIGNED NOT NULL,
  inspector_id BIGINT UNSIGNED,

  -- 점검 정보
  inspection_type VARCHAR(20) NOT NULL,  -- 정기/수시/특별
  inspection_date DATE NOT NULL,
  started_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,

  -- 점검 결과
  overall_status VARCHAR(20),  -- 정상/불량/보완필요
  notes TEXT,

  -- 상태 관리
  status ENUM('draft', 'completed', 'submitted', 'approved') DEFAULT 'draft',

  -- 메타 정보
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  synced_at TIMESTAMP NULL,
  is_deleted TINYINT(1) DEFAULT 0,

  FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE CASCADE,
  FOREIGN KEY (inspector_id) REFERENCES users(id) ON DELETE SET NULL,

  INDEX idx_building (building_id),
  INDEX idx_inspector (inspector_id),
  INDEX idx_date (inspection_date),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. inspection_items 테이블 (점검 항목)
-- ============================================================================
CREATE TABLE IF NOT EXISTS inspection_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- 참조
  inspection_id BIGINT UNSIGNED NOT NULL,

  -- 점검 항목
  category VARCHAR(50) NOT NULL,  -- 소화기/옥내소화전/자동화재탐지/스프링클러
  item_title VARCHAR(255) NOT NULL,
  item_order INT DEFAULT 0,

  -- 점검 결과
  status ENUM('normal', 'defective', 'not_applicable'),
  memo TEXT,

  -- 메타
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,

  INDEX idx_inspection (inspection_id),
  INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. inspection_photos 테이블 (점검 사진)
-- ============================================================================
CREATE TABLE IF NOT EXISTS inspection_photos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- 참조
  inspection_item_id BIGINT UNSIGNED NOT NULL,

  -- 사진 정보
  file_path VARCHAR(500) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size BIGINT,
  taken_at TIMESTAMP NULL,

  -- 서버 정보
  server_url VARCHAR(500),
  is_uploaded TINYINT(1) DEFAULT 1,  -- 서버는 이미 업로드된 상태

  -- 메타
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (inspection_item_id) REFERENCES inspection_items(id) ON DELETE CASCADE,

  INDEX idx_inspection_item (inspection_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. sync_logs 테이블 (동기화 로그)
-- ============================================================================
CREATE TABLE IF NOT EXISTS sync_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- 동기화 정보
  user_id BIGINT UNSIGNED,
  table_name VARCHAR(50) NOT NULL,
  operation ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  record_id BIGINT UNSIGNED NOT NULL,

  -- 데이터
  data_snapshot JSON,

  -- 상태
  status ENUM('success', 'failed') DEFAULT 'success',
  error_message TEXT,

  -- 메타
  synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,

  INDEX idx_user (user_id),
  INDEX idx_table (table_name),
  INDEX idx_synced_at (synced_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 초기 데이터 삽입
-- ============================================================================

-- 기본 관리자 계정 (비밀번호: admin123 - 나중에 변경 필요)
INSERT INTO users (email, password_hash, name, role, organization)
VALUES (
  'admin@firesafety.kr',
  '$2a$10$8Z5K5yZJYxZKZqZqZqZqZuO5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z5Z',  -- admin123 해시
  '시스템 관리자',
  'admin',
  '소방청'
)
ON DUPLICATE KEY UPDATE id=id;

-- ============================================================================
-- 뷰 생성 (통계 및 조회 최적화)
-- ============================================================================

-- 건물별 최근 점검 정보 뷰
CREATE OR REPLACE VIEW v_buildings_with_last_inspection AS
SELECT
  b.*,
  i.id as last_inspection_id,
  i.inspection_date as last_inspection_date,
  i.overall_status as last_inspection_status,
  u.name as last_inspector_name
FROM buildings b
LEFT JOIN (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY building_id ORDER BY inspection_date DESC) as rn
  FROM inspections
  WHERE is_deleted = 0
) i ON b.id = i.building_id AND i.rn = 1
LEFT JOIN users u ON i.inspector_id = u.id
WHERE b.is_deleted = 0;

-- 점검 통계 뷰
CREATE OR REPLACE VIEW v_inspection_statistics AS
SELECT
  i.id,
  i.building_id,
  i.inspection_date,
  COUNT(ii.id) as total_items,
  SUM(CASE WHEN ii.status = 'normal' THEN 1 ELSE 0 END) as normal_count,
  SUM(CASE WHEN ii.status = 'defective' THEN 1 ELSE 0 END) as defective_count,
  SUM(CASE WHEN ii.status = 'not_applicable' THEN 1 ELSE 0 END) as na_count,
  SUM(CASE WHEN ii.status IS NULL THEN 1 ELSE 0 END) as unchecked_count
FROM inspections i
LEFT JOIN inspection_items ii ON i.id = ii.inspection_id
WHERE i.is_deleted = 0
GROUP BY i.id, i.building_id, i.inspection_date;
