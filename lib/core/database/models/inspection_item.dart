/// 점검 항목 모델
class InspectionItem {
  final int? id;
  final int inspectionId;

  final String category; // 소화기/옥내소화전/자동화재탐지/스프링클러
  final String itemTitle;
  final int itemOrder;

  final String? status; // normal/defective/not_applicable
  final String? memo;

  final String? createdAt;
  final String? updatedAt;

  InspectionItem({
    this.id,
    required this.inspectionId,
    required this.category,
    required this.itemTitle,
    this.itemOrder = 0,
    this.status,
    this.memo,
    this.createdAt,
    this.updatedAt,
  });

  factory InspectionItem.fromMap(Map<String, dynamic> map) {
    return InspectionItem(
      id: map['id'] as int?,
      inspectionId: map['inspection_id'] as int,
      category: map['category'] as String,
      itemTitle: map['item_title'] as String,
      itemOrder: map['item_order'] as int? ?? 0,
      status: map['status'] as String?,
      memo: map['memo'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'inspection_id': inspectionId,
      'category': category,
      'item_title': itemTitle,
      'item_order': itemOrder,
      'status': status,
      'memo': memo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 점검 완료 여부
  bool get isChecked => status != null;

  /// 정상 여부
  bool get isNormal => status == 'normal';

  /// 불량 여부
  bool get isDefective => status == 'defective';

  /// 해당없음 여부
  bool get isNotApplicable => status == 'not_applicable';

  InspectionItem copyWith({
    int? id,
    int? inspectionId,
    String? category,
    String? itemTitle,
    int? itemOrder,
    String? status,
    String? memo,
    String? createdAt,
    String? updatedAt,
  }) {
    return InspectionItem(
      id: id ?? this.id,
      inspectionId: inspectionId ?? this.inspectionId,
      category: category ?? this.category,
      itemTitle: itemTitle ?? this.itemTitle,
      itemOrder: itemOrder ?? this.itemOrder,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'InspectionItem(id: $id, title: $itemTitle, status: $status)';
  }
}

/// 점검 항목 상태 enum
enum InspectionItemStatus {
  normal('정상', 'normal'),
  defective('불량', 'defective'),
  notApplicable('해당없음', 'not_applicable');

  final String label;
  final String value;

  const InspectionItemStatus(this.label, this.value);

  static InspectionItemStatus? fromValue(String? value) {
    if (value == null) return null;
    return InspectionItemStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InspectionItemStatus.normal,
    );
  }
}
