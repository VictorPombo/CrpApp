import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Serviço de hash criptográfico para autenticação de certificados.
///
/// Em produção (Supabase), a SECRET_KEY será uma variável de ambiente
/// do servidor, impossibilitando forjamento. Localmente, usamos uma
/// chave mock para manter a mesma arquitetura.
class CertificateHashService {
  // MOCK: Em produção, essa chave vem do backend (Supabase env var)
  static const _secretKey = 'CRP-ENG-2026-SECRET-K3Y-PR0D';

  /// Normaliza uma data ISO 8601 para formato consistente (sem microssegundos
  /// e sem timezone). Garante que o hash gerado no Dart e o hash verificado
  /// com dados do Supabase (TIMESTAMPTZ) produzam o mesmo resultado.
  static String _normalizeDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    // Truncar para segundos e remover timezone
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)
        .toIso8601String();
  }

  /// Gera hash SHA-256 para um certificado.
  ///
  /// O hash é baseado em dados imutáveis do certificado + chave secreta,
  /// tornando impossível forjar sem acesso ao servidor.
  static String generateHash({
    required String serial,
    required String cpf,
    required String courseId,
    required int quizScore,
    required String issuedAt,
  }) {
    final normalizedDate = _normalizeDate(issuedAt);
    final payload = '$serial|$cpf|$courseId|$quizScore|$normalizedDate|$_secretKey';
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifica se o hash de um certificado é válido.
  ///
  /// Recalcula o hash com os dados do certificado e compara
  /// com o hash armazenado.
  static bool verifyHash({
    required String serial,
    required String cpf,
    required String courseId,
    required int quizScore,
    required String issuedAt,
    required String storedHash,
  }) {
    final computedHash = generateHash(
      serial: serial,
      cpf: cpf,
      courseId: courseId,
      quizScore: quizScore,
      issuedAt: issuedAt, // generateHash já normaliza internamente
    );
    return computedHash == storedHash;
  }

  /// Exibe hash truncado para UI (ex: SHA-256: 9a8c1f...)
  static String shortHash(String hash) {
    if (hash.length <= 12) return hash;
    return '${hash.substring(0, 12)}...';
  }

  /// Gera número serial único para certificado.
  ///
  /// Formato: CRP-{ANO}-{CÓDIGO_CURSO}-{SEQUENCIAL}
  /// Exemplo: CRP-2026-NR10-0001
  static String generateSerial({
    required String courseCode,
    required int sequentialNumber,
    int? year,
  }) {
    final y = year ?? DateTime.now().year;
    final code = courseCode.replaceAll('-', '').toUpperCase();
    final seq = sequentialNumber.toString().padLeft(4, '0');
    return 'CRP-$y-$code-$seq';
  }

  /// Gera serial ÚNICO por usuário — como um RG do certificado.
  ///
  /// Formato: CRP-{ANO}-{CÓDIGO_CURSO}-{HASH_CURTO}
  /// O hash é derivado do userId + courseId, garantindo que cada
  /// usuário tenha um serial irrepetível para cada curso.
  /// Exemplo: CRP-2026-NR10-A3F2B1
  static String generateUniqueSerial({
    required String courseCode,
    required String userId,
    required String courseId,
    int? year,
  }) {
    final y = year ?? DateTime.now().year;
    final code = courseCode.replaceAll('-', '').toUpperCase();
    // Gerar hash curto do userId + courseId (6 chars hex uppercase)
    final payload = '$userId|$courseId|$y|$_secretKey';
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);
    final shortId = digest.toString().substring(0, 6).toUpperCase();
    return 'CRP-$y-$code-$shortId';
  }

  /// Mascara CPF para exibição pública (LGPD).
  ///
  /// Entrada: "123.456.789-00"
  /// Saída:   "***.456.789-**"
  static String maskCpf(String cpf) {
    if (cpf.length < 14) return '***.***.***-**';
    return '***${cpf.substring(3, 11)}**';
  }
}
