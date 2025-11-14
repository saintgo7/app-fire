/// 점검 기록 모델
class Inspection {
  final int? id;
  final int buildingId;
  final int? inspectorId;

  final String inspectionType; // 정기/수시/특별
  final String inspectionDate; // YYYY-MM-DD
  final String? startedAt;
  final String? completedAt;

  final String? overallStatus; // 정상/불량/보완필요
  final String? notes;

  final String status; // draft/completed/submitted/approved

  final String? createdAt;
  final String? updatedAt;
  final String? syncedAt;
  final int isDeleted;

  Inspection({
    this.id,
    required this.buildingId,
    this.inspectorId,
    required this.inspectionType,
    required this.inspectionDate,
    this.startedAt,
    this.completedAt,
    this.overallStatus,
    this.notes,
    this.status = 'draft',
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.isDeleted = 0,
  });

  factory Inspection.fromMap(Map<String, dynamic> map) {
    return Inspection(
      id: map['id'] as int?,
      buildingId: map['building_id'] as int,
      inspectorId: map['inspector_id'] as int?,
      inspectionType: map['inspection_type'] as String,
      inspectionDate: map['inspection_date'] as String,
      startedAt: map['started_at'] as String?,
      completedAt: map['completed_at'] as String?,
      overallStatus: map['overall_status'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'draft',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      syncedAt: map['synced_at'] as String?,
      isDeleted: map['is_deleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'building_id': buildingId,
      'inspector_id': inspectorId,
      'inspection_type': inspectionType,
      'inspection_date': inspectionDate,
      'started_at': startedAt,
      'completed_at': completedAt,
      'overall_status': overallStatus,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
      'is_deleted': isDeleted,
    };
  }

  /// 점검 진행 중인지 확인
  bool get isInProgress {
    return startedAt != null && completedAt == null;
  }

  /// 점검 완료되었는지 확인
  bool get isCompleted {
    return status == 'completed' || completedAt != null;
  }

  /// 동기화 필요 여부
  bool get needsSync {
    if (syncedAt == null) return true;
    if (updatedAt == null) return false;
    return DateTime.parse(updatedAt!).isAfter(DateTime.parse(syncedAt!));
  }

  Inspection copyWith({
    int? id,
    int? buildingId,
    int? inspectorId,
    String? inspectionType,
    String? inspectionDate,
    String? startedAt,
    String? completedAt,
    String? overallStatus,
    String? notes,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? syncedAt,
    int? isDeleted,
  }) {
    return Inspection(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      inspectorId: inspectorId ?? this.inspectorId,
      inspectionType: inspectionType ?? this.inspectionType,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      overallStatus: overallStatus ?? this.overallStatus,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Inspection(id: $id, buildingId: $buildingId, date: $inspectionDate, status: $status)';
  }
}
