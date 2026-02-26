class Course {
  final String id;
  final String code;
  final String title;
  final String description;
  final String category;
  final int hours;
  final int lessonsCount;
  final double progress; // 0.0 - 1.0

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.category = 'Geral',
    required this.hours,
    required this.lessonsCount,
    this.progress = 0.0,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        code: json['code'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: (json['category'] as String?) ?? 'Geral',
        hours: json['hours'] as int,
        lessonsCount: json['lessons_count'] as int,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'hours': hours,
        'lessons_count': lessonsCount,
        'category': category,
        'progress': progress,
      };
}
