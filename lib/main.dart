import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 카카오 SDK 초기화
  // TODO: 실제 네이티브 앱 키로 변경 필요
  KakaoSdk.init(
    nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',
    javaScriptAppKey: 'YOUR_KAKAO_JAVASCRIPT_APP_KEY',
  );

  // 알림 서비스 초기화
  await NotificationService.instance.init();

  runApp(const FireSafetyInspectorApp());
} 