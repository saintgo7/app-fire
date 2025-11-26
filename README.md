# 소방점검관리사 앱 (Fire Safety Inspector App)

소방 안전 점검을 효율적으로 수행하고 관리할 수 있는 Flutter 모바일 애플리케이션입니다.

## 📱 주요 기능

- ✅ **실시간 점검**: 체크리스트를 통한 체계적인 점검 수행
- 📸 **사진 첨부**: 점검 항목별 사진 첨부 및 관리
- 📄 **보고서 생성**: PDF 형식의 점검 보고서 자동 생성
- 📅 **일정 관리**: 캘린더를 통한 점검 일정 관리
- ⚖️ **법령 조회**: 소방 관련 법령 검색 및 조회
- 🔄 **오프라인 지원**: 인터넷 연결 없이도 점검 수행 가능
- ☁️ **자동 동기화**: 데이터 자동 백업 및 동기화

## 🚀 시작하기

### 요구사항

- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상
- Android Studio / VS Code
- Android SDK (Android 개발용)
- Xcode (iOS 개발용, macOS만)

### 설치 방법

```bash
# 저장소 클론
git clone <repository-url>
cd app-fire

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 📚 문서

- [사용자 가이드 (마크다운)](docs/user-guide.md)
- [사용자 가이드 (HTML)](docs/user-guide.html)
- [데이터베이스 스키마](docs/database-schema.md)
- [백엔드 배포 가이드](backend/DEPLOY_GUIDE.md)

## 🏗️ 프로젝트 구조

```
lib/
├── core/              # 핵심 기능
│   ├── api/          # API 클라이언트
│   ├── constants/    # 상수 정의
│   ├── database/     # 데이터베이스
│   ├── services/     # 서비스
│   └── theme/        # 테마 설정
├── features/         # 기능별 모듈
│   ├── auth/         # 인증
│   ├── home/         # 홈 화면
│   ├── inspection/   # 점검
│   ├── report/       # 보고서
│   ├── schedule/     # 일정
│   ├── settings/     # 설정
│   └── legal/        # 법령
└── shared/           # 공통 위젯 및 모델
    ├── models/       # 공통 모델
    ├── providers/    # 상태 관리
    └── widgets/      # 공통 위젯
```

## 🛠️ 기술 스택

- **프레임워크**: Flutter 3.38.1
- **언어**: Dart 3.10.0
- **상태 관리**: Provider, BLoC
- **데이터베이스**: SQLite (sqflite)
- **네트워킹**: Dio
- **인증**: Firebase Auth
- **지도**: Google Maps Flutter
- **PDF 생성**: pdf 패키지

## 📖 사용 방법

자세한 사용 방법은 [사용자 가이드](docs/user-guide.md)를 참조하세요.

### 빠른 시작

1. **회원가입/로그인**: 앱 실행 후 계정을 생성하거나 로그인합니다
2. **점검 시작**: 홈 화면에서 "점검 시작" 버튼을 클릭합니다
3. **항목 점검**: 각 점검 항목의 상태를 선택하고 사진을 첨부합니다
4. **메모 작성**: 필요시 메모를 작성합니다
5. **점검 완료**: 모든 항목을 점검한 후 완료 버튼을 클릭합니다
6. **보고서 확인**: 완료된 점검은 보고서 화면에서 확인할 수 있습니다

## 🔧 개발

### 환경 변수 설정

`.env` 파일을 생성하고 다음 변수를 설정하세요:

```env
API_URL=https://fire.abada.co.kr
```

### 빌드

```bash
# Android APK 빌드
flutter build apk --release

# iOS 빌드 (macOS만)
flutter build ios --release

# Linux 빌드
flutter build linux --release
```

## 📄 라이선스

이 프로젝트는 소방 안전 점검 업무를 위한 내부 사용 목적으로 개발되었습니다.

## 📞 지원

- 이메일: support@firesafety.kr
- 문서: [사용자 가이드](docs/user-guide.md)

---

**소방점검관리사 앱으로 안전하고 효율적인 점검을 시작하세요! 🔥**
