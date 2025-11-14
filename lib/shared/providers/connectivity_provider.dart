import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  ConnectivityResult _currentStatus = ConnectivityResult.wifi;

  ConnectivityProvider() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isOnline => _isOnline;
  ConnectivityResult get currentStatus => _currentStatus;

  /// 초기 연결 상태 확인
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('ConnectivityProvider: 연결 상태 확인 실패: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  /// 연결 상태 업데이트
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _isOnline = false;
      _currentStatus = ConnectivityResult.none;
    } else {
      final result = results.first;
      _currentStatus = result;
      _isOnline = result != ConnectivityResult.none;
    }

    debugPrint('ConnectivityProvider: 연결 상태 변경 - ${_isOnline ? "온라인" : "오프라인"} ($_currentStatus)');
    notifyListeners();
  }

  /// 수동으로 연결 상태 설정 (테스트용)
  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  /// 연결 타입 확인
  bool get isWifi => _currentStatus == ConnectivityResult.wifi;
  bool get isMobile => _currentStatus == ConnectivityResult.mobile;
  bool get isEthernet => _currentStatus == ConnectivityResult.ethernet;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
} 