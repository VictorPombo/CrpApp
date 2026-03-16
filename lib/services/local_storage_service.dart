import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço centralizado de persistência local via SharedPreferences.
/// Gerencia enrollments, certificados, anotações e pagamentos.
class LocalStorageService {
  static SharedPreferences? _prefs;

  /// Inicializa o serviço (chamar antes de usar)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'LocalStorageService.init() não foi chamado');
    return _prefs!;
  }

  // ═══════════════════════════════════════
  // ENROLLMENTS
  // ═══════════════════════════════════════

  static const _keyEnrollments = 'enrollments';

  /// Retorna todas as matrículas salvas
  static List<Map<String, dynamic>> getEnrollments() {
    final raw = _p.getString(_keyEnrollments);
    if (raw == null) return [];
    return (json.decode(raw) as List).cast<Map<String, dynamic>>();
  }

  /// Retorna enrollment de um curso específico (null se não matriculado)
  static Map<String, dynamic>? getEnrollment(String courseId) {
    final list = getEnrollments();
    try {
      return list.firstWhere((e) => e['course_id'] == courseId);
    } catch (_) {
      return null;
    }
  }

  /// Verifica se está matriculado em um curso
  static bool isEnrolled(String courseId) {
    return getEnrollment(courseId) != null;
  }

  /// Cria nova matrícula após compra
  static Future<void> enrollCourse({
    required String courseId,
    required int totalLessons,
  }) async {
    final list = getEnrollments();

    // Não duplicar
    if (list.any((e) => e['course_id'] == courseId)) return;

    list.add({
      'course_id': courseId,
      'status': 'em_andamento',
      'progress': 0.0,
      'completed_lessons': <String>[],
      'total_lessons': totalLessons,
      'started_at': DateTime.now().toIso8601String(),
      'completed_at': null,
      'last_accessed_at': DateTime.now().toIso8601String(),
    });

    await _p.setString(_keyEnrollments, json.encode(list));
  }

  /// Marca uma aula como concluída e atualiza progresso.
  /// Se o aluno não estiver matriculado, cria enrollment automaticamente.
  static Future<double> markLessonComplete({
    required String courseId,
    required String lessonId,
    int totalLessons = 12,
  }) async {
    final list = getEnrollments();
    var idx = list.indexWhere((e) => e['course_id'] == courseId);

    // Auto-criar enrollment se não existe
    if (idx == -1) {
      list.add({
        'course_id': courseId,
        'status': 'em_andamento',
        'progress': 0.0,
        'completed_lessons': <String>[],
        'total_lessons': totalLessons,
        'started_at': DateTime.now().toIso8601String(),
        'completed_at': null,
        'last_accessed_at': DateTime.now().toIso8601String(),
      });
      idx = list.length - 1;
    }

    final enrollment = Map<String, dynamic>.from(list[idx]);
    final completed = List<String>.from(enrollment['completed_lessons'] ?? []);

    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
    }

    final total = (enrollment['total_lessons'] as int?) ?? totalLessons;
    final progress = (completed.length / total).clamp(0.0, 1.0);

    enrollment['completed_lessons'] = completed;
    enrollment['progress'] = progress;
    enrollment['last_accessed_at'] = DateTime.now().toIso8601String();

    if (progress >= 1.0) {
      enrollment['status'] = 'concluido';
      enrollment['completed_at'] = DateTime.now().toIso8601String();
    }

    list[idx] = enrollment;
    await _p.setString(_keyEnrollments, json.encode(list));
    return progress;
  }

  /// Retorna lista de lesson IDs concluídas de um curso
  static List<String> getCompletedLessons(String courseId) {
    final enrollment = getEnrollment(courseId);
    if (enrollment == null) return [];
    return List<String>.from(enrollment['completed_lessons'] ?? []);
  }

  /// Retorna progresso de um curso (0.0 a 1.0)
  static double getProgress(String courseId) {
    final enrollment = getEnrollment(courseId);
    if (enrollment == null) return 0.0;
    return (enrollment['progress'] as num?)?.toDouble() ?? 0.0;
  }

  // ═══════════════════════════════════════
  // CERTIFICATES
  // ═══════════════════════════════════════

  static const _keyCertificates = 'certificates';

  /// Retorna todos os certificados emitidos
  static List<Map<String, dynamic>> getCertificates() {
    final raw = _p.getString(_keyCertificates);
    if (raw == null) return [];
    return (json.decode(raw) as List).cast<Map<String, dynamic>>();
  }

  /// Retorna certificado de um curso (null se não possui)
  static Map<String, dynamic>? getCertificate(String courseId) {
    final list = getCertificates();
    try {
      return list.firstWhere((c) => c['course_id'] == courseId);
    } catch (_) {
      return null;
    }
  }

  /// Emite certificado para um curso concluído
  static Future<void> issueCertificate({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required int courseHours,
    required int quizScore,
  }) async {
    final list = getCertificates();

    // Não duplicar
    if (list.any((c) => c['course_id'] == courseId)) return;

    final year = DateTime.now().year;
    final seq = (list.length + 1).toString().padLeft(4, '0');
    final code = 'CRP-${courseCode.replaceAll('NR-', '')}-$year-$seq';

    list.add({
      'course_id': courseId,
      'course_code': courseCode,
      'course_title': courseTitle,
      'course_hours': courseHours,
      'cert_code': code,
      'quiz_score': quizScore,
      'issued_at': DateTime.now().toIso8601String(),
      'valid_until':
          DateTime.now().add(const Duration(days: 730)).toIso8601String(),
    });

    await _p.setString(_keyCertificates, json.encode(list));
  }

  // ═══════════════════════════════════════
  // ANOTAÇÕES
  // ═══════════════════════════════════════

  static const _keyAnnotationPrefix = 'annotation_';

  /// Salva anotação de uma aula
  static Future<void> saveAnnotation(String lessonId, String text) async {
    await _p.setString('$_keyAnnotationPrefix$lessonId', text);
  }

  /// Carrega anotação de uma aula
  static String getAnnotation(String lessonId) {
    return _p.getString('$_keyAnnotationPrefix$lessonId') ?? '';
  }

  // ═══════════════════════════════════════
  // PAGAMENTOS
  // ═══════════════════════════════════════

  static const _keyPayments = 'payments';

  /// Registra um pagamento
  static Future<void> addPayment({
    required String courseId,
    required String courseTitle,
    required double amount,
    required String method,
  }) async {
    final list = getPayments();
    final seq = (list.length + 1).toString().padLeft(3, '0');

    list.add({
      'course_id': courseId,
      'course': courseTitle,
      'date': _formatDate(DateTime.now()),
      'amount': 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
      'method': method,
      'status': 'pago',
      'txId': 'TXN-${DateTime.now().year}-$seq',
    });

    await _p.setString(_keyPayments, json.encode(list));
  }

  /// Retorna todos os pagamentos
  static List<Map<String, dynamic>> getPayments() {
    final raw = _p.getString(_keyPayments);
    if (raw == null) return [];
    return (json.decode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ═══════════════════════════════════════
  // UTILITÁRIOS
  // ═══════════════════════════════════════

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// Limpa todos os dados do usuário (para logout)
  static Future<void> clearAll() async {
    await _p.remove(_keyEnrollments);
    await _p.remove(_keyCertificates);
    await _p.remove(_keyPayments);

    // Limpar anotações
    final keys =
        _p.getKeys().where((k) => k.startsWith(_keyAnnotationPrefix));
    for (final key in keys) {
      await _p.remove(key);
    }
  }
}
