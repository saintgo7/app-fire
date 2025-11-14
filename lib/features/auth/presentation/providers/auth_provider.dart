import 'package:flutter/foundation.dart';
import '../../../../core/api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  /// 로그인
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.login(email, password);
      _user = data['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// 회원가입
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? organization,
    String? fireStation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        organization: organization,
        fireStation: fireStation,
      );
      _user = data['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _api.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// 내 정보 새로고침
  Future<void> refreshUser() async {
    try {
      final data = await _api.getMe();
      _user = data;
      notifyListeners();
    } catch (e) {
      // 토큰이 만료되었거나 유효하지 않으면 로그아웃
      await signOut();
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 