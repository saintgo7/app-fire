// 한국어 주석: 인증 상태 관리 Provider
/// Authentication state management provider

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _authenticated = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  bool get isAuthenticated => _authenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  /// 앱 시작 시 저장된 토큰 확인
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // 토큰이 있으면 인증된 것으로 간주
      _authenticated = token != null && token.isNotEmpty;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _authenticated = false;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 실제 인증 로직 구현 (API 호출)
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
      
      // 임시로 토큰 저장 (실제로는 API 응답에서 받아야 함)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'temp_token_$email');
      
      _authenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _authenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    
    _authenticated = false;
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 실제 회원가입 로직 구현 (Firebase Auth 등)
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
      
      _authenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _authenticated = false;
      notifyListeners();
      rethrow;
    }
  }
} 