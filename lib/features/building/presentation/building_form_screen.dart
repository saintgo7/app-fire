import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/database/models/building.dart';
import '../../../core/database/dao/building_dao.dart';

class BuildingFormScreen extends StatefulWidget {
  final Building? building; // null for add, non-null for edit

  const BuildingFormScreen({
    super.key,
    this.building,
  });

  @override
  State<BuildingFormScreen> createState() => _BuildingFormScreenState();
}

class _BuildingFormScreenState extends State<BuildingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BuildingDao _buildingDao = BuildingDao();

  // Controllers
  late final TextEditingController _buildingNameController;
  late final TextEditingController _floorAboveController;
  late final TextEditingController _floorBelowController;
  late final TextEditingController _totalAreaController;
  late final TextEditingController _mainPurposeController;
  late final TextEditingController _structureTypeController;
  late final TextEditingController _addressRoadController;
  late final TextEditingController _addressJibunController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _regionSidoController;
  late final TextEditingController _regionSigunguController;
  late final TextEditingController _regionDongController;
  late final TextEditingController _fireStationController;
  late final TextEditingController _managementGradeController;
  late final TextEditingController _managerNameController;
  late final TextEditingController _managerPhoneController;
  late final TextEditingController _completionDateController;

  // Boolean values
  bool _isApartment = false;
  bool _requiresSelfInspection = false;
  bool _safetyManagerRequired = false;
  bool _hasSprinkler = false;
  bool _hasSmokeControl = false;
  bool _hasWaterSpray = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final building = widget.building;

    _buildingNameController = TextEditingController(text: building?.buildingName ?? '');
    _floorAboveController = TextEditingController(text: building?.floorAbove.toString() ?? '');
    _floorBelowController = TextEditingController(text: building?.floorBelow.toString() ?? '0');
    _totalAreaController = TextEditingController(text: building?.totalArea?.toString() ?? '');
    _mainPurposeController = TextEditingController(text: building?.mainPurpose ?? '');
    _structureTypeController = TextEditingController(text: building?.structureType ?? '');
    _addressRoadController = TextEditingController(text: building?.addressRoad ?? '');
    _addressJibunController = TextEditingController(text: building?.addressJibun ?? '');
    _postalCodeController = TextEditingController(text: building?.postalCode ?? '');
    _regionSidoController = TextEditingController(text: building?.regionSido ?? '');
    _regionSigunguController = TextEditingController(text: building?.regionSigungu ?? '');
    _regionDongController = TextEditingController(text: building?.regionDong ?? '');
    _fireStationController = TextEditingController(text: building?.fireStationName ?? '');
    _managementGradeController = TextEditingController(text: building?.managementGrade ?? '');
    _managerNameController = TextEditingController(text: building?.managerName ?? '');
    _managerPhoneController = TextEditingController(text: building?.managerPhone ?? '');
    _completionDateController = TextEditingController(text: building?.completionDate ?? '');

    if (building != null) {
      _isApartment = building.isApartment == 'Y';
      _requiresSelfInspection = building.requiresSelfInspection == 'Y';
      _safetyManagerRequired = building.safetyManagerRequired == 'Y';
      _hasSprinkler = building.hasSprinkler == 'Y';
      _hasSmokeControl = building.hasSmokeControl == 'Y';
      _hasWaterSpray = building.hasWaterSpray == 'Y';
    }
  }

  @override
  void dispose() {
    _buildingNameController.dispose();
    _floorAboveController.dispose();
    _floorBelowController.dispose();
    _totalAreaController.dispose();
    _mainPurposeController.dispose();
    _structureTypeController.dispose();
    _addressRoadController.dispose();
    _addressJibunController.dispose();
    _postalCodeController.dispose();
    _regionSidoController.dispose();
    _regionSigunguController.dispose();
    _regionDongController.dispose();
    _fireStationController.dispose();
    _managementGradeController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _completionDateController.dispose();
    super.dispose();
  }

  Future<void> _saveBuilding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final building = Building(
        id: widget.building?.id,
        buildingName: _buildingNameController.text.trim(),
        floorAbove: int.parse(_floorAboveController.text),
        floorBelow: int.parse(_floorBelowController.text),
        totalArea: _totalAreaController.text.isEmpty
            ? null
            : double.parse(_totalAreaController.text),
        mainPurpose: _mainPurposeController.text.trim().isEmpty
            ? null
            : _mainPurposeController.text.trim(),
        structureType: _structureTypeController.text.trim().isEmpty
            ? null
            : _structureTypeController.text.trim(),
        addressRoad: _addressRoadController.text.trim().isEmpty
            ? null
            : _addressRoadController.text.trim(),
        addressJibun: _addressJibunController.text.trim().isEmpty
            ? null
            : _addressJibunController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        regionSido: _regionSidoController.text.trim(),
        regionSigungu: _regionSigunguController.text.trim(),
        regionDong: _regionDongController.text.trim(),
        fireStationName: _fireStationController.text.trim().isEmpty
            ? null
            : _fireStationController.text.trim(),
        managementGrade: _managementGradeController.text.trim().isEmpty
            ? null
            : _managementGradeController.text.trim(),
        managerName: _managerNameController.text.trim().isEmpty
            ? null
            : _managerNameController.text.trim(),
        managerPhone: _managerPhoneController.text.trim().isEmpty
            ? null
            : _managerPhoneController.text.trim(),
        completionDate: _completionDateController.text.trim().isEmpty
            ? null
            : _completionDateController.text.trim(),
        isApartment: _isApartment ? 'Y' : 'N',
        requiresSelfInspection: _requiresSelfInspection ? 'Y' : 'N',
        safetyManagerRequired: _safetyManagerRequired ? 'Y' : 'N',
        hasSprinkler: _hasSprinkler ? 'Y' : 'N',
        hasSmokeControl: _hasSmokeControl ? 'Y' : 'N',
        hasWaterSpray: _hasWaterSpray ? 'Y' : 'N',
        isDeleted: 'N',
      );

      if (widget.building == null) {
        await _buildingDao.createBuilding(building);
      } else {
        await _buildingDao.updateBuilding(building);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.building != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isEdit ? '건물 수정' : '건물 추가',
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보
              _buildSectionTitle('기본 정보', required: true),
              const SizedBox(height: 12),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // 위치 정보
              _buildSectionTitle('위치 정보', required: true),
              const SizedBox(height: 12),
              _buildLocationSection(),
              const SizedBox(height: 24),

              // 소방 설비
              _buildSectionTitle('소방 설비'),
              const SizedBox(height: 12),
              _buildFireEquipmentSection(),
              const SizedBox(height: 24),

              // 관리 정보
              _buildSectionTitle('관리 정보'),
              const SizedBox(height: 12),
              _buildManagementSection(),
              const SizedBox(height: 24),

              // 담당자 정보
              _buildSectionTitle('담당자 정보'),
              const SizedBox(height: 12),
              _buildContactSection(),
              const SizedBox(height: 32),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBuilding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEdit ? '수정 완료' : '추가 완료',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.errorLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _buildingNameController,
              decoration: const InputDecoration(
                labelText: '건물명 *',
                hintText: '예: 서울시청 본관',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '건물명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _floorAboveController,
                    decoration: const InputDecoration(
                      labelText: '지상 층수 *',
                      hintText: '예: 10',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '지상 층수를 입력해주세요';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return '1 이상의 숫자를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _floorBelowController,
                    decoration: const InputDecoration(
                      labelText: '지하 층수',
                      hintText: '예: 2',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalAreaController,
              decoration: const InputDecoration(
                labelText: '연면적 (㎡)',
                hintText: '예: 5000.50',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mainPurposeController,
              decoration: const InputDecoration(
                labelText: '주용도',
                hintText: '예: 업무시설',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _structureTypeController,
              decoration: const InputDecoration(
                labelText: '구조',
                hintText: '예: 철근콘크리트조',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _completionDateController,
              decoration: const InputDecoration(
                labelText: '준공일',
                hintText: 'YYYY-MM-DD',
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                '아파트',
                style: AppTextStyles.bodyMedium,
              ),
              value: _isApartment,
              onChanged: (value) {
                setState(() {
                  _isApartment = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _regionSidoController,
              decoration: const InputDecoration(
                labelText: '시/도 *',
                hintText: '예: 서울특별시',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '시/도를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regionSigunguController,
              decoration: const InputDecoration(
                labelText: '시/군/구 *',
                hintText: '예: 중구',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '시/군/구를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regionDongController,
              decoration: const InputDecoration(
                labelText: '읍/면/동 *',
                hintText: '예: 태평로1가',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '읍/면/동을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressRoadController,
              decoration: const InputDecoration(
                labelText: '도로명 주소',
                hintText: '예: 세종대로 110',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressJibunController,
              decoration: const InputDecoration(
                labelText: '지번 주소',
                hintText: '예: 태평로1가 31',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: '우편번호',
                hintText: '예: 04524',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFireEquipmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    color: AppColors.equipmentSprinkler,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '스프링클러',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              value: _hasSprinkler,
              onChanged: (value) {
                setState(() {
                  _hasSprinkler = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.air,
                    color: AppColors.equipmentAlarm,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '연기제어설비',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              value: _hasSmokeControl,
              onChanged: (value) {
                setState(() {
                  _hasSmokeControl = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.shower,
                    color: AppColors.statusGood,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '물분무소화설비',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              value: _hasWaterSpray,
              onChanged: (value) {
                setState(() {
                  _hasWaterSpray = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _fireStationController,
              decoration: const InputDecoration(
                labelText: '관할 소방서',
                hintText: '예: 서울중부소방서',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managementGradeController,
              decoration: const InputDecoration(
                labelText: '관리 등급',
                hintText: '예: 1급',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                '자체점검 대상',
                style: AppTextStyles.bodyMedium,
              ),
              value: _requiresSelfInspection,
              onChanged: (value) {
                setState(() {
                  _requiresSelfInspection = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                '안전관리자 필요',
                style: AppTextStyles.bodyMedium,
              ),
              value: _safetyManagerRequired,
              onChanged: (value) {
                setState(() {
                  _safetyManagerRequired = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _managerNameController,
              decoration: const InputDecoration(
                labelText: '담당자명',
                hintText: '예: 홍길동',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managerPhoneController,
              decoration: const InputDecoration(
                labelText: '연락처',
                hintText: '예: 010-1234-5678',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
}
