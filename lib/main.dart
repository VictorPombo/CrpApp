import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'providers/auth_service.dart';
import 'services/local_storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/certificate_screen.dart';
import 'screens/certificate_validation_screen.dart';
import 'screens/student/quiz_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await LocalStorageService.clearAll(); // Reset para demo
  await LocalStorageService.seedDemoData(); // Popular dados de teste
  await ThemeService.load();
  await AuthService.load(); // Restaurar sessão antes do runApp
  runApp(const CrpApp());
}

class CrpApp extends StatefulWidget {
  const CrpApp({super.key});

  @override
  State<CrpApp> createState() => _CrpAppState();
}

class _CrpAppState extends State<CrpApp> {
  late final GoRouter _router;

  // Rotas que exigem autenticação
  static const _protectedPrefixes = ['/lesson', '/certificate', '/quiz'];

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: AuthService.notifier,
      redirect: _guardRedirect,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/course/:courseId',
          builder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            return CourseDetailScreen(courseId: courseId);
          },
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) {
            final lessonId = state.pathParameters['lessonId']!;
            return LessonPlayerScreen(lessonId: lessonId);
          },
        ),
        GoRoute(
          path: '/certificate/:courseId',
          builder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return CertificateScreen(
              courseId: courseId,
              quizScore: extra?['quizScore'] as int?,
              progressPercent: (extra?['progressPercent'] as double?) ?? 1.0,
            );
          },
        ),
        GoRoute(
          path: '/validar/:code',
          builder: (context, state) {
            final code = state.pathParameters['code']!;
            return CertificateValidationScreen(code: code);
          },
        ),
        GoRoute(
          path: '/quiz/:courseId',
          builder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            final courseTitle =
                state.uri.queryParameters['title'] ?? 'Avaliação';
            return QuizScreen(
              courseId: courseId,
              courseTitle: courseTitle,
            );
          },
        ),
      ],
    );
  }

  /// Guard de rota: redireciona para login se não autenticado
  String? _guardRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = AuthService.isAuthenticated;
    final currentPath = state.uri.path;

    // Verificar se a rota é protegida
    final isProtected =
        _protectedPrefixes.any((p) => currentPath.startsWith(p));

    if (isProtected && !isLoggedIn) {
      // Salvar destino original para redirect após login
      final destination = Uri.encodeComponent(state.uri.toString());
      return '/login?redirect=$destination';
    }

    // Se está logado e tentando acessar login/register → ir para home
    if (isLoggedIn &&
        (currentPath == '/login' || currentPath == '/register')) {
      return '/home';
    }

    return null; // Sem redirect
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'CRP Cursos',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
        );
      },
    );
  }
}