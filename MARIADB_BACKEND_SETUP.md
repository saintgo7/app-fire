# MariaDB 백엔드 설정 가이드

이 문서는 Fire Safety Inspector 앱에서 Firebase Firestore를 MariaDB로 변경하고 Node.js/Express 백엔드 API를 설정하는 방법을 안내합니다.

## 목차
1. [MariaDB 설치 및 설정](#1-mariadb-설치-및-설정)
2. [백엔드 API 서버 설정](#2-백엔드-api-서버-설정)
3. [Flutter 앱 설정](#3-flutter-앱-설정)
4. [테스트 및 실행](#4-테스트-및-실행)

---

## 1. MariaDB 설치 및 설정

### 1.1 MariaDB 설치

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

#### Windows
[MariaDB 공식 사이트](https://mariadb.org/download/)에서 설치 파일 다운로드

### 1.2 MariaDB 보안 설정
```bash
sudo mysql_secure_installation
```

### 1.3 데이터베이스 및 사용자 생성

MariaDB에 로그인:
```bash
mysql -u root -p
```

다음 SQL 명령 실행:
```sql
-- 데이터베이스 사용자 생성
CREATE USER 'fire_inspector'@'localhost' IDENTIFIED BY 'your_secure_password';

-- 권한 부여
GRANT ALL PRIVILEGES ON fire_safety_inspector.* TO 'fire_inspector'@'localhost';
FLUSH PRIVILEGES;
```

### 1.4 스키마 생성

프로젝트의 스키마 파일 실행:
```bash
mysql -u fire_inspector -p < backend/database/schema.sql
```

또는 MariaDB에 로그인 후:
```sql
SOURCE /path/to/app-fire/backend/database/schema.sql;
```

### 1.5 데이터베이스 확인

```sql
USE fire_safety_inspector;
SHOW TABLES;

-- 테이블 구조 확인
DESCRIBE users;
DESCRIBE inspections;
DESCRIBE checklist_items;
```

---

## 2. 백엔드 API 서버 설정

### 2.1 Node.js 설치

Node.js 16 이상이 필요합니다.

#### 설치 확인
```bash
node --version
npm --version
```

#### 설치되지 않은 경우
- Ubuntu/Debian: `sudo apt install nodejs npm`
- macOS: `brew install node`
- Windows: [Node.js 공식 사이트](https://nodejs.org/)에서 다운로드

### 2.2 백엔드 디렉토리로 이동

```bash
cd backend
```

### 2.3 의존성 설치

```bash
npm install
```

### 2.4 환경 변수 설정

`.env` 파일 생성:
```bash
cp .env.example .env
```

`.env` 파일 편집:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MariaDB Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=fire_inspector
DB_PASSWORD=your_secure_password
DB_NAME=fire_safety_inspector

# JWT Secret (강력한 임의 문자열로 변경)
JWT_SECRET=your_very_long_and_secure_jwt_secret_key_change_this
JWT_EXPIRES_IN=7d

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760

# CORS (Flutter 앱이 접근할 URL)
CORS_ORIGIN=*

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

**중요**: 프로덕션 환경에서는 `JWT_SECRET`을 강력한 임의 문자열로 변경하세요!

### 2.5 업로드 디렉토리 생성

```bash
mkdir uploads
```

### 2.6 서버 실행

#### 개발 모드 (자동 재시작)
```bash
npm run dev
```

#### 프로덕션 모드
```bash
npm start
```

서버가 성공적으로 시작되면 다음과 같은 메시지가 표시됩니다:
```
✅ MariaDB 연결 성공: 2
🚀 서버가 포트 3000에서 실행 중입니다.
📝 환경: development
🔗 API URL: http://localhost:3000/api
```

### 2.7 API 엔드포인트 확인

헬스체크:
```bash
curl http://localhost:3000/health
```

응답 예시:
```json
{
  "status": "ok",
  "timestamp": "2025-01-10T12:00:00.000Z",
  "uptime": 123.456
}
```

---

## 3. Flutter 앱 설정

### 3.1 API Base URL 설정

`lib/core/services/api_service.dart` 파일에서 Base URL을 실제 서버 주소로 변경:

```dart
// 개발 환경
static const String baseUrl = 'http://localhost:3000/api';

// 실제 기기 테스트 (컴퓨터의 로컬 IP 주소 사용)
// static const String baseUrl = 'http://192.168.1.100:3000/api';

// 프로덕션 환경
// static const String baseUrl = 'https://your-domain.com/api';
```

**Android 에뮬레이터에서 테스트하는 경우**:
- localhost 대신 `10.0.2.2` 사용:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

**iOS 시뮬레이터에서 테스트하는 경우**:
- localhost 그대로 사용 가능

**실제 기기에서 테스트하는 경우**:
1. 컴퓨터의 로컬 IP 주소 확인:
   - Windows: `ipconfig`
   - macOS/Linux: `ifconfig` 또는 `ip addr`
2. 해당 IP 주소로 Base URL 설정

### 3.2 의존성 설치

```bash
flutter pub get
```

### 3.3 Android 네트워크 권한 확인

`android/app/src/main/AndroidManifest.xml` 파일에 인터넷 권한이 있는지 확인 (이미 추가됨):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### 3.4 iOS HTTP 통신 허용 (개발 환경)

개발 환경에서 HTTP 통신을 허용하려면 `ios/Runner/Info.plist`에 추가:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**주의**: 프로덕션에서는 HTTPS를 사용해야 합니다!

---

## 4. 테스트 및 실행

### 4.1 백엔드 서버 실행

터미널 1:
```bash
cd backend
npm run dev
```

### 4.2 Flutter 앱 실행

터미널 2:
```bash
flutter run
```

### 4.3 로그인 테스트

1. 앱 실행
2. 소셜 로그인 버튼 클릭 (Google, Kakao, Naver)
3. 로그인 프로세스 완료
4. 백엔드 서버 로그 확인:
   ```
   🔵 [REQUEST] POST /api/auth/social-login
   🟢 [RESPONSE] 200 /api/auth/social-login
   ```

5. MariaDB 데이터 확인:
   ```sql
   SELECT * FROM users;
   ```

### 4.4 API 테스트 (Postman 또는 curl)

#### 소셜 로그인
```bash
curl -X POST http://localhost:3000/api/auth/social-login \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "test_user_123",
    "email": "test@example.com",
    "displayName": "Test User",
    "photoUrl": null,
    "phoneNumber": null,
    "loginProvider": "google"
  }'
```

응답 예시:
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "uid": "test_user_123",
      "email": "test@example.com",
      ...
    }
  }
}
```

#### 인증된 요청 (토큰 사용)
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### 점검 목록 조회
```bash
curl -X GET http://localhost:3000/api/inspections \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 5. 아키텍처 변경 사항 요약

### 기존 (Firebase)
```
Flutter App → Firebase Auth → Firestore
```

### 변경 후 (MariaDB)
```
Flutter App → REST API (JWT) → Node.js/Express → MariaDB
```

### 주요 변경 사항

1. **인증**:
   - Firebase Auth → JWT 토큰 기반 인증
   - 소셜 로그인은 그대로 유지 (Google, Kakao, Naver)
   - 토큰은 SharedPreferences에 저장

2. **데이터 저장**:
   - Firestore → MariaDB
   - 실시간 업데이트 → REST API 폴링 또는 WebSocket (필요시)

3. **API 통신**:
   - 직접 Firestore SDK 사용 → HTTP API 호출 (Dio)
   - ApiService 클래스를 통한 중앙화된 API 관리

4. **오프라인 지원**:
   - 기존 SQLite/Hive 로컬 저장소 계속 사용
   - 네트워크 연결 시 백엔드 API와 동기화

---

## 6. 프로덕션 배포

### 6.1 백엔드 서버 배포

#### PM2를 사용한 프로세스 관리
```bash
npm install -g pm2
pm2 start server.js --name fire-inspector-api
pm2 startup
pm2 save
```

#### Nginx 리버스 프록시 설정
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### HTTPS 설정 (Let's Encrypt)
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 6.2 MariaDB 프로덕션 설정

1. **백업 설정**:
   ```bash
   mysqldump -u fire_inspector -p fire_safety_inspector > backup.sql
   ```

2. **성능 최적화**:
   - `my.cnf` 파일 튜닝
   - 인덱스 최적화
   - 쿼리 성능 모니터링

3. **보안**:
   - 원격 접속 제한
   - 강력한 비밀번호 사용
   - 정기적인 보안 업데이트

### 6.3 Flutter 앱 배포

1. Base URL을 프로덕션 서버로 변경
2. HTTP를 HTTPS로 변경
3. 릴리스 빌드:
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

---

## 7. 문제 해결

### 7.1 데이터베이스 연결 실패
```
❌ MariaDB 연결 실패: Access denied for user
```

**해결책**:
- `.env` 파일의 DB_USER와 DB_PASSWORD 확인
- MariaDB 사용자 권한 확인
- MariaDB 서비스 실행 여부 확인: `sudo systemctl status mariadb`

### 7.2 Flutter 앱에서 API 연결 실패
```
DioException: Connection refused
```

**해결책**:
- 백엔드 서버가 실행 중인지 확인
- Base URL이 올바른지 확인 (localhost vs 10.0.2.2 vs 로컬 IP)
- 방화벽 설정 확인
- Android 인터넷 권한 확인

### 7.3 JWT 토큰 만료
```
401 Unauthorized: 유효하지 않은 토큰입니다.
```

**해결책**:
- 토큰 갱신 API 호출: `/api/auth/refresh`
- 자동 로그아웃 후 재로그인

### 7.4 CORS 오류
```
Access to XMLHttpRequest has been blocked by CORS policy
```

**해결책**:
- `.env` 파일의 `CORS_ORIGIN` 설정 확인
- 프로덕션에서는 특정 도메인만 허용 권장

---

## 8. 추가 개선 사항

### 8.1 실시간 업데이트
- WebSocket 또는 Server-Sent Events (SSE) 구현
- Socket.IO 사용 고려

### 8.2 파일 업로드
- Multer 미들웨어 설정
- AWS S3 또는 MinIO 연동

### 8.3 캐싱
- Redis 연동으로 성능 향상
- API 응답 캐싱

### 8.4 모니터링
- Winston으로 로그 관리
- Sentry로 에러 추적
- Prometheus + Grafana로 메트릭 모니터링

---

## 9. 참고 자료

- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [JWT.io](https://jwt.io/)
- [Dio Package](https://pub.dev/packages/dio)
- [REST API Best Practices](https://restfulapi.net/)
