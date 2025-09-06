import 'package:flutter/foundation.dart';
import 'connectivity_provider.dart';

class SyncProvider extends ChangeNotifier {
  final ConnectivityProvider connectivity;
  bool _backingUp = false;

  SyncProvider(this.connectivity);

  bool get backingUp => _backingUp;

  Future<void> manualSync() async {
    _backingUp = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _backingUp = false;
    notifyListeners();
  }
} 