# AWS EC2 실제 배포 명령어 가이드

이 문서는 실제 AWS EC2에 배포할 때 사용하는 명령어를 단계별로 정리한 가이드입니다.

---

## 🔧 1단계: SSH 접속 테스트

### 1-1. SSH 키 권한 설정 (로컬 PC에서 실행)

```bash
# SSH 키 파일 권한 설정 (400으로 변경)
chmod 400 /path/to/your-key.pem
```

### 1-2. EC2 인스턴스 접속

```bash
# 템플릿 (아래 정보를 실제 값으로 변경)
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# 예시
# ssh -i ~/Downloads/my-key.pem ubuntu@54.180.123.45
```

**접속 성공 시 나타나는 화면:**
```
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-1044-aws x86_64)
...
ubuntu@ip-172-31-xxx-xxx:~$
```

---

## 🔒 2단계: 보안 그룹 확인 (AWS 콘솔에서)

**AWS Console → EC2 → Security Groups**에서 확인:

### 인바운드 규칙

| 타입 | 포트 | 소스 | 설명 |
|------|------|------|------|
| SSH | 22 | My IP | SSH 접속 |
| Custom TCP | 3000 | 0.0.0.0/0 | API 서버 |
| MySQL/Aurora | 3306 | sg-xxxxxx | MariaDB (내부만) |

**확인 방법:**
1. AWS Console → EC2 → Instances
2. 해당 인스턴스 클릭 → Security 탭
3. Security groups 클릭
4. Inbound rules 확인

---

## 📦 3단계: 자동 배포 스크립트 실행 (EC2 내부에서)

### 3-1. 스크립트 다운로드

```bash
# 현재 위치 확인
pwd
# /home/ubuntu

# 스크립트 다운로드
wget https://raw.githubusercontent.com/saintgo7/app-fire/claude/review-current-code-01EFxfuyignexFkXbVQaQbFP/backend/scripts/ec2_quickstart.sh

# 실행 권한 부여
chmod +x ec2_quickstart.sh

# 스크립트 확인
ls -la ec2_quickstart.sh
```

### 3-2. 스크립트 실행

```bash
# 자동 배포 스크립트 실행 (10-15분 소요)
./ec2_quickstart.sh
```

**실행 과정:**
1. ✅ 시스템 업데이트
2. ✅ Node.js 18 설치
3. ✅ PM2 설치
4. ✅ MariaDB 설치
5. ✅ Git 설치
6. ✅ 프로젝트 클론
7. ✅ npm 패키지 설치
8. ✅ .env 파일 생성

**완료 메시지:**
```
✅ 자동 배포 스크립트 완료!

다음 단계:
1. .env 파일 수정
2. MariaDB 데이터베이스 생성
3. 스키마 임포트
4. PM2 서버 시작
```

---

## ⚙️ 4단계: 환경 변수 설정

### 4-1. .env 파일 수정

```bash
# 프로젝트 디렉토리로 이동
cd ~/app-fire/backend

# .env 파일 편집
nano .env
```

### 4-2. 다음 값들을 수정하세요

```bash
# 데이터베이스 설정
DB_HOST=localhost
DB_PORT=3306
DB_NAME=fire_safety_db
DB_USER=fire_safety_user
DB_PASSWORD=YOUR_STRONG_PASSWORD_HERE  # ⚠️ 변경 필수!

# JWT 설정
JWT_SECRET=YOUR_RANDOM_64CHAR_STRING_HERE  # ⚠️ 변경 필수!
JWT_EXPIRES_IN=7d

# 서버 설정
PORT=3000
NODE_ENV=production

# CORS 설정 (옵션)
ALLOWED_ORIGINS=*
```

**nano 에디터 사용법:**
- 수정: 화살표 키로 이동 후 값 변경
- 저장: `Ctrl + O` → Enter
- 종료: `Ctrl + X`

### 4-3. JWT_SECRET 생성 (EC2에서)

```bash
# 무작위 64자 문자열 생성
openssl rand -base64 64 | tr -d '\n'
```

출력 예시:
```
xK9mP2vR8nQ7sL4tY3uI6oE1wA5zX0cV8bN4mM6hJ2gF9dS3kL7pR1qT5yU4iO8e
```

이 값을 복사해서 `.env` 파일의 `JWT_SECRET`에 붙여넣으세요.

### 4-4. 설정 확인

```bash
# .env 파일 내용 확인 (비밀번호 제외)
cat .env | grep -v PASSWORD | grep -v SECRET
```

---

## 🗄️ 5단계: MariaDB 설정

### 5-1. MariaDB 접속

```bash
# MariaDB root 계정 접속 (초기 비밀번호 없음)
sudo mysql -u root
```

또는 비밀번호 설정되어 있다면:
```bash
sudo mysql -u root -p
```

### 5-2. 데이터베이스 및 사용자 생성

MariaDB 프롬프트에서 실행:

```sql
-- 데이터베이스 생성
CREATE DATABASE fire_safety_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 (.env의 DB_PASSWORD와 동일하게!)
CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'YOUR_STRONG_PASSWORD_HERE';

-- 권한 부여
GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';

-- 권한 적용
FLUSH PRIVILEGES;

-- 확인
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User = 'fire_safety_user';

-- 종료
EXIT;
```

### 5-3. 연결 테스트

```bash
# 새로 생성한 사용자로 접속 테스트
mysql -u fire_safety_user -p fire_safety_db

# 비밀번호 입력 후 접속되면 성공
# EXIT; 로 나가기
```

---

## 📊 6단계: 데이터베이스 스키마 임포트

### 6-1. SQL 스키마 파일 확인

```bash
# 스키마 파일 위치 확인
ls -la ~/app-fire/backend/sql/schema.sql
```

### 6-2. 스키마 임포트

```bash
# 방법 1: mysql 명령어 사용
mysql -u fire_safety_user -p fire_safety_db < ~/app-fire/backend/sql/schema.sql

# 비밀번호 입력 후 임포트 완료
```

또는

```bash
# 방법 2: Node.js 스크립트 사용
cd ~/app-fire/backend
node scripts/import-sql.js
```

### 6-3. 테이블 생성 확인

```bash
# MariaDB 접속
mysql -u fire_safety_user -p fire_safety_db

# 테이블 목록 확인
SHOW TABLES;
```

**예상 출력:**
```
+---------------------------+
| Tables_in_fire_safety_db  |
+---------------------------+
| users                     |
| buildings                 |
| inspections               |
| inspection_items          |
| photos                    |
| sync_logs                 |
+---------------------------+
```

```sql
-- 테이블 구조 확인
DESCRIBE users;

-- 종료
EXIT;
```

---

## 🚀 7단계: PM2로 서버 시작

### 7-1. 서버 시작

```bash
# 프로젝트 디렉토리로 이동
cd ~/app-fire/backend

# PM2로 서버 시작
pm2 start src/index.js --name fire-safety-api

# 서버 상태 확인
pm2 status
```

**예상 출력:**
```
┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
│ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
│ 0  │ fire-safety-api    │ fork     │ 0    │ online    │ 0%       │ 45.2mb   │
└────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

### 7-2. 로그 확인

```bash
# 실시간 로그 보기
pm2 logs fire-safety-api

# 최근 로그만 보기
pm2 logs fire-safety-api --lines 50

# 로그 종료: Ctrl + C
```

**정상 시작 로그 예시:**
```
[2025-01-17 10:30:15] Server running on port 3000
[2025-01-17 10:30:15] Environment: production
[2025-01-17 10:30:15] Database connected successfully
```

### 7-3. PM2 자동 재시작 설정

```bash
# PM2 설정 저장
pm2 save

# 시스템 재부팅 시 자동 시작 설정
pm2 startup

# 출력되는 명령어를 복사해서 실행
# 예: sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
```

### 7-4. PM2 관리 명령어

```bash
# 서버 재시작
pm2 restart fire-safety-api

# 서버 중지
pm2 stop fire-safety-api

# 서버 삭제
pm2 delete fire-safety-api

# 모든 프로세스 보기
pm2 list

# CPU/메모리 모니터링
pm2 monit
```

---

## ✅ 8단계: API 서버 동작 확인

### 8-1. 로컬 테스트 (EC2 내부)

```bash
# Health check
curl http://localhost:3000/api/health

# 예상 응답:
# {"status":"OK","timestamp":"2025-01-17T10:30:00.000Z"}
```

### 8-2. 회원가입 테스트

```bash
# 사용자 등록
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test1234",
    "name": "테스트",
    "role": "inspector",
    "organization": "테스트기관"
  }'

# 예상 응답: JWT 토큰 포함된 JSON
```

### 8-3. 로그인 테스트

```bash
# 로그인
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test1234"
  }'

# 예상 응답: JWT 토큰
```

### 8-4. 외부 접속 테스트 (로컬 PC에서)

```bash
# 로컬 PC에서 실행
curl http://YOUR_EC2_PUBLIC_IP:3000/api/health

# 예시
# curl http://54.180.123.45:3000/api/health
```

**❌ 접속 안 되는 경우:**
- 보안 그룹에서 3000 포트 확인
- EC2 인스턴스의 퍼블릭 IP 확인
- 방화벽 확인: `sudo ufw status`

---

## 📱 9단계: Flutter 앱 연결 설정

### 9-1. API URL 변경 (로컬 PC에서)

**파일:** `lib/core/api/api_client.dart`

```dart
// 변경 전
static const String baseUrl = 'http://localhost:3000/api';

// 변경 후
static const String baseUrl = 'http://YOUR_EC2_PUBLIC_IP:3000/api';
// 예: static const String baseUrl = 'http://54.180.123.45:3000/api';
```

### 9-2. Flutter 앱 재실행

```bash
# 로컬 PC에서
cd /path/to/app-fire
flutter clean
flutter pub get
flutter run
```

### 9-3. 앱에서 테스트

1. **회원가입** - 새 계정 생성
2. **로그인** - 생성한 계정으로 로그인
3. **데이터 동기화** - 홈 화면에서 Sync 버튼 클릭

---

## 🔍 트러블슈팅

### 문제 1: SSH 접속 실패

```bash
# 키 파일 권한 확인
ls -la your-key.pem

# 400이 아니면 변경
chmod 400 your-key.pem

# 보안 그룹 SSH(22) 포트 확인
```

### 문제 2: MariaDB 접속 실패

```bash
# MariaDB 서비스 상태 확인
sudo systemctl status mariadb

# 재시작
sudo systemctl restart mariadb

# 로그 확인
sudo tail -f /var/log/mysql/error.log
```

### 문제 3: PM2 서버 시작 실패

```bash
# 로그 확인
pm2 logs fire-safety-api --lines 100

# .env 파일 확인
cat ~/app-fire/backend/.env

# 데이터베이스 연결 확인
mysql -u fire_safety_user -p fire_safety_db
```

### 문제 4: 외부에서 API 접속 안 됨

```bash
# EC2 내부에서 테스트
curl http://localhost:3000/api/health

# 포트 리스닝 확인
sudo netstat -tlnp | grep 3000

# 방화벽 확인
sudo ufw status

# 방화벽 비활성화 (테스트용)
sudo ufw disable
```

**보안 그룹 재확인:**
- AWS Console → EC2 → Security Groups
- Inbound rules에 3000 포트 추가

### 문제 5: 메모리 부족

```bash
# 메모리 확인
free -h

# Swap 메모리 추가 (1GB)
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 영구 적용
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 📊 모니터링 명령어

```bash
# PM2 모니터링
pm2 monit

# 시스템 리소스
htop

# 디스크 사용량
df -h

# 메모리 사용량
free -h

# 네트워크 연결
sudo netstat -tlnp

# 로그 실시간 보기
pm2 logs fire-safety-api --lines 100
```

---

## 🎉 배포 완료!

모든 단계를 완료했다면 다음과 같이 동작합니다:

```
Flutter App (Local PC)
    ↓ HTTP
EC2 Server:3000 (Node.js API)
    ↓ SQL
MariaDB (localhost:3306)
```

**다음 단계:**
1. ✅ (선택) Nginx 리버스 프록시 설정
2. ✅ (선택) SSL/TLS 인증서 설정 (Let's Encrypt)
3. ✅ (선택) 도메인 연결
4. ✅ 정기 백업 설정
5. ✅ CloudWatch 모니터링 설정

---

**배포 중 문제가 발생하면 알려주세요!**
