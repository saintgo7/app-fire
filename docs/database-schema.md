# Database Schema Design

## 📋 개요
소방 안전 점검 앱을 위한 통합 데이터베이스 스키마

## 🗄️ 테이블 구조

### 1. buildings (건물 정보)
소방 점검 대상 건물 마스터 데이터

```sql
CREATE TABLE buildings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 기본 정보
  building_name TEXT NOT NULL,              -- 대상물명
  category TEXT,                            -- 대상물_구분명_참고

  -- 위치 정보
  region_sido TEXT NOT NULL,                -- 시/도 (예: 서울특별시)
  region_sigungu TEXT NOT NULL,             -- 시/군/구 (예: 도봉구)
  region_dong TEXT NOT NULL,                -- 동 (예: 방학동)
  address_jibun TEXT,                       -- 주소(지번)
  address_road TEXT,                        -- 주소(도로명)
  latitude REAL,                            -- 위도 (나중에 geocoding)
  longitude REAL,                           -- 경도

  -- 건물 상세
  main_usage TEXT,                          -- 주용도명
  is_apartment TEXT DEFAULT 'N',            -- 아파트여부 (Y/N)
  total_area REAL,                          -- 연면적(㎡)
  household_count INTEGER DEFAULT 0,        -- 세대수
  floor_above INTEGER DEFAULT 0,            -- 지상층수
  floor_below INTEGER DEFAULT 0,            -- 지하층수
  approval_date TEXT,                       -- 사용승인일 (YYYYMMDD)

  -- 소방 설비
  has_sprinkler TEXT DEFAULT 'N',           -- 스프링클러 (Y/N)
  has_smoke_control TEXT DEFAULT 'N',       -- 제연설비 (Y/N)
  has_water_spray TEXT DEFAULT 'N',         -- 물분무등 (Y/N)

  -- 관리 정보
  fire_station TEXT,                        -- 관할소방서
  is_tunnel TEXT DEFAULT 'N',               -- 터널여부 (Y/N)
  grade_level TEXT,                         -- 등급대상 (1급/2급/3급)
  requires_self_inspection TEXT DEFAULT 'N',-- 자체점검여부 (Y/N)

  -- 메타 정보
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT,                           -- 서버 동기화 시간
  is_deleted INTEGER DEFAULT 0              -- soft delete
);

-- 인덱스
CREATE INDEX idx_buildings_region ON buildings(region_sido, region_sigungu, region_dong);
CREATE INDEX idx_buildings_name ON buildings(building_name);
CREATE INDEX idx_buildings_fire_station ON buildings(fire_station);
```

### 2. inspections (점검 기록)
실제 점검 작업 데이터

```sql
CREATE TABLE inspections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 참조
  building_id INTEGER NOT NULL,             -- buildings.id
  inspector_id INTEGER,                     -- 점검자 ID (나중에 users 테이블 연결)

  -- 점검 정보
  inspection_type TEXT NOT NULL,            -- 점검 구분 (정기/수시/특별)
  inspection_date TEXT NOT NULL,            -- 점검일자 (YYYY-MM-DD)
  started_at TEXT,                          -- 점검 시작 시간
  completed_at TEXT,                        -- 점검 완료 시간

  -- 점검 결과
  overall_status TEXT,                      -- 종합 상태 (정상/불량/보완필요)
  notes TEXT,                               -- 종합 소견

  -- 상태 관리
  status TEXT DEFAULT 'draft',              -- draft/completed/submitted/approved

  -- 메타 정보
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT,
  is_deleted INTEGER DEFAULT 0,

  FOREIGN KEY (building_id) REFERENCES buildings(id)
);

CREATE INDEX idx_inspections_building ON inspections(building_id);
CREATE INDEX idx_inspections_date ON inspections(inspection_date);
CREATE INDEX idx_inspections_status ON inspections(status);
```

### 3. inspection_items (점검 항목 체크리스트)
각 점검의 세부 항목

```sql
CREATE TABLE inspection_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 참조
  inspection_id INTEGER NOT NULL,           -- inspections.id

  -- 점검 항목
  category TEXT NOT NULL,                   -- 카테고리 (소화기/옥내소화전/자동화재탐지/스프링클러)
  item_title TEXT NOT NULL,                 -- 점검 항목명
  item_order INTEGER DEFAULT 0,             -- 표시 순서

  -- 점검 결과
  status TEXT,                              -- normal/defective/not_applicable
  memo TEXT,                                -- 메모

  -- 메타
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE
);

CREATE INDEX idx_inspection_items_inspection ON inspection_items(inspection_id);
```

### 4. inspection_photos (점검 사진)
점검 항목별 사진

```sql
CREATE TABLE inspection_photos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 참조
  inspection_item_id INTEGER NOT NULL,      -- inspection_items.id

  -- 사진 정보
  file_path TEXT NOT NULL,                  -- 로컬 파일 경로
  file_name TEXT NOT NULL,                  -- 파일명
  file_size INTEGER,                        -- 파일 크기 (bytes)
  taken_at TEXT,                            -- 촬영 시간

  -- 서버 정보
  server_url TEXT,                          -- 서버 업로드 후 URL
  is_uploaded INTEGER DEFAULT 0,            -- 업로드 여부

  -- 메타
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (inspection_item_id) REFERENCES inspection_items(id) ON DELETE CASCADE
);

CREATE INDEX idx_inspection_photos_item ON inspection_photos(inspection_item_id);
```

### 5. users (사용자 - 간단 버전)
점검자 정보

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 기본 정보
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,

  -- 소속
  organization TEXT,                        -- 소속 기관
  fire_station TEXT,                        -- 담당 소방서

  -- 인증 (로컬에는 토큰만 저장)
  auth_token TEXT,
  refresh_token TEXT,

  -- 메타
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  last_login_at TEXT
);
```

### 6. sync_queue (동기화 큐)
오프라인 작업 내역 추적

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- 동기화 정보
  table_name TEXT NOT NULL,                 -- 대상 테이블
  record_id INTEGER NOT NULL,               -- 레코드 ID
  operation TEXT NOT NULL,                  -- INSERT/UPDATE/DELETE
  data TEXT,                                -- JSON 데이터

  -- 상태
  status TEXT DEFAULT 'pending',            -- pending/synced/failed
  retry_count INTEGER DEFAULT 0,
  error_message TEXT,

  -- 메타
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT
);

CREATE INDEX idx_sync_queue_status ON sync_queue(status);
```

## 🔄 데이터 플로우

### 1. 건물 데이터 (초기 로드)
```
SQL 파일 (지역별)
  → Python 스크립트로 통합
  → MariaDB에 import
  → API 통해 앱에서 다운로드 (지역별/소방서별)
  → SQLite에 저장
```

### 2. 점검 작업
```
앱에서 점검 수행
  → SQLite에 저장 (오프라인)
  → sync_queue에 기록
  → 온라인 시 API로 전송
  → MariaDB에 저장
  → 다른 기기에서도 조회 가능
```

## 📝 마이그레이션 전략

### Flutter (SQLite)
- sqflite 패키지 사용
- 버전 관리로 스키마 마이그레이션
- 초기 데이터는 assets 또는 API에서 다운로드

### Node.js (MariaDB)
- Sequelize ORM 사용
- Migration 파일로 버전 관리
- SQL 파일을 통합하여 초기 데이터 import

## 🌍 지역 데이터 통합 전략

기존: `buildings_seoul_dobong_gu_banghagdong` (테이블 수백 개)
개선: `buildings` 테이블 하나 + region 컬럼으로 필터링

**장점:**
- 간단한 쿼리
- 관리 용이
- 인덱스 효율적
- 전국 데이터 통합 가능
