// 한국어 주석: 보고서 화면
/// Report screen for viewing and managing inspection reports

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/accessibility_wrapper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = '전체';

  // 샘플 보고서 데이터
  final List<ReportItem> _reports = [
    ReportItem(
      id: 1,
      buildingName: '강남 파이낸스 센터',
      address: '서울시 강남구 테헤란로 152',
      inspectionDate: '2024.11.25',
      inspectorName: '김점검',
      status: ReportStatus.completed,
      normalCount: 18,
      defectiveCount: 2,
      totalCount: 20,
    ),
    ReportItem(
      id: 2,
      buildingName: '서초 자이 아파트',
      address: '서울시 서초구 반포대로 100',
      inspectionDate: '2024.11.24',
      inspectorName: '김점검',
      status: ReportStatus.pending,
      normalCount: 15,
      defectiveCount: 5,
      totalCount: 20,
    ),
    ReportItem(
      id: 3,
      buildingName: '역삼 빌딩',
      address: '서울시 강남구 역삼동 123',
      inspectionDate: '2024.11.23',
      inspectorName: '김점검',
      status: ReportStatus.submitted,
      normalCount: 20,
      defectiveCount: 0,
      totalCount: 20,
    ),
    ReportItem(
      id: 4,
      buildingName: '삼성동 오피스텔',
      address: '서울시 강남구 삼성동 456',
      inspectionDate: '2024.11.22',
      inspectorName: '이점검',
      status: ReportStatus.approved,
      normalCount: 19,
      defectiveCount: 1,
      totalCount: 20,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ReportItem> get _filteredReports {
    if (_filterStatus == '전체') return _reports;
    return _reports.where((r) {
      switch (_filterStatus) {
        case '완료':
          return r.status == ReportStatus.completed;
        case '대기':
          return r.status == ReportStatus.pending;
        case '제출':
          return r.status == ReportStatus.submitted;
        case '승인':
          return r.status == ReportStatus.approved;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('보고서'),
        actions: [
          AccessibleIconButton(
            icon: Icons.filter_list,
            semanticLabel: '필터',
            tooltip: '필터',
            onPressed: _showFilterDialog,
          ),
          AccessibleIconButton(
            icon: Icons.search,
            semanticLabel: '검색',
            tooltip: '검색',
            onPressed: () {
              // TODO: 검색 기능
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '점검 보고서'),
            Tab(text: '통계'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportList(),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    final reports = _filteredReports;

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '보고서가 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(ReportItem report) {
    final progressPercent = report.normalCount / report.totalCount;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () {
        _showReportDetail(report);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description,
                  color: _getStatusColor(report.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.buildingName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(report.status),
                  style: TextStyle(
                    color: _getStatusColor(report.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 진행률 바
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '점검 결과',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${report.normalCount}/${report.totalCount} 정상',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: AppColors.error.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(AppColors.success),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                report.inspectionDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.person,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                report.inspectorName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              if (report.defectiveCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '불량 ${report.defectiveCount}건',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    // 통계 계산
    final totalReports = _reports.length;
    final completedReports = _reports.where((r) =>
        r.status == ReportStatus.completed ||
        r.status == ReportStatus.submitted ||
        r.status == ReportStatus.approved).length;
    final totalNormal = _reports.fold<int>(0, (sum, r) => sum + r.normalCount);
    final totalDefective = _reports.fold<int>(0, (sum, r) => sum + r.defectiveCount);
    final totalItems = _reports.fold<int>(0, (sum, r) => sum + r.totalCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 카드
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '총 보고서',
                  '$totalReports',
                  Icons.description,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  '완료',
                  '$completedReports',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '정상 항목',
                  '$totalNormal',
                  Icons.thumb_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  '불량 항목',
                  '$totalDefective',
                  Icons.warning,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 차트 영역
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '점검 결과 비율',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // 간단한 비율 바
                Row(
                  children: [
                    Expanded(
                      flex: totalNormal,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '정상 ${(totalNormal / totalItems * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    if (totalDefective > 0)
                      Expanded(
                        flex: totalDefective,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '불량 ${(totalDefective / totalItems * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // 범례
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('정상', AppColors.success),
                    const SizedBox(width: AppSpacing.lg),
                    _buildLegendItem('불량', AppColors.error),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.warning;
      case ReportStatus.completed:
        return AppColors.info;
      case ReportStatus.submitted:
        return AppColors.secondary;
      case ReportStatus.approved:
        return AppColors.success;
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return '대기';
      case ReportStatus.completed:
        return '완료';
      case ReportStatus.submitted:
        return '제출';
      case ReportStatus.approved:
        return '승인';
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              '상태 필터',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['전체', '대기', '완료', '제출', '승인'].map((status) {
                final isSelected = _filterStatus == status;
                return FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = status;
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.1),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showReportDetail(ReportItem report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.buildingName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.address,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(report.status),
                        style: TextStyle(
                          color: _getStatusColor(report.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 점검 정보
                      _buildInfoRow('점검일', report.inspectionDate),
                      _buildInfoRow('점검자', report.inspectorName),
                      _buildInfoRow('총 항목', '${report.totalCount}개'),
                      _buildInfoRow('정상', '${report.normalCount}개'),
                      _buildInfoRow('불량', '${report.defectiveCount}개'),
                      const SizedBox(height: AppSpacing.lg),
                      // 버튼
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'PDF 내보내기',
                              onPressed: () {
                                // TODO: PDF 생성
                              },
                              type: AppButtonType.outline,
                              icon: Icons.picture_as_pdf,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              text: '공유',
                              onPressed: () {
                                // TODO: 공유
                              },
                              type: AppButtonType.primary,
                              icon: Icons.share,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// 보고서 데이터 모델
class ReportItem {
  final int id;
  final String buildingName;
  final String address;
  final String inspectionDate;
  final String inspectorName;
  final ReportStatus status;
  final int normalCount;
  final int defectiveCount;
  final int totalCount;

  ReportItem({
    required this.id,
    required this.buildingName,
    required this.address,
    required this.inspectionDate,
    required this.inspectorName,
    required this.status,
    required this.normalCount,
    required this.defectiveCount,
    required this.totalCount,
  });
}

enum ReportStatus {
  pending,
  completed,
  submitted,
  approved,
}
