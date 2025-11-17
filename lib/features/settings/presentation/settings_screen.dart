import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '설정',
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 알림 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '알림',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('푸시 알림', style: AppTextStyles.bodyLarge),
                  subtitle: Text(
                    '점검 일정 및 알림 받기',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  secondary: Icon(
                    Icons.notifications,
                    color: AppColors.secondaryLight,
                  ),
                  value: provider.pushEnabled,
                  onChanged: provider.togglePush,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text('법령 업데이트 알림', style: AppTextStyles.bodyLarge),
                  subtitle: Text(
                    '소방 법령 변경 사항 알림',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  secondary: Icon(
                    Icons.gavel,
                    color: AppColors.tertiaryLight,
                  ),
                  value: provider.lawUpdateEnabled,
                  onChanged: provider.toggleLawUpdate,
                ),
              ],
            ),
          ),

          // 백업 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              '데이터 백업',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Wi-Fi에서만 백업', style: AppTextStyles.bodyLarge),
                  subtitle: Text(
                    '데이터 절약을 위해 Wi-Fi 연결 시에만 백업',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  secondary: Icon(
                    Icons.wifi,
                    color: AppColors.secondaryLight,
                  ),
                  value: provider.backupWifiOnly,
                  onChanged: provider.toggleBackupWifiOnly,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: provider.backingUp
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.cloud_upload,
                          color: AppColors.statusGood,
                        ),
                  title: Text('수동 백업', style: AppTextStyles.bodyLarge),
                  subtitle: Text(
                    '지금 데이터 백업하기',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                  onTap: provider.backingUp ? null : provider.manualBackup,
                ),
              ],
            ),
          ),

          // 계정 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              '계정',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: AppColors.errorLight,
              ),
              title: Text(
                '로그아웃',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.errorLight,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.onSurfaceVariantLight,
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('로그아웃', style: AppTextStyles.titleMedium),
                    content: Text(
                      '정말 로그아웃 하시겠습니까?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('취소', style: AppTextStyles.labelLarge),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          '로그아웃',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.errorLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 