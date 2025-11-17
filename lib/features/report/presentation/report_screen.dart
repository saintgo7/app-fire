import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '리포트',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: '필터',
            onPressed: () {
              // TODO: 필터 기능
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: '다운로드',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'PDF 다운로드 (준비 중)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 요약 카드
            _buildSummaryCard(context),
            const SizedBox(height: 24),

            // 기간별 통계
            Text(
              '기간별 점검 현황',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildPeriodStats(context),
            const SizedBox(height: 24),

            // 불량 항목 목록
            Text(
              '불량 항목 (최근)',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildDefectiveItems(context),
          ],
        ),
      ),
    );
  }

  /// 통계 요약 카드
  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: AppColors.primaryLight,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '이번 달 점검 통계',
                  style: AppTextStyles.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 통계 그리드
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: '총 점검',
                    value: '48',
                    color: AppColors.secondaryLight,
                    icon: Icons.list_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    label: '정상',
                    value: '42',
                    color: AppColors.statusGood,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: '불량',
                    value: '6',
                    color: AppColors.statusDefective,
                    icon: Icons.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    label: '진행중',
                    value: '3',
                    color: AppColors.statusWarning,
                    icon: Icons.pending_actions,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.statisticsNumber.copyWith(
              color: color,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.statisticsLabel,
          ),
        ],
      ),
    );
  }

  /// 기간별 통계
  Widget _buildPeriodStats(BuildContext context) {
    final periods = [
      {'period': '2025-01', 'total': 48, 'defective': 6},
      {'period': '2024-12', 'total': 52, 'defective': 4},
      {'period': '2024-11', 'total': 45, 'defective': 8},
      {'period': '2024-10', 'total': 50, 'defective': 5},
    ];

    return Column(
      children: periods.map((period) {
        final total = period['total'] as int;
        final defective = period['defective'] as int;
        final successRate = ((total - defective) / total * 100).toInt();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 기간
                Container(
                  width: 80,
                  child: Text(
                    period['period'] as String,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                const SizedBox(width: 16),

                // 진행률 바
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '정상률: $successRate%',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            '불량: $defective건',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.statusDefective,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: successRate / 100,
                          minHeight: 8,
                          backgroundColor: AppColors.statusDefective.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            successRate >= 90
                                ? AppColors.statusGood
                                : successRate >= 75
                                    ? AppColors.statusWarning
                                    : AppColors.statusDefective,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 불량 항목 목록
  Widget _buildDefectiveItems(BuildContext context) {
    final defectiveItems = [
      {
        'building': '서울시청 본관',
        'item': '소화기: 압력 게이지',
        'date': '2025-01-15',
      },
      {
        'building': '도봉구청',
        'item': '스프링클러: 배관 압력',
        'date': '2025-01-14',
      },
      {
        'building': '방학동 주민센터',
        'item': '자동화재탐지: 감지기 상태',
        'date': '2025-01-13',
      },
    ];

    return Column(
      children: defectiveItems.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.statusDefective.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error,
                color: AppColors.statusDefective,
                size: 28,
              ),
            ),
            title: Text(
              item['building']!,
              style: AppTextStyles.inspectionItemTitle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item['item']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.statusDefective,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['date']!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.onSurfaceVariantLight,
            ),
            onTap: () {
              // TODO: 상세 보기
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${item['building']} 상세 보기',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
