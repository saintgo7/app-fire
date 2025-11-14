/// 건물 정보 모델
class Building {
  final int? id;
  final String buildingName;
  final String? category;

  // 위치
  final String regionSido;
  final String regionSigungu;
  final String regionDong;
  final String? addressJibun;
  final String? addressRoad;
  final double? latitude;
  final double? longitude;

  // 건물 상세
  final String? mainUsage;
  final String isApartment;
  final double? totalArea;
  final int householdCount;
  final int floorAbove;
  final int floorBelow;
  final String? approvalDate;

  // 소방 설비
  final String hasSprinkler;
  final String hasSmokeControl;
  final String hasWaterSpray;

  // 관리 정보
  final String? fireStation;
  final String isTunnel;
  final String? gradeLevel;
  final String requiresSelfInspection;

  // 메타
  final String? createdAt;
  final String? updatedAt;
  final String? syncedAt;
  final int isDeleted;

  Building({
    this.id,
    required this.buildingName,
    this.category,
    required this.regionSido,
    required this.regionSigungu,
    required this.regionDong,
    this.addressJibun,
    this.addressRoad,
    this.latitude,
    this.longitude,
    this.mainUsage,
    this.isApartment = 'N',
    this.totalArea,
    this.householdCount = 0,
    this.floorAbove = 0,
    this.floorBelow = 0,
    this.approvalDate,
    this.hasSprinkler = 'N',
    this.hasSmokeControl = 'N',
    this.hasWaterSpray = 'N',
    this.fireStation,
    this.isTunnel = 'N',
    this.gradeLevel,
    this.requiresSelfInspection = 'N',
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.isDeleted = 0,
  });

  /// DB Map에서 Building 객체 생성
  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      id: map['id'] as int?,
      buildingName: map['building_name'] as String,
      category: map['category'] as String?,
      regionSido: map['region_sido'] as String,
      regionSigungu: map['region_sigungu'] as String,
      regionDong: map['region_dong'] as String,
      addressJibun: map['address_jibun'] as String?,
      addressRoad: map['address_road'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      mainUsage: map['main_usage'] as String?,
      isApartment: map['is_apartment'] as String? ?? 'N',
      totalArea: map['total_area'] as double?,
      householdCount: map['household_count'] as int? ?? 0,
      floorAbove: map['floor_above'] as int? ?? 0,
      floorBelow: map['floor_below'] as int? ?? 0,
      approvalDate: map['approval_date'] as String?,
      hasSprinkler: map['has_sprinkler'] as String? ?? 'N',
      hasSmokeControl: map['has_smoke_control'] as String? ?? 'N',
      hasWaterSpray: map['has_water_spray'] as String? ?? 'N',
      fireStation: map['fire_station'] as String?,
      isTunnel: map['is_tunnel'] as String? ?? 'N',
      gradeLevel: map['grade_level'] as String?,
      requiresSelfInspection: map['requires_self_inspection'] as String? ?? 'N',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      syncedAt: map['synced_at'] as String?,
      isDeleted: map['is_deleted'] as int? ?? 0,
    );
  }

  /// Building 객체를 DB Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'building_name': buildingName,
      'category': category,
      'region_sido': regionSido,
      'region_sigungu': regionSigungu,
      'region_dong': regionDong,
      'address_jibun': addressJibun,
      'address_road': addressRoad,
      'latitude': latitude,
      'longitude': longitude,
      'main_usage': mainUsage,
      'is_apartment': isApartment,
      'total_area': totalArea,
      'household_count': householdCount,
      'floor_above': floorAbove,
      'floor_below': floorBelow,
      'approval_date': approvalDate,
      'has_sprinkler': hasSprinkler,
      'has_smoke_control': hasSmokeControl,
      'has_water_spray': hasWaterSpray,
      'fire_station': fireStation,
      'is_tunnel': isTunnel,
      'grade_level': gradeLevel,
      'requires_self_inspection': requiresSelfInspection,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
      'is_deleted': isDeleted,
    };
  }

  /// 전체 주소 반환
  String get fullAddress {
    return addressRoad ?? addressJibun ?? '$regionSido $regionSigungu $regionDong';
  }

  /// 소방설비 보유 여부 체크
  bool get hasAnyFireEquipment {
    return hasSprinkler == 'Y' || hasSmokeControl == 'Y' || hasWaterSpray == 'Y';
  }

  /// copyWith 메서드
  Building copyWith({
    int? id,
    String? buildingName,
    String? category,
    String? regionSido,
    String? regionSigungu,
    String? regionDong,
    String? addressJibun,
    String? addressRoad,
    double? latitude,
    double? longitude,
    String? mainUsage,
    String? isApartment,
    double? totalArea,
    int? householdCount,
    int? floorAbove,
    int? floorBelow,
    String? approvalDate,
    String? hasSprinkler,
    String? hasSmokeControl,
    String? hasWaterSpray,
    String? fireStation,
    String? isTunnel,
    String? gradeLevel,
    String? requiresSelfInspection,
    String? createdAt,
    String? updatedAt,
    String? syncedAt,
    int? isDeleted,
  }) {
    return Building(
      id: id ?? this.id,
      buildingName: buildingName ?? this.buildingName,
      category: category ?? this.category,
      regionSido: regionSido ?? this.regionSido,
      regionSigungu: regionSigungu ?? this.regionSigungu,
      regionDong: regionDong ?? this.regionDong,
      addressJibun: addressJibun ?? this.addressJibun,
      addressRoad: addressRoad ?? this.addressRoad,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mainUsage: mainUsage ?? this.mainUsage,
      isApartment: isApartment ?? this.isApartment,
      totalArea: totalArea ?? this.totalArea,
      householdCount: householdCount ?? this.householdCount,
      floorAbove: floorAbove ?? this.floorAbove,
      floorBelow: floorBelow ?? this.floorBelow,
      approvalDate: approvalDate ?? this.approvalDate,
      hasSprinkler: hasSprinkler ?? this.hasSprinkler,
      hasSmokeControl: hasSmokeControl ?? this.hasSmokeControl,
      hasWaterSpray: hasWaterSpray ?? this.hasWaterSpray,
      fireStation: fireStation ?? this.fireStation,
      isTunnel: isTunnel ?? this.isTunnel,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      requiresSelfInspection: requiresSelfInspection ?? this.requiresSelfInspection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Building(id: $id, name: $buildingName, address: $fullAddress)';
  }
}
