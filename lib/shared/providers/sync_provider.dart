import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_provider.dart';
import '../../core/api/api_service.dart';
import '../../core/database/dao/inspection_dao.dart';
import '../../core/database/dao/building_dao.dart';

class SyncProvider extends ChangeNotifier {
  final ConnectivityProvider connectivity;
  final ApiService _api = ApiService();
  final InspectionDao _inspectionDao = InspectionDao();
  final BuildingDao _buildingDao = BuildingDao();

  bool _isSyncing = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  int _syncedInspections = 0;
  int _downloadedBuildings = 0;

  SyncProvider(this.connectivity) {
    _loadLastSyncTime();
  }

  bool get isSyncing => _isSyncing;
  bool get backingUp => _isSyncing; // 호환성 유지
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get syncedInspections => _syncedInspections;
  int get downloadedBuildings => _downloadedBuildings;

  /// 마지막 동기화 시간 불러오기
  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_sync_timestamp');
    if (timestamp != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      notifyListeners();
    }
  }

  /// 마지막 동기화 시간 저장
  Future<void> _saveLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSyncTime = DateTime.now();
    await prefs.setInt('last_sync_timestamp', _lastSyncTime!.millisecondsSinceEpoch);
  }

  /// 수동 동기화
  Future<bool> manualSync() async {
    if (!connectivity.isOnline) {
      _errorMessage = '네트워크에 연결되어 있지 않습니다';
      notifyListeners();
      return false;
    }

    if (_isSyncing) {
      return false; // 이미 동기화 중
    }

    _isSyncing = true;
    _errorMessage = null;
    _syncedInspections = 0;
    _downloadedBuildings = 0;
    notifyListeners();

    try {
      // 1. 로컬에서 동기화되지 않은 점검 데이터 가져오기
      final unsyncedInspections = await _inspectionDao.getUnsyncedInspections();

      if (unsyncedInspections.isNotEmpty) {
        // 2. 점검 데이터를 서버로 업로드
        final inspectionsData = unsyncedInspections.map((inspection) {
          return inspection.toMap();
        }).toList();

        final syncedIds = await _api.syncInspections(inspectionsData);
        _syncedInspections = syncedIds.length;

        // 3. 동기화된 점검들의 synced_at 업데이트
        for (int i = 0; i < unsyncedInspections.length; i++) {
          final inspection = unsyncedInspections[i];
          final updatedInspection = inspection.copyWith(
            syncedAt: DateTime.now().toIso8601String(),
          );
          await _inspectionDao.updateInspection(updatedInspection);
        }
      }

      // 4. 서버에서 업데이트된 건물 데이터 다운로드
      final lastSyncTimeStr = _lastSyncTime?.toIso8601String();
      final buildings = await _api.downloadBuildings(
        updatedAfter: lastSyncTimeStr,
      );

      if (buildings.isNotEmpty) {
        // 5. 건물 데이터 로컬 DB에 저장
        for (final building in buildings) {
          final existingBuilding = await _buildingDao.getBuildingById(building.id!);
          if (existingBuilding == null) {
            await _buildingDao.insertBuilding(building);
          } else {
            await _buildingDao.updateBuilding(building);
          }
        }
        _downloadedBuildings = buildings.length;
      }

      // 6. 마지막 동기화 시간 저장
      await _saveLastSyncTime();

      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  /// 자동 동기화 (백그라운드)
  Future<void> autoSync() async {
    if (connectivity.isOnline && !_isSyncing) {
      await manualSync();
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 