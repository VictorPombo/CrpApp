import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/supabase_config.dart';
import 'certificate_hash_service.dart';

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
  // QUIZ RESULTS
  // ═══════════════════════════════════════

  /// Salva resultado do quiz no enrollment
  static Future<void> saveQuizResult(String courseId, int score) async {
    final list = getEnrollments();
    final idx = list.indexWhere((e) => e['course_id'] == courseId);
    if (idx < 0) return;
    list[idx]['quiz_score'] = score;
    list[idx]['quiz_approved'] = score >= 70;
    list[idx]['quiz_date'] = DateTime.now().toIso8601String();
    await _p.setString(_keyEnrollments, json.encode(list));
  }

  /// Retorna nota do quiz (null se não fez)
  static int? getQuizScore(String courseId) {
    final enrollment = getEnrollment(courseId);
    if (enrollment == null) return null;
    return enrollment['quiz_score'] as int?;
  }

  /// Retorna se o quiz foi aprovado
  static bool isQuizApproved(String courseId) {
    final enrollment = getEnrollment(courseId);
    if (enrollment == null) return false;
    return enrollment['quiz_approved'] == true;
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

  /// Emite certificado para um curso concluido
  static Future<void> issueCertificate({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required int courseHours,
    required int quizScore,
    String? studentName,
    String? studentCpf,
    String? company,
    String? instructorName,
    String? instructorCrea,
  }) async {
    final list = getCertificates();

    // Nao duplicar
    if (list.any((c) => c['course_id'] == courseId)) return;

    final now = DateTime.now();
    final issuedAt = now.toIso8601String();
    final validUntil = now.add(const Duration(days: 730)).toIso8601String();
    final seq = list.length + 1;

    // Serial unico deterministico
    final serial = CertificateHashService.generateSerial(
      courseCode: courseCode,
      sequentialNumber: seq,
      year: now.year,
    );

    // Hash SHA-256 para autenticidade
    final hash = CertificateHashService.generateHash(
      serial: serial,
      cpf: studentCpf ?? '',
      courseId: courseId,
      quizScore: quizScore,
      issuedAt: issuedAt,
    );

    list.add({
      'course_id': courseId,
      'course_code': courseCode,
      'course_title': courseTitle,
      'course_hours': courseHours,
      'cert_code': serial,
      'hash': hash,
      'quiz_score': quizScore,
      'student_name': studentName ?? 'Aluno',
      'student_cpf': studentCpf ?? '',
      'company': company ?? '',
      'instructor_name': instructorName ?? 'Eng. Carlos Roberto Palácio',
      'instructor_crea': instructorCrea ?? 'CREA-SP · RNP 2614455296',
      'issued_at': issuedAt,
      'valid_until': validUntil,
      'status': 'valid', // valid | expired | revoked
    });

    await _p.setString(_keyCertificates, json.encode(list));
  }

  /// Atualiza campos de um certificado existente no localStorage.
  /// Usado para personalizar o certificado com dados do usuário logado.
  static Future<void> updateCertificate({
    required String courseId,
    required Map<String, dynamic> updates,
  }) async {
    final list = getCertificates();
    final idx = list.indexWhere((c) => c['course_id'] == courseId);
    if (idx == -1) return;

    for (final entry in updates.entries) {
      list[idx][entry.key] = entry.value;
    }

    await _p.setString(_keyCertificates, json.encode(list));
    await _p.reload();

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

    // Se Supabase auth ativo, limpar chaves de sessão mock antigas
    if (SupabaseConfig.useSupabaseAuth) {
      await _p.remove('auth_user_id');
      await _p.remove('auth_user');
      await _p.remove('auth_email');
      await _p.remove('auth_cpf');
      await _p.remove('auth_company');
      await _p.remove('auth_role');
      // Limpar chaves de usuários mock
      final userKeys = _p.getKeys().where((k) => k.startsWith('user_'));
      for (final key in userKeys) {
        await _p.remove(key);
      }
    }

    // Forçar reload do cache interno
    await _p.reload();

  }

  /// Seed data para demonstração — cria 4 estados de teste.
  static Future<void> seedDemoData() async {


    // ─── Auto-registro e auto-login do demo user ───
    // (Só no modo mock — com Supabase, o user registra conta real)
    if (!SupabaseConfig.useSupabaseAuth) {
      await _p.setString('user_carlos_pass', '123456');
      await _p.setString('user_carlos_email', 'carlos@crptreinamentos.com.br');
      await _p.setString('user_carlos_cpf', '123.456.789-00');
      await _p.setString('user_carlos_company', 'CRP Treinamentos');
      // Persistir sessão ativa
      await _p.setString('auth_user_id', 'carlos');
      await _p.setString('auth_user', 'carlos');
      await _p.setString('auth_email', 'carlos@crptreinamentos.com.br');
      await _p.setString('auth_cpf', '123.456.789-00');
      await _p.setString('auth_company', 'CRP Treinamentos');
      await _p.setString('auth_role', 'student');

    } else {

    }

    final now = DateTime.now().toIso8601String();

    // ─── Estado 2: NR-05 (CIPA) → Em andamento (~40%, 12 de 30 aulas) ───
    final nr05Completed = List.generate(12, (i) {
      final m = (i ~/ 6) + 1;
      final l = (i % 6) + 1;
      return 'nr05_m${m}_l$l';
    });

    // ─── Estado 3: NR-35 → Pronto para quiz (~83%, 20 de 24 aulas) ───
    final nr35Completed = List.generate(20, (i) {
      final m = (i ~/ 6) + 1;
      final l = (i % 6) + 1;
      return 'nr35_m${m}_l$l';
    });

    // ─── Estado 4: NR-10 → Completo (100%, quiz aprovado) ───
    final nr10Completed = List.generate(30, (i) {
      final m = (i ~/ 6) + 1;
      final l = (i % 6) + 1;
      return 'nr10_m${m}_l$l';
    });

    final enrollments = [
      {
        'course_id': 'nr05',
        'status': 'em_andamento',
        'progress': 12 / 30, // 40%
        'completed_lessons': nr05Completed,
        'total_lessons': 30,
        'started_at': now,
        'completed_at': null,
        'last_accessed_at': now,
      },
      {
        'course_id': 'nr35',
        'status': 'em_andamento',
        'progress': 20 / 24, // 83%
        'completed_lessons': nr35Completed,
        'total_lessons': 24,
        'started_at': now,
        'completed_at': null,
        'last_accessed_at': now,
      },
      {
        'course_id': 'nr10',
        'status': 'concluido',
        'progress': 1.0, // 100%
        'completed_lessons': nr10Completed,
        'total_lessons': 30,
        'started_at': now,
        'completed_at': now,
        'last_accessed_at': now,
        'quiz_score': 85,
        'quiz_approved': true,
        'quiz_date': now,
      },
    ];

    await _p.setString(_keyEnrollments, json.encode(enrollments));

    // Certificados NÃO são pré-gerados no seed.
    // São emitidos permanentemente quando o usuário visualiza
    // o certificado pela primeira vez (com dados reais do auth).
    // Isso garante serial único, hash SHA-256 correto e nome real.

    // Pagamento para os 3 cursos matriculados
    final payments = [
      {
        'course_id': 'nr05',
        'course_title': 'CIPA — Comissão Interna de Prevenção de Acidentes',
        'amount': 'R\$ 189,90',
        'method': 'Pix',
        'date': _formatDate(DateTime.now()),
        'status': 'Aprovado',
      },
      {
        'course_id': 'nr35',
        'course_title': 'Trabalho em Altura',
        'amount': 'R\$ 249,90',
        'method': 'Cartão de Crédito',
        'date': _formatDate(DateTime.now()),
        'status': 'Aprovado',
      },
      {
        'course_id': 'nr10',
        'course_title': 'Segurança em Instalações e Serviços em Eletricidade',
        'amount': 'R\$ 299,90',
        'method': 'Boleto',
        'date': _formatDate(DateTime.now().subtract(const Duration(days: 30))),
        'status': 'Aprovado',
      },
    ];

    await _p.setString(_keyPayments, json.encode(payments));

    // Verificação
    await _p.reload();
    final check = _p.getString(_keyEnrollments);



  }
}
