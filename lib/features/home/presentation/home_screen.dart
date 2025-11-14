import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/providers/sync_provider.dart';
import '../../../shared/providers/connectivity_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final syncProvider = context.watch<SyncProvider>();
    final connectivityProvider = context.watch<ConnectivityProvider>();

    // 인증되지 않은 경우 로그인 화면으로 이동
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('소방 안전 점검'),
        actions: [
          // 네트워크 상태 표시
          IconButton(
            icon: Icon(
              connectivityProvider.isOnline
                  ? Icons.cloud_done
                  : Icons.cloud_off,
              color: connectivityProvider.isOnline
                  ? AppColors.statusGood
                  : AppColors.statusWarning,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    connectivityProvider.isOnline
                        ? '온라인'
                        : '오프라인 모드',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // 동기화 버튼
          IconButton(
            icon: syncProvider.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: syncProvider.isSyncing
                ? null
                : () async {
                    await syncProvider.manualSync();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            syncProvider.errorMessage ??
                                '동기화 완료: ${syncProvider.syncedInspections}개 업로드, ${syncProvider.downloadedBuildings}개 다운로드',
                          ),
                          backgroundColor: syncProvider.errorMessage != null
                              ? AppColors.errorLight
                              : AppColors.statusGood,
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await syncProvider.manualSync();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 환영 카드
              _buildWelcomeCard(context, authProvider),
              const SizedBox(height: 24),

              // 통계 카드들
              Text(
                '오늘의 현황',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildStatisticsCards(context),
              const SizedBox(height: 24),

              // 빠른 액션 버튼들
              Text(
                '빠른 메뉴',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // 최근 점검 목록
              Text(
                '최근 점검',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildRecentInspections(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/inspection');
        },
        icon: const Icon(Icons.add_task),
        label: const Text('새 점검'),
      ),
    );
  }

  /// 환영 카드
  Widget _buildWelcomeCard(BuildContext context, AuthProvider authProvider) {
    final userName = authProvider.user?['name'] ?? '점검관';
    final organization = authProvider.user?['organization'] ?? '';

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryLight,
              AppColors.primaryLight.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안녕하세요, $userName님',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (organization.isNotEmpty)
                        Text(
                          organization,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '오늘도 안전한 하루 되세요!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 카드들
  Widget _buildStatisticsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle,
            iconColor: AppColors.statusGood,
            label: '완료',
            value: '12',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.pending_actions,
            iconColor: AppColors.statusWarning,
            label: '진행중',
            value: '3',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.error,
            iconColor: AppColors.statusDefective,
            label: '불량',
            value: '1',
          ),
        ),
      ],
    );
  }

  /// 통계 카드 (개별)
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.statisticsNumber,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.statisticsLabel,
            ),
          ],
        ),
      ),
    );
  }

  /// 빠른 액션 버튼들
  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildQuickActionCard(
          context,
          icon: Icons.list_alt,
          label: '점검 목록',
          color: AppColors.secondaryLight,
          onTap: () => Navigator.pushNamed(context, '/inspection'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.apartment,
          label: '건물 관리',
          color: AppColors.tertiaryLight,
          onTap: () {
            // TODO: 건물 목록 화면으로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('건물 관리 화면 (준비 중)')),
            );
          },
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.assessment,
          label: '리포트',
          color: AppColors.equipmentSprinkler,
          onTap: () => Navigator.pushNamed(context, '/report'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.calendar_today,
          label: '일정',
          color: AppColors.equipmentAlarm,
          onTap: () => Navigator.pushNamed(context, '/schedule'),
        ),
      ],
    );
  }

  /// 빠른 액션 카드 (개별)
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 최근 점검 목록
  Widget _buildRecentInspections(BuildContext context) {
    // TODO: 실제 데이터로 교체
    final recentInspections = [
      {
        'building': '서울시청 본관',
        'date': '2025-01-14',
        'status': 'completed',
        'statusLabel': '완료',
      },
      {
        'building': '도봉구청',
        'date': '2025-01-13',
        'status': 'pending',
        'statusLabel': '진행중',
      },
      {
        'building': '방학동 주민센터',
        'date': '2025-01-12',
        'status': 'defective',
        'statusLabel': '불량 발견',
      },
    ];

    return Column(
      children: recentInspections
          .map((inspection) =>
              _buildInspectionCard(context, inspection))
          .toList(),
    );
  }

  /// 점검 카드 (개별)
  Widget _buildInspectionCard(
    BuildContext context,
    Map<String, String> inspection,
  ) {
    Color statusColor;
    switch (inspection['status']) {
      case 'completed':
        statusColor = AppColors.statusGood;
        break;
      case 'pending':
        statusColor = AppColors.statusWarning;
        break;
      case 'defective':
        statusColor = AppColors.statusDefective;
        break;
      default:
        statusColor = AppColors.statusPending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: 점검 상세 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${inspection['building']} 상세 보기'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection['building']!,
                      style: AppTextStyles.inspectionItemTitle,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.onSurfaceVariantLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          inspection['date']!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariantLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 상태 칩
              Chip(
                label: Text(
                  inspection['statusLabel']!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                  ),
                ),
                backgroundColor: statusColor.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 