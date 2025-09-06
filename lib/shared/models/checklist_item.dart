enum ChecklistStatus { normal, defective, notApplicable }

class ChecklistItem {
  final String title;
  ChecklistStatus? status;
  String memo;
  final List<dynamic> photos;

  ChecklistItem({
    required this.title,
    this.status,
    this.memo = '',
    List<dynamic>? photos,
  }) : photos = photos ?? [];
} 