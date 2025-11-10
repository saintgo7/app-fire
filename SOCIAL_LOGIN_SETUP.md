# 소셜 로그인 설정 가이드

이 문서는 Fire Safety Inspector 앱에 구현된 소셜 로그인(Google, Kakao, Naver)을 설정하는 방법을 안내합니다.

## 목차
1. [구글 로그인 설정](#1-구글-로그인-설정)
2. [카카오 로그인 설정](#2-카카오-로그인-설정)
3. [네이버 로그인 설정](#3-네이버-로그인-설정)
4. [Firebase 설정](#4-firebase-설정)

---

## 1. 구글 로그인 설정

### 1.1 Firebase Console 설정

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. 프로젝트 선택 또는 생성
3. **Authentication** → **Sign-in method** → **Google** 활성화
4. 프로젝트 지원 이메일 입력

### 1.2 Android 설정

1. Firebase Console에서 **Project Settings** → **Your apps** → Android 앱 추가
2. 패키지 이름 입력: `com.example.fire_safety_inspector`
3. SHA-1 인증서 지문 추가:
   ```bash
   # Debug 키 SHA-1 얻기
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # Release 키 SHA-1 얻기
   keytool -list -v -keystore <your-release-keystore-path> -alias <your-alias>
   ```
4. `google-services.json` 다운로드 후 `android/app/` 디렉토리에 저장

### 1.3 iOS 설정 (필요시)

1. Firebase Console에서 iOS 앱 추가
2. Bundle ID 입력
3. `GoogleService-Info.plist` 다운로드 후 `ios/Runner/` 디렉토리에 저장
4. `ios/Runner/Info.plist`에 URL scheme 추가:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.[REVERSED_CLIENT_ID]</string>
       </array>
     </dict>
   </array>
   ```

---

## 2. 카카오 로그인 설정

### 2.1 카카오 개발자 콘솔 설정

1. [카카오 개발자 콘솔](https://developers.kakao.com/)에 접속
2. 애플리케이션 추가 또는 선택
3. **앱 설정** → **요약 정보**에서 다음 키 확인:
   - Native 앱 키
   - JavaScript 앱 키

### 2.2 플랫폼 등록

#### Android
1. **앱 설정** → **플랫폼** → **Android 플랫폼 등록**
2. 패키지명: `com.example.fire_safety_inspector`
3. 키 해시 등록:
   ```bash
   # Debug 키 해시
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64

   # Release 키 해시
   keytool -exportcert -alias <your-alias> -keystore <your-keystore-path> | openssl sha1 -binary | openssl base64
   ```

#### iOS (필요시)
1. **앱 설정** → **플랫폼** → **iOS 플랫폼 등록**
2. Bundle ID 입력

### 2.3 코드에 앱 키 설정

1. `lib/main.dart` 파일 수정:
   ```dart
   KakaoSdk.init(
     nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',  // 여기에 실제 네이티브 앱 키 입력
     javaScriptAppKey: 'YOUR_KAKAO_JAVASCRIPT_APP_KEY',  // 여기에 실제 JavaScript 앱 키 입력
   );
   ```

2. `android/app/src/main/AndroidManifest.xml` 파일 수정:
   ```xml
   <data android:host="oauth"
         android:scheme="kakaoYOUR_KAKAO_NATIVE_APP_KEY" />  <!-- kakao 뒤에 실제 앱 키 입력 -->
   ```

### 2.4 Redirect URI 등록

1. **앱 설정** → **제품 설정** → **카카오 로그인** → **Redirect URI 등록**
2. Android: `kakao{YOUR_APP_KEY}://oauth`
3. 카카오 로그인 활성화

---

## 3. 네이버 로그인 설정

### 3.1 네이버 개발자 센터 설정

1. [네이버 개발자 센터](https://developers.naver.com/)에 접속
2. **Application** → **애플리케이션 등록**
3. 애플리케이션 정보 입력:
   - 애플리케이션 이름
   - 사용 API: 네이버 로그인
   - 제공 정보: 이메일, 닉네임, 프로필 사진 등

### 3.2 환경 설정

1. **API 설정** → **Android**:
   - 패키지명: `com.example.fire_safety_inspector`

2. **API 설정** → **iOS** (필요시):
   - URL Scheme 입력

### 3.3 Client ID/Secret 확인

1. **Application** → **내 애플리케이션**에서 Client ID와 Client Secret 확인

### 3.4 코드에 Client ID/Secret 설정

네이버 로그인은 플랫폼별로 설정이 필요합니다:

#### Android: `android/app/src/main/res/values/strings.xml` 생성
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="naver_client_id">YOUR_NAVER_CLIENT_ID</string>
    <string name="naver_client_secret">YOUR_NAVER_CLIENT_SECRET</string>
    <string name="naver_client_name">Fire Safety Inspector</string>
</resources>
```

#### iOS: `ios/Runner/Info.plist` (필요시)
```xml
<key>NaverThirdPartyConstantsForApp</key>
<dict>
    <key>kConsumerKey</key>
    <string>YOUR_NAVER_CLIENT_ID</string>
    <key>kConsumerSecret</key>
    <string>YOUR_NAVER_CLIENT_SECRET</string>
    <key>kServiceAppName</key>
    <string>Fire Safety Inspector</string>
    <key>kServiceAppUrlScheme</key>
    <string>naverloginYOUR_NAVER_CLIENT_ID</string>
</dict>
```

---

## 4. Firebase 설정

### 4.1 Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. 프로젝트 이름 입력
3. Google Analytics 설정 (선택 사항)

### 4.2 Android 앱 추가

1. Firebase Console에서 Android 앱 추가
2. 패키지명: `com.example.fire_safety_inspector`
3. `google-services.json` 다운로드
4. `android/app/` 디렉토리에 저장

### 4.3 iOS 앱 추가 (필요시)

1. Firebase Console에서 iOS 앱 추가
2. Bundle ID 입력
3. `GoogleService-Info.plist` 다운로드
4. `ios/Runner/` 디렉토리에 저장

### 4.4 Firebase Authentication 설정

1. Firebase Console → **Authentication**
2. **Sign-in method** 탭에서 다음 활성화:
   - Google
   - 익명(카카오/네이버 로그인용)

### 4.5 Firestore 설정

1. Firebase Console → **Firestore Database**
2. **데이터베이스 만들기**
3. 테스트 모드 또는 프로덕션 모드 선택
4. 위치 선택 (asia-northeast3 권장)

### 4.6 보안 규칙 설정

Firestore 보안 규칙 예시:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 데이터만 읽고 쓸 수 있음
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // 점검 데이터는 인증된 사용자만 접근 가능
    match /inspections/{inspectionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 5. 빌드 및 테스트

### 5.1 패키지 설치
```bash
flutter pub get
```

### 5.2 Android 빌드
```bash
flutter build apk --debug
# 또는
flutter run
```

### 5.3 로그인 테스트

1. 앱 실행
2. 각 소셜 로그인 버튼 클릭
3. 로그인 프로세스 확인
4. Firebase Console에서 사용자 등록 확인

---

## 6. 주의사항

### 보안
- **절대 API 키를 Git에 커밋하지 마세요!**
- `google-services.json`과 `GoogleService-Info.plist`는 `.gitignore`에 추가
- 프로덕션에서는 환경 변수 사용 권장

### 카카오/네이버 로그인 제한사항
- 현재 구현은 Firebase 익명 로그인을 사용합니다
- 완전한 통합을 위해서는 백엔드에서 Custom Token 생성 필요
- 자세한 내용은 [Firebase Custom Token](https://firebase.google.com/docs/auth/admin/create-custom-tokens) 참고

### 디버그 vs 릴리스
- 디버그와 릴리스 빌드는 각각 다른 키 해시 필요
- 각 플랫폼 개발자 콘솔에 모두 등록 필요

---

## 7. 문제 해결

### 구글 로그인 실패
- SHA-1 인증서가 올바르게 등록되었는지 확인
- `google-services.json` 파일이 올바른 위치에 있는지 확인

### 카카오 로그인 실패
- 앱 키가 올바르게 설정되었는지 확인
- 키 해시가 정확한지 확인
- 카카오톡 앱 설치 여부 확인

### 네이버 로그인 실패
- Client ID/Secret이 올바른지 확인
- `strings.xml` 파일이 존재하는지 확인
- 패키지명이 일치하는지 확인

### Firebase 오류
- `google-services.json` 파일이 최신인지 확인
- Firebase SDK 버전 확인
- 인터넷 연결 확인

---

## 8. 참고 자료

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Kakao Flutter SDK](https://developers.kakao.com/docs/latest/ko/flutter/getting-started)
- [Naver Login for Flutter](https://pub.dev/packages/flutter_naver_login)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
