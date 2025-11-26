import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is not configured for Web yet, and not used by AuthProvider/NotificationService currently.
  // await Firebase.initializeApp(); 
  await NotificationService.instance.init();
  runApp(const FireSafetyInspectorApp());
} 