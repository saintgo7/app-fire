# Fire Safety Inspection Backend API

소방 안전 점검 앱을 위한 Node.js + Express + MariaDB 백엔드 API 서버

## 📋 목차

- [기술 스택](#기술-스택)
- [시작하기](#시작하기)
- [환경 설정](#환경-설정)
- [데이터베이스 설정](#데이터베이스-설정)
- [API 엔드포인트](#api-엔드포인트)
- [배포 (AWS EC2)](#배포-aws-ec2)

## 🛠 기술 스택

- **Runtime**: Node.js >= 18.0.0
- **Framework**: Express.js 4.x
- **Database**: MariaDB 10.x
- **ORM**: Native MariaDB Driver
- **Security**: Helmet, CORS
- **Development**: Nodemon

## 🚀 시작하기

### 로컬 개발 환경

```bash
# 의존성 설치
npm install

# 환경변수 설정
cp .env.example .env
# .env 파일을 편집하여 데이터베이스 정보 입력

# 데이터베이스 스키마 생성
mysql -u root -p < sql/schema.sql

# 개발 서버 시작
npm run dev

# 또는 프로덕션 모드
npm start
```

서버가 `http://localhost:3000` 에서 시작됩니다.

## ⚙️ 환경 설정

`.env` 파일 예시:

```env
# Server
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_safety_user
DB_PASSWORD=your_secure_password
DB_NAME=fire_safety_db
DB_CONNECTION_LIMIT=10

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=*
```

## 🗄️ 데이터베이스 설정

### 1. MariaDB 설치 (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install mariadb-server
sudo mysql_secure_installation
```

### 2. 데이터베이스 및 사용자 생성

```sql
-- MariaDB에 root로 로그인
sudo mysql -u root -p

-- 데이터베이스 생성
CREATE DATABASE fire_safety_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 및 권한 부여
CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';
FLUSH PRIVILEGES;

EXIT;
```

### 3. 스키마 생성

```bash
mysql -u fire_safety_user -p fire_safety_db < sql/schema.sql
```

### 4. SQL 데이터 Import (지역별 건물 데이터)

```bash
# SQL 파일이 있는 디렉토리 지정
node scripts/import-sql.js /path/to/eng_sql/seoul/dobong-gu

# 여러 지역을 순차적으로 import
node scripts/import-sql.js /path/to/eng_sql/seoul/gangnam-gu
node scripts/import-sql.js /path/to/eng_sql/busan/haeundae-gu
```

## 📡 API 엔드포인트

### 인증

```
POST   /api/auth/login       - 로그인
POST   /api/auth/register    - 회원가입
```

### 건물

```
GET    /api/buildings              - 건물 목록 (페이지네이션, 필터링)
GET    /api/buildings/:id          - 건물 상세
POST   /api/buildings              - 건물 등록
PUT    /api/buildings/:id          - 건물 수정
DELETE /api/buildings/:id          - 건물 삭제
GET    /api/buildings/regions/sidos     - 시/도 목록
GET    /api/buildings/regions/sigungus  - 시/군/구 목록
```

### 점검

```
GET    /api/inspections            - 점검 목록
GET    /api/inspections/:id        - 점검 상세 (항목 포함)
POST   /api/inspections            - 점검 생성
PUT    /api/inspections/:id        - 점검 수정
PUT    /api/inspections/:id/complete    - 점검 완료
DELETE /api/inspections/:id        - 점검 삭제
PUT    /api/inspections/:id/items/:itemId  - 점검 항목 수정
GET    /api/inspections/:id/statistics    - 점검 통계
```

### 동기화

```
POST   /api/sync/inspections       - 앱에서 점검 데이터 동기화
GET    /api/sync/buildings         - 앱으로 건물 데이터 다운로드
```

### 사용자

```
GET    /api/users                  - 사용자 목록
GET    /api/users/:id              - 사용자 상세
```

### 예시 요청

```bash
# 건물 목록 조회 (서울 도봉구)
curl "http://localhost:3000/api/buildings?sido=서울특별시&sigungu=도봉구&page=1&limit=20"

# 점검 생성
curl -X POST http://localhost:3000/api/inspections \
  -H "Content-Type: application/json" \
  -d '{
    "building_id": 1,
    "inspector_id": 1,
    "inspection_type": "정기",
    "inspection_date": "2025-11-14",
    "items": [
      {
        "category": "소화기",
        "item_title": "소화기: 위치 표시",
        "status": "normal"
      }
    ]
  }'

# 헬스체크
curl http://localhost:3000/health
```

## 🚀 배포 (AWS EC2)

### 1. EC2 인스턴스 접속

```bash
ssh -i your-key.pem ubuntu@ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com
```

### 2. Node.js 설치

```bash
# Node.js 18.x 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 버전 확인
node -v
npm -v
```

### 3. MariaDB 설치 및 설정

```bash
sudo apt update
sudo apt install -y mariadb-server
sudo mysql_secure_installation

# MariaDB 시작
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### 4. 프로젝트 배포

```bash
# Git clone
git clone https://github.com/saintgo7/app-fire.git
cd app-fire/backend

# 의존성 설치
npm install

# 환경변수 설정
cp .env.example .env
nano .env  # DB 정보 입력

# 데이터베이스 스키마 생성
mysql -u fire_safety_user -p fire_safety_db < sql/schema.sql

# PM2로 서버 실행
sudo npm install -g pm2
pm2 start src/index.js --name fire-safety-api
pm2 save
pm2 startup
```

### 5. Nginx 리버스 프록시 설정 (선택사항)

```bash
sudo apt install -y nginx

# Nginx 설정 파일 생성
sudo nano /etc/nginx/sites-available/fire-safety-api
```

설정 파일 내용:

```nginx
server {
    listen 80;
    server_name ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```bash
# 심볼릭 링크 생성 및 Nginx 재시작
sudo ln -s /etc/nginx/sites-available/fire-safety-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6. 방화벽 설정

```bash
# EC2 Security Group에서 포트 열기
# - Inbound: 80 (HTTP), 443 (HTTPS), 3000 (API - 개발용)
```

### 7. SQL 데이터 Import

```bash
# 로컬에서 EC2로 SQL 파일 복사
scp -i your-key.pem -r /path/to/eng_sql ubuntu@ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com:~/

# EC2에서 import
cd ~/app-fire/backend
node scripts/import-sql.js ~/eng_sql/seoul/dobong-gu
```

### 8. 서버 상태 확인

```bash
# PM2 프로세스 상태
pm2 status
pm2 logs fire-safety-api

# API 테스트
curl http://localhost:3000/health
```

## 📝 개발 가이드

### 로그 확인

```bash
# PM2 로그
pm2 logs fire-safety-api

# 실시간 로그
pm2 logs fire-safety-api --lines 100
```

### 서버 재시작

```bash
# 코드 변경 후 재시작
pm2 restart fire-safety-api

# 또는 reload (무중단 재시작)
pm2 reload fire-safety-api
```

### 데이터베이스 백업

```bash
# 백업
mysqldump -u fire_safety_user -p fire_safety_db > backup_$(date +%Y%m%d).sql

# 복원
mysql -u fire_safety_user -p fire_safety_db < backup_20251114.sql
```

## 🔧 트러블슈팅

### 데이터베이스 연결 실패

```bash
# MariaDB 상태 확인
sudo systemctl status mariadb

# 연결 테스트
mysql -u fire_safety_user -p -h localhost
```

### 포트 사용 중 에러

```bash
# 포트 사용 프로세스 확인
sudo lsof -i :3000

# 프로세스 종료
sudo kill -9 <PID>
```

## 📄 라이선스

MIT

## 👥 문의

이슈는 GitHub Issues에 등록해주세요.
