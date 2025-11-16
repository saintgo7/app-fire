// 한국어 주석: 점검 일정 관리 화면
/// Schedule management screen with calendar view and inspection schedule list.

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Sample inspection schedule data
  final Map<DateTime, List<ScheduleItem>> _schedules = {
    DateTime.utc(2024, 3, 15): [
      ScheduleItem(
        buildingName: '강남 타워',
        time: '10:00',
        type: '정기점검',
        status: ScheduleStatus.scheduled,
      ),
    ],
    DateTime.utc(2024, 3, 20): [
      ScheduleItem(
        buildingName: '서초 오피스텔',
        time: '14:00',
        type: '종합점검',
        status: ScheduleStatus.scheduled,
      ),
      ScheduleItem(
        buildingName: '역삼 빌딩',
        time: '16:30',
        type: '정기점검',
        status: ScheduleStatus.scheduled,
      ),
    ],
    DateTime.utc(2024, 3, 10): [
      ScheduleItem(
        buildingName: '판교 오피스',
        time: '09:00',
        type: '정기점검',
        status: ScheduleStatus.completed,
      ),
    ],
  };

  List<ScheduleItem> _getSchedulesForDay(DateTime day) {
    return _schedules[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('점검 일정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: '필터',
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(8),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
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
              eventLoader: _getSchedulesForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),

          // Schedule List
          Expanded(
            child: _selectedDay != null
                ? _buildScheduleList(_getSchedulesForDay(_selectedDay!))
                : _buildUpcomingSchedules(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new schedule
          _showAddScheduleDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScheduleList(List<ScheduleItem> schedules) {
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '예정된 일정이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _ScheduleCard(schedule: schedule);
      },
    );
  }

  Widget _buildUpcomingSchedules() {
    final upcomingSchedules = <MapEntry<DateTime, ScheduleItem>>[];
    final now = DateTime.now();

    _schedules.forEach((date, items) {
      if (date.isAfter(now) || isSameDay(date, now)) {
        for (var item in items) {
          upcomingSchedules.add(MapEntry(date, item));
        }
      }
    });

    upcomingSchedules.sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '다가오는 일정',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...upcomingSchedules.map((entry) => _ScheduleCard(
              schedule: entry.value,
              showDate: true,
              date: entry.key,
            )),
      ],
    );
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 일정 추가'),
        content: const Text('일정 추가 기능은 곧 구현됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem schedule;
  final bool showDate;
  final DateTime? date;

  const _ScheduleCard({
    required this.schedule,
    this.showDate = false,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: schedule.status == ScheduleStatus.completed
              ? Colors.green.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          child: Icon(
            schedule.status == ScheduleStatus.completed
                ? Icons.check_circle
                : Icons.schedule,
            color: schedule.status == ScheduleStatus.completed
                ? Colors.green
                : Colors.blue,
          ),
        ),
        title: Text(
          schedule.buildingName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(schedule.time),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(schedule.type),
              ],
            ),
            if (showDate && date != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'),
                ],
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: schedule.status == ScheduleStatus.completed
                ? Colors.green.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            schedule.status == ScheduleStatus.completed ? '완료' : '예정',
            style: TextStyle(
              color: schedule.status == ScheduleStatus.completed
                  ? Colors.green
                  : Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // TODO: Show schedule details
        },
      ),
    );
  }
}

enum ScheduleStatus { scheduled, completed, cancelled }

class ScheduleItem {
  final String buildingName;
  final String time;
  final String type;
  final ScheduleStatus status;

  ScheduleItem({
    required this.buildingName,
    required this.time,
    required this.type,
    required this.status,
  });
}
