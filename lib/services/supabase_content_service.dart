import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service para gerenciar conteúdo de aulas (apostilas, vídeos) e quizzes via Supabase.
class SupabaseContentService {
  static final _client = Supabase.instance.client;

  /// Diagnóstico: verifica acesso às tabelas de conteúdo via anon key
  static Future<void> diagnose() async {
    debugPrint('\n🔍 ═══ SUPABASE DIAGNOSTIC START ═══');
    debugPrint('🔍 Auth user: ${_client.auth.currentUser?.id ?? "NOT LOGGED IN"}');
    debugPrint('🔍 Auth session: ${_client.auth.currentSession != null ? "ACTIVE" : "NO SESSION"}');
    
    // Test 1: lesson_content table access (no filters)
    try {
      final allContent = await _client.from('lesson_content').select('id, lesson_id, content_type').limit(3);
      debugPrint('🔍 lesson_content SELECT (no filter): ${allContent.length} rows returned');
      for (final row in allContent) {
        debugPrint('   → lesson_id=${row['lesson_id']}, type=${row['content_type']}');
      }
    } catch (e) {
      debugPrint('🔍 ❌ lesson_content SELECT failed: $e');
    }
    
    // Test 2: quizzes table access
    try {
      final allQuizzes = await _client.from('quizzes').select('id, module_id, title').limit(3);
      debugPrint('🔍 quizzes SELECT (no filter): ${allQuizzes.length} rows returned');
      for (final row in allQuizzes) {
        debugPrint('   → module_id=${row['module_id']}, title=${row['title']}');
      }
    } catch (e) {
      debugPrint('🔍 ❌ quizzes SELECT failed: $e');
    }
    
    // Test 3: specific query matching what _loadApostila does
    try {
      final specific = await _client
          .from('lesson_content')
          .select()
          .eq('lesson_id', 'nr10_m1_l1')
          .eq('content_type', 'apostila')
          .maybeSingle();
      debugPrint('🔍 specific query (nr10_m1_l1 + apostila): ${specific != null ? "FOUND" : "NULL"}');
    } catch (e) {
      debugPrint('🔍 ❌ specific query failed: $e');
    }
    
    debugPrint('🔍 ═══ SUPABASE DIAGNOSTIC END ═══\n');
  }
  // ═══════════════════════════════════════
  // CONTEÚDO DAS AULAS
  // ═══════════════════════════════════════

  /// Busca todo o conteúdo de uma aula (apostila + vídeo)
  static Future<List<Map<String, dynamic>>> getLessonContent(
    String courseId, {
    String? contentType,
    String? lessonId,
  }) async {
    try {
      var query = _client.from('lesson_content').select().eq('course_id', courseId);
      if (contentType != null) query = query.eq('content_type', contentType);
      if (lessonId != null) query = query.eq('lesson_id', lessonId);
      final response = await query.order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ getLessonContent error: $e');
      return [];
    }
  }

  /// Busca apostila de uma aula
  static Future<Map<String, dynamic>?> getApostila(String lessonId) async {
    try {
      final response = await _client
          .from('lesson_content')
          .select()
          .eq('lesson_id', lessonId)
          .eq('content_type', 'apostila')
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('❌ getApostila error for lessonId=$lessonId: $e');
      return null;
    }
  }

  /// Busca vídeo de uma aula
  static Future<Map<String, dynamic>?> getVideo(String lessonId) async {
    try {
      final response = await _client
          .from('lesson_content')
          .select()
          .eq('lesson_id', lessonId)
          .eq('content_type', 'video')
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('❌ getVideo error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════
  // QUIZZES
  // ═══════════════════════════════════════

  /// Busca quiz de um módulo específico
  static Future<Map<String, dynamic>?> getModuleQuiz(String moduleId) async {
    try {
      final response = await _client
          .from('quizzes')
          .select()
          .eq('module_id', moduleId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('❌ getModuleQuiz error for moduleId=$moduleId: $e');
      return null;
    }
  }

  /// Busca todas as questões de um quiz
  static Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) async {
    try {
      final response = await _client
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ getQuizQuestions error: $e');
      return [];
    }
  }

  /// Busca quiz completo (quiz + questões) de um módulo
  static Future<Map<String, dynamic>?> getFullModuleQuiz(String moduleId) async {
    final quiz = await getModuleQuiz(moduleId);
    if (quiz == null) return null;

    final questions = await getQuizQuestions(quiz['id'].toString());
    return {
      ...quiz,
      'questions': questions,
    };
  }

  // ═══════════════════════════════════════
  // TENTATIVAS DE QUIZ
  // ═══════════════════════════════════════

  /// Submete tentativa de quiz
  /// Retorna score em % e se passou
  static Future<Map<String, dynamic>?> submitQuizAttempt({
    required String quizId,
    required Map<String, String> answers, // {"question_id": "a", ...}
    required int passingScore,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Buscar questões para calcular nota
      final questions = await getQuizQuestions(quizId);
      if (questions.isEmpty) return null;

      int correct = 0;
      for (final q in questions) {
        final qId = q['id'].toString();
        final userAnswer = answers[qId];
        if (userAnswer == q['correct_option']) {
          correct++;
        }
      }

      final score = ((correct / questions.length) * 100).round();
      final passed = score >= passingScore;

      // Upsert — atualiza se já tentou antes
      final response = await _client
          .from('quiz_attempts')
          .upsert({
            'user_id': user.id,
            'quiz_id': quizId,
            'score': score,
            'answers': answers,
            'passed': passed,
            'attempted_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,quiz_id')
          .select()
          .single();

      return {
        ...response,
        'total_questions': questions.length,
        'correct_count': correct,
      };
    } catch (e) {
      return null;
    }
  }

  /// Busca tentativa anterior do usuário para um quiz
  static Future<Map<String, dynamic>?> getQuizAttempt(String quizId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('quiz_attempts')
          .select()
          .eq('user_id', user.id)
          .eq('quiz_id', quizId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Busca todas as tentativas do usuário para um curso
  static Future<List<Map<String, dynamic>>> getCourseAttempts(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      // Buscar quizzes do curso
      final quizzes = await _client
          .from('quizzes')
          .select('id')
          .eq('course_id', courseId);

      final quizIds = (quizzes as List).map((q) => q['id'].toString()).toList();
      if (quizIds.isEmpty) return [];

      final response = await _client
          .from('quiz_attempts')
          .select()
          .eq('user_id', user.id)
          .inFilter('quiz_id', quizIds);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
