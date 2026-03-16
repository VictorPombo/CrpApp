import 'module_model.dart';

class Course {
  final String id;
  final String code;
  final String title;
  final String description;
  final String category;
  final int hours;
  final int lessonsCount;
  final double progress; // 0.0 - 1.0
  final double price;
  final String? thumbnailUrl;
  final String instructorName;
  final String instructorCrea;
  final double rating;
  final int studentsCount;
  final bool published;
  final List<String> objectives;
  final List<Module> modules;

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.category = 'Geral',
    required this.hours,
    required this.lessonsCount,
    this.progress = 0.0,
    this.price = 0.0,
    this.thumbnailUrl,
    this.instructorName = '',
    this.instructorCrea = '',
    this.rating = 0.0,
    this.studentsCount = 0,
    this.published = true,
    this.objectives = const [],
    this.modules = const [],
  });

  bool get isFree => price <= 0;

  String get priceFormatted =>
      isFree ? 'Gratuito' : 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  int get modulesCount => modules.length;

  /// Cria cópia com progresso atualizado (para enrollment real)
  Course copyWithProgress(double newProgress) => Course(
        id: id,
        code: code,
        title: title,
        description: description,
        category: category,
        hours: hours,
        lessonsCount: lessonsCount,
        progress: newProgress,
        price: price,
        thumbnailUrl: thumbnailUrl,
        instructorName: instructorName,
        instructorCrea: instructorCrea,
        rating: rating,
        studentsCount: studentsCount,
        published: published,
        objectives: objectives,
        modules: modules,
      );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        code: json['code'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: (json['category'] as String?) ?? 'Geral',
        hours: json['hours'] as int,
        lessonsCount: json['lessons_count'] as int,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        thumbnailUrl: json['thumbnail_url'] as String?,
        instructorName: (json['instructor_name'] as String?) ?? '',
        instructorCrea: (json['instructor_crea'] as String?) ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        studentsCount: (json['students_count'] as int?) ?? 0,
        objectives: (json['objectives'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        modules: (json['modules'] as List<dynamic>?)
                ?.map((e) => Module.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
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
        'price': price,
        'instructor_name': instructorName,
        'instructor_crea': instructorCrea,
        'rating': rating,
        'students_count': studentsCount,
      };
}
