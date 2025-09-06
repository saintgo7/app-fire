import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'shared/providers/connectivity_provider.dart';
import 'shared/providers/sync_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/report/presentation/report_screen.dart';
import 'features/schedule/presentation/schedule_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/legal/presentation/legal_screen.dart';
import 'features/inspection/presentation/inspection_screen.dart';

class FireSafetyInspectorApp extends StatelessWidget {
  const FireSafetyInspectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProxyProvider<ConnectivityProvider, SyncProvider>(
          create: (context) => SyncProvider(context.read<ConnectivityProvider>()),
          update: (_, connectivity, previous) => previous ?? SyncProvider(connectivity),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Fire Safety Inspector',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/report': (_) => const ReportScreen(),
          '/schedule': (_) => const ScheduleScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/legal': (_) => const LegalScreen(),
          '/inspection': (_) => const InspectionScreen(),
        },
      ),
    );
  }
} 