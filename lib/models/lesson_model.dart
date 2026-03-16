class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final String? videoUrl;
  final int durationSeconds;
  final int sortOrder;
  final List<LessonMaterial> materials;

  Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    this.description = '',
    this.videoUrl,
    required this.durationSeconds,
    required this.sortOrder,
    this.materials = const [],
  });

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining > 0 ? '${hours}h${remaining}min' : '${hours}h';
  }

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        moduleId: json['module_id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        videoUrl: json['video_url'] as String?,
        durationSeconds: json['duration_seconds'] as int,
        sortOrder: json['sort_order'] as int,
        materials: (json['materials'] as List<dynamic>?)
                ?.map(
                    (e) => LessonMaterial.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class LessonMaterial {
  final String id;
  final String lessonId;
  final String title;
  final String fileUrl;
  final String fileType; // PDF, PPT, ZIP
  final int fileSizeBytes;

  LessonMaterial({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeBytes,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '${fileSizeBytes} B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory LessonMaterial.fromJson(Map<String, dynamic> json) =>
      LessonMaterial(
        id: json['id'] as String,
        lessonId: json['lesson_id'] as String,
        title: json['title'] as String,
        fileUrl: json['file_url'] as String,
        fileType: json['file_type'] as String,
        fileSizeBytes: json['file_size_bytes'] as int,
      );
}
