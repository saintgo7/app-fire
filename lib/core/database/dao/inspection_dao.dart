import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/inspection.dart';
import '../models/inspection_item.dart';
import '../models/inspection_photo.dart';

/// 점검 데이터 접근 객체 (DAO)
class InspectionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ========== Inspection CRUD ==========

  /// 점검 생성
  Future<int> createInspection(Inspection inspection) async {
    final db = await _dbHelper.database;
    return await db.insert('inspections', inspection.toMap());
  }

  /// 점검 조회 (ID)
  Future<Inspection?> getInspection(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspections',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Inspection.fromMap(maps.first);
  }

  /// 특정 건물의 모든 점검 목록
  Future<List<Inspection>> getInspectionsByBuilding(int buildingId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspections',
      where: 'building_id = ? AND is_deleted = 0',
      whereArgs: [buildingId],
      orderBy: 'inspection_date DESC',
    );

    return maps.map((map) => Inspection.fromMap(map)).toList();
  }

  /// 날짜 범위로 점검 목록 조회
  Future<List<Inspection>> getInspectionsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspections',
      where:
          'inspection_date >= ? AND inspection_date <= ? AND is_deleted = 0',
      whereArgs: [startDate, endDate],
      orderBy: 'inspection_date DESC',
    );

    return maps.map((map) => Inspection.fromMap(map)).toList();
  }

  /// 모든 점검 목록 (최근 순)
  Future<List<Inspection>> getAllInspections({int? limit}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspections',
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => Inspection.fromMap(map)).toList();
  }

  /// 동기화되지 않은 점검 목록 조회
  Future<List<Inspection>> getUnsyncedInspections() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspections',
      where: 'is_deleted = 0 AND (synced_at IS NULL OR updated_at > synced_at)',
      orderBy: 'updated_at ASC',
    );

    return maps.map((map) => Inspection.fromMap(map)).toList();
  }

  /// 점검 업데이트
  Future<int> updateInspection(Inspection inspection) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inspections',
      inspection.toMap(),
      where: 'id = ?',
      whereArgs: [inspection.id],
    );
  }

  /// 점검 삭제 (soft delete)
  Future<int> deleteInspection(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inspections',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 점검 완전 삭제 (hard delete)
  Future<int> hardDeleteInspection(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inspections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== InspectionItem CRUD ==========

  /// 점검 항목 생성
  Future<int> createInspectionItem(InspectionItem item) async {
    final db = await _dbHelper.database;
    return await db.insert('inspection_items', item.toMap());
  }

  /// 점검 항목 목록 생성 (batch)
  Future<void> createInspectionItems(List<InspectionItem> items) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var item in items) {
      batch.insert('inspection_items', item.toMap());
    }

    await batch.commit(noResult: true);
  }

  /// 점검 항목 조회
  Future<InspectionItem?> getInspectionItem(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspection_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return InspectionItem.fromMap(maps.first);
  }

  /// 특정 점검의 모든 항목 조회
  Future<List<InspectionItem>> getInspectionItems(int inspectionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspection_items',
      where: 'inspection_id = ?',
      whereArgs: [inspectionId],
      orderBy: 'item_order ASC, id ASC',
    );

    return maps.map((map) => InspectionItem.fromMap(map)).toList();
  }

  /// 카테고리별 점검 항목 조회
  Future<List<InspectionItem>> getInspectionItemsByCategory(
    int inspectionId,
    String category,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspection_items',
      where: 'inspection_id = ? AND category = ?',
      whereArgs: [inspectionId, category],
      orderBy: 'item_order ASC',
    );

    return maps.map((map) => InspectionItem.fromMap(map)).toList();
  }

  /// 점검 항목 업데이트
  Future<int> updateInspectionItem(InspectionItem item) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inspection_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 점검 항목 삭제
  Future<int> deleteInspectionItem(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inspection_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 점검의 모든 항목 삭제
  Future<int> deleteInspectionItems(int inspectionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inspection_items',
      where: 'inspection_id = ?',
      whereArgs: [inspectionId],
    );
  }

  // ========== InspectionPhoto CRUD ==========

  /// 사진 생성
  Future<int> createInspectionPhoto(InspectionPhoto photo) async {
    final db = await _dbHelper.database;
    return await db.insert('inspection_photos', photo.toMap());
  }

  /// 사진 조회
  Future<InspectionPhoto?> getInspectionPhoto(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspection_photos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return InspectionPhoto.fromMap(maps.first);
  }

  /// 특정 점검 항목의 사진 목록
  Future<List<InspectionPhoto>> getInspectionPhotos(
      int inspectionItemId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspection_photos',
      where: 'inspection_item_id = ?',
      whereArgs: [inspectionItemId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => InspectionPhoto.fromMap(map)).toList();
  }

  /// 점검의 모든 사진 조회 (join)
  Future<List<InspectionPhoto>> getAllPhotosForInspection(
      int inspectionId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT p.*
      FROM inspection_photos p
      INNER JOIN inspection_items i ON p.inspection_item_id = i.id
      WHERE i.inspection_id = ?
      ORDER BY p.created_at ASC
    ''', [inspectionId]);

    return maps.map((map) => InspectionPhoto.fromMap(map)).toList();
  }

  /// 사진 업데이트
  Future<int> updateInspectionPhoto(InspectionPhoto photo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'inspection_photos',
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }

  /// 사진 삭제
  Future<int> deleteInspectionPhoto(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'inspection_photos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 업로드되지 않은 사진 목록
  Future<List<InspectionPhoto>> getUnuploadedPhotos() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'inspection_photos',
      where: 'is_uploaded = 0',
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => InspectionPhoto.fromMap(map)).toList();
  }

  // ========== 통계 및 유틸리티 ==========

  /// 점검 진행률 계산
  Future<double> getInspectionProgress(int inspectionId) async {
    final items = await getInspectionItems(inspectionId);
    if (items.isEmpty) return 0.0;

    final checkedCount = items.where((item) => item.status != null).length;
    return checkedCount / items.length;
  }

  /// 불량 항목 개수
  Future<int> getDefectiveItemsCount(int inspectionId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM inspection_items
      WHERE inspection_id = ? AND status = 'defective'
    ''', [inspectionId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 점검 완료 처리
  Future<void> completeInspection(int inspectionId) async {
    final now = DateTime.now().toIso8601String();
    final db = await _dbHelper.database;

    await db.update(
      'inspections',
      {
        'status': 'completed',
        'completed_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [inspectionId],
    );
  }

  /// 점검 시작 처리
  Future<void> startInspection(int inspectionId) async {
    final now = DateTime.now().toIso8601String();
    final db = await _dbHelper.database;

    await db.update(
      'inspections',
      {
        'started_at': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [inspectionId],
    );
  }
}
