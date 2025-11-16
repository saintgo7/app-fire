// 한국어 주석: 메인 홈 화면
/// Main home screen with dashboard and quick navigation.

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소방안전 점검'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '설정',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘도 안전한 점검을 시작하세요',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '빠른 실행',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _QuickActionCard(
                        icon: Icons.assignment_outlined,
                        title: '점검 시작',
                        subtitle: '새로운 점검',
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/inspection'),
                      ),
                      _QuickActionCard(
                        icon: Icons.calendar_today,
                        title: '일정 관리',
                        subtitle: '점검 일정',
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/schedule'),
                      ),
                      _QuickActionCard(
                        icon: Icons.description_outlined,
                        title: '보고서',
                        subtitle: '점검 보고서',
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/report'),
                      ),
                      _QuickActionCard(
                        icon: Icons.gavel,
                        title: '법령 정보',
                        subtitle: '관련 법령',
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/legal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Inspections
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '최근 점검',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Show all inspections
                        },
                        child: const Text('전체보기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RecentInspectionCard(
                    buildingName: '강남 타워',
                    date: '2024-03-15',
                    status: '완료',
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _RecentInspectionCard(
                    buildingName: '서초 오피스텔',
                    date: '2024-03-10',
                    status: '진행중',
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/inspection'),
        icon: const Icon(Icons.add),
        label: const Text('새 점검'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentInspectionCard extends StatelessWidget {
  final String buildingName;
  final String date;
  final String status;
  final Color statusColor;

  const _RecentInspectionCard({
    required this.buildingName,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.business, color: statusColor),
        ),
        title: Text(
          buildingName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // TODO: Open inspection details
        },
      ),
    );
  }
}
