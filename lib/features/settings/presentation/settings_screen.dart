// 한국어 주석: 앱 설정 화면
/// App settings screen with user preferences and account management.

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
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '점검자',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'inspector@example.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notification Settings Section
          _buildSectionHeader(context, '알림 설정'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('푸시 알림'),
                  subtitle: const Text('점검 일정 및 중요 공지사항'),
                  value: provider.pushEnabled,
                  onChanged: provider.togglePush,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.update),
                  title: const Text('법령 업데이트 알림'),
                  subtitle: const Text('소방 관련 법령 개정 알림'),
                  value: provider.lawUpdateEnabled,
                  onChanged: provider.toggleLawUpdate,
                ),
              ],
            ),
          ),

          // Data & Backup Section
          _buildSectionHeader(context, '데이터 및 백업'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.wifi),
                  title: const Text('Wi-Fi에서만 백업'),
                  subtitle: const Text('데이터 사용량 절약'),
                  value: provider.backupWifiOnly,
                  onChanged: provider.toggleBackupWifiOnly,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: provider.backingUp
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  title: const Text('수동 백업'),
                  subtitle: const Text('지금 데이터 백업하기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: provider.backingUp ? null : provider.manualBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('저장 공간 관리'),
                  subtitle: const Text('캐시 및 임시 파일 삭제'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show storage management
                    _showStorageDialog(context);
                  },
                ),
              ],
            ),
          ),

          // App Information Section
          _buildSectionHeader(context, '앱 정보'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('버전 정보'),
                  subtitle: const Text('v0.1.0+1'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show version info
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('이용약관'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show terms of service
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('개인정보 처리방침'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
              ],
            ),
          ),

          // Account Section
          _buildSectionHeader(context, '계정'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () async {
                final shouldLogout = await _showLogoutDialog(context);
                if (shouldLogout == true) {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (_) => false);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장 공간 관리'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('사용 중인 저장 공간: 42.5 MB'),
            const SizedBox(height: 16),
            const Text('• 이미지: 35.2 MB'),
            const Text('• 보고서: 5.8 MB'),
            const Text('• 캐시: 1.5 MB'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Clear cache
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('캐시가 삭제되었습니다')),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('캐시 삭제'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
