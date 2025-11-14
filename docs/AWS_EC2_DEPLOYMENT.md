# AWS EC2 배포 가이드

소방 안전 점검 앱 백엔드 서버를 AWS EC2에 배포하는 단계별 가이드입니다.

## 📋 목차

1. [사전 준비](#1-사전-준비)
2. [EC2 인스턴스 설정](#2-ec2-인스턴스-설정)
3. [서버 환경 구축](#3-서버-환경-구축)
4. [애플리케이션 배포](#4-애플리케이션-배포)
5. [데이터베이스 설정](#5-데이터베이스-설정)
6. [서버 실행](#6-서버-실행)
7. [Flutter 앱 연결](#7-flutter-앱-연결)
8. [문제 해결](#8-문제-해결)

---

## 1. 사전 준비

### 필요한 정보

- AWS 계정
- EC2 인스턴스 (이미 생성되어 있음)
- SSH 키 파일 (.pem)
- EC2 Public IP 주소

### 로컬에서 준비

```bash
# SSH 키 파일 권한 설정 (macOS/Linux)
chmod 400 your-key.pem

# Windows의 경우
# 파일 우클릭 → 속성 → 보안 → 고급 → 소유자 변경
```

---

## 2. EC2 인스턴스 설정

### 보안 그룹 설정

AWS 콘솔에서 EC2 보안 그룹 인바운드 규칙 추가:

| 타입 | 프로토콜 | 포트 범위 | 소스 | 설명 |
|------|---------|----------|------|------|
| SSH | TCP | 22 | 내 IP | SSH 접속 |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 | Node.js API |
| Custom TCP | TCP | 3306 | 127.0.0.1/32 | MariaDB (로컬만) |

**보안 주의:** 프로덕션 환경에서는 API 포트(3000)도 제한하거나 Nginx를 통해 80/443 포트로 리버스 프록시 설정을 권장합니다.

---

## 3. 서버 환경 구축

### Step 1: EC2에 SSH 접속

```bash
# macOS/Linux
ssh -i your-key.pem ubuntu@ec2-xx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com

# 또는 Public IP 사용
ssh -i your-key.pem ubuntu@13.123.45.67
```

**Windows 사용자:**
```bash
# PowerShell 또는 PuTTY 사용
ssh -i your-key.pem ubuntu@ec2-xx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com
```

### Step 2: 시스템 업데이트

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 3: Node.js 설치

```bash
# Node.js 18.x 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 버전 확인
node --version  # v18.x.x 이상
npm --version   # 9.x.x 이상
```

### Step 4: PM2 설치 (프로세스 관리자)

```bash
sudo npm install -g pm2

# PM2 버전 확인
pm2 --version
```

### Step 5: Git 설치

```bash
sudo apt install -y git

# Git 버전 확인
git --version
```

---

## 4. 애플리케이션 배포

### Step 1: 저장소 클론

```bash
# 홈 디렉토리로 이동
cd ~

# 저장소 클론
git clone https://github.com/saintgo7/app-fire.git

# 프로젝트 디렉토리로 이동
cd app-fire/backend
```

### Step 2: 의존성 설치

```bash
npm install
```

### Step 3: 환경 변수 설정

```bash
# .env 파일 생성
cp .env.example .env

# nano 에디터로 편집
nano .env
```

**.env 파일 내용:**

```env
# 서버 설정
NODE_ENV=production
PORT=3000

# 데이터베이스 설정
DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_safety_user
DB_PASSWORD=your_strong_password_here
DB_NAME=fire_safety_db

# JWT 설정
JWT_SECRET=your_very_long_and_secure_random_string_here

# 파일 업로드 경로
UPLOAD_DIR=./uploads

# CORS 설정
CORS_ORIGIN=*
```

**중요:** JWT_SECRET은 반드시 복잡한 랜덤 문자열로 변경하세요!

**JWT_SECRET 생성 방법:**
```bash
# 랜덤 문자열 생성
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**nano 에디터 사용법:**
- 편집 후 `Ctrl + O` → Enter (저장)
- `Ctrl + X` (종료)

---

## 5. 데이터베이스 설정

### Step 1: MariaDB 설치

```bash
sudo apt install -y mariadb-server

# MariaDB 실행 확인
sudo systemctl status mariadb

# 자동 시작 설정
sudo systemctl enable mariadb
```

### Step 2: MariaDB 보안 설정

```bash
sudo mysql_secure_installation
```

**설정 옵션:**
```
Enter current password for root: (그냥 Enter)
Set root password? Y
New password: your_root_password
Remove anonymous users? Y
Disallow root login remotely? Y
Remove test database? Y
Reload privilege tables? Y
```

### Step 3: 데이터베이스 및 사용자 생성

```bash
# MariaDB 접속
sudo mysql -u root -p
# 위에서 설정한 root 비밀번호 입력
```

**MariaDB 콘솔에서 실행:**

```sql
-- 데이터베이스 생성
CREATE DATABASE fire_safety_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 및 권한 부여
CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'your_strong_password_here';
GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';
FLUSH PRIVILEGES;

-- 확인
SHOW DATABASES;
SELECT User, Host FROM mysql.user;

-- 종료
EXIT;
```

**주의:** `your_strong_password_here`를 실제 강력한 비밀번호로 변경하세요! (`.env` 파일의 DB_PASSWORD와 동일해야 함)

### Step 4: 스키마 생성

```bash
# 백엔드 디렉토리에서
cd ~/app-fire/backend

# 스키마 파일 실행
mysql -u fire_safety_user -p fire_safety_db < sql/schema.sql
# 비밀번호 입력
```

### Step 5: 테이블 확인

```bash
mysql -u fire_safety_user -p fire_safety_db -e "SHOW TABLES;"
```

**예상 출력:**
```
+---------------------------+
| Tables_in_fire_safety_db  |
+---------------------------+
| buildings                 |
| inspection_items          |
| inspection_photos         |
| inspections               |
| sync_logs                 |
| users                     |
+---------------------------+
```

---

## 6. 서버 실행

### 방법 1: 자동 배포 스크립트 사용 (권장)

```bash
cd ~/app-fire/backend

# 스크립트 실행 권한 부여
chmod +x deploy.sh

# 배포 스크립트 실행
./deploy.sh
```

스크립트가 자동으로:
1. Node.js 설치 확인
2. MariaDB 설치 확인
3. npm install 실행
4. PM2로 서버 시작
5. PM2 자동 시작 설정

### 방법 2: 수동 실행

#### 개발 모드 (테스트용)

```bash
cd ~/app-fire/backend
npm start
```

**단점:** SSH 연결이 끊기면 서버도 종료됨

#### 프로덕션 모드 (PM2 사용)

```bash
cd ~/app-fire/backend

# PM2로 서버 시작
pm2 start src/index.js --name fire-safety-api

# 프로세스 확인
pm2 list

# 로그 확인
pm2 logs fire-safety-api

# PM2 자동 시작 설정
pm2 startup
# 출력된 명령어 실행 (sudo로 시작)

pm2 save
```

### 서버 상태 확인

```bash
# PM2 상태 확인
pm2 status

# 로그 실시간 보기
pm2 logs fire-safety-api --lines 50

# 메모리/CPU 사용량 확인
pm2 monit
```

### API 테스트

```bash
# 서버 헬스 체크 (EC2 내부에서)
curl http://localhost:3000/

# 외부에서 접속 테스트 (로컬 PC에서)
curl http://ec2-xx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com:3000/
```

**예상 응답:**
```json
{
  "message": "Fire Safety API Server",
  "version": "1.0.0"
}
```

---

## 7. Flutter 앱 연결

### Step 1: EC2 Public IP 확인

AWS 콘솔 또는 터미널에서:

```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

예시: `13.123.45.67`

### Step 2: Flutter 앱 설정 변경

**lib/core/api/api_client.dart** 파일 수정:

```dart
class ApiClient {
  static final ApiClient instance = ApiClient._init();
  late Dio _dio;

  // 변경 전
  // static const String baseUrl = 'http://localhost:3000';

  // 변경 후 (EC2 Public IP 또는 도메인)
  static const String baseUrl = 'http://13.123.45.67:3000';
  // 또는
  // static const String baseUrl = 'http://ec2-xx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com:3000';
```

### Step 3: 앱 재빌드 및 실행

```bash
cd ~/app-fire  # 로컬 PC에서

# 패키지 재설치
flutter pub get

# 앱 실행
flutter run
```

### Step 4: 회원가입 및 로그인 테스트

1. 앱에서 회원가입
2. 로그인
3. 홈 대시보드에서 동기화 버튼 클릭
4. 네트워크 상태 확인 (초록색 체크)

---

## 8. 문제 해결

### 문제 1: "Connection refused" 오류

**원인:** 서버가 실행되지 않거나 방화벽 차단

**해결:**
```bash
# 서버 상태 확인
pm2 status

# 서버 재시작
pm2 restart fire-safety-api

# 포트 확인
sudo netstat -tlnp | grep 3000

# EC2 보안 그룹 확인
# AWS 콘솔 → EC2 → 보안 그룹 → 인바운드 규칙에 포트 3000 추가
```

### 문제 2: "Database connection failed"

**원인:** MariaDB 연결 실패

**해결:**
```bash
# MariaDB 상태 확인
sudo systemctl status mariadb

# MariaDB 재시작
sudo systemctl restart mariadb

# .env 파일 확인
cat ~/app-fire/backend/.env

# 데이터베이스 접속 테스트
mysql -u fire_safety_user -p fire_safety_db
```

### 문제 3: "Cannot find module" 오류

**원인:** npm 패키지 미설치

**해결:**
```bash
cd ~/app-fire/backend
rm -rf node_modules package-lock.json
npm install
pm2 restart fire-safety-api
```

### 문제 4: PM2가 재부팅 후 자동 시작 안 됨

**해결:**
```bash
pm2 startup
# 출력된 명령어 실행

pm2 save
```

### 문제 5: 앱에서 "Network Error" 발생

**원인:** Flutter 앱이 EC2 서버에 접근 불가

**체크리스트:**
1. EC2 보안 그룹에서 포트 3000 허용 확인
2. Flutter 앱의 baseUrl이 EC2 Public IP로 설정되었는지 확인
3. EC2 서버가 실행 중인지 확인: `pm2 status`
4. 로컬 PC에서 EC2 서버 접근 테스트: `curl http://EC2_IP:3000/`

---

## 🔐 보안 권장사항

### 1. Nginx 리버스 프록시 설정 (권장)

포트 3000을 직접 노출하는 대신 Nginx를 통해 80/443 포트로 서비스:

```bash
sudo apt install -y nginx

# Nginx 설정 파일 생성
sudo nano /etc/nginx/sites-available/fire-safety-api
```

**Nginx 설정:**
```nginx
server {
    listen 80;
    server_name your-domain.com;  # 또는 EC2 Public IP

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
# 설정 활성화
sudo ln -s /etc/nginx/sites-available/fire-safety-api /etc/nginx/sites-enabled/

# Nginx 재시작
sudo systemctl restart nginx
```

이제 Flutter 앱에서 `http://your-ec2-ip` (포트 없이) 사용 가능!

### 2. SSL/TLS 인증서 설정 (HTTPS)

```bash
# Certbot 설치
sudo apt install -y certbot python3-certbot-nginx

# 인증서 발급 (도메인이 있는 경우)
sudo certbot --nginx -d your-domain.com
```

### 3. 환경 변수 보안

```bash
# .env 파일 권한 제한
chmod 600 ~/app-fire/backend/.env
```

### 4. 방화벽 설정

```bash
# UFW 방화벽 활성화
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw enable

# 상태 확인
sudo ufw status
```

---

## 📊 모니터링

### PM2 모니터링

```bash
# 실시간 모니터링
pm2 monit

# 프로세스 정보
pm2 show fire-safety-api

# 로그 확인
pm2 logs fire-safety-api --lines 100
```

### 시스템 리소스 확인

```bash
# 메모리 사용량
free -h

# 디스크 사용량
df -h

# CPU 사용량
top
```

---

## 🔄 업데이트 배포

코드 변경 후 서버에 반영:

```bash
# EC2에 SSH 접속
ssh -i your-key.pem ubuntu@ec2-xx-xxx-xxx-xxx.ap-northeast-1.compute.amazonaws.com

# 프로젝트 디렉토리로 이동
cd ~/app-fire

# 최신 코드 가져오기
git pull origin main

# 백엔드 디렉토리로 이동
cd backend

# 의존성 업데이트
npm install

# 서버 재시작
pm2 restart fire-safety-api

# 로그 확인
pm2 logs fire-safety-api
```

---

## 📝 요약 체크리스트

### EC2 서버 설정
- [ ] EC2 보안 그룹에 포트 22, 3000 추가
- [ ] SSH 접속 성공
- [ ] Node.js 18+ 설치
- [ ] PM2 설치
- [ ] Git 설치

### 애플리케이션 배포
- [ ] 저장소 클론
- [ ] npm install 완료
- [ ] .env 파일 설정 (JWT_SECRET, DB 비밀번호)

### 데이터베이스 설정
- [ ] MariaDB 설치
- [ ] 데이터베이스 및 사용자 생성
- [ ] 스키마 생성 완료
- [ ] 테이블 확인 (6개)

### 서버 실행
- [ ] PM2로 서버 시작
- [ ] PM2 자동 시작 설정
- [ ] API 테스트 성공 (curl로 확인)

### Flutter 앱 연결
- [ ] EC2 Public IP 확인
- [ ] Flutter 앱 baseUrl 변경
- [ ] 앱에서 회원가입/로그인 성공
- [ ] 동기화 테스트 성공

---

## 🎉 배포 완료!

축하합니다! AWS EC2에서 소방 안전 점검 앱 백엔드 서버가 성공적으로 실행되고 있습니다.

**다음 단계:**
1. 도메인 연결 (선택)
2. HTTPS 설정 (권장)
3. 데이터베이스 백업 자동화
4. 모니터링 설정 (CloudWatch 등)

---

**작성일:** 2025-01-14
**최종 업데이트:** 2025-01-14
