import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite 데이터베이스 헬퍼 클래스
/// 싱글톤 패턴으로 구현
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// 데이터베이스 버전
  static const int _version = 1;
  static const String _databaseName = 'fire_safety.db';

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _createDB(Database db, int version) async {
    // 1. buildings 테이블
    await db.execute('''
      CREATE TABLE buildings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        building_name TEXT NOT NULL,
        category TEXT,

        region_sido TEXT NOT NULL,
        region_sigungu TEXT NOT NULL,
        region_dong TEXT NOT NULL,
        address_jibun TEXT,
        address_road TEXT,
        latitude REAL,
        longitude REAL,

        main_usage TEXT,
        is_apartment TEXT DEFAULT 'N',
        total_area REAL,
        household_count INTEGER DEFAULT 0,
        floor_above INTEGER DEFAULT 0,
        floor_below INTEGER DEFAULT 0,
        approval_date TEXT,

        has_sprinkler TEXT DEFAULT 'N',
        has_smoke_control TEXT DEFAULT 'N',
        has_water_spray TEXT DEFAULT 'N',

        fire_station TEXT,
        is_tunnel TEXT DEFAULT 'N',
        grade_level TEXT,
        requires_self_inspection TEXT DEFAULT 'N',

        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_at TEXT,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_buildings_region
      ON buildings(region_sido, region_sigungu, region_dong)
    ''');

    await db.execute('''
      CREATE INDEX idx_buildings_name ON buildings(building_name)
    ''');

    // 2. inspections 테이블
    await db.execute('''
      CREATE TABLE inspections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        building_id INTEGER NOT NULL,
        inspector_id INTEGER,

        inspection_type TEXT NOT NULL,
        inspection_date TEXT NOT NULL,
        started_at TEXT,
        completed_at TEXT,

        overall_status TEXT,
        notes TEXT,

        status TEXT DEFAULT 'draft',

        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_at TEXT,
        is_deleted INTEGER DEFAULT 0,

        FOREIGN KEY (building_id) REFERENCES buildings(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_inspections_building ON inspections(building_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_inspections_date ON inspections(inspection_date)
    ''');

    // 3. inspection_items 테이블
    await db.execute('''
      CREATE TABLE inspection_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        inspection_id INTEGER NOT NULL,

        category TEXT NOT NULL,
        item_title TEXT NOT NULL,
        item_order INTEGER DEFAULT 0,

        status TEXT,
        memo TEXT,

        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,

        FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_inspection_items_inspection
      ON inspection_items(inspection_id)
    ''');

    // 4. inspection_photos 테이블
    await db.execute('''
      CREATE TABLE inspection_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        inspection_item_id INTEGER NOT NULL,

        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_size INTEGER,
        taken_at TEXT,

        server_url TEXT,
        is_uploaded INTEGER DEFAULT 0,

        created_at TEXT DEFAULT CURRENT_TIMESTAMP,

        FOREIGN KEY (inspection_item_id) REFERENCES inspection_items(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_inspection_photos_item
      ON inspection_photos(inspection_item_id)
    ''');

    // 5. users 테이블
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,

        organization TEXT,
        fire_station TEXT,

        auth_token TEXT,
        refresh_token TEXT,

        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        last_login_at TEXT
      )
    ''');

    // 6. sync_queue 테이블
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,

        status TEXT DEFAULT 'pending',
        retry_count INTEGER DEFAULT 0,
        error_message TEXT,

        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_status ON sync_queue(status)
    ''');
  }

  /// 데이터베이스 업그레이드
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // 버전 업그레이드 시 마이그레이션 로직
    if (oldVersion < 2) {
      // 예: 버전 2로 업그레이드 시 실행할 SQL
      // await db.execute('ALTER TABLE buildings ADD COLUMN new_field TEXT');
    }
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 데이터베이스 삭제 (디버깅용)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// 모든 테이블 데이터 삭제
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('sync_queue');
    await db.delete('inspection_photos');
    await db.delete('inspection_items');
    await db.delete('inspections');
    await db.delete('buildings');
    await db.delete('users');
  }
}
