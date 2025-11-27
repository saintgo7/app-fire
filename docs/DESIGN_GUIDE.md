# 소방점검관리사 앱 디자인 가이드

## 1. 디자인 시스템 개요

### 1.1 Material Design 3 기반
- `useMaterial3: true` 적용
- `ColorScheme.fromSeed()` 사용
- 16px~24px 라운드 코너

---

## 2. 색상 팔레트 (AppColors)

```dart
// 파일: lib/core/constants/app_colors.dart

// Primary - 프리미엄 레드
primary: #D32F2F      // 메인 강조색
primaryLight: #FF6659  // 밝은 버전
primaryDark: #9A0007   // 어두운 버전

// Secondary - 딥 틸
secondary: #00695C     // 보조 강조색
secondaryLight: #439889
secondaryDark: #003D33

// Surface & Background
surface: #FFFFFF       // 카드, 다이얼로그
surfaceVariant: #F5F7FA // 약간 어두운 표면
background: #F0F2F5    // 스크린 배경

// Status Colors
success: #43A047       // 정상, 완료
error: #E53935         // 오류, 불량
warning: #FB8C00       // 경고, 진행중
info: #1E88E5          // 정보

// Text Colors
textPrimary: #1A1C1E   // 제목, 중요 텍스트
textSecondary: #424242 // 부제목, 설명
textDisabled: #9E9E9E  // 비활성화
textOnPrimary: #FFFFFF // Primary 배경 위 텍스트

// Border & Divider
border: #E0E0E0
divider: #EEEEEE
```

### 사용 예시
```dart
Container(
  color: AppColors.primary,
  child: Text('텍스트', style: TextStyle(color: AppColors.textOnPrimary)),
)
```

---

## 3. 간격 시스템 (AppSpacing)

```dart
// 파일: lib/core/constants/app_spacing.dart

// Base Unit: 4dp
xs: 4.0    // 최소 간격
sm: 8.0    // 작은 간격
md: 16.0   // 기본 간격
lg: 24.0   // 큰 간격
xl: 32.0   // 매우 큰 간격
xxl: 48.0  // 최대 간격

// Specific
screenPadding: 16.0    // 화면 패딩
cardMargin: 8.0        // 카드 마진
cardPadding: 16.0      // 카드 패딩
buttonHeight: 48.0     // 버튼 높이
iconSize: 24.0         // 아이콘 크기
iconSizeSmall: 20.0
iconSizeLarge: 32.0
```

### 사용 예시
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.screenPadding),
  child: Column(
    children: [
      Widget1(),
      SizedBox(height: AppSpacing.md),
      Widget2(),
    ],
  ),
)
```

---

## 4. 타이포그래피 (AppTypography)

```dart
// 파일: lib/core/constants/app_typography.dart

// Font Family: Noto Sans KR

headline1: 24px Bold    // 대제목
headline2: 20px Bold    // 중제목
headline3: 18px Bold    // 소제목
title: 18px SemiBold    // 타이틀
titleMedium: 16px SemiBold
bodyLarge: 16px Regular // 본문 (강조)
body: 14px Regular      // 본문
caption: 12px Regular   // 캡션
button: 14px SemiBold   // 버튼 텍스트
label: 12px Medium      // 라벨
```

### 사용 예시
```dart
Text(
  '제목',
  style: Theme.of(context).textTheme.headlineSmall,
)
```

---

## 5. 공통 위젯

### 5.1 AppButton
```dart
// 파일: lib/shared/widgets/app_button.dart

// 타입: primary, secondary, outline, text
AppButton(
  text: '로그인',
  onPressed: () {},
  type: AppButtonType.primary,
  isLoading: false,
  icon: Icons.login,
)
```

### 5.2 AppCard
```dart
// 파일: lib/shared/widgets/app_card.dart

AppCard(
  child: Column(...),
  padding: EdgeInsets.all(16),
  onTap: () {},
  semanticLabel: '카드 설명',
)
```

### 5.3 StatusChip
```dart
// 파일: lib/shared/widgets/status_chip.dart

StatusChip(
  status: ChecklistStatus.normal,  // normal, defective, notApplicable
  selected: true,
  onTap: () {},
)
```

### 5.4 AccessibleIconButton
```dart
// 파일: lib/shared/widgets/accessibility_wrapper.dart

AccessibleIconButton(
  icon: Icons.settings,
  semanticLabel: '설정',
  tooltip: '설정 열기',
  onPressed: () {},
)
```

---

## 6. 화면 템플릿

### 6.1 기본 화면 구조
```dart
Scaffold(
  backgroundColor: AppColors.background,
  appBar: AppBar(
    title: Text('화면 제목'),
    actions: [
      AccessibleIconButton(...),
    ],
  ),
  body: ListView(
    padding: EdgeInsets.all(AppSpacing.screenPadding),
    children: [
      // 콘텐츠
    ],
  ),
)
```

### 6.2 카드 리스트 화면
```dart
Scaffold(
  body: ListView.builder(
    padding: EdgeInsets.all(AppSpacing.screenPadding),
    itemCount: items.length,
    itemBuilder: (context, index) {
      return AppCard(
        child: ListTile(
          title: Text(items[index].title),
          subtitle: Text(items[index].subtitle),
          trailing: Icon(Icons.chevron_right),
        ),
        onTap: () {},
      );
    },
  ),
)
```

### 6.3 폼 화면
```dart
Scaffold(
  body: SingleChildScrollView(
    padding: EdgeInsets.all(AppSpacing.screenPadding),
    child: Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: '이메일',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            text: '저장',
            onPressed: () {},
          ),
        ],
      ),
    ),
  ),
)
```

---

## 7. 화면별 현황

| 화면 | 파일 | 상태 |
|------|------|------|
| 로그인 | `login_screen.dart` | ✅ 완성 |
| 회원가입 | `register_screen.dart` | ✅ 완성 |
| 홈 | `home_screen.dart` | ✅ 완성 |
| 점검 | `inspection_screen.dart` | ✅ 완성 |
| 설정 | `settings_screen.dart` | ✅ 완성 |
| 일정 | `schedule_screen.dart` | ⚠️ Placeholder |
| 법령 | `legal_screen.dart` | ⚠️ Placeholder |
| 보고서 | `report_screen.dart` | ⚠️ Placeholder |

---

## 8. 디자인 패턴

### 8.1 그라데이션 카드 (홈 화면 스타일)
```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primary, AppColors.primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: // 콘텐츠
)
```

### 8.2 스탯 카드
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.border.withOpacity(0.5)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      Icon(Icons.check_circle, color: AppColors.success),
      Text('12', style: Theme.of(context).textTheme.headlineMedium),
      Text('완료'),
    ],
  ),
)
```

### 8.3 Quick Action 버튼
```dart
InkWell(
  onTap: () {},
  borderRadius: BorderRadius.circular(16),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
      SizedBox(height: 8),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  ),
)
```

---

## 9. 접근성 가이드

### 9.1 필수 사항
- 모든 버튼에 `semanticLabel` 제공
- 아이콘 버튼에 `tooltip` 추가
- 최소 터치 영역 48dp 유지
- 색상 대비 비율 4.5:1 이상

### 9.2 위젯 사용
```dart
// 버튼
AccessibleButton(
  semanticLabel: '저장 버튼',
  hint: '변경사항을 저장합니다',
  child: ElevatedButton(...),
)

// 아이콘 버튼
AccessibleIconButton(
  icon: Icons.settings,
  semanticLabel: '설정',
  tooltip: '설정 열기',
)

// 카드
AccessibleCard(
  semanticLabel: '점검 항목 카드',
  child: Card(...),
)
```

---

## 10. 파일 구조

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # 색상
│   │   ├── app_spacing.dart     # 간격
│   │   └── app_typography.dart  # 타이포그래피
│   └── theme/
│       ├── app_theme.dart       # 테마 설정
│       └── accessibility_theme.dart
│
├── shared/
│   └── widgets/
│       ├── app_button.dart      # 공통 버튼
│       ├── app_card.dart        # 공통 카드
│       ├── status_chip.dart     # 상태 칩
│       └── accessibility_wrapper.dart
│
└── features/
    ├── auth/presentation/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── home/presentation/
    │   └── home_screen.dart
    ├── inspection/presentation/
    │   └── inspection_screen.dart
    ├── settings/presentation/
    │   └── settings_screen.dart
    ├── schedule/presentation/
    │   └── schedule_screen.dart    # TODO
    ├── legal/presentation/
    │   └── legal_screen.dart       # TODO
    └── report/presentation/
        └── report_screen.dart      # TODO
```
