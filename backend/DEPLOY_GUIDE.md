# 🚀 EC2 배포 가이드

AWS EC2에 Fire Safety Backend API를 배포하는 완전한 가이드입니다.

## 📋 사전 준비

### 1. EC2 인스턴스 정보
- **주소**: `ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com`
- **OS**: Ubuntu 20.04 LTS 이상
- **최소 사양**: t2.small (2GB RAM)

### 2. 로컬에서 준비할 것
- SSH 키 파일 (`.pem`)
- SQL 데이터 파일 (선택사항)

---

## 🔧 자동 배포 (권장)

### 1단계: EC2 접속

```bash
ssh -i your-key.pem ubuntu@ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com
```

### 2단계: 배포 스크립트 다운로드 및 실행

```bash
# Git clone
git clone https://github.com/saintgo7/app-fire.git
cd app-fire/backend

# 배포 스크립트 실행
chmod +x deploy.sh
./deploy.sh
```

스크립트가 자동으로:
- ✅ Node.js 설치
- ✅ MariaDB 설치
- ✅ 프로젝트 클론
- ✅ 의존성 설치
- ✅ 환경변수 설정
- ✅ 데이터베이스 생성 가이드
- ✅ PM2로 서버 시작
- ✅ Nginx 설정 (선택)

---

## 🛠 수동 배포

### 1. Node.js 설치

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v  # 확인
```

### 2. MariaDB 설치 및 설정

```bash
sudo apt install -y mariadb-server
sudo mysql_secure_installation

# 데이터베이스 생성
sudo mysql -u root -p
```

MySQL에서 실행:
```sql
CREATE DATABASE fire_safety_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. 프로젝트 설정

```bash
# Git clone
cd ~
git clone https://github.com/saintgo7/app-fire.git
cd app-fire/backend

# 의존성 설치
npm install

# 환경변수 설정
cp .env.example .env
nano .env
```

`.env` 파일 수정:
```env
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_safety_user
DB_PASSWORD=your_secure_password  # 위에서 설정한 비밀번호
DB_NAME=fire_safety_db

JWT_SECRET=랜덤한_긴_문자열_여기에_입력  # 보안을 위해 반드시 변경!
JWT_EXPIRES_IN=7d

CORS_ORIGIN=*
```

### 4. 데이터베이스 스키마 생성

```bash
mysql -u fire_safety_user -p fire_safety_db < sql/schema.sql
```

### 5. PM2로 서버 시작

```bash
# PM2 설치
sudo npm install -g pm2

# 서버 시작
pm2 start src/index.js --name fire-safety-api

# PM2 저장 및 부팅 시 자동 시작
pm2 save
pm2 startup
```

---

## 📥 SQL 데이터 Import

### 로컬에서 EC2로 파일 전송

```bash
# Windows에서 (PowerShell/CMD)
scp -i your-key.pem -r "G:\내 드라이브\20-app-fire\eng_sql" ubuntu@ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com:~/
```

### EC2에서 Import 실행

```bash
cd ~/app-fire/backend
node scripts/import-sql.js ~/eng_sql
```

---

## 🌐 Nginx 설정 (선택사항)

Nginx를 리버스 프록시로 사용하여 80 포트로 서비스:

```bash
sudo apt install -y nginx

# 설정 파일 생성
sudo nano /etc/nginx/sites-available/fire-safety-api
```

내용:
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
# 활성화
sudo ln -s /etc/nginx/sites-available/fire-safety-api /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Nginx 테스트 및 재시작
sudo nginx -t
sudo systemctl restart nginx
```

---

## 🔒 보안 그룹 설정 (AWS Console)

EC2 인스턴스의 Security Group에서 다음 포트 열기:

| Type  | Port | Source    | Description |
|-------|------|-----------|-------------|
| HTTP  | 80   | 0.0.0.0/0 | Nginx       |
| HTTPS | 443  | 0.0.0.0/0 | SSL (나중에) |
| Custom | 3000 | 0.0.0.0/0 | API (개발용) |
| SSH   | 22   | My IP     | SSH 접속    |

---

## ✅ 배포 확인

### 1. 서버 상태 확인

```bash
pm2 status
pm2 logs fire-safety-api
```

### 2. API 테스트

```bash
# 로컬에서
curl http://ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com:3000/health

# 또는 Nginx 사용 시
curl http://ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com/health
```

### 3. API 문서 확인

브라우저에서:
```
http://ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com:3000/api-docs
```

---

## 🔄 업데이트 배포

코드 변경 후 재배포:

```bash
ssh -i your-key.pem ubuntu@ec2-54-250-110-110.ap-northeast-1.compute.amazonaws.com

cd ~/app-fire
git pull origin claude/review-current-code-01EFxfuyignexFkXbVQaQbFP

cd backend
npm install  # 의존성이 변경된 경우

pm2 restart fire-safety-api
pm2 logs fire-safety-api
```

---

## 🧪 API 테스트 예시

### 1. 회원가입

```bash
curl -X POST http://your-server:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "테스트 점검관",
    "organization": "서울소방청",
    "fire_station": "도봉소방서"
  }'
```

### 2. 로그인

```bash
curl -X POST http://your-server:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. 건물 목록 조회

```bash
TOKEN="your_token_here"

curl -X GET "http://your-server:3000/api/buildings?sido=서울특별시&sigungu=도봉구" \
  -H "Authorization: Bearer $TOKEN"
```

### 4. 점검 생성

```bash
curl -X POST http://your-server:3000/api/inspections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "building_id": 1,
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
```

---

## 🐛 트러블슈팅

### 서버가 시작되지 않을 때

```bash
# 로그 확인
pm2 logs fire-safety-api --lines 100

# 수동 실행하여 에러 확인
cd ~/app-fire/backend
node src/index.js
```

### 데이터베이스 연결 실패

```bash
# MariaDB 상태 확인
sudo systemctl status mariadb

# 연결 테스트
mysql -u fire_safety_user -p -h localhost fire_safety_db
```

### 포트가 이미 사용 중

```bash
# 포트 사용 프로세스 확인
sudo lsof -i :3000

# 프로세스 종료
sudo kill -9 <PID>
```

---

## 📊 모니터링

### PM2 모니터링

```bash
pm2 monit
```

### 로그 확인

```bash
# 실시간 로그
pm2 logs fire-safety-api

# 최근 100줄
pm2 logs fire-safety-api --lines 100

# 에러만 보기
pm2 logs fire-safety-api --err
```

---

## 🔐 보안 강화 (권장)

### 1. 방화벽 설정

```bash
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw status
```

### 2. SSL 인증서 (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 3. 정기 백업

```bash
# 데이터베이스 백업 스크립트
crontab -e

# 매일 새벽 3시 백업
0 3 * * * mysqldump -u fire_safety_user -p'password' fire_safety_db > ~/backups/db_$(date +\%Y\%m\%d).sql
```

---

## 📞 문의

문제가 발생하면 GitHub Issues에 등록해주세요.

**성공적인 배포를 기원합니다! 🔥**
