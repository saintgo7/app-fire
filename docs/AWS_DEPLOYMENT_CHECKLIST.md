# AWS EC2 배포 체크리스트

배포 전에 다음 항목들을 확인하고 준비하세요.

## ✅ 1단계: AWS EC2 인스턴스 정보 확인

### 필요한 정보
- [ ] EC2 퍼블릭 IP 주소: `_____________________`
- [ ] EC2 SSH 키 파일 경로: `_____________________`
- [ ] EC2 사용자명 (보통 `ubuntu` 또는 `ec2-user`): `_____________________`
- [ ] EC2 운영체제: Ubuntu 20.04/22.04 권장

### EC2 인스턴스 사양 권장
- **타입**: t2.small 이상 (t2.micro는 메모리 부족 가능)
- **스토리지**: 최소 8GB (20GB 권장)
- **운영체제**: Ubuntu Server 20.04 LTS 또는 22.04 LTS

---

## ✅ 2단계: 보안 그룹 설정 확인

AWS 콘솔 → EC2 → Security Groups에서 다음 인바운드 규칙이 설정되어 있는지 확인:

| 타입 | 프로토콜 | 포트 범위 | 소스 | 용도 |
|------|----------|-----------|------|------|
| SSH | TCP | 22 | My IP 또는 특정 IP | EC2 SSH 접속 |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 (또는 특정 IP) | Node.js API 서버 |
| MySQL/Aurora | TCP | 3306 | sg-xxxxxx (같은 보안그룹) | MariaDB (localhost만) |

**중요:**
- SSH는 보안을 위해 특정 IP만 허용하는 것을 권장합니다
- 3306 포트는 외부 노출하지 않는 것이 안전합니다 (localhost만)

---

## ✅ 3단계: SSH 키 파일 권한 설정

macOS/Linux:
```bash
chmod 400 your-key.pem
```

Windows (Git Bash):
```bash
chmod 400 your-key.pem
```

---

## ✅ 4단계: 환경 변수 준비

배포 중에 설정할 값들을 미리 준비하세요:

```bash
# 데이터베이스 설정
DB_HOST=localhost
DB_PORT=3306
DB_NAME=fire_safety_db
DB_USER=fire_safety_user
DB_PASSWORD=________________  # 강력한 비밀번호 준비 (최소 16자)

# JWT 설정
JWT_SECRET=________________   # 무작위 64자 이상 문자열 준비
JWT_EXPIRES_IN=7d

# 서버 설정
PORT=3000
NODE_ENV=production
```

### JWT_SECRET 생성 방법

macOS/Linux:
```bash
openssl rand -base64 64
```

Windows (PowerShell):
```powershell
[Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

온라인 생성기:
- https://randomkeygen.com/ (CodeIgniter Encryption Keys 사용)

---

## ✅ 5단계: 배포 스크립트 다운로드 URL

GitHub 리포지토리의 스크립트를 사용합니다:
```
https://raw.githubusercontent.com/saintgo7/app-fire/claude/review-current-code-01EFxfuyignexFkXbVQaQbFP/backend/scripts/ec2_quickstart.sh
```

---

## ✅ 6단계: Flutter 앱 설정

배포 완료 후 Flutter 앱에서 API URL을 변경해야 합니다:

**파일:** `lib/core/api/api_client.dart`

**변경 전:**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**변경 후:**
```dart
static const String baseUrl = 'http://YOUR_EC2_PUBLIC_IP:3000/api';
```

---

## 📝 배포 진행 순서

1. ✅ SSH 접속 테스트
2. ✅ 보안 그룹 확인
3. ✅ 자동 배포 스크립트 실행
4. ✅ .env 파일 수정
5. ✅ MariaDB 설정
6. ✅ 스키마 임포트
7. ✅ PM2 서버 시작
8. ✅ API 테스트
9. ✅ Flutter 앱 연결

---

## 🔒 보안 체크리스트

배포 후 반드시 확인:

- [ ] SSH 포트(22)는 특정 IP만 허용
- [ ] MariaDB 포트(3306)는 외부 노출되지 않음
- [ ] .env 파일의 비밀번호가 강력함 (16자 이상)
- [ ] JWT_SECRET이 무작위 64자 이상
- [ ] 기본 root 비밀번호 변경됨
- [ ] 불필요한 포트가 열려있지 않음

---

## 📞 문제 발생 시

배포 중 문제가 발생하면 다음을 확인하세요:

1. **SSH 접속 실패**
   - 키 파일 권한: `chmod 400 your-key.pem`
   - 보안 그룹에 SSH(22) 포트 열려있는지 확인
   - EC2 인스턴스가 실행 중인지 확인

2. **스크립트 실행 실패**
   - 인터넷 연결 확인
   - 스토리지 공간 확인: `df -h`
   - 메모리 확인: `free -h`

3. **MariaDB 연결 실패**
   - MariaDB 서비스 상태: `sudo systemctl status mariadb`
   - 사용자 권한 확인
   - 비밀번호 확인

4. **PM2 서버 시작 실패**
   - 로그 확인: `pm2 logs fire-safety-api`
   - .env 파일 확인
   - 데이터베이스 연결 확인

---

**다음 단계로 진행할 준비가 되셨으면 알려주세요!**
