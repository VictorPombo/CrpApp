import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/app_spacing.dart';
import '../core/config/supabase_config.dart';
import '../providers/auth_service.dart';
import '../services/course_service_mock.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_certificate_service.dart';
import '../models/course_model.dart';

/// Tela "Meus Cursos" — Baseada no mockup meus_cursos.png
class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final _service = CourseServiceMock();
  late Future<List<Course>> _coursesFuture;
  String _selectedFilter = 'Todos';
  int _certCount = 0;

  final _filters = ['Todos', 'Em andamento', 'Concluídos', 'Não iniciados'];

  @override
  void initState() {
    super.initState();
    _coursesFuture = _service.fetchCourses();
    _loadCertCount();
  }

  Future<void> _loadCertCount() async {
    if (SupabaseConfig.useSupabaseAuth) {
      final certs = await SupabaseCertificateService.getUserCertificates();
      if (mounted) setState(() => _certCount = certs.length);
    } else {
      setState(() => _certCount = LocalStorageService.getCertificates().length);
    }
  }

  List<Course> _applyFilter(List<Course> courses) {
    switch (_selectedFilter) {
      case 'Em andamento':
        return courses.where((c) => c.progress > 0 && c.progress < 1).toList();
      case 'Concluídos':
        return courses.where((c) => c.progress >= 1.0).toList();
      case 'Não iniciados':
        return courses.where((c) => c.progress == 0).toList();
      default:
        return courses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allCourses = snapshot.data ?? [];

          // Filtrar apenas cursos com enrollment real
          final enrollments = LocalStorageService.getEnrollments();
          final enrolledIds = enrollments.map((e) => e['course_id'] as String).toSet();


          final enrolledCourses = allCourses.where((c) => enrolledIds.contains(c.id)).map((c) {
            final progress = LocalStorageService.getProgress(c.id);
            return c.copyWithProgress(progress);
          }).toList();

          final enrolled = enrolledCourses.where((c) => c.progress > 0 && c.progress < 1.0).toList();
          final completed = enrolledCourses.where((c) => c.progress >= 1.0).toList();
          final filtered = _applyFilter(enrolledCourses);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth(context)),
              child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Meus cursos',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium),
                                const SizedBox(height: 4),
                                Builder(builder: (_) {
                                  final name = AuthService.currentUser.username ?? 'Aluno';
                                  final firstName = name.split(' ').first;
                                  return Text('Olá, $firstName',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]));
                                }),
                              ],
                            ),
                          ),
                          // Avatar
                          Builder(builder: (_) {
                            final name = AuthService.currentUser.username ?? 'Aluno';
                            final parts = name.split(' ');
                            final initials = parts.length >= 2
                                ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
                                : parts.first.substring(0, 2).toUpperCase();
                            return Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                              value: '${enrolledCourses.length}', label: 'Cursos'),
                          _StatChip(
                              value: '${completed.length}',
                              label: 'Concluídos'),
                          _StatChip(
                              value: '$_certCount',
                              label: 'Certificados'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((f) {
                            final selected = f == _selectedFilter;
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(f, style: const TextStyle(fontSize: 13)),
                                selected: selected,
                                selectedColor: AppColors.secondary,
                                backgroundColor: isDark ? AppColors.darkCard : null,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : isDark
                                          ? Colors.grey[300]
                                          : AppColors.textBody,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.secondary
                                      : isDark
                                          ? Colors.grey[600]!
                                          : Colors.grey[300]!,
                                ),
                                onSelected: (_) =>
                                    setState(() => _selectedFilter = f),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Continuar de onde parei
                      if (enrolled.isNotEmpty &&
                          _selectedFilter == 'Todos') ...[
                        Text('Continuar de onde parei',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),

              // Course list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = filtered[index];
                    return _MyCourseCard(course: course);
                  },
                  childCount: filtered.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
          ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppColors.darkDivider : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _MyCourseCard extends StatelessWidget {
  final Course course;
  const _MyCourseCard({required this.course});

  String get _statusLabel {
    if (course.progress >= 1.0) return 'Concluído';
    if (course.progress > 0) return 'Em andamento';
    return 'Não iniciado';
  }

  Color get _statusColor {
    if (course.progress >= 1.0) return AppColors.info;
    if (course.progress > 0) return AppColors.badgeEmAndamento;
    return AppColors.badgeNaoIniciado;
  }

  Color get _progressColor {
    if (course.progress >= 1.0) return AppColors.success;
    return AppColors.secondary;
  }

  /// Formata data de conclusão real do enrollment
  String _formatCompletionDate(String courseId) {
    final enrollment = LocalStorageService.getEnrollment(courseId);
    if (enrollment == null || enrollment['completed_at'] == null) return '—';
    try {
      final date = DateTime.parse(enrollment['completed_at'] as String);
      final months = [
        '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
        'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
      ];
      return '${months[date.month]} ${date.year}';
    } catch (_) {
      return '—';
    }
  }

  /// Calcula label dinâmico para "última aula"
  String _lastAccessLabel(String courseId) {
    final enrollment = LocalStorageService.getEnrollment(courseId);
    if (enrollment == null || enrollment['last_accessed_at'] == null) {
      return 'Última aula: —';
    }
    try {
      final last = DateTime.parse(enrollment['last_accessed_at'] as String);
      final diff = DateTime.now().difference(last);
      if (diff.inDays == 0) return 'Última aula: hoje';
      if (diff.inDays == 1) return 'Última aula: ontem';
      if (diff.inDays < 7) return 'Última aula: há ${diff.inDays} dias';
      return 'Última aula: há ${(diff.inDays / 7).floor()} sem.';
    } catch (_) {
      return 'Última aula: —';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lessonsCompleted =
        (course.lessonsCount * course.progress).round();

    return GestureDetector(
      onTap: () => context.push('/course/${course.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Ícone
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      course.code.replaceAll('NR-', ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Título e info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${course.code} — ${course.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.progress >= 1.0
                            ? 'Concluído em ${_formatCompletionDate(course.id)}'
                            : '${course.modulesCount} módulos · ${course.hours}h de conteúdo',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Progress
            Row(
              children: [
                Text(
                  '$lessonsCompleted/${course.lessonsCount} aulas',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  '${(course.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: course.progress,
                backgroundColor:
                    isDark ? AppColors.darkDivider : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),

            // Action
            Row(
              children: [
                if (course.progress >= 0.75 && course.progress < 1.0 && !LocalStorageService.isQuizApproved(course.id)) ...[
                  Text(_lastAccessLabel(course.id),
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.grey[500] : Colors.grey[500])),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => context.push('/course/${course.id}'),
                    child: const Text('Fazer avaliação'),
                  ),
                ] else if (course.progress > 0 && course.progress < 1.0) ...[
                  Text(_lastAccessLabel(course.id),
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.grey[500] : Colors.grey[500])),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => context.push('/course/${course.id}'),
                    child: const Text('Continuar →'),
                  ),
                ] else if (course.progress >= 1.0) ...[
                  Text(
                      LocalStorageService.isQuizApproved(course.id)
                          ? 'Certificado disponível'
                          : 'Avaliação pendente',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.grey[400] : Colors.grey[600])),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () =>
                        context.push('/course/${course.id}'),
                    child: Text(LocalStorageService.isQuizApproved(course.id)
                        ? 'Ver certificado'
                        : 'Fazer avaliação'),
                  ),
                ] else ...[
                  Text('Pronto para começar',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.grey[400] : Colors.grey[600])),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => context.push('/course/${course.id}'),
                    child: const Text('Iniciar curso →'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
