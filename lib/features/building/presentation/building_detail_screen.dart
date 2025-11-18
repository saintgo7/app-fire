import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/database/models/building.dart';
import '../../../core/database/dao/building_dao.dart';
import 'building_form_screen.dart';

class BuildingDetailScreen extends StatefulWidget {
  final String buildingId;

  const BuildingDetailScreen({
    super.key,
    required this.buildingId,
  });

  @override
  State<BuildingDetailScreen> createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends State<BuildingDetailScreen> {
  final BuildingDao _buildingDao = BuildingDao();
  Building? _building;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBuilding();
  }

  Future<void> _loadBuilding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final building = await _buildingDao.getBuildingById(widget.buildingId);
      setState(() {
        _building = building;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('건물 정보 로드 실패: $e'),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '건물 상세',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '수정',
            onPressed: () async {
              if (_building == null) return;

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => BuildingFormScreen(
                    building: _building,
                  ),
                ),
              );

              if (result == true) {
                _loadBuilding(); // Reload after edit
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '삭제',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    '건물 삭제',
                    style: AppTextStyles.titleMedium,
                  ),
                  content: Text(
                    '정말 이 건물을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        '취소',
                        style: AppTextStyles.labelLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        '삭제',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.errorLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                try {
                  await _buildingDao.deleteBuilding(widget.buildingId);
                  if (mounted) {
                    Navigator.pop(context, true); // Return to list
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('삭제 실패: $e'),
                        backgroundColor: AppColors.errorLight,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _building == null
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.onSurfaceVariantLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '건물 정보를 찾을 수 없습니다',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final building = _building!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 건물명 헤더
          _buildHeaderCard(building),
          const SizedBox(height: 16),

          // 기본 정보
          _buildSectionTitle('기본 정보'),
          const SizedBox(height: 8),
          _buildBasicInfoCard(building),
          const SizedBox(height: 16),

          // 위치 정보
          _buildSectionTitle('위치 정보'),
          const SizedBox(height: 8),
          _buildLocationCard(building),
          const SizedBox(height: 16),

          // 소방 설비
          _buildSectionTitle('소방 설비'),
          const SizedBox(height: 8),
          _buildFireEquipmentCard(building),
          const SizedBox(height: 16),

          // 관리 정보
          _buildSectionTitle('관리 정보'),
          const SizedBox(height: 8),
          _buildManagementCard(building),
          const SizedBox(height: 16),

          // 담당자 정보
          if (building.managerName != null || building.managerPhone != null) ...[
            _buildSectionTitle('담당자 정보'),
            const SizedBox(height: 8),
            _buildContactCard(building),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    IconData icon;
    switch (title) {
      case '기본 정보':
        icon = Icons.info_outline;
        break;
      case '위치 정보':
        icon = Icons.location_on_outlined;
        break;
      case '소방 설비':
        icon = Icons.local_fire_department_outlined;
        break;
      case '관리 정보':
        icon = Icons.admin_panel_settings_outlined;
        break;
      case '담당자 정보':
        icon = Icons.person_outline;
        break;
      default:
        icon = Icons.info_outline;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.3),
                  AppColors.primaryLight.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(Building building) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryLight,
              AppColors.primaryLight.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.apartment,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    building.buildingName,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (building.requiresSelfInspection == 'Y')
              Chip(
                label: Text(
                  '자체점검 대상',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.white.withOpacity(0.2),
                side: BorderSide(color: Colors.white, width: 1),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(Building building) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.layers,
              label: '층수',
              value: '지상 ${building.floorAbove}층${building.floorBelow > 0 ? " / 지하 ${building.floorBelow}층" : ""}',
            ),
            if (building.totalArea != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.square_foot,
                label: '연면적',
                value: '${building.totalArea!.toStringAsFixed(2)} ㎡',
              ),
            ],
            if (building.mainPurpose != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.business,
                label: '주용도',
                value: building.mainPurpose!,
              ),
            ],
            if (building.structureType != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.foundation,
                label: '구조',
                value: building.structureType!,
              ),
            ],
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.home,
              label: '건물 유형',
              value: building.isApartment == 'Y' ? '아파트' : '일반 건물',
            ),
            if (building.completionDate != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: '준공일',
                value: building.completionDate!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Building building) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.location_on,
              label: '주소',
              value: building.fullAddress,
              valueFlex: 3,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.map,
              label: '행정구역',
              value: '${building.regionSido} ${building.regionSigungu} ${building.regionDong}',
              valueFlex: 3,
            ),
            if (building.addressJibun != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.pin_drop,
                label: '지번 주소',
                value: building.addressJibun!,
                valueFlex: 3,
              ),
            ],
            if (building.postalCode != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.mail,
                label: '우편번호',
                value: building.postalCode!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFireEquipmentCard(Building building) {
    final equipmentList = <Map<String, dynamic>>[
      {
        'icon': Icons.water_drop,
        'name': '스프링클러',
        'color': AppColors.equipmentSprinkler,
        'hasEquipment': building.hasSprinkler == 'Y',
      },
      {
        'icon': Icons.air,
        'name': '연기제어설비',
        'color': AppColors.equipmentAlarm,
        'hasEquipment': building.hasSmokeControl == 'Y',
      },
      {
        'icon': Icons.shower,
        'name': '물분무소화설비',
        'color': AppColors.statusGood,
        'hasEquipment': building.hasWaterSpray == 'Y',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: equipmentList.length,
      itemBuilder: (context, index) {
        final equipment = equipmentList[index];
        final hasEquipment = equipment['hasEquipment'] as bool;
        final color = equipment['color'] as Color;

        return Card(
          elevation: hasEquipment ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: hasEquipment
                  ? color.withOpacity(0.3)
                  : AppColors.onSurfaceVariantLight.withOpacity(0.1),
              width: hasEquipment ? 2 : 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: hasEquipment
                  ? LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasEquipment
                        ? color.withOpacity(0.2)
                        : AppColors.onSurfaceVariantLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    equipment['icon'] as IconData,
                    color: hasEquipment
                        ? color
                        : AppColors.onSurfaceVariantLight.withOpacity(0.5),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  equipment['name'] as String,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: hasEquipment
                        ? color
                        : AppColors.onSurfaceVariantLight,
                    fontWeight: hasEquipment ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (hasEquipment)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 16,
                  )
                else
                  Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.onSurfaceVariantLight.withOpacity(0.3),
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManagementCard(Building building) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (building.fireStationName != null) ...[
              _buildInfoRow(
                icon: Icons.local_fire_department,
                label: '관할 소방서',
                value: building.fireStationName!,
              ),
              const Divider(height: 24),
            ],
            if (building.managementGrade != null) ...[
              _buildInfoRow(
                icon: Icons.grade,
                label: '관리 등급',
                value: building.managementGrade!,
              ),
              const Divider(height: 24),
            ],
            _buildInfoRow(
              icon: Icons.assignment,
              label: '자체점검 대상',
              value: building.requiresSelfInspection == 'Y' ? '예' : '아니오',
            ),
            if (building.safetyManagerRequired == 'Y') ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.security,
                label: '안전관리자',
                value: '필요',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Building building) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (building.managerName != null) ...[
              _buildInfoRow(
                icon: Icons.person,
                label: '담당자명',
                value: building.managerName!,
              ),
            ],
            if (building.managerPhone != null) ...[
              if (building.managerName != null) const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.phone,
                label: '연락처',
                value: building.managerPhone!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int labelFlex = 1,
    int valueFlex = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.onSurfaceVariantLight,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: labelFlex,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariantLight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: valueFlex,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
