import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/database/dao/building_dao.dart';
import '../../../core/database/models/building.dart';
import 'building_detail_screen.dart';
import 'building_form_screen.dart';

class BuildingListScreen extends StatefulWidget {
  const BuildingListScreen({super.key});

  @override
  State<BuildingListScreen> createState() => _BuildingListScreenState();
}

class _BuildingListScreenState extends State<BuildingListScreen> {
  final BuildingDao _buildingDao = BuildingDao();
  final TextEditingController _searchController = TextEditingController();

  List<Building> _buildings = [];
  List<Building> _filteredBuildings = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBuildings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final buildings = await _buildingDao.getAllBuildings();
      setState(() {
        _buildings = buildings;
        _filteredBuildings = buildings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('건물 목록 로드 실패: $e'),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    }
  }

  void _searchBuildings(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBuildings = _buildings;
      } else {
        _filteredBuildings = _buildings.where((building) {
          final nameLower = building.buildingName.toLowerCase();
          final addressLower = building.fullAddress.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) ||
              addressLower.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '건물 관리',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: '필터',
            onPressed: () {
              // TODO: 필터 기능
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('필터 기능 (준비 중)')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          _buildSearchBar(),

          // 통계 카드
          _buildStatsCard(),

          // 건물 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBuildings.isEmpty
                    ? _buildEmptyState()
                    : _buildBuildingList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const BuildingFormScreen(),
            ),
          );
          if (result == true) {
            _loadBuildings(); // Reload the list after adding
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
          '건물 추가',
          style: AppTextStyles.labelLarge,
        ),
      ),
    );
  }

  /// 검색 바
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _searchBuildings,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: '건물명 또는 주소 검색',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariantLight.withOpacity(0.6),
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchBuildings('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  /// 통계 카드
  Widget _buildStatsCard() {
    final totalCount = _buildings.length;
    final selfInspectionCount =
        _buildings.where((b) => b.requiresSelfInspection == 'Y').length;
    final hasEquipmentCount =
        _buildings.where((b) => b.hasAnyFireEquipment).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: '전체',
                  value: '$totalCount',
                  color: AppColors.secondaryLight,
                  icon: Icons.apartment,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '자체점검',
                  value: '$selfInspectionCount',
                  color: AppColors.tertiaryLight,
                  icon: Icons.assignment,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '소방설비',
                  value: '$hasEquipmentCount',
                  color: AppColors.statusGood,
                  icon: Icons.local_fire_department,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
      ],
    );
  }

  /// 건물 목록
  Widget _buildBuildingList() {
    return RefreshIndicator(
      onRefresh: _loadBuildings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredBuildings.length,
        itemBuilder: (context, index) {
          final building = _filteredBuildings[index];
          return _buildBuildingCard(building);
        },
      ),
    );
  }

  /// 건물 카드
  Widget _buildBuildingCard(Building building) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => BuildingDetailScreen(
                buildingId: building.id!,
              ),
            ),
          );
          if (result == true) {
            _loadBuildings(); // Reload the list after deletion or update
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 건물명 및 카테고리
              Row(
                children: [
                  Expanded(
                    child: Text(
                      building.buildingName,
                      style: AppTextStyles.inspectionItemTitle,
                    ),
                  ),
                  if (building.requiresSelfInspection == 'Y')
                    Chip(
                      label: Text(
                        '자체점검',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.tertiaryLight,
                        ),
                      ),
                      backgroundColor: AppColors.tertiaryLight.withOpacity(0.1),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // 주소
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.onSurfaceVariantLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      building.fullAddress,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariantLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 건물 정보
              Row(
                children: [
                  _buildInfoBadge(
                    icon: Icons.layers,
                    text: '${building.floorAbove}층',
                  ),
                  const SizedBox(width: 8),
                  if (building.totalArea != null)
                    _buildInfoBadge(
                      icon: Icons.square_foot,
                      text: '${building.totalArea!.toStringAsFixed(0)}㎡',
                    ),
                  const SizedBox(width: 8),
                  if (building.isApartment == 'Y')
                    _buildInfoBadge(
                      icon: Icons.home,
                      text: '아파트',
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // 소방 설비
              if (building.hasAnyFireEquipment)
                Wrap(
                  spacing: 4,
                  children: [
                    if (building.hasSprinkler == 'Y')
                      _buildEquipmentChip('스프링클러'),
                    if (building.hasSmokeControl == 'Y')
                      _buildEquipmentChip('연기제어'),
                    if (building.hasWaterSpray == 'Y')
                      _buildEquipmentChip('물분무'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariantLight),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChip(String label) {
    return Chip(
      label: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.statusGood,
        ),
      ),
      backgroundColor: AppColors.statusGood.withOpacity(0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.apartment : Icons.search_off,
            size: 80,
            color: AppColors.onSurfaceVariantLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? '등록된 건물이 없습니다' : '검색 결과가 없습니다',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isEmpty)
            Text(
              '새 건물을 추가하려면 하단의 버튼을 누르세요',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariantLight,
              ),
            ),
        ],
      ),
    );
  }
}
