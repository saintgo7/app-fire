import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화는 나중에 설정
  // await Firebase.initializeApp();
  await NotificationService.instance.init();
  runApp(const FireSafetyInspectorApp());
}
