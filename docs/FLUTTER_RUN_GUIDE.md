# Flutter 앱 실행 가이드

## 🚨 중요 안내

현재 환경은 **서버 환경**입니다. Flutter 앱을 실행하려면 **로컬 PC**에서 실행해야 합니다.

---

## 📱 로컬 PC에서 Flutter 앱 실행하기

### 1단계: 프로젝트 클론 (로컬 PC에서)

```bash
# 터미널 열기 (Windows: PowerShell, macOS/Linux: Terminal)

# 프로젝트 클론
git clone https://github.com/saintgo7/app-fire.git
cd app-fire

# 현재 브랜치로 체크아웃
git checkout claude/review-current-code-01EFxfuyignexFkXbVQaQbFP
```

### 2단계: Flutter 설치 확인

```bash
flutter doctor
```

**예상 출력:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Android Studio (version xxxx)
[✓] VS Code (version xxxx)
[✓] Connected device (x available)
```

**Flutter가 없다면:**
- [Flutter 공식 설치 가이드](https://docs.flutter.dev/get-started/install)

### 3단계: 패키지 설치

```bash
cd app-fire
flutter pub get
```

### 4단계: 실행 가능한 디바이스 확인

```bash
flutter devices
```

**예상 출력:**
```
3 connected devices:

sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
Chrome (web)                • chrome        • web-javascript • Google Chrome 120.0
macOS (desktop)             • macos         • darwin-arm64   • macOS 14.0
```

### 5단계: 앱 실행

#### 옵션 1: Android 에뮬레이터 (권장)

```bash
# 에뮬레이터 실행 (Android Studio AVD Manager)
# 또는 명령어로 실행
flutter emulators --launch <emulator-id>

# 앱 실행
flutter run
```

#### 옵션 2: Chrome 웹 (빠른 확인)

```bash
flutter run -d chrome
```

#### 옵션 3: 특정 디바이스 선택

```bash
# 디바이스 목록 보기
flutter devices

# 특정 디바이스로 실행
flutter run -d emulator-5554
```

---

## 🎯 실행 후 확인 사항

### 1. 로그인 화면
앱 실행 시 자동으로 표시됩니다.

**테스트 계정 만들기:**
- "계정이 없으신가요? 회원가입" 클릭
- 정보 입력 후 회원가입

### 2. 홈 대시보드
로그인 성공 후 자동으로 표시됩니다.

**확인할 UI 요소:**
- ✅ 환영 카드 (빨강 그라데이션)
- ✅ 통계 카드 3개 (완료/진행중/불량)
- ✅ 빠른 메뉴 4개 버튼
- ✅ 최근 점검 목록 3개
- ✅ FloatingActionButton "새 점검"

### 3. Material Design 3 테마 확인
- 소방차 빨강색 (Primary: #D32F2F)
- 둥근 카드 (12pt radius)
- 그림자 효과 (elevation)

---

## 🔧 Hot Reload 사용하기

앱 실행 중에 코드를 수정하고 즉시 반영:

```bash
# 터미널에서
r  # Hot Reload (빠름)
R  # Hot Restart (완전 재시작)
q  # 종료
```

**실습 예시:**
1. 앱 실행 유지
2. `lib/core/theme/app_colors.dart` 파일 열기
3. Primary 색상 변경:
   ```dart
   static const Color primaryLight = Color(0xFF1976D2); // 파랑으로 변경
   ```
4. 터미널에서 `r` 입력
5. 앱에서 색상 변경 확인!

---

## 🐛 문제 해결

### "No devices found" 오류

**Android:**
```bash
# Android Studio 실행 → AVD Manager → 에뮬레이터 생성 및 실행
```

**Chrome:**
```bash
# Chrome 활성화
flutter config --enable-web
flutter devices
```

### "Gradle build failed" 오류

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### "Pod install failed" 오류 (iOS/macOS)

```bash
cd ios
pod install
cd ..
flutter run
```

---

## 📸 스크린샷 모드

실행 화면 캡처:

```bash
# 앱 실행 중
# 디바이스에서 스크린샷 찍기
# Android: Ctrl+S
# iOS Simulator: Cmd+S
```

---

## 🌐 백엔드 연결 (선택)

로컬에서 백엔드도 함께 테스트하려면:

### 터미널 1: 백엔드 서버

```bash
cd app-fire/backend
npm install
cp .env.example .env
npm start
```

### 터미널 2: Flutter 앱

```bash
cd app-fire
flutter run
```

**참고:**
- 백엔드 없이도 앱은 SQLite로 동작합니다
- 로그인/회원가입은 백엔드 없이는 작동하지 않습니다

---

## 💡 추천 실행 환경

### Android 에뮬레이터 (권장)
- **장점**: 실제 기기와 가장 유사
- **설정**: Pixel 6, API 33 (Android 13)
- **Material 3**: 완벽 지원

### Chrome (빠른 확인용)
- **장점**: 즉시 실행 가능
- **단점**: 일부 모바일 기능 제한

---

## 🎉 실행 성공 체크리스트

앱이 정상적으로 실행되면 다음을 확인할 수 있습니다:

- [ ] 로그인 화면 표시
- [ ] Material Design 3 스타일 적용
- [ ] 회원가입 가능
- [ ] 로그인 후 홈 대시보드 표시
- [ ] 환영 카드 표시
- [ ] 통계 카드 3개 표시
- [ ] 빠른 메뉴 4개 버튼 표시
- [ ] 최근 점검 목록 표시
- [ ] "새 점검" 버튼 표시

---

**작성일:** 2025-01-14
