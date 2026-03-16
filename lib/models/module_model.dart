import 'lesson_model.dart';

class Module {
  final String id;
  final String courseId;
  final String title;
  final int sortOrder;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.sortOrder,
    this.lessons = const [],
  });

  int get totalLessons => lessons.length;

  int get totalDurationMinutes =>
      lessons.fold(0, (sum, l) => sum + (l.durationSeconds ~/ 60));

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        title: json['title'] as String,
        sortOrder: json['sort_order'] as int,
        lessons: (json['lessons'] as List<dynamic>?)
                ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
