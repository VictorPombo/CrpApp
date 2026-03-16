enum EnrollmentStatus { emAndamento, concluido }

class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final EnrollmentStatus status;
  final double progressPct; // 0.0 - 1.0
  final int completedLessons;
  final int totalLessons;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    this.status = EnrollmentStatus.emAndamento,
    this.progressPct = 0.0,
    this.completedLessons = 0,
    required this.totalLessons,
    required this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  bool get isCompleted => status == EnrollmentStatus.concluido;

  String get progressFormatted => '${(progressPct * 100).toInt()}%';

  String get lastAccessLabel {
    if (lastAccessedAt == null) return 'Nunca acessado';
    final diff = DateTime.now().difference(lastAccessedAt!);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return '${lastAccessedAt!.day}/${lastAccessedAt!.month}/${lastAccessedAt!.year}';
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        courseId: json['course_id'] as String,
        status: json['status'] == 'concluido'
            ? EnrollmentStatus.concluido
            : EnrollmentStatus.emAndamento,
        progressPct: (json['progress_pct'] as num?)?.toDouble() ?? 0.0,
        completedLessons: (json['completed_lessons'] as int?) ?? 0,
        totalLessons: json['total_lessons'] as int,
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        lastAccessedAt: json['last_accessed_at'] != null
            ? DateTime.parse(json['last_accessed_at'] as String)
            : null,
      );
}
