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
    final payload = '$serial|$cpf|$courseId|$quizScore|$issuedAt|$_secretKey';
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
      issuedAt: issuedAt,
    );
    return computedHash == storedHash;
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

  /// Mascara CPF para exibição pública (LGPD).
  ///
  /// Entrada: "123.456.789-00"
  /// Saída:   "***.456.789-**"
  static String maskCpf(String cpf) {
    if (cpf.length < 14) return '***.***.***-**';
    return '***${cpf.substring(3, 11)}**';
  }

  /// Retorna hash parcial para exibição (primeiros 16 chars).
  static String shortHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 16)}...';
  }
}
