import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _authenticated = false;

  bool get isAuthenticated => _authenticated;

  Future<void> signIn() async {
    _authenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _authenticated = false;
    notifyListeners();
  }
} 