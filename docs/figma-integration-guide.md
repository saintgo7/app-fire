# Figma 연동 가이드

소방 안전 점검 앱의 Flutter 코드와 Figma 디자인을 연결하는 가이드입니다.

## 📋 목차

1. [Figma Material Design 3 Kit 다운로드](#1-figma-material-design-3-kit-다운로드)
2. [디자인 토큰 동기화](#2-디자인-토큰-동기화)
3. [Figma to Flutter 워크플로우](#3-figma-to-flutter-워크플로우)
4. [컴포넌트 매핑 가이드](#4-컴포넌트-매핑-가이드)
5. [색상 스킴 커스터마이징](#5-색상-스킴-커스터마이징)

---

## 1. Figma Material Design 3 Kit 다운로드

### Material Design 3 공식 Kit

**다운로드 링크:**
- [Material Design 3 Design Kit (Google)](https://www.figma.com/community/file/1035203688168086460)

**포함 내용:**
- ✅ 모든 Material 3 컴포넌트
- ✅ Light/Dark 테마
- ✅ 색상 토큰
- ✅ 타이포그래피 시스템
- ✅ 아이콘 라이브러리

### 소방 안전 앱 전용 템플릿 (추천)

**추천 Figma 템플릿:**

1. **Fire Safety Mobile App Template**
   - 링크: [Figma Community - Fire Safety](https://www.figma.com/community/search?q=fire%20safety%20app)
   - 특징: 소방 관련 UI/UX 패턴

2. **Inspection & Checklist App Template**
   - 링크: [Figma Community - Inspection App](https://www.figma.com/community/search?q=inspection%20app)
   - 특징: 점검 리스트, 체크박스 UI

3. **Material 3 Dashboard Template**
   - 링크: [Figma Community - Dashboard](https://www.figma.com/community/search?q=material%20dashboard)
   - 특징: 데이터 시각화, 통계 대시보드

---

## 2. 디자인 토큰 동기화

### 2.1 색상 토큰 매핑

현재 Flutter 앱의 색상 스킴은 `lib/core/theme/app_colors.dart`에 정의되어 있습니다.

#### Figma에서 색상 설정하기

1. Figma에서 **Material Theme Builder** 플러그인 설치
   - Figma → Plugins → Browse plugins → "Material Theme Builder" 검색

2. Primary Color 설정
   ```
   Primary Color: #D32F2F (소방차 빨강)
   ```

3. 플러그인 실행 후 "Export to JSON" 클릭

4. JSON 파일을 Flutter 색상 코드로 변환
   ```json
   {
     "primary": "#D32F2F",
     "secondary": "#1976D2",
     "tertiary": "#FF6F00"
   }
   ```

#### Flutter 색상 스킴과 매핑

| Figma 토큰 | Flutter 코드 | 값 |
|-----------|-------------|-----|
| Primary | `AppColors.primaryLight` | `#D32F2F` |
| Secondary | `AppColors.secondaryLight` | `#1976D2` |
| Tertiary | `AppColors.tertiaryLight` | `#FF6F00` |
| Error | `AppColors.errorLight` | `#BA1A1A` |
| Background | `AppColors.backgroundLight` | `#FFFBFE` |
| Surface | `AppColors.surfaceLight` | `#FFFBFE` |

### 2.2 타이포그래피 토큰 매핑

`lib/core/theme/app_text_styles.dart`에 정의된 타이포그래피와 Figma를 동기화합니다.

| Figma Text Style | Flutter TextStyle | 크기 | 굵기 |
|-----------------|-------------------|------|------|
| Display Large | `AppTextStyles.displayLarge` | 57pt | Regular |
| Headline Large | `AppTextStyles.headlineLarge` | 32pt | Regular |
| Title Large | `AppTextStyles.titleLarge` | 22pt | Medium |
| Body Large | `AppTextStyles.bodyLarge` | 16pt | Regular |
| Label Large | `AppTextStyles.labelLarge` | 14pt | Medium |

#### Figma에서 Text Styles 설정

1. Figma에서 Text → Text Styles 메뉴 열기
2. 새 스타일 생성:
   - 이름: `Display/Large`
   - Font: Pretendard (또는 Roboto)
   - Size: 57
   - Weight: Regular (400)
   - Line Height: 64

3. 모든 텍스트 스타일 동일하게 생성

---

## 3. Figma to Flutter 워크플로우

### 옵션 1: 수동 구현 (권장)

**장점:** 완전한 제어, 최적화된 코드
**단점:** 시간 소요

**워크플로우:**
1. Figma에서 디자인 완성
2. Inspect 패널에서 스타일 확인
3. Flutter 위젯으로 수동 구현
4. 색상/폰트는 `app_colors.dart`, `app_text_styles.dart` 사용

**예시:**
```dart
// Figma: Card with 12pt radius, elevation 1
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 1,
  child: ...
)
```

### 옵션 2: DhiWise (반자동)

**링크:** [DhiWise - Figma to Flutter](https://www.dhiwise.com/)

**워크플로우:**
1. Figma 파일을 DhiWise에 업로드
2. 자동 변환된 Flutter 코드 다운로드
3. 기존 프로젝트에 통합 (색상/테마는 수동 조정)

**주의:** 생성된 코드는 최적화 필요

### 옵션 3: FlutterFlow (비주얼 빌더)

**링크:** [FlutterFlow](https://flutterflow.io/)

**워크플로우:**
1. FlutterFlow에서 Figma import
2. 비주얼 에디터에서 조정
3. Flutter 코드 export

**주의:** 복잡한 로직은 수동 구현 필요

---

## 4. 컴포넌트 매핑 가이드

### 4.1 Button 컴포넌트

#### Figma Component: Elevated Button
```
Properties:
- Width: Auto
- Height: 48pt
- Padding: 24pt horizontal, 12pt vertical
- Border Radius: 8pt
- Background: Primary color
```

#### Flutter 코드
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    minimumSize: const Size(64, 48),
  ),
  child: const Text('버튼'),
)
```

**또는 테마 사용:**
```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('버튼'),
) // 자동으로 app_theme.dart의 스타일 적용
```

### 4.2 Card 컴포넌트

#### Figma Component: Card
```
Properties:
- Border Radius: 12pt
- Elevation: Shadow (1dp)
- Background: Surface color
- Padding: 16pt
```

#### Flutter 코드
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('카드 제목', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Text('카드 내용', style: AppTextStyles.bodyMedium),
      ],
    ),
  ),
)
```

### 4.3 TextField 컴포넌트

#### Figma Component: TextField
```
Properties:
- Border Radius: 8pt
- Border: 1pt outline
- Padding: 16pt
- Label: Body Medium
```

#### Flutter 코드
```dart
TextField(
  decoration: const InputDecoration(
    labelText: '이메일',
    hintText: 'email@example.com',
    prefixIcon: Icon(Icons.email),
  ),
)
```

---

## 5. 색상 스킴 커스터마이징

### Material Theme Builder 사용

1. **웹사이트 접속**
   - [Material Theme Builder](https://m3.material.io/theme-builder)

2. **Primary Color 설정**
   - Primary: `#D32F2F` (소방차 빨강)
   - 자동으로 Secondary, Tertiary 색상 생성됨

3. **색상 조정**
   - Secondary: `#1976D2` (파랑)
   - Tertiary: `#FF6F00` (주황)

4. **Export**
   - "Export" → "Flutter (Dart)" 선택
   - 생성된 코드를 `app_colors.dart`에 복사

### Figma Plugin으로 생성

1. **Figma에서 Material Theme Builder 실행**
2. **색상 선택 및 미리보기**
3. **Export to Flutter** 클릭
4. **코드 복사하여 적용**

---

## 6. 실전 예시: 점검 항목 카드 디자인

### Figma 디자인

```
Component: Inspection Item Card
├─ Container (Card)
│  ├─ Border Radius: 12pt
│  ├─ Padding: 16pt
│  ├─ Background: Surface
│  │
│  ├─ Row
│  │  ├─ Icon (24x24) - Fire Department
│  │  ├─ Spacing: 12pt
│  │  ├─ Column (flex: 1)
│  │  │  ├─ Text: "스프링클러 점검" (Title Medium)
│  │  │  ├─ Spacing: 4pt
│  │  │  └─ Text: "2025-01-14" (Body Small, Grey)
│  │  │
│  │  └─ Chip
│  │     ├─ Text: "양호" (Label Medium)
│  │     └─ Background: Green Container
```

### Flutter 구현

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        // 아이콘
        Icon(
          Icons.local_fire_department,
          size: 24,
          color: AppColors.primaryLight,
        ),
        const SizedBox(width: 12),

        // 텍스트 영역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '스프링클러 점검',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '2025-01-14',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
        ),

        // 상태 칩
        Chip(
          label: Text(
            '양호',
            style: AppTextStyles.labelMedium,
          ),
          backgroundColor: AppColors.statusGood.withOpacity(0.12),
          labelStyle: TextStyle(color: AppColors.statusGood),
        ),
      ],
    ),
  ),
)
```

---

## 7. Figma 파일 조직 구조 (권장)

```
📁 소방 안전 점검 앱
├─ 📄 Cover (프로젝트 소개)
├─ 🎨 Design Tokens
│  ├─ Colors (색상 팔레트)
│  ├─ Typography (텍스트 스타일)
│  └─ Spacing (간격 시스템)
│
├─ 🧩 Components
│  ├─ Buttons
│  ├─ Cards
│  ├─ TextFields
│  ├─ Chips
│  └─ App-specific (점검 항목, 건물 카드 등)
│
├─ 📱 Screens - Light
│  ├─ Login
│  ├─ Home
│  ├─ Inspection
│  ├─ Report
│  └─ Settings
│
└─ 🌙 Screens - Dark
   └─ (동일한 화면 구조)
```

---

## 8. 자주 사용하는 Figma 단축키

| 단축키 | 기능 |
|--------|------|
| `F` | Frame 생성 |
| `R` | Rectangle 생성 |
| `T` | Text 생성 |
| `Ctrl/Cmd + D` | 복제 |
| `Ctrl/Cmd + G` | 그룹 |
| `Alt + Drag` | 간격 확인 |
| `Ctrl/Cmd + K` | 컴포넌트 생성 |
| `Ctrl/Cmd + /` | 빠른 액션 |

---

## 9. 디자인 시스템 유지 관리

### 색상 변경 시

1. **Figma:**
   - Design Tokens 페이지에서 색상 수정
   - 모든 컴포넌트에 자동 반영

2. **Flutter:**
   - `lib/core/theme/app_colors.dart` 수정
   - Hot Reload로 즉시 확인

### 타이포그래피 변경 시

1. **Figma:**
   - Text Styles 수정

2. **Flutter:**
   - `lib/core/theme/app_text_styles.dart` 수정

---

## 10. 추천 Figma 플러그인

| 플러그인 | 용도 |
|---------|------|
| **Material Theme Builder** | Material 3 색상 생성 |
| **Iconify** | 아이콘 라이브러리 (Material Icons 포함) |
| **Unsplash** | 무료 이미지 |
| **Content Reel** | 더미 데이터 생성 |
| **Stark** | 접근성 체크 |
| **A11y - Color Contrast Checker** | 색상 대비 검사 |

---

## 11. 참고 자료

### 공식 문서
- [Material Design 3](https://m3.material.io/)
- [Flutter Material 3](https://docs.flutter.dev/ui/design/material)
- [Figma Best Practices](https://www.figma.com/best-practices/)

### 유용한 링크
- [Material Color Tool](https://m2.material.io/resources/color/)
- [Google Fonts](https://fonts.google.com/)
- [Material Icons](https://fonts.google.com/icons)

### 커뮤니티
- [Figma Community](https://www.figma.com/community)
- [Flutter UI Kits](https://flutterawesome.com/)

---

## 12. 문제 해결 (Troubleshooting)

### Q: Figma에서 본 색상과 Flutter에서 다르게 보여요
**A:** 색상 프로파일 차이일 수 있습니다.
- Figma에서 `#D32F2F` → Flutter에서 `Color(0xFFD32F2F)` 확인
- 투명도가 포함되었는지 확인 (ARGB vs RGB)

### Q: 폰트가 적용되지 않아요
**A:** 폰트 파일이 포함되었는지 확인
```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Medium.ttf
          weight: 500
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

### Q: Material 3 컴포넌트가 이상해요
**A:** `useMaterial3: true` 확인
```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true, // ← 이 부분!
  ),
)
```

---

## 🎯 빠른 시작 체크리스트

- [ ] Figma Material 3 Kit 다운로드
- [ ] 색상 팔레트 설정 (Primary: #D32F2F)
- [ ] Material Theme Builder로 색상 스킴 생성
- [ ] Flutter 앱에서 `AppTheme.lightTheme` 적용 확인
- [ ] 로그인 화면 디자인 → Flutter 구현
- [ ] 점검 리스트 화면 디자인 → Flutter 구현
- [ ] Light/Dark 테마 모두 확인

---

**작성일:** 2025-01-14
**업데이트:** Flutter 3.x + Material Design 3 기준
