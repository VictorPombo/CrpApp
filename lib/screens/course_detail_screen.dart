import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/app_spacing.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../services/course_service_mock.dart';
import '../services/local_storage_service.dart';
import '../services/certificate_eligibility_service.dart';
import '../providers/auth_service.dart';
import 'purchase/cart_screen.dart';
import 'lesson_screen.dart';
import 'student/quiz_screen.dart';

/// Tela de detalhes do curso (antes da compra).
/// Baseada no mockup: detalhe_curso.png
class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Course? _course;
  bool _loading = true;

  // Mock: IDs das aulas concluídas (simula enrollment)
  // Na integração real, virá do EnrollmentService
  final Set<String> _completedLessonIds = {};

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final courses = await CourseServiceMock().fetchCourses();
    final c = courses.firstWhere((c) => c.id == widget.courseId,
        orElse: () => courses.first);

    // Carregar aulas concluídas do LocalStorageService (dados reais)
    final realCompleted = LocalStorageService.getCompletedLessons(widget.courseId);

    setState(() {
      _course = c;
      _completedLessonIds.addAll(realCompleted);
      _loading = false;
    });
  }

  /// Retorna o ID da próxima aula a assistir (primeira não concluída)
  String? _getCurrentLessonId(Course course) {
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (!_completedLessonIds.contains(lesson.id)) {
          return lesson.id;
        }
      }
    }
    return null; // todas concluídas
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final course = _course!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth(context)),
          child: CustomScrollView(
        slivers: [
          // Header com gradiente
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                child: SafeArea(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(
                                  5,
                                  (i) => Icon(
                                        i < course.rating.floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      )),
                              const SizedBox(width: 6),
                              Text(
                                '${course.rating}  ·  ${course.studentsCount} alunos',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatBox(
                      value: '${course.hours}h',
                      label: 'Carga',
                      icon: Icons.schedule),
                  _StatBox(
                      value: '${course.modulesCount}',
                      label: 'Módulos',
                      icon: Icons.folder_outlined),
                  _StatBox(
                      value: '${course.lessonsCount}',
                      label: 'Aulas',
                      icon: Icons.play_circle_outline),
                  _StatBox(
                      value: '✓',
                      label: 'Certificado',
                      icon: Icons.workspace_premium),
                ],
              ),
            ),
          ),

          // Sobre o curso
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sobre o curso',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(course.description,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),

                  // Objetivos
                  if (course.objectives.isNotEmpty) ...[
                    Text('O que você vai aprender',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...course.objectives.map((obj) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(obj,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],

                  // Conteúdo programático
                  Text('Conteúdo programático',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Módulos com estados visuais
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = course.modules[index];
                final currentLessonId = _getCurrentLessonId(course);

                // Calcular progresso do módulo
                final completedInModule = module.lessons
                    .where((l) => _completedLessonIds.contains(l.id))
                    .length;
                final totalInModule = module.totalLessons;
                final moduleProgress = totalInModule > 0
                    ? (completedInModule / totalInModule * 100).toInt()
                    : 0;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      'Módulo ${module.sortOrder} — ${module.title}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    trailing: Text(
                      completedInModule > 0
                          ? '$completedInModule/$totalInModule · $moduleProgress%'
                          : '$totalInModule aulas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: completedInModule > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: completedInModule > 0
                            ? const Color(0xFF3B6D11)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    children: [
                      ...module.lessons.map((lesson) {
                      // Calcula o índice global da aula
                      int globalIndex = 0;
                      for (final m in course.modules) {
                        if (m.id == module.id) {
                          globalIndex += lesson.sortOrder;
                          break;
                        }
                        globalIndex += m.totalLessons;
                      }

                      final isCompleted =
                          _completedLessonIds.contains(lesson.id);
                      final isCurrent = lesson.id == currentLessonId;

                      return _buildLessonRow(
                        context: context,
                        lesson: lesson,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isDark: isDark,
                        globalIndex: globalIndex,
                        course: course,
                      );
                    }),
                      // Quiz do módulo
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: InkWell(
                          onTap: () => context.push(
                            '/module-quiz/${module.id}'
                            '?title=${Uri.encodeComponent('Quiz — ${module.title}')}',
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6C5CE7).withValues(alpha: isDark ? 0.2 : 0.08),
                                  const Color(0xFFA29BFE).withValues(alpha: isDark ? 0.1 : 0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.quiz_outlined, size: 16, color: Color(0xFF6C5CE7)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('Quiz do Módulo',
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFA29BFE) : const Color(0xFF6C5CE7),
                                    )),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 14,
                                    color: isDark ? const Color(0xFFA29BFE) : const Color(0xFF6C5CE7)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: course.modules.length,
            ),
          ),

          // Instrutor
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child:
                          Icon(Icons.person, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.instructorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(course.instructorCrea,
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barra de ação (dentro do scroll, respeita o ConstrainedBox)
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final isEnrolled = LocalStorageService.isEnrolled(course.id);
                final isDarkAction = Theme.of(context).brightness == Brightness.dark;

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkAction ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isEnrolled
                      ? _buildEnrolledBottomBar(course, isDarkAction)
                      : Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('à vista',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500])),
                                Text(
                                  course.priceFormatted,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CartScreen(course: course),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              child: const Text('Comprar curso',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  /// Constrói uma row de aula com 3 estados visuais:
  /// 1. Concluída (verde)  2. Atual (azul)  3. Não iniciada (cinza)
  Widget _buildLessonRow({
    required BuildContext context,
    required Lesson lesson,
    required bool isCompleted,
    required bool isCurrent,
    required bool isDark,
    required int globalIndex,
    required Course course,
  }) {
    // ── Cores por estado ──
    const greenMain = Color(0xFF3B6D11);
    const greenBg = Color(0xFFEAF3DE);
    const blueMain = Color(0xFF185FA5);
    const blueBg = Color(0xFFE6F1FB);
    const grayIcon = Color(0xFFB4B2A9);

    // Ícone
    Widget leadingIcon;
    if (isCompleted) {
      leadingIcon = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? greenMain.withValues(alpha: 0.2) : greenBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle, size: 20, color: greenMain),
      );
    } else if (isCurrent) {
      leadingIcon = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? blueMain.withValues(alpha: 0.2) : blueBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_circle_fill, size: 20, color: blueMain),
      );
    } else {
      leadingIcon =
          const Icon(Icons.play_circle_outline, size: 20, color: grayIcon);
    }

    // Título
    TextStyle titleStyle;
    if (isCompleted) {
      titleStyle = TextStyle(
        fontSize: 13,
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        decoration: TextDecoration.lineThrough,
        decorationColor: isDark ? Colors.grey[500] : Colors.grey[600],
      );
    } else if (isCurrent) {
      titleStyle = TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : blueMain,
      );
    } else {
      titleStyle = TextStyle(
        fontSize: 13,
        color: isDark ? Colors.grey[400] : Colors.grey[700],
      );
    }

    // Badge
    Widget? badge;
    if (isCompleted) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? greenMain.withValues(alpha: 0.15) : greenBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Concluída',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: greenMain)),
      );
    } else if (isCurrent) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? blueMain.withValues(alpha: 0.15) : blueBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Assistir agora',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: blueMain)),
      );
    }

    // Fundo e borda para aula atual
    BoxDecoration? rowDecoration;
    if (isCurrent) {
      rowDecoration = BoxDecoration(
        color: isDark
            ? blueMain.withValues(alpha: 0.08)
            : Colors.blue.withValues(alpha: 0.06),
        border: const Border(
          left: BorderSide(color: blueMain, width: 3),
        ),
      );
    }

    return Container(
      decoration: rowDecoration,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(
          left: isCurrent ? 13 : 16,
          right: 16,
        ),
        leading: leadingIcon,
        title: Text(lesson.title, style: titleStyle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              badge,
              const SizedBox(width: 8),
            ],
            Text(lesson.durationFormatted,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600])),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonPlayerScreen(
                lessonId: lesson.id,
                lesson: lesson,
                currentIndex: globalIndex,
                totalLessons: course.lessonsCount,
                courseId: course.id,
              ),
            ),
          ).then((_) {
            // Recarregar aulas concluídas ao voltar do player
            final updated = LocalStorageService.getCompletedLessons(widget.courseId);
            setState(() {
              _completedLessonIds.clear();
              _completedLessonIds.addAll(updated);
            });
          });
        },
      ),
    );
  }

  /// Barra inferior dinâmica para aluno matriculado
  Widget _buildEnrolledBottomBar(Course course, bool isDark) {
    final progress = LocalStorageService.getProgress(course.id);
    final quizApproved = LocalStorageService.isQuizApproved(course.id);
    final quizScore = LocalStorageService.getQuizScore(course.id);
    final allLessons = course.modules.expand((m) => m.lessons).toList();

    // Estado 1: Quiz aprovado → Ver certificado
    if (quizApproved && quizScore != null) {
      final user = AuthService.currentUser;
      final elig = CertificateEligibilityService.check(
        progressPercent: progress, quizScore: quizScore,
        userCpf: user.cpf, userCompany: user.company,
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text('Avaliação aprovada com $quizScore%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.success)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/certificate/${course.id}',
                extra: {'quizScore': quizScore, 'progressPercent': progress}),
              icon: const Icon(Icons.workspace_premium_outlined),
              label: Text(elig.isEligible ? 'Ver certificado' : 'Verificar certificado',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    }

    // Estado 2: Progresso >= 75% → Fazer avaliação
    if (progress >= 0.75) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.secondary.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.school_outlined,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                    size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${(progress * 100).toInt()}% concluído — pronto para avaliação!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.secondary : AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    courseId: course.id, courseTitle: course.title,
                    progressPercent: progress,
                  ),
                ));
                _loadCourse();
              },
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Fazer avaliação',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    }

    // Estado 3: Progresso < 75% → Continuar curso
    final completed = LocalStorageService.getCompletedLessons(course.id);
    final nextLesson = allLessons.firstWhere(
      (l) => !completed.contains(l.id),
      orElse: () => allLessons.first,
    );
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => LessonPlayerScreen(
              lessonId: nextLesson.id, lesson: nextLesson,
              courseId: course.id,
              currentIndex: allLessons.indexOf(nextLesson) + 1,
              totalLessons: allLessons.length,
            ),
          ));
          _loadCourse();
        },
        icon: const Icon(Icons.play_circle_outline),
        label: Text('Continuar curso · ${(progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBox(
      {required this.value, required this.label, required this.icon});

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
            color: isDark ? AppColors.darkDivider : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
