import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/course_service_mock.dart';
import '../../services/local_storage_service.dart';
import '../../models/course_model.dart';

class CourseHistoryScreen extends StatefulWidget {
  const CourseHistoryScreen({super.key});

  @override
  State<CourseHistoryScreen> createState() => _CourseHistoryScreenState();
}

class _CourseHistoryScreenState extends State<CourseHistoryScreen> {
  final _service = CourseServiceMock();
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _service.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de cursos')),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allCourses = snapshot.data ?? [];

          // Filtrar apenas cursos com enrollment real
          final enrollments = LocalStorageService.getEnrollments();
          final enrolledIds =
              enrollments.map((e) => e['course_id'] as String).toSet();

          final enrolledCourses = allCourses
              .where((c) => enrolledIds.contains(c.id))
              .map((c) {
            final progress = LocalStorageService.getProgress(c.id);
            return c.copyWithProgress(progress);
          }).toList();

          if (enrolledCourses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_outlined,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Nenhum curso no histórico',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Seus cursos aparecerão aqui após iniciar um',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              isDark ? Colors.grey[600] : Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: enrolledCourses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final course = enrolledCourses[index];
              final statusLabel = course.progress >= 1.0
                  ? 'Concluído'
                  : course.progress > 0
                      ? 'Em andamento'
                      : 'Não iniciado';
              final statusColor = course.progress >= 1.0
                  ? AppColors.success
                  : course.progress > 0
                      ? AppColors.secondary
                      : Colors.grey;
              final progressPercent =
                  '${(course.progress * 100).toStringAsFixed(0)}%';

              return GestureDetector(
                onTap: () => context.push('/course/${course.id}'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isDark ? AppColors.darkDivider : Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Ícone NR
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                course.code.replaceAll('NR-', ''),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${course.code} — ${course.title}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${course.hours}h · ${course.lessonsCount} aulas',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      // Barra de progresso
                      if (course.progress > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: course.progress,
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  color: course.progress >= 1.0
                                      ? AppColors.success
                                      : AppColors.primary,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(progressPercent,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600])),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
