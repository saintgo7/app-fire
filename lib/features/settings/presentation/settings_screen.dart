import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('푸시 알림'),
            value: provider.pushEnabled,
            onChanged: provider.togglePush,
          ),
          SwitchListTile(
            title: const Text('법령 업데이트 알림'),
            value: provider.lawUpdateEnabled,
            onChanged: provider.toggleLawUpdate,
          ),
          SwitchListTile(
            title: const Text('Wi-Fi에서만 백업'),
            value: provider.backupWifiOnly,
            onChanged: provider.toggleBackupWifiOnly,
          ),
          ListTile(
            leading: provider.backingUp
                ? const CircularProgressIndicator()
                : const Icon(Icons.cloud_upload),
            title: const Text('수동 백업'),
            onTap: provider.manualBackup,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
          ),
        ],
      ),
    );
  }
} 