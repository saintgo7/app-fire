# 🚀 AWS EC2 배포 빠른 시작 가이드

실제 AWS EC2에 배포하기 위한 빠른 참조 가이드입니다.

---

## 📋 배포 전 준비사항

- [ ] AWS EC2 인스턴스 생성 완료 (Ubuntu 20.04/22.04)
- [ ] EC2 퍼블릭 IP 주소 확인: `________________`
- [ ] SSH 키 파일 다운로드: `________________`
- [ ] 보안 그룹 설정 (포트 22, 3000 오픈)

---

## 🔥 10분 배포 (복사-붙여넣기)

### 1️⃣ 로컬 PC에서: SSH 접속

```bash
# SSH 키 권한 설정
chmod 400 /path/to/your-key.pem

# EC2 접속
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

---

### 2️⃣ EC2에서: 자동 배포 스크립트 실행

```bash
# 스크립트 다운로드
wget https://raw.githubusercontent.com/saintgo7/app-fire/claude/review-current-code-01EFxfuyignexFkXbVQaQbFP/backend/scripts/ec2_quickstart.sh

# 실행 권한 부여
chmod +x ec2_quickstart.sh

# 실행 (10-15분 소요)
./ec2_quickstart.sh
```

---

### 3️⃣ EC2에서: 환경 변수 설정

```bash
# 프로젝트로 이동
cd ~/app-fire/backend

# JWT_SECRET 생성
openssl rand -base64 64 | tr -d '\n'
# 출력된 값을 복사하세요!

# .env 파일 수정
nano .env
```

**수정할 값:**
```bash
DB_PASSWORD=your_strong_password_here  # ⚠️ 변경!
JWT_SECRET=your_jwt_secret_here        # ⚠️ 위에서 생성한 값!
```

**저장:** `Ctrl + O` → Enter → `Ctrl + X`

---

### 4️⃣ EC2에서: MariaDB 설정

```bash
# MariaDB 접속
sudo mysql -u root
```

```sql
-- 데이터베이스 생성
CREATE DATABASE fire_safety_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 사용자 생성 (.env의 DB_PASSWORD와 동일하게!)
CREATE USER 'fire_safety_user'@'localhost' IDENTIFIED BY 'your_strong_password_here';

-- 권한 부여
GRANT ALL PRIVILEGES ON fire_safety_db.* TO 'fire_safety_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# 스키마 임포트
mysql -u fire_safety_user -p fire_safety_db < ~/app-fire/backend/sql/schema.sql
# 비밀번호 입력!
```

---

### 5️⃣ EC2에서: 서버 시작

```bash
# PM2로 서버 시작
cd ~/app-fire/backend
pm2 start src/index.js --name fire-safety-api

# 상태 확인
pm2 status

# 로그 확인
pm2 logs fire-safety-api --lines 20

# 자동 재시작 설정
pm2 save
pm2 startup
# 출력된 명령어를 복사해서 실행!
```

---

### 6️⃣ EC2에서: API 테스트

```bash
# Health check
curl http://localhost:3000/api/health

# 예상 응답: {"status":"OK",...}
```

---

### 7️⃣ 로컬 PC에서: 외부 접속 테스트

```bash
# 로컬 PC에서 실행
curl http://YOUR_EC2_PUBLIC_IP:3000/api/health

# 예: curl http://54.180.123.45:3000/api/health
```

**❌ 접속 안 되면:**
- AWS Console → EC2 → Security Groups
- Inbound rules에 포트 3000 추가

---

### 8️⃣ 로컬 PC에서: Flutter 앱 연결

**파일:** `lib/core/api/api_client.dart`

```dart
// 변경
static const String baseUrl = 'http://YOUR_EC2_PUBLIC_IP:3000/api';
```

```bash
# Flutter 재실행
flutter clean
flutter pub get
flutter run
```

---

## ✅ 배포 완료!

이제 Flutter 앱에서 회원가입/로그인을 테스트하세요!

---

## 🔍 빠른 문제 해결

### SSH 접속 안 됨
```bash
chmod 400 your-key.pem
# 보안 그룹에서 포트 22 확인
```

### MariaDB 오류
```bash
sudo systemctl restart mariadb
sudo systemctl status mariadb
```

### PM2 서버 오류
```bash
pm2 logs fire-safety-api --lines 50
# .env 파일 확인
cat ~/app-fire/backend/.env
```

### 외부 접속 안 됨
```bash
# EC2 내부에서 먼저 테스트
curl http://localhost:3000/api/health

# 보안 그룹에서 포트 3000 확인
```

---

## 📚 상세 가이드

더 자세한 정보는 다음 문서를 참조하세요:

- **[AWS_DEPLOYMENT_COMMANDS.md](docs/AWS_DEPLOYMENT_COMMANDS.md)** - 단계별 명령어 가이드
- **[AWS_DEPLOYMENT_CHECKLIST.md](docs/AWS_DEPLOYMENT_CHECKLIST.md)** - 배포 전 체크리스트
- **[AWS_EC2_DEPLOYMENT.md](docs/AWS_EC2_DEPLOYMENT.md)** - 전체 배포 가이드

---

## 📞 도움이 필요하신가요?

배포 중 문제가 발생하면:
1. PM2 로그 확인: `pm2 logs fire-safety-api --lines 100`
2. MariaDB 상태 확인: `sudo systemctl status mariadb`
3. 보안 그룹 설정 재확인
4. .env 파일 값 확인

**Happy Deploying! 🎉**
