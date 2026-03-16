class Certificate {
  final String id;
  final String userId;
  final String courseId;
  final String enrollmentId;
  final String certificateCode; // CRP-NR35-2025-0847
  final String? pdfUrl;
  final DateTime issuedAt;
  final DateTime validUntil;
  final String studentName;
  final String courseTitle;
  final String courseCode;
  final int courseHours;
  final String instructorName;
  final String instructorCrea;

  Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrollmentId,
    required this.certificateCode,
    this.pdfUrl,
    required this.issuedAt,
    required this.validUntil,
    required this.studentName,
    required this.courseTitle,
    required this.courseCode,
    required this.courseHours,
    required this.instructorName,
    required this.instructorCrea,
  });

  bool get isValid => DateTime.now().isBefore(validUntil);

  String get validityLabel =>
      '${_monthName(validUntil.month)} ${validUntil.year}';

  String get issuedLabel =>
      '${_monthName(issuedAt.month)} ${issuedAt.year}';

  static String _monthName(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        courseId: json['course_id'] as String,
        enrollmentId: json['enrollment_id'] as String,
        certificateCode: json['certificate_code'] as String,
        pdfUrl: json['pdf_url'] as String?,
        issuedAt: DateTime.parse(json['issued_at'] as String),
        validUntil: DateTime.parse(json['valid_until'] as String),
        studentName: json['student_name'] as String,
        courseTitle: json['course_title'] as String,
        courseCode: json['course_code'] as String,
        courseHours: json['course_hours'] as int,
        instructorName: json['instructor_name'] as String,
        instructorCrea: json['instructor_crea'] as String,
      );
}
