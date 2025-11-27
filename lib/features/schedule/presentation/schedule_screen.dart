// 한국어 주석: 일정 관리 화면
/// Schedule management screen with calendar and task list

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/accessibility_wrapper.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 샘플 일정 데이터
  final Map<DateTime, List<ScheduleEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  void _initializeEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _events[today] = [
      ScheduleEvent(
        title: '강남 파이낸스 센터',
        type: '정기 점검',
        time: '09:00',
        status: ScheduleStatus.scheduled,
      ),
      ScheduleEvent(
        title: '서초 자이 아파트',
        type: '수시 점검',
        time: '14:00',
        status: ScheduleStatus.inProgress,
      ),
    ];
    _events[today.add(const Duration(days: 1))] = [
      ScheduleEvent(
        title: '역삼 빌딩',
        type: '정기 점검',
        time: '10:00',
        status: ScheduleStatus.scheduled,
      ),
    ];
    _events[today.add(const Duration(days: 3))] = [
      ScheduleEvent(
        title: '삼성동 오피스텔',
        type: '특별 점검',
        time: '11:00',
        status: ScheduleStatus.scheduled,
      ),
    ];
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('일정 관리'),
        actions: [
          AccessibleIconButton(
            icon: Icons.today,
            semanticLabel: '오늘로 이동',
            tooltip: '오늘',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
          AccessibleIconButton(
            icon: Icons.add,
            semanticLabel: '일정 추가',
            tooltip: '새 일정',
            onPressed: () {
              _showAddScheduleDialog();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: TableCalendar<ScheduleEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        locale: 'ko_KR',
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: const TextStyle(color: AppColors.primary),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildEventList() {
    final events = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : _getEventsForDay(_focusedDay);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '예정된 일정이 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: _showAddScheduleDialog,
              icon: const Icon(Icons.add),
              label: const Text('일정 추가'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(ScheduleEvent event) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () {
        // TODO: 일정 상세 화면으로 이동
      },
      child: Row(
        children: [
          // 시간 표시
          Container(
            width: 60,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getStatusColor(event.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  event.time,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(event.status),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 일정 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 상태 칩
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(event.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(event.status),
              style: TextStyle(
                color: _getStatusColor(event.status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return AppColors.info;
      case ScheduleStatus.inProgress:
        return AppColors.warning;
      case ScheduleStatus.completed:
        return AppColors.success;
      case ScheduleStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.scheduled:
        return '예정';
      case ScheduleStatus.inProgress:
        return '진행중';
      case ScheduleStatus.completed:
        return '완료';
      case ScheduleStatus.cancelled:
        return '취소';
    }
  }

  void _showAddScheduleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '새 일정 추가',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // TODO: 일정 추가 폼 구현
            const Center(
              child: Text('일정 추가 폼을 구현해주세요'),
            ),
          ],
        ),
      ),
    );
  }
}

// 일정 데이터 모델
class ScheduleEvent {
  final String title;
  final String type;
  final String time;
  final ScheduleStatus status;

  ScheduleEvent({
    required this.title,
    required this.type,
    required this.time,
    required this.status,
  });
}

enum ScheduleStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}
