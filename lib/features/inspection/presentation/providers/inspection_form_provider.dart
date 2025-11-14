import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/database/dao/inspection_dao.dart';
import '../../../../core/database/models/inspection.dart';
import '../../../../core/database/models/inspection_item.dart';
import '../../../../core/database/models/inspection_photo.dart';
import '../../../../shared/models/checklist_item.dart';

/// 점검 폼 프로바이더 (SQLite 연동)
class InspectionFormProvider extends ChangeNotifier {
  final InspectionDao _dao = InspectionDao();

  // 점검 정보
  Inspection? _inspection;
  List<InspectionItem> _items = [];
  Map<int, List<InspectionPhoto>> _photos = {}; // item_id -> photos

  // 기존 UI 호환성을 위한 레거시 데이터
  final List<ChecklistItem> items;

  bool _isLoading = false;
  String? _errorMessage;

  InspectionFormProvider(this.items) {
    _initializeFromLegacy();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Inspection? get inspection => _inspection;
  List<InspectionItem> get inspectionItems => _items;

  double get progress {
    if (_items.isEmpty) {
      return items.isEmpty
          ? 0
          : items.where((e) => e.status != null).length / items.length;
    }
    return _items.where((e) => e.status != null).length / _items.length;
  }

  /// 레거시 데이터를 DB 모델로 변환 (초기화)
  void _initializeFromLegacy() {
    // ChecklistItem -> InspectionItem 변환
    // 실제 점검 시작 시 createInspection()을 호출해야 함
  }

  /// 새로운 점검 생성
  Future<void> createInspection({
    required int buildingId,
    required String inspectionType,
    String? inspectionDate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final now = DateTime.now();
      final inspection = Inspection(
        buildingId: buildingId,
        inspectionType: inspectionType,
        inspectionDate: inspectionDate ?? now.toIso8601String().split('T')[0],
        startedAt: now.toIso8601String(),
        status: 'draft',
      );

      final inspectionId = await _dao.createInspection(inspection);
      _inspection = inspection.copyWith(id: inspectionId);

      // 기본 체크리스트 항목 생성
      await _createDefaultItems(inspectionId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '점검 생성 실패: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 기본 점검 항목 생성
  Future<void> _createDefaultItems(int inspectionId) async {
    final defaultItems = [
      InspectionItem(
          inspectionId: inspectionId,
          category: '소화기',
          itemTitle: '소화기: 위치 표시',
          itemOrder: 1),
      InspectionItem(
          inspectionId: inspectionId,
          category: '소화기',
          itemTitle: '소화기: 압력 게이지',
          itemOrder: 2),
      InspectionItem(
          inspectionId: inspectionId,
          category: '소화기',
          itemTitle: '소화기: 안전핀 상태',
          itemOrder: 3),
      InspectionItem(
          inspectionId: inspectionId,
          category: '옥내소화전',
          itemTitle: '옥내소화전: 호스 상태',
          itemOrder: 4),
      InspectionItem(
          inspectionId: inspectionId,
          category: '옥내소화전',
          itemTitle: '옥내소화전: 밸브 개폐',
          itemOrder: 5),
      InspectionItem(
          inspectionId: inspectionId,
          category: '옥내소화전',
          itemTitle: '옥내소화전: 방수압',
          itemOrder: 6),
      InspectionItem(
          inspectionId: inspectionId,
          category: '자동화재탐지',
          itemTitle: '자동화재탐지: 감지기 상태',
          itemOrder: 7),
      InspectionItem(
          inspectionId: inspectionId,
          category: '자동화재탐지',
          itemTitle: '자동화재탐지: 수신기 표시등',
          itemOrder: 8),
      InspectionItem(
          inspectionId: inspectionId,
          category: '스프링클러',
          itemTitle: '스프링클러: 헤드 상태',
          itemOrder: 9),
      InspectionItem(
          inspectionId: inspectionId,
          category: '스프링클러',
          itemTitle: '스프링클러: 배관 압력',
          itemOrder: 10),
      InspectionItem(
          inspectionId: inspectionId,
          category: '스프링클러',
          itemTitle: '스프링클러: 물공급',
          itemOrder: 11),
    ];

    await _dao.createInspectionItems(defaultItems);
    _items = defaultItems;
  }

  /// 점검 불러오기
  Future<void> loadInspection(int inspectionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _inspection = await _dao.getInspection(inspectionId);
      if (_inspection == null) {
        throw Exception('점검을 찾을 수 없습니다');
      }

      _items = await _dao.getInspectionItems(inspectionId);

      // 사진 로드
      _photos.clear();
      for (var item in _items) {
        final photos = await _dao.getInspectionPhotos(item.id!);
        _photos[item.id!] = photos;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '점검 불러오기 실패: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 점검 항목 상태 변경
  Future<void> setStatus(int index, ChecklistStatus status) async {
    // 레거시 호환
    items[index].status = status;

    // DB 업데이트
    if (_items.isNotEmpty && index < _items.length) {
      final item = _items[index];
      final statusValue = _mapLegacyStatus(status);

      final updatedItem = item.copyWith(
        status: statusValue,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _dao.updateInspectionItem(updatedItem);
      _items[index] = updatedItem;
    }

    notifyListeners();
  }

  /// 레거시 상태를 DB 상태로 변환
  String _mapLegacyStatus(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.normal:
        return 'normal';
      case ChecklistStatus.defective:
        return 'defective';
      case ChecklistStatus.notApplicable:
        return 'not_applicable';
    }
  }

  /// 사진 추가
  Future<void> addPhoto(int index, XFile photo) async {
    // 레거시 호환
    items[index].photos.add(photo);

    // DB 저장
    if (_items.isNotEmpty && index < _items.length) {
      final item = _items[index];
      final now = DateTime.now();

      final inspectionPhoto = InspectionPhoto(
        inspectionItemId: item.id!,
        filePath: photo.path,
        fileName: photo.name,
        fileSize: await photo.length(),
        takenAt: now.toIso8601String(),
      );

      final photoId = await _dao.createInspectionPhoto(inspectionPhoto);

      _photos[item.id!] = _photos[item.id!] ?? [];
      _photos[item.id!]!.add(inspectionPhoto.copyWith(id: photoId));
    }

    notifyListeners();
  }

  /// 메모 업데이트
  Future<void> updateMemo(int index, String memo) async {
    // 레거시 호환
    items[index].memo = memo;

    // DB 업데이트
    if (_items.isNotEmpty && index < _items.length) {
      final item = _items[index];
      final updatedItem = item.copyWith(
        memo: memo,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _dao.updateInspectionItem(updatedItem);
      _items[index] = updatedItem;
    }

    notifyListeners();
  }

  /// 임시 저장
  Future<void> saveDraft() async {
    if (_inspection == null) {
      _errorMessage = '점검이 초기화되지 않았습니다';
      notifyListeners();
      return;
    }

    try {
      final updatedInspection = _inspection!.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _dao.updateInspection(updatedInspection);
      _inspection = updatedInspection;

      notifyListeners();
    } catch (e) {
      _errorMessage = '임시 저장 실패: $e';
      notifyListeners();
    }
  }

  /// 점검 완료
  Future<void> completeInspection() async {
    if (_inspection == null) return;

    try {
      await _dao.completeInspection(_inspection!.id!);
      _inspection = _inspection!.copyWith(
        status: 'completed',
        completedAt: DateTime.now().toIso8601String(),
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = '점검 완료 처리 실패: $e';
      notifyListeners();
    }
  }

  /// 특정 항목의 사진 목록 가져오기
  List<InspectionPhoto> getPhotosForItem(int itemId) {
    return _photos[itemId] ?? [];
  }
} 