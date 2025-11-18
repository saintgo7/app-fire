class Environment {
  // 환경 타입
  static const String dev = 'dev';
  static const String staging = 'staging';
  static const String production = 'production';

  // 현재 환경 (빌드 시 변경)
  static const String currentEnvironment = String.fromEnvironment(
    'ENV',
    defaultValue: dev,
  );

  // API Base URL
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case production:
        // 실제 프로덕션 도메인으로 변경
        return 'https://api.fire-safety-inspector.com/api';
      case staging:
        // 스테이징 서버 (테스트용)
        return 'https://staging-api.fire-safety-inspector.com/api';
      case dev:
      default:
        // 개발 환경
        // Android 에뮬레이터: 10.0.2.2
        // iOS 시뮬레이터: localhost
        // 실제 기기: 컴퓨터의 로컬 IP
        return 'http://10.0.2.2:3000/api';
    }
  }

  // 환경별 설정
  static bool get isProduction => currentEnvironment == production;
  static bool get isDevelopment => currentEnvironment == dev;
  static bool get isStaging => currentEnvironment == staging;

  // 디버그 모드
  static bool get enableDebugLog => !isProduction;

  // 앱 이름
  static String get appName {
    switch (currentEnvironment) {
      case production:
        return 'Fire Safety Inspector';
      case staging:
        return 'Fire Safety Inspector (Staging)';
      case dev:
      default:
        return 'Fire Safety Inspector (Dev)';
    }
  }

  // 환경 정보 출력
  static void printEnvironmentInfo() {
    print('=================================');
    print('Environment: $currentEnvironment');
    print('API Base URL: $apiBaseUrl');
    print('App Name: $appName');
    print('Debug Log: $enableDebugLog');
    print('=================================');
  }
}
