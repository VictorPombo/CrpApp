import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'certificate_hash_service.dart';

/// Serviço de certificados via Supabase.
///
/// Certificados são IMUTÁVEIS após emissão — como documentos oficiais.
/// O serial é único por usuário (derivado do userId via SHA-256).
/// Qualquer pessoa pode validar um certificado pelo serial (sem login).
class SupabaseCertificateService {
  static final _client = Supabase.instance.client;

  /// Emite um certificado permanente para o usuário logado.
  /// Retorna o mapa do certificado emitido, ou null se falhar.
  /// Se o certificado já existe, retorna o existente (sem duplicar).
  static Future<Map<String, dynamic>?> issueCertificate({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required int courseHours,
    required int quizScore,
    required String studentName,
    String? studentCpf,
    String? company,
    String? instructorName,
    String? instructorCrea,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {

        return null;
      }

      // Verificar se já existe (constraint unique_user_course)
      final existing = await _client
          .from('certificates')
          .select()
          .eq('user_id', user.id)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existing != null) {

        return existing;
      }

      // Gerar serial único
      final serial = CertificateHashService.generateUniqueSerial(
        courseCode: courseCode,
        userId: user.id,
        courseId: courseId,
      );

      final now = DateTime.now();
      final issuedAt = now.toIso8601String();
      final validUntil = DateTime(now.year + 2, now.month, now.day).toIso8601String();

      // Gerar hash SHA-256
      final hash = CertificateHashService.generateHash(
        serial: serial,
        cpf: studentCpf ?? '',
        courseId: courseId,
        quizScore: quizScore,
        issuedAt: issuedAt,
      );

      final certData = {
        'user_id': user.id,
        'course_id': courseId,
        'course_code': courseCode,
        'course_title': courseTitle,
        'course_hours': courseHours,
        'student_name': studentName,
        'student_cpf': studentCpf ?? '',
        'company': company ?? '',
        'cert_code': serial,
        'hash': hash,
        'quiz_score': quizScore,
        'instructor_name': instructorName ?? 'Eng. Carlos Roberto Palácio',
        'instructor_crea': instructorCrea ?? 'CREA-SP · RNP 2614455296',
        'issued_at': issuedAt,
        'valid_until': validUntil,
        'status': 'valid',
      };

      final response = await _client
          .from('certificates')
          .insert(certData)
          .select()
          .single();


      return response;
    } catch (e) {

      return null;
    }
  }

  /// Busca certificados do usuário logado.
  static Future<List<Map<String, dynamic>>> getUserCertificates() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('certificates')
          .select()
          .eq('user_id', user.id)
          .order('issued_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {

      return [];
    }
  }

  /// Busca certificado do usuário para um curso específico.
  static Future<Map<String, dynamic>?> getCertificate(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('certificates')
          .select()
          .eq('user_id', user.id)
          .eq('course_id', courseId)
          .maybeSingle();

      return response;
    } catch (e) {

      return null;
    }
  }

  /// Valida um certificado pelo serial (PÚBLICO — sem login).
  /// Usado pela tela de validação e por empresas externas.
  static Future<Map<String, dynamic>?> validateBySerial(String certCode) async {
    try {
      final response = await _client
          .from('certificates')
          .select()
          .eq('cert_code', certCode)
          .maybeSingle();

      if (response != null) {

      } else {

      }

      return response;
    } catch (e) {

      return null;
    }
  }
}
