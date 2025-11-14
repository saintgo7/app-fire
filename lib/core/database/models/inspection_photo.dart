import 'dart:io';

/// 점검 사진 모델
class InspectionPhoto {
  final int? id;
  final int inspectionItemId;

  final String filePath;
  final String fileName;
  final int? fileSize;
  final String? takenAt;

  final String? serverUrl;
  final int isUploaded;

  final String? createdAt;

  InspectionPhoto({
    this.id,
    required this.inspectionItemId,
    required this.filePath,
    required this.fileName,
    this.fileSize,
    this.takenAt,
    this.serverUrl,
    this.isUploaded = 0,
    this.createdAt,
  });

  factory InspectionPhoto.fromMap(Map<String, dynamic> map) {
    return InspectionPhoto(
      id: map['id'] as int?,
      inspectionItemId: map['inspection_item_id'] as int,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      fileSize: map['file_size'] as int?,
      takenAt: map['taken_at'] as String?,
      serverUrl: map['server_url'] as String?,
      isUploaded: map['is_uploaded'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'inspection_item_id': inspectionItemId,
      'file_path': filePath,
      'file_name': fileName,
      'file_size': fileSize,
      'taken_at': takenAt,
      'server_url': serverUrl,
      'is_uploaded': isUploaded,
      'created_at': createdAt,
    };
  }

  /// 파일이 존재하는지 확인
  bool fileExists() {
    return File(filePath).existsSync();
  }

  /// 파일 크기를 MB로 반환
  double? get fileSizeMB {
    if (fileSize == null) return null;
    return fileSize! / (1024 * 1024);
  }

  /// 업로드 필요 여부
  bool get needsUpload {
    return isUploaded == 0 && serverUrl == null;
  }

  InspectionPhoto copyWith({
    int? id,
    int? inspectionItemId,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? takenAt,
    String? serverUrl,
    int? isUploaded,
    String? createdAt,
  }) {
    return InspectionPhoto(
      id: id ?? this.id,
      inspectionItemId: inspectionItemId ?? this.inspectionItemId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      takenAt: takenAt ?? this.takenAt,
      serverUrl: serverUrl ?? this.serverUrl,
      isUploaded: isUploaded ?? this.isUploaded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'InspectionPhoto(id: $id, fileName: $fileName, uploaded: ${isUploaded == 1})';
  }
}
