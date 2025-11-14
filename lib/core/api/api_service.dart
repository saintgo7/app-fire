import 'package:dio/dio.dart';
import 'api_client.dart';
import '../database/models/building.dart';
import '../database/models/inspection.dart';

/// API 서비스 클래스
class ApiService {
  final ApiClient _client = ApiClient.instance;

  // ========== 인증 API ==========

  /// 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.data['success']) {
      final data = response.data['data'];
      await _client.saveToken(data['token'], data['refreshToken']);
      return data;
    }

    throw Exception(response.data['message'] ?? '로그인 실패');
  }

  /// 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? organization,
    String? fireStation,
  }) async {
    final response = await _client.post('/api/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'organization': organization,
      'fire_station': fireStation,
    });

    if (response.data['success']) {
      final data = response.data['data'];
      await _client.saveToken(data['token'], data['refreshToken']);
      return data;
    }

    throw Exception(response.data['message'] ?? '회원가입 실패');
  }

  /// 로그아웃
  Future<void> logout() async {
    await _client.clearToken();
  }

  /// 내 정보 조회
  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get('/api/auth/me');
    return response.data['data'];
  }

  // ========== 건물 API ==========

  /// 건물 목록 조회
  Future<Map<String, dynamic>> getBuildings({
    int page = 1,
    int limit = 20,
    String? sido,
    String? sigungu,
    String? dong,
    String? fireStation,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (sido != null) 'sido': sido,
      if (sigungu != null) 'sigungu': sigungu,
      if (dong != null) 'dong': dong,
      if (fireStation != null) 'fire_station': fireStation,
      if (search != null) 'search': search,
    };

    final response = await _client.get('/api/buildings', queryParameters: queryParams);

    return {
      'buildings': (response.data['data'] as List)
          .map((json) => Building.fromMap(json))
          .toList(),
      'pagination': response.data['pagination'],
    };
  }

  /// 건물 상세 조회
  Future<Building> getBuilding(int id) async {
    final response = await _client.get('/api/buildings/$id');
    return Building.fromMap(response.data['data']);
  }

  /// 건물 등록
  Future<Building> createBuilding(Building building) async {
    final response = await _client.post('/api/buildings', data: building.toMap());
    return Building.fromMap(response.data['data']);
  }

  /// 건물 수정
  Future<void> updateBuilding(Building building) async {
    await _client.put('/api/buildings/${building.id}', data: building.toMap());
  }

  // ========== 점검 API ==========

  /// 점검 목록 조회
  Future<List<Inspection>> getInspections({
    int page = 1,
    int limit = 20,
    int? buildingId,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (buildingId != null) 'building_id': buildingId,
      if (status != null) 'status': status,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
    };

    final response = await _client.get('/api/inspections', queryParameters: queryParams);

    return (response.data['data'] as List)
        .map((json) => Inspection.fromMap(json))
        .toList();
  }

  /// 점검 상세 조회
  Future<Map<String, dynamic>> getInspection(int id) async {
    final response = await _client.get('/api/inspections/$id');
    return response.data['data'];
  }

  /// 점검 생성
  Future<int> createInspection(Map<String, dynamic> data) async {
    final response = await _client.post('/api/inspections', data: data);
    return response.data['data']['id'];
  }

  /// 점검 수정
  Future<void> updateInspection(int id, Map<String, dynamic> data) async {
    await _client.put('/api/inspections/$id', data: data);
  }

  /// 점검 완료
  Future<void> completeInspection(int id) async {
    await _client.put('/api/inspections/$id/complete');
  }

  /// 점검 항목 수정
  Future<void> updateInspectionItem(int inspectionId, int itemId, Map<String, dynamic> data) async {
    await _client.put('/api/inspections/$inspectionId/items/$itemId', data: data);
  }

  // ========== 동기화 API ==========

  /// 점검 데이터 동기화 (앱 → 서버)
  Future<List<int>> syncInspections(List<Map<String, dynamic>> inspections) async {
    final response = await _client.post('/api/sync/inspections', data: {
      'inspections': inspections,
    });

    return List<int>.from(response.data['data']['syncedIds']);
  }

  /// 건물 데이터 다운로드 (서버 → 앱)
  Future<List<Building>> downloadBuildings({
    String? sido,
    String? sigungu,
    String? fireStation,
    String? updatedAfter,
  }) async {
    final queryParams = <String, dynamic>{
      if (sido != null) 'sido': sido,
      if (sigungu != null) 'sigungu': sigungu,
      if (fireStation != null) 'fire_station': fireStation,
      if (updatedAfter != null) 'updated_after': updatedAfter,
    };

    final response = await _client.get('/api/sync/buildings', queryParameters: queryParams);

    return (response.data['data'] as List)
        .map((json) => Building.fromMap(json))
        .toList();
  }

  // ========== 파일 업로드 API ==========

  /// 사진 업로드
  Future<String> uploadPhoto(String filePath, {int? inspectionItemId}) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath),
      if (inspectionItemId != null) 'inspection_item_id': inspectionItemId,
    });

    final endpoint =
        inspectionItemId != null ? '/api/upload/inspection-photo' : '/api/upload/photo';

    final response = await _client.dio.post(endpoint, data: formData);

    return response.data['data']['url'];
  }

  /// 다중 사진 업로드
  Future<List<String>> uploadPhotos(List<String> filePaths, {int? inspectionItemId}) async {
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );

    final formData = FormData.fromMap({
      'photos': files,
      if (inspectionItemId != null) 'inspection_item_id': inspectionItemId,
    });

    final endpoint =
        inspectionItemId != null ? '/api/upload/inspection-photos' : '/api/upload/photos';

    final response = await _client.dio.post(endpoint, data: formData);

    return (response.data['data'] as List)
        .map((item) => item['url'] as String)
        .toList();
  }
}
