import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  bool pushEnabled = true;
  bool lawUpdateEnabled = true;
  bool backupWifiOnly = true;
  bool backingUp = false;

  void togglePush(bool v) {
    pushEnabled = v;
    notifyListeners();
  }

  void toggleLawUpdate(bool v) {
    lawUpdateEnabled = v;
    notifyListeners();
  }

  void toggleBackupWifiOnly(bool v) {
    backupWifiOnly = v;
    notifyListeners();
  }

  Future<void> manualBackup() async {
    backingUp = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    backingUp = false;
    notifyListeners();
  }
} 