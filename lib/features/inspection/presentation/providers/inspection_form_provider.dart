import 'package:flutter/foundation.dart';
import '../../../../shared/models/checklist_item.dart';

class InspectionFormProvider extends ChangeNotifier {
  final List<ChecklistItem> items;
  InspectionFormProvider(this.items);

  double get progress =>
      items.isEmpty ? 0 : items.where((e) => e.status != null).length / items.length;

  void setStatus(int index, ChecklistStatus status) {
    items[index].status = status;
    notifyListeners();
  }

  void addPhoto(int index, dynamic photo) {
    items[index].photos.add(photo);
    notifyListeners();
  }

  void updateMemo(int index, String memo) {
    items[index].memo = memo;
    notifyListeners();
  }

  Future<void> saveDraft() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
} 