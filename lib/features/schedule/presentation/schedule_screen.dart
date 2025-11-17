import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '점검 일정',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            tooltip: '월별 보기',
            onPressed: () {
              // TODO: 월별 캘린더 보기
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이번 주 일정
            _buildWeeklySchedule(context),
            const SizedBox(height: 24),

            // 예정된 점검
            Text(
              '예정된 점검',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildScheduleList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '새 일정 추가 (준비 중)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          '일정 추가',
          style: AppTextStyles.labelLarge,
        ),
      ),
    );
  }

  /// 이번 주 일정 요약
  Widget _buildWeeklySchedule(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(7, (index) {
      final date = now.add(Duration(days: index - now.weekday + 1));
      return date;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번 주',
                  style: AppTextStyles.titleLarge,
                ),
                Chip(
                  label: Text(
                    '총 5건',
                    style: AppTextStyles.labelSmall,
                  ),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 요일별 카드
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDays.length,
                itemBuilder: (context, index) {
                  final date = weekDays[index];
                  final isToday = date.day == now.day &&
                      date.month == now.month &&
                      date.year == now.year;
                  final hasSchedule = index == 1 || index == 3 || index == 5;

                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primaryLight
                                : hasSchedule
                                    ? AppColors.secondaryLight.withOpacity(0.1)
                                    : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getWeekdayName(date.weekday),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isToday
                                      ? Colors.white
                                      : AppColors.onSurfaceLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: isToday
                                      ? Colors.white
                                      : AppColors.onSurfaceLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (hasSchedule)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 일정 목록
  Widget _buildScheduleList(BuildContext context) {
    final schedules = [
      {
        'building': '서울시청 본관',
        'date': '2025-01-20',
        'time': '10:00',
        'priority': 'high',
      },
      {
        'building': '도봉구청',
        'date': '2025-01-22',
        'time': '14:00',
        'priority': 'medium',
      },
      {
        'building': '방학동 주민센터',
        'date': '2025-01-24',
        'time': '09:30',
        'priority': 'high',
      },
      {
        'building': '창동역 지하상가',
        'date': '2025-01-26',
        'time': '13:00',
        'priority': 'low',
      },
    ];

    return Column(
      children: schedules.map((schedule) {
        final priority = schedule['priority'];
        Color priorityColor;
        if (priority == 'high') {
          priorityColor = AppColors.priorityHigh;
        } else if (priority == 'medium') {
          priorityColor = AppColors.priorityMedium;
        } else {
          priorityColor = AppColors.priorityLow;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event,
                color: priorityColor,
                size: 28,
              ),
            ),
            title: Text(
              schedule['building']!,
              style: AppTextStyles.inspectionItemTitle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule['date']!,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.onSurfaceVariantLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule['time']!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                priority == 'high'
                    ? '긴급'
                    : priority == 'medium'
                        ? '보통'
                        : '낮음',
                style: AppTextStyles.labelSmall.copyWith(
                  color: priorityColor,
                ),
              ),
              backgroundColor: priorityColor.withOpacity(0.1),
              side: BorderSide.none,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${schedule['building']} 일정 상세',
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

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }
}
