# 🚒 소방 안전 점검 앱

Flutter + Node.js 기반 소방 안전 점검 모바일 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Material Design 3](https://img.shields.io/badge/Material-Design%203-6200EE?logo=material-design)](https://m3.material.io/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)

## 📱 주요 기능

- ✅ **오프라인 우선**: SQLite를 사용한 로컬 데이터 저장
- ✅ **자동 동기화**: 온라인 시 서버와 자동 동기화
- ✅ **Material Design 3**: 최신 디자인 시스템 적용
- ✅ **JWT 인증**: 안전한 사용자 인증
- ✅ **실시간 네트워크 상태**: 연결 상태 표시
- ✅ **다크 테마 지원**: 시스템 설정 따름

## 🎨 UI 미리보기

### 현재 구현된 화면

#### 🏠 홈 대시보드
- 사용자 환영 카드 (그라데이션 배경)
- 오늘의 현황 통계 (완료/진행중/불량)
- 빠른 메뉴 (점검 목록, 건물 관리, 리포트, 일정)
- 최근 점검 목록
- Pull-to-Refresh 지원

#### 🔐 인증 화면
- 로그인 (이메일/비밀번호)
- 회원가입 (7개 필드)
- 실시간 유효성 검증
- 에러 메시지 표시

---

## 🚀 빠른 시작

### 사전 요구사항

```bash
flutter --version  # 3.0 이상
node --version     # 18 이상 (백엔드용)
```

### 1. 프로젝트 설정

```bash
# 저장소 클론
git clone https://github.com/saintgo7/app-fire.git
cd app-fire

# Flutter 패키지 설치
flutter pub get
```

### 2. 앱 실행

```bash
# Android 에뮬레이터에서 실행
flutter run

# Chrome에서 실행 (개발용)
flutter run -d chrome

# 특정 디바이스 선택
flutter devices
flutter run -d <device-id>
```

### 3. 백엔드 서버 실행 (선택)

```bash
cd backend
npm install
cp .env.example .env
# .env 파일 편집 후
npm start
```

**참고:** 앱은 오프라인에서도 동작합니다 (SQLite 사용)

---

## 📂 프로젝트 구조

```
lib/
├── core/
│   ├── theme/              # Material Design 3 테마
│   ├── database/           # SQLite + DAO
│   └── api/                # Dio + JWT
├── features/
│   ├── auth/               # 로그인/회원가입
│   ├── home/               # 홈 대시보드 ⭐ NEW
│   ├── inspection/         # 점검 기능
│   └── ...
└── shared/
    └── providers/          # 상태 관리 (Provider)
```

---

## 🎨 Material Design 3 테마

### 색상 스킴

| 역할 | 라이트 모드 | 설명 |
|------|------------|------|
| Primary | `#D32F2F` | 소방차 빨강 |
| Secondary | `#1976D2` | 안전 파랑 |
| Tertiary | `#FF6F00` | 경고 주황 |

### 상태 색상

| 상태 | 색상 | 용도 |
|------|------|------|
| 양호 | `#4CAF50` | 점검 통과 |
| 주의 | `#FF9800` | 주의 필요 |
| 불량 | `#F44336` | 불량 발견 |

### 테마 커스터마이징

```dart
// lib/core/theme/app_colors.dart 수정
static const Color primaryLight = Color(0xFFD32F2F);
```

---

## 🔧 주요 화면 확인 방법

### 1. 로그인 화면
앱 실행 시 자동으로 표시됩니다.

```
이메일: test@example.com
비밀번호: test123 (6자 이상)
```

### 2. 회원가입 화면
로그인 화면에서 "계정이 없으신가요? 회원가입" 클릭

### 3. 홈 대시보드
로그인 후 자동 이동:
- 환영 카드 (사용자 정보 표시)
- 통계 (완료 12 / 진행중 3 / 불량 1)
- 빠른 메뉴 4개 버튼
- 최근 점검 3개 항목

### 4. Hot Reload로 UI 실시간 수정

```bash
# 앱 실행 중 코드 수정 후
r  # Hot Reload
R  # Hot Restart
```

---

## 🛠️ 기술 스택

### Frontend
- Flutter 3.x + Dart 3.x
- Material Design 3 (useMaterial3: true)
- Provider (상태 관리)
- SQLite (sqflite)
- Dio (HTTP client)

### Backend
- Node.js 18+ + Express
- MariaDB
- JWT Authentication
- Swagger API Docs

---

## 📖 문서

- [Figma 연동 가이드](docs/figma-integration-guide.md)
- [데이터베이스 스키마](docs/database-schema.md)
- [백엔드 배포](backend/DEPLOY_GUIDE.md)

---

## 🐛 문제 해결

### Flutter SDK를 찾을 수 없음

```bash
flutter doctor
export PATH="$PATH:`pwd`/flutter/bin"
```

### Gradle build 실패 (Android)

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
```

### Hot Reload 안 됨

터미널에서 `R` 키 입력 (Hot Restart)

---

## 📝 라이센스

MIT License

---

**최근 업데이트:** 2025-01-14
**버전:** 1.0.0
**작성자:** saintgo7
