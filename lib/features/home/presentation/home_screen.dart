// 한국어 주석: 홈 화면 - 주요 기능 접근 및 대시보드
/// Home screen with quick access to main features and dashboard

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/accessibility_wrapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeSection(context),
                const SizedBox(height: 24),
                _buildStatsSection(context),
                const SizedBox(height: 32),
                _buildQuickActionsSection(context),
                const SizedBox(height: 32),
                _buildRecentInspectionsSection(context),
                const SizedBox(height: 80), // Bottom padding for FAB/Nav
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0, // Standard AppBar height
      floating: true,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Text(
        '소방점검관리사',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        AccessibleIconButton(
          icon: Icons.notifications_outlined,
          semanticLabel: '알림',
          tooltip: '알림',
          onPressed: () {
            // 알림 화면으로 이동
          },
        ),
        AccessibleIconButton(
          icon: Icons.settings_outlined,
          semanticLabel: '설정',
          tooltip: '설정',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity( 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '안녕하세요, 관리자님',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity( 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '오늘도 안전한\n하루 되세요!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity( 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '2023년 11월 26일', // 실제 날짜로 변경 필요
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '오늘의 현황',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                label: '완료',
                value: '12',
                total: '20',
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                label: '진행중',
                value: '5',
                total: '20',
                color: AppColors.warning,
                icon: Icons.timelapse,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String total,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity( 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                '$value/$total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '빠른 실행',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.add_task,
              label: '점검시작',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, '/inspection'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.calendar_month,
              label: '일정관리',
              color: AppColors.secondary,
              onTap: () => Navigator.pushNamed(context, '/schedule'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.analytics_outlined,
              label: '보고서',
              color: AppColors.info,
              onTap: () => Navigator.pushNamed(context, '/report'),
            ),
            _buildQuickActionButton(
              context,
              icon: Icons.gavel_outlined,
              label: '법령정보',
              color: AppColors.success,
              onTap: () => Navigator.pushNamed(context, '/legal'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInspectionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 활동',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('전체보기'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withOpacity( 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRecentActivityItem(
                context,
                title: '강남 파이낸스 센터',
                subtitle: '정기 소방 점검 완료',
                time: '2시간 전',
                status: '완료',
                statusColor: AppColors.success,
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildRecentActivityItem(
                context,
                title: '서초 자이 아파트',
                subtitle: '소방 시설 점검 진행중',
                time: '4시간 전',
                status: '진행중',
                statusColor: AppColors.warning,
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildRecentActivityItem(
                context,
                title: '역삼 빌딩',
                subtitle: '점검 예정',
                time: '내일',
                status: '대기',
                statusColor: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.business, color: AppColors.textSecondary),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textDisabled,
              fontSize: 11,
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GNav(
            gap: 8,
            activeColor: AppColors.primary,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppColors.primary.withOpacity( 0.1),
            color: AppColors.textDisabled,
            tabs: const [
              GButton(
                icon: Icons.home_rounded,
                text: '홈',
              ),
              GButton(
                icon: Icons.calendar_today_rounded,
                text: '일정',
              ),
              GButton(
                icon: Icons.analytics_rounded,
                text: '보고서',
              ),
              GButton(
                icon: Icons.settings_rounded,
                text: '설정',
              ),
            ],
            selectedIndex: 0,
            onTabChange: (index) {
              switch (index) {
                case 1:
                  Navigator.pushNamed(context, '/schedule');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/report');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/settings');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}

// Simple GNav implementation for demo purposes (usually from google_nav_bar package)
// Since we don't have the package, we'll revert to standard BottomNavigationBar but styled better
// Wait, I should stick to standard widgets if I don't want to add dependencies.
// Let's rewrite _buildBottomNavigationBar to use standard BottomNavigationBar but styled.

class GNav extends StatelessWidget {
  // Placeholder to avoid errors if I used it above.
  // But actually, I should just use BottomNavigationBar to be safe.
  const GNav({super.key, required this.tabs, required this.onTabChange, required this.selectedIndex, this.gap, this.activeColor, this.iconSize, this.padding, this.duration, this.tabBackgroundColor, this.color});
  final List<GButton> tabs;
  final Function(int) onTabChange;
  final int selectedIndex;
  final double? gap;
  final Color? activeColor;
  final double? iconSize;
  final EdgeInsets? padding;
  final Duration? duration;
  final Color? tabBackgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final btn = entry.value;
        final isSelected = index == selectedIndex;
        return InkWell(
          onTap: () => onTabChange(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: padding ?? const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? tabBackgroundColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  btn.icon,
                  color: isSelected ? activeColor : color,
                  size: iconSize,
                ),
                if (isSelected) ...[
                  SizedBox(width: gap ?? 8),
                  Text(
                    btn.text,
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class GButton {
  const GButton({required this.icon, required this.text});
  final IconData icon;
  final String text;
}
 