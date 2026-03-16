import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/certificate_eligibility_service.dart';

/// Widget reutilizável que mostra o status de elegibilidade do certificado.
/// Usar em: CourseDetailScreen, MyCoursesScreen, CertificateScreen.
class CertificateEligibilityCard extends StatelessWidget {
  final CertificateEligibilityResult result;
  final VoidCallback? onStartQuiz;
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onViewCertificate;

  const CertificateEligibilityCard({
    super.key,
    required this.result,
    this.onStartQuiz,
    this.onCompleteProfile,
    this.onViewCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (result.isEligible) {
      return _buildEligibleCard(context, isDark);
    }
    return _buildBlockedCard(context, isDark);
  }

  /// Card verde — certificado disponível
  Widget _buildEligibleCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified,
                    color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Certificado disponível!',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success)),
                    SizedBox(height: 2),
                    Text('Todas as condições foram atendidas.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checklist verde
          _conditionRow('75% das aulas assistidas', true, isDark),
          _conditionRow('Avaliação aprovada (${result.quizScore}%)', true, isDark),
          _conditionRow('Dados pessoais completos', true, isDark),

          if (onViewCertificate != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewCertificate,
                icon: const Icon(Icons.workspace_premium, size: 20),
                label: const Text('Ver certificado',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Card âmbar — certificado bloqueado com ações
  Widget _buildBlockedCard(BuildContext context, bool isDark) {
    final progressOk = !result.blockedBy
        .contains(CertificateBlockReason.insufficientProgress);
    final quizOk =
        !result.blockedBy.contains(CertificateBlockReason.quizNotApproved);
    final profileOk = !result.blockedBy
        .contains(CertificateBlockReason.incompleteProfileData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline,
                    color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Certificado bloqueado',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary)),
                    const SizedBox(height: 2),
                    Text('${result.conditionsMet}/3 condições atendidas',
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de progresso das condições
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: result.conditionsMet / 3,
              backgroundColor:
                  isDark ? AppColors.darkDivider : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                result.conditionsMet >= 2
                    ? AppColors.secondary
                    : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),

          // Checklist
          _conditionRow(
            'Assistir 75% das aulas (${(result.progressPercent * 100).toInt()}%)',
            progressOk,
            isDark,
          ),
          _conditionRow(
            result.quizScore != null
                ? 'Avaliação (${result.quizScore}% — mínimo 70%)'
                : 'Realizar avaliação final',
            quizOk,
            isDark,
          ),
          _conditionRow('Preencher CPF e empresa', profileOk, isDark),

          const SizedBox(height: 16),

          // Botões de ação para condições bloqueadas
          if (!quizOk && onStartQuiz != null)
            _actionButton(
              label: 'Fazer avaliação',
              icon: Icons.quiz_outlined,
              onTap: onStartQuiz!,
            ),
          if (!profileOk && onCompleteProfile != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _actionButton(
                label: 'Preencher perfil',
                icon: Icons.person_outline,
                onTap: onCompleteProfile!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _conditionRow(String text, bool met, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: met ? AppColors.success : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: met
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: met ? FontWeight.w500 : FontWeight.normal,
                decoration: met ? TextDecoration.none : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
