// Serviço central de elegibilidade para emissão de certificado.
//
// REGRA LEGAL: cursos de NR são treinamentos obrigatórios pelo MTE.
// O certificado só pode ser emitido com as 3 condições satisfeitas.
// Nunca mover esta lógica para dentro de widgets ou telas.

enum CertificateBlockReason {
  /// Menos de 75% das aulas assistidas
  insufficientProgress,

  /// Avaliação não realizada ou nota < 70%
  quizNotApproved,

  /// CPF ou empresa não preenchidos no perfil
  incompleteProfileData,
}

class CertificateEligibilityResult {
  final bool isEligible;
  final List<CertificateBlockReason> blockedBy;
  final double progressPercent;
  final int? quizScore;
  final bool hasRequiredProfileData;

  const CertificateEligibilityResult({
    required this.isEligible,
    required this.blockedBy,
    required this.progressPercent,
    this.quizScore,
    required this.hasRequiredProfileData,
  });

  /// Mensagem amigável para exibir ao aluno explicando o que falta
  String get blockMessage {
    if (isEligible) return '';
    final messages = <String>[];
    if (blockedBy.contains(CertificateBlockReason.insufficientProgress)) {
      final pct = (progressPercent * 100).toInt();
      messages.add('• Complete pelo menos 75% das aulas (atual: $pct%)');
    }
    if (blockedBy.contains(CertificateBlockReason.quizNotApproved)) {
      if (quizScore == null) {
        messages.add('• Realize a avaliação final (nota mínima: 70%)');
      } else {
        messages.add('• Nota da avaliação insuficiente ($quizScore% — mínimo 70%)');
      }
    }
    if (blockedBy.contains(CertificateBlockReason.incompleteProfileData)) {
      messages.add('• Preencha seu CPF e empresa no perfil');
    }
    return 'Para emitir o certificado:\n${messages.join('\n')}';
  }

  /// Progresso de elegibilidade (0-3): quantas condições foram atendidas
  int get conditionsMet => 3 - blockedBy.length;
}

class CertificateEligibilityService {
  /// Verifica se o aluno pode emitir o certificado para um curso específico.
  ///
  /// [progressPercent] — de 0.0 a 1.0 (ex: 0.85 = 85%)
  /// [quizScore] — de 0 a 100, ou null se avaliação não foi feita
  /// [userCpf] — CPF do aluno
  /// [userCompany] — Empresa do aluno
  static CertificateEligibilityResult check({
    required double progressPercent,
    required int? quizScore,
    required String? userCpf,
    required String? userCompany,
  }) {
    final blocked = <CertificateBlockReason>[];

    // Condição 1: presença mínima de 75%
    if (progressPercent < 0.75) {
      blocked.add(CertificateBlockReason.insufficientProgress);
    }

    // Condição 2: avaliação aprovada com 70%+
    if (quizScore == null || quizScore < 70) {
      blocked.add(CertificateBlockReason.quizNotApproved);
    }

    // Condição 3: dados obrigatórios do aluno preenchidos
    final hasCpf = userCpf != null && userCpf.trim().isNotEmpty;
    final hasCompany = userCompany != null && userCompany.trim().isNotEmpty;
    if (!hasCpf || !hasCompany) {
      blocked.add(CertificateBlockReason.incompleteProfileData);
    }

    return CertificateEligibilityResult(
      isEligible: blocked.isEmpty,
      blockedBy: blocked,
      progressPercent: progressPercent,
      quizScore: quizScore,
      hasRequiredProfileData: hasCpf && hasCompany,
    );
  }
}
