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

  // 필터 상태
  String? _filterSido;
  String? _filterSigungu;
  String? _filterDong;
  bool? _filterSelfInspection;
  bool? _filterHasEquipment;
  bool? _filterIsApartment;

  // 정렬 상태
  String _sortBy = '이름순';
  final List<String> _sortOptions = ['이름순', '최근 등록순', '층수 높은순', '층수 낮은순', '면적 큰순'];

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
      List<Building> buildings;

      // 검색 쿼리가 있으면 검색, 없으면 필터 적용
      if (_searchQuery.isNotEmpty) {
        buildings = await _buildingDao.searchBuildings(
          _searchQuery,
          orderBy: _getSortOrderBy(),
        );
      } else if (_hasActiveFilters()) {
        buildings = await _buildingDao.getFilteredBuildings(
          sido: _filterSido,
          sigungu: _filterSigungu,
          dong: _filterDong,
          requiresSelfInspection: _filterSelfInspection,
          hasFireEquipment: _filterHasEquipment,
          isApartment: _filterIsApartment,
          orderBy: _getSortOrderBy(),
        );
      } else {
        buildings = await _buildingDao.getAllBuildings();
        _applySorting(buildings);
      }

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

  void _searchBuildings(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      if (query.isEmpty) {
        await _loadBuildings();
      } else {
        final buildings = await _buildingDao.searchBuildings(
          query,
          orderBy: _getSortOrderBy(),
        );
        setState(() {
          _buildings = buildings;
          _filteredBuildings = buildings;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 실패: $e'),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    }
  }

  bool _hasActiveFilters() {
    return _filterSido != null ||
        _filterSigungu != null ||
        _filterDong != null ||
        _filterSelfInspection != null ||
        _filterHasEquipment != null ||
        _filterIsApartment != null;
  }

  String _getSortOrderBy() {
    switch (_sortBy) {
      case '최근 등록순':
        return 'created_at DESC';
      case '층수 높은순':
        return 'floor_above DESC';
      case '층수 낮은순':
        return 'floor_above ASC';
      case '면적 큰순':
        return 'total_area DESC';
      default:
        return 'building_name ASC';
    }
  }

  void _applySorting(List<Building> buildings) {
    switch (_sortBy) {
      case '최근 등록순':
        buildings.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
        break;
      case '층수 높은순':
        buildings.sort((a, b) => b.floorAbove.compareTo(a.floorAbove));
        break;
      case '층수 낮은순':
        buildings.sort((a, b) => a.floorAbove.compareTo(b.floorAbove));
        break;
      case '면적 큰순':
        buildings.sort((a, b) => (b.totalArea ?? 0).compareTo(a.totalArea ?? 0));
        break;
      default:
        buildings.sort((a, b) => a.buildingName.compareTo(b.buildingName));
    }
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
          // 정렬 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '정렬',
            onSelected: (String value) {
              setState(() {
                _sortBy = value;
              });
              _loadBuildings();
            },
            itemBuilder: (context) => _sortOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Row(
                  children: [
                    if (choice == _sortBy)
                      Icon(Icons.check, size: 20, color: AppColors.primaryLight)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Text(choice),
                  ],
                ),
              );
            }).toList(),
          ),
          // 필터 버튼
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: '필터',
                onPressed: _showFilterDialog,
              ),
              if (_hasActiveFilters())
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              label: '자체점검',
              value: '$selfInspectionCount',
              color: AppColors.tertiaryLight,
              icon: Icons.assignment,
            ),
          ),
          const SizedBox(width: 12),
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
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariantLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
    final accentColor = building.requiresSelfInspection == 'Y'
        ? AppColors.tertiaryLight
        : AppColors.secondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // 좌측 액센트 바
            Container(
              width: 6,
              height: 120,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // 카드 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 건물명 및 카테고리
                    Row(
                      children: [
                        Icon(
                          Icons.apartment,
                          color: accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            building.buildingName,
                            style: AppTextStyles.inspectionItemTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (building.requiresSelfInspection == 'Y')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.tertiaryLight.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '자체점검',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.tertiaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

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
                    const SizedBox(height: 12),

                    // 건물 정보 및 소방 설비
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
                        const Spacer(),
                        if (building.hasAnyFireEquipment)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusGood.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: AppColors.statusGood,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '설비 ${[
                                    building.hasSprinkler == 'Y',
                                    building.hasSmokeControl == 'Y',
                                    building.hasWaterSpray == 'Y',
                                  ].where((e) => e).length}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.statusGood,
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
              ),
            ),
          ],
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

  /// 필터 다이얼로그
  void _showFilterDialog() {
    // 다이얼로그용 임시 상태
    String? tempSido = _filterSido;
    String? tempSigungu = _filterSigungu;
    String? tempDong = _filterDong;
    bool? tempSelfInspection = _filterSelfInspection;
    bool? tempHasEquipment = _filterHasEquipment;
    bool? tempIsApartment = _filterIsApartment;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primaryLight),
              const SizedBox(width: 12),
              Text(
                '필터',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 자체점검 대상
                SwitchListTile(
                  title: Text(
                    '자체점검 대상만 표시',
                    style: AppTextStyles.bodyMedium,
                  ),
                  value: tempSelfInspection == true,
                  onChanged: (value) {
                    setDialogState(() {
                      tempSelfInspection = value ? true : null;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const Divider(),

                // 소방설비 보유
                SwitchListTile(
                  title: Text(
                    '소방설비 보유 건물만',
                    style: AppTextStyles.bodyMedium,
                  ),
                  value: tempHasEquipment == true,
                  onChanged: (value) {
                    setDialogState(() {
                      tempHasEquipment = value ? true : null;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const Divider(),

                // 아파트
                CheckboxListTile(
                  title: Text(
                    '아파트만 표시',
                    style: AppTextStyles.bodyMedium,
                  ),
                  value: tempIsApartment == true,
                  onChanged: (value) {
                    setDialogState(() {
                      tempIsApartment = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 16),
                Text(
                  '지역',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 시/도 선택
                FutureBuilder<List<String>>(
                  future: _buildingDao.getRegionSidos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '시/도',
                        isDense: true,
                      ),
                      value: tempSido,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('전체'),
                        ),
                        ...snapshot.data!.map((sido) => DropdownMenuItem(
                              value: sido,
                              child: Text(sido),
                            )),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempSido = value;
                          tempSigungu = null;
                          tempDong = null;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  tempSido = null;
                  tempSigungu = null;
                  tempDong = null;
                  tempSelfInspection = null;
                  tempHasEquipment = null;
                  tempIsApartment = null;
                });
              },
              child: Text(
                '초기화',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onSurfaceVariantLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: AppTextStyles.labelLarge,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterSido = tempSido;
                  _filterSigungu = tempSigungu;
                  _filterDong = tempDong;
                  _filterSelfInspection = tempSelfInspection;
                  _filterHasEquipment = tempHasEquipment;
                  _filterIsApartment = tempIsApartment;
                });
                _loadBuildings();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
              ),
              child: Text(
                '적용',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
