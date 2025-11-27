// 한국어 주석: 법령 정보 화면
/// Legal information screen for fire safety regulations

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/accessibility_wrapper.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '전체';

  // 법령 카테고리
  final List<String> _categories = [
    '전체',
    '소방기본법',
    '소방시설법',
    '화재예방법',
    '위험물안전관리법',
  ];

  // 샘플 법령 데이터
  final List<LegalItem> _legalItems = [
    LegalItem(
      title: '소방기본법',
      subtitle: '법률 제18522호',
      category: '소방기본법',
      lastUpdated: '2024.01.15',
      description: '화재를 예방하고 경계하며 진압하고 화재, 재난·재해, 그 밖의 위급한 상황에서의 구조·구급활동 등을 통하여 국민의 생명·신체 및 재산을 보호함으로써 공공의 안녕 및 질서 유지와 복리증진에 이바지함을 목적으로 한다.',
    ),
    LegalItem(
      title: '소방시설 설치 및 관리에 관한 법률',
      subtitle: '법률 제18523호',
      category: '소방시설법',
      lastUpdated: '2024.01.20',
      description: '화재와 재난·재해로부터 국민의 생명, 신체 및 재산을 보호하기 위하여 소방시설등의 설치·관리에 필요한 사항을 규정함을 목적으로 한다.',
    ),
    LegalItem(
      title: '화재의 예방 및 안전관리에 관한 법률',
      subtitle: '법률 제18524호',
      category: '화재예방법',
      lastUpdated: '2024.02.01',
      description: '화재의 예방과 안전관리에 관한 사항을 규정하여 화재로 인한 피해를 방지하고 국민의 생명, 신체 및 재산을 보호함을 목적으로 한다.',
    ),
    LegalItem(
      title: '위험물안전관리법',
      subtitle: '법률 제18525호',
      category: '위험물안전관리법',
      lastUpdated: '2024.02.15',
      description: '위험물의 저장·취급 및 운반과 이에 따른 안전관리에 관한 사항을 규정함으로써 위험물로 인한 위해를 방지하여 공공의 안전을 확보함을 목적으로 한다.',
    ),
    LegalItem(
      title: '소방시설공사업법',
      subtitle: '법률 제18526호',
      category: '소방시설법',
      lastUpdated: '2024.03.01',
      description: '소방시설공사 및 소방기술의 관리에 필요한 사항을 규정하여 소방시설공사의 적정한 시공과 안전관리를 도모함을 목적으로 한다.',
    ),
  ];

  List<LegalItem> get _filteredItems {
    var items = _legalItems;

    // 카테고리 필터
    if (_selectedCategory != '전체') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // 검색 필터
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((item) =>
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query)).toList();
    }

    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('법령 정보'),
        actions: [
          AccessibleIconButton(
            icon: Icons.bookmark_border,
            semanticLabel: '북마크',
            tooltip: '저장된 법령',
            onPressed: () {
              // TODO: 북마크 화면
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(
            child: _buildLegalList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '법령 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.1),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegalList() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '검색 결과가 없습니다',
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildLegalCard(item);
      },
    );
  }

  Widget _buildLegalCard(LegalItem item) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () {
        _showLegalDetail(item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.gavel,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textDisabled,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.update,
                size: 14,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: 4),
              Text(
                '최종 수정: ${item.lastUpdated}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDisabled,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLegalDetail(LegalItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
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
                            item.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {
                        // TODO: 북마크 기능
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // TODO: 공유 기능
                      },
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
                      Text(
                        '제1조 (목적)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.8,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // TODO: 법령 전문 표시
                      Center(
                        child: Text(
                          '법령 전문은 추후 추가 예정입니다.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
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
}

// 법령 데이터 모델
class LegalItem {
  final String title;
  final String subtitle;
  final String category;
  final String lastUpdated;
  final String description;

  LegalItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.lastUpdated,
    required this.description,
  });
}
