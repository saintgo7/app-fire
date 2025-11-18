import 'package:sqflite/sqflite.dart' as sqflite;
import '../database_helper.dart';
import '../models/building.dart';

/// 건물 데이터 접근 객체 (DAO)
class BuildingDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 건물 생성
  Future<int> createBuilding(Building building) async {
    final db = await _dbHelper.database;
    return await db.insert('buildings', building.toMap());
  }

  /// 건물 목록 생성 (batch insert)
  Future<void> createBuildings(List<Building> buildings) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var building in buildings) {
      batch.insert('buildings', building.toMap());
    }

    await batch.commit(noResult: true);
  }

  /// 건물 조회 (ID)
  Future<Building?> getBuilding(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Building.fromMap(maps.first);
  }

  /// 건물 조회 (String ID)
  Future<Building?> getBuildingById(String id) async {
    try {
      final intId = int.parse(id);
      return await getBuilding(intId);
    } catch (e) {
      return null;
    }
  }

  /// 모든 건물 목록
  Future<List<Building>> getAllBuildings({int? limit}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: 'is_deleted = 0',
      orderBy: 'building_name ASC',
      limit: limit,
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 지역별 건물 목록
  Future<List<Building>> getBuildingsByRegion({
    String? sido,
    String? sigungu,
    String? dong,
  }) async {
    final db = await _dbHelper.database;
    final where = <String>['is_deleted = 0'];
    final whereArgs = <dynamic>[];

    if (sido != null) {
      where.add('region_sido = ?');
      whereArgs.add(sido);
    }
    if (sigungu != null) {
      where.add('region_sigungu = ?');
      whereArgs.add(sigungu);
    }
    if (dong != null) {
      where.add('region_dong = ?');
      whereArgs.add(dong);
    }

    final maps = await db.query(
      'buildings',
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'building_name ASC',
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 소방서별 건물 목록
  Future<List<Building>> getBuildingsByFireStation(String fireStation) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: 'fire_station = ? AND is_deleted = 0',
      whereArgs: [fireStation],
      orderBy: 'building_name ASC',
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 건물 검색 (이름)
  Future<List<Building>> searchBuildingsByName(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: 'building_name LIKE ? AND is_deleted = 0',
      whereArgs: ['%$query%'],
      orderBy: 'building_name ASC',
      limit: 50,
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 건물 검색 (주소)
  Future<List<Building>> searchBuildingsByAddress(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: '(address_jibun LIKE ? OR address_road LIKE ?) AND is_deleted = 0',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'building_name ASC',
      limit: 50,
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 통합 건물 검색 (이름 + 주소 + 지역)
  Future<List<Building>> searchBuildings(String query, {String? orderBy}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: '''
        (building_name LIKE ? OR
         address_jibun LIKE ? OR
         address_road LIKE ? OR
         region_sido LIKE ? OR
         region_sigungu LIKE ? OR
         region_dong LIKE ?)
        AND is_deleted = 0
      ''',
      whereArgs: List.filled(6, '%$query%'),
      orderBy: orderBy ?? 'building_name ASC',
      limit: 100,
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 자체점검 대상 건물 목록
  Future<List<Building>> getSelfInspectionBuildings() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: 'requires_self_inspection = ? AND is_deleted = 0',
      whereArgs: ['Y'],
      orderBy: 'building_name ASC',
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 등급별 건물 목록
  Future<List<Building>> getBuildingsByGrade(String gradeLevel) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'buildings',
      where: 'grade_level = ? AND is_deleted = 0',
      whereArgs: [gradeLevel],
      orderBy: 'building_name ASC',
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 건물 업데이트
  Future<int> updateBuilding(Building building) async {
    final db = await _dbHelper.database;
    return await db.update(
      'buildings',
      building.toMap(),
      where: 'id = ?',
      whereArgs: [building.id],
    );
  }

  /// 건물 삭제 (soft delete)
  Future<int> deleteBuilding(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'buildings',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 건물 완전 삭제 (hard delete)
  Future<int> hardDeleteBuilding(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'buildings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 총 건물 수
  Future<int> getBuildingCount() async {
    final db = await _dbHelper.database;
    return sqflite.Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM buildings WHERE is_deleted = 0'),
        ) ??
        0;
  }

  /// 지역 목록 (시/도)
  Future<List<String>> getRegionSidos() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT region_sido
      FROM buildings
      WHERE is_deleted = 0
      ORDER BY region_sido
    ''');

    return maps.map((map) => map['region_sido'] as String).toList();
  }

  /// 지역 목록 (시/군/구)
  Future<List<String>> getRegionSigungus(String sido) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT region_sigungu
      FROM buildings
      WHERE region_sido = ? AND is_deleted = 0
      ORDER BY region_sigungu
    ''', [sido]);

    return maps.map((map) => map['region_sigungu'] as String).toList();
  }

  /// 지역 목록 (동)
  Future<List<String>> getRegionDongs(String sido, String sigungu) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT region_dong
      FROM buildings
      WHERE region_sido = ? AND region_sigungu = ? AND is_deleted = 0
      ORDER BY region_dong
    ''', [sido, sigungu]);

    return maps.map((map) => map['region_dong'] as String).toList();
  }

  /// 소방서 목록
  Future<List<String>> getFireStations() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT fire_station
      FROM buildings
      WHERE fire_station IS NOT NULL AND is_deleted = 0
      ORDER BY fire_station
    ''');

    return maps.map((map) => map['fire_station'] as String).toList();
  }

  /// 고급 필터링 건물 목록
  Future<List<Building>> getFilteredBuildings({
    String? sido,
    String? sigungu,
    String? dong,
    bool? requiresSelfInspection,
    bool? hasFireEquipment,
    bool? isApartment,
    String orderBy = 'building_name ASC',
  }) async {
    final db = await _dbHelper.database;
    final where = <String>['is_deleted = 0'];
    final whereArgs = <dynamic>[];

    // 지역 필터
    if (sido != null && sido.isNotEmpty) {
      where.add('region_sido = ?');
      whereArgs.add(sido);
    }
    if (sigungu != null && sigungu.isNotEmpty) {
      where.add('region_sigungu = ?');
      whereArgs.add(sigungu);
    }
    if (dong != null && dong.isNotEmpty) {
      where.add('region_dong = ?');
      whereArgs.add(dong);
    }

    // 자체점검 필터
    if (requiresSelfInspection != null) {
      where.add('requires_self_inspection = ?');
      whereArgs.add(requiresSelfInspection ? 'Y' : 'N');
    }

    // 소방설비 필터
    if (hasFireEquipment == true) {
      where.add('(has_sprinkler = ? OR has_smoke_control = ? OR has_water_spray = ?)');
      whereArgs.addAll(['Y', 'Y', 'Y']);
    }

    // 아파트 필터
    if (isApartment != null) {
      where.add('is_apartment = ?');
      whereArgs.add(isApartment ? 'Y' : 'N');
    }

    final maps = await db.query(
      'buildings',
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  /// 삭제된 건물 복구
  Future<int> restoreBuilding(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'buildings',
      {'is_deleted': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
