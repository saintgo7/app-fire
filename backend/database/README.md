# 데이터베이스 관리 가이드

Fire Safety Inspector 데이터베이스 관리를 위한 스크립트 및 사용법 안내

## 📋 목차

- [스크립트 개요](#스크립트-개요)
- [사전 준비](#사전-준비)
- [데이터베이스 초기화](#데이터베이스-초기화)
- [백업 및 복원](#백업-및-복원)
- [마이그레이션](#마이그레이션)
- [문제 해결](#문제-해결)

---

## 스크립트 개요

### 사용 가능한 스크립트

| 스크립트 | 설명 | 사용 시기 |
|---------|------|-----------|
| `init-db.sh` | 데이터베이스 초기화 | 최초 설치 또는 완전 초기화 필요 시 |
| `backup.sh` | 데이터베이스 백업 | 정기적인 백업 (일일/주간 권장) |
| `restore.sh` | 데이터베이스 복원 | 백업 파일로 복원 필요 시 |

### 파일 구조

```
database/
├── schema.sql              # 데이터베이스 스키마 정의
├── seed.sql                # 초기 데이터 (법령 정보, 테스트 데이터)
├── init-db.sh              # 초기화 스크립트
├── backup.sh               # 백업 스크립트
├── restore.sh              # 복원 스크립트
├── migrations/             # 마이그레이션 파일
│   └── 001_create_initial_tables.sql
├── backups/                # 백업 파일 저장 (자동 생성)
└── README.md               # 이 파일
```

---

## 사전 준비

### 1. MariaDB 설치

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

#### macOS (Homebrew)
```bash
brew install mariadb
brew services start mariadb
```

### 2. 보안 설정
```bash
sudo mysql_secure_installation
```

### 3. 데이터베이스 사용자 생성

MariaDB에 로그인:
```bash
mysql -u root -p
```

사용자 생성 및 권한 부여:
```sql
CREATE USER 'fire_inspector'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON fire_safety_inspector.* TO 'fire_inspector'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. 환경 변수 설정

`backend/.env` 파일 생성:
```bash
cd ../
cp .env.example .env
```

`.env` 파일 편집하여 데이터베이스 정보 입력:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_inspector
DB_PASSWORD=your_secure_password
DB_NAME=fire_safety_inspector
```

### 5. 스크립트 실행 권한 부여

```bash
chmod +x init-db.sh backup.sh restore.sh
```

---

## 데이터베이스 초기화

### 전체 초기화 (최초 설치)

```bash
./init-db.sh
```

이 스크립트는 다음 작업을 수행합니다:

1. ⚠️ **기존 데이터베이스 삭제** (확인 메시지 표시)
2. 새로운 데이터베이스 생성
3. 테이블 스키마 생성 (`schema.sql`)
4. 초기 데이터 삽입 (`seed.sql`)
5. 테이블 목록 표시

### 실행 예시

```bash
$ ./init-db.sh

================================================
Fire Safety Inspector DB 초기화
================================================

데이터베이스 설정:
  Host: localhost
  Port: 3306
  Database: fire_safety_inspector
  User: fire_inspector

경고: 기존 데이터베이스가 삭제됩니다. 계속하시겠습니까? [y/N]: y

[1/4] 데이터베이스 삭제 및 재생성...
✓ 데이터베이스 생성 완료

[2/4] 테이블 스키마 생성...
✓ 테이블 생성 완료

[3/4] Seed 데이터 삽입...
✓ Seed 데이터 삽입 완료

[4/4] 테이블 확인...
✓ 총 9개의 테이블이 생성되었습니다.

생성된 테이블:
+----------------------------+
| Tables_in_fire_safety_inspector |
+----------------------------+
| buildings                  |
| checklist_items            |
| inspection_photos          |
| inspections                |
| legal_regulations          |
| notifications              |
| reports                    |
| schedules                  |
| users                      |
+----------------------------+

================================================
데이터베이스 초기화 완료!
================================================
```

---

## 백업 및 복원

### 백업 생성

```bash
./backup.sh
```

**특징**:
- 자동으로 날짜-시간 형식의 파일명 생성
- gzip으로 압축하여 저장
- 30일 이상 된 백업 파일 자동 삭제
- `backups/` 디렉토리에 저장

### 백업 예시

```bash
$ ./backup.sh

================================================
Fire Safety Inspector DB 백업
================================================

데이터베이스 백업 중...
파일: ./backups/fire_safety_inspector_20250110_143022.sql

✓ 백업 완료!
  파일: ./backups/fire_safety_inspector_20250110_143022.sql.gz
  크기: 15K

오래된 백업 파일 정리 중...
✓ 현재 5개의 백업 파일이 있습니다.

================================================
백업 완료!
================================================
```

### 데이터베이스 복원

```bash
./restore.sh
```

**프로세스**:
1. 사용 가능한 백업 파일 목록 표시
2. 복원할 파일 선택
3. 확인 후 복원 실행

### 복원 예시

```bash
$ ./restore.sh

================================================
Fire Safety Inspector DB 복원
================================================

사용 가능한 백업 파일:

  [1] fire_safety_inspector_20250110_143022.sql.gz (2025-01-10 14:30:22, 15K)
  [2] fire_safety_inspector_20250109_100000.sql.gz (2025-01-09 10:00:00, 12K)
  [3] fire_safety_inspector_20250108_100000.sql.gz (2025-01-08 10:00:00, 10K)

복원할 백업 파일 번호를 선택하세요: 1

선택한 파일: fire_safety_inspector_20250110_143022.sql.gz

경고: 현재 데이터베이스의 모든 데이터가 삭제되고 백업 데이터로 복원됩니다!
계속하시겠습니까? [y/N]: y

데이터베이스 복원 중...

✓ 복원 완료!

  테이블 개수: 9
  사용자: 3명
  점검 기록: 2건

================================================
복원 완료!
================================================
```

---

## 마이그레이션

### 마이그레이션 파일 생성

새로운 마이그레이션 파일을 `migrations/` 디렉토리에 생성:

```sql
-- migrations/002_add_user_settings.sql
-- Migration 002: Add user settings table
-- Created: 2025-01-11

CREATE TABLE user_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_setting (user_id, setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 마이그레이션 실행

```bash
mysql -u fire_inspector -p fire_safety_inspector < migrations/002_add_user_settings.sql
```

---

## 데이터베이스 구조

### 주요 테이블

#### users
사용자 정보 (소셜 로그인 통합)
- uid, email, display_name
- login_provider (google, kakao, naver)

#### buildings
건물 정보
- name, address, building_type
- latitude, longitude (지도 좌표)

#### inspections
점검 기록
- inspection_date, inspector_name
- status (in_progress, completed, submitted)
- overall_result (pass, fail, conditional_pass)

#### checklist_items
체크리스트 항목
- category, title, description
- status (normal, defective, not_applicable)
- memo, order_index

#### inspection_photos
점검 사진
- photo_url, thumbnail_url
- caption, file_size

#### schedules
점검 일정
- scheduled_date, scheduled_time
- reminder_enabled

#### legal_regulations
법령 정보
- title, category, content
- law_reference, effective_date

#### notifications
알림
- title, message, notification_type
- is_read, related_id, related_type

#### reports
보고서
- report_type, file_url
- generated_at

---

## 문제 해결

### 권한 오류

```
ERROR 1045 (28000): Access denied for user
```

**해결책**:
- `.env` 파일의 DB_USER와 DB_PASSWORD 확인
- MariaDB 사용자 권한 재설정

```sql
GRANT ALL PRIVILEGES ON fire_safety_inspector.* TO 'fire_inspector'@'localhost';
FLUSH PRIVILEGES;
```

### 연결 오류

```
ERROR 2002 (HY000): Can't connect to local MySQL server
```

**해결책**:
- MariaDB 서비스 실행 확인
```bash
sudo systemctl status mariadb
sudo systemctl start mariadb
```

### 스크립트 실행 권한 오류

```
Permission denied
```

**해결책**:
```bash
chmod +x init-db.sh backup.sh restore.sh
```

### 백업 파일이 너무 큼

**해결책**:
- 압축 파일(`.gz`)이 자동으로 생성됨
- 오래된 백업 파일 수동 삭제:
```bash
rm backups/old_backup_file.sql.gz
```

---

## 정기 유지보수

### 일일 백업 설정 (Cron)

```bash
# crontab -e 편집
0 2 * * * cd /path/to/backend/database && ./backup.sh
```

매일 새벽 2시에 자동 백업

### 주간 최적화

```sql
-- 테이블 최적화
OPTIMIZE TABLE users, buildings, inspections, checklist_items;

-- 인덱스 재구성
ANALYZE TABLE users, buildings, inspections, checklist_items;
```

### 디스크 공간 확인

```bash
# 데이터베이스 크기 확인
mysql -u fire_inspector -p -e "
SELECT table_schema AS 'Database',
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'fire_safety_inspector'
GROUP BY table_schema;
"
```

---

## 추가 리소스

- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [MySQL Backup Best Practices](https://dev.mysql.com/doc/refman/8.0/en/backup-and-recovery.html)
- [프로젝트 메인 README](../../README.md)
- [백엔드 설정 가이드](../../MARIADB_BACKEND_SETUP.md)

---

## 지원

문제가 발생하면 다음을 확인하세요:
1. `.env` 파일 설정
2. MariaDB 서비스 실행 상태
3. 사용자 권한
4. 로그 파일 (`/var/log/mysql/error.log`)
