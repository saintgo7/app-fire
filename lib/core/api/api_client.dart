import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API 클라이언트 (싱글톤)
class ApiClient {
  static final ApiClient instance = ApiClient._init();
  late Dio _dio;

  // API 기본 URL (환경별로 변경)
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'https://fire.abada.co.kr');

  ApiClient._init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // JWT 토큰 추가
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 401 에러 시 토큰 갱신 시도
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // 재시도
            final opts = error.requestOptions;
            final token = await _getToken();
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              return handler.reject(error);
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  /// GET 요청
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  /// DELETE 요청
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  /// 토큰 가져오기
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// 토큰 저장
  Future<void> saveToken(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('refresh_token', refreshToken);
  }

  /// 토큰 삭제
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return false;

      final response = await _dio.post('/api/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await saveToken(data['token'], data['refreshToken']);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
