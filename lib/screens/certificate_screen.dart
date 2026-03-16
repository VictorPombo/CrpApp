import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/theme/app_theme.dart';
import '../models/certificate_model.dart';
import '../providers/auth_service.dart';
import '../services/certificate_eligibility_service.dart';
import '../services/course_service_mock.dart';
import '../widgets/certificate_eligibility_card.dart';

/// Tela de certificado com validação de elegibilidade.
/// O certificado só é exibido quando as 3 condições legais são atendidas.
class CertificateScreen extends StatefulWidget {
  final String courseId;
  final int? quizScore;
  final double progressPercent;

  const CertificateScreen({
    super.key,
    required this.courseId,
    this.quizScore,
    this.progressPercent = 1.0,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _loading = true;
  String _courseTitle = '';
  String _courseCode = '';
  int _courseHours = 0;
  String _instructorName = '';
  String _instructorCrea = '';

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final courses = await CourseServiceMock().fetchCourses();
    final course = courses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => courses.first,
    );
    setState(() {
      _courseTitle = course.title;
      _courseCode = course.code;
      _courseHours = course.hours;
      _instructorName = course.instructorName;
      _instructorCrea = course.instructorCrea;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Dados do usuário logado
    final auth = AuthService.currentUser;
    final studentName = auth.username ?? 'Aluno';
    final studentCpf = auth.cpf;
    final studentCompany = auth.company;
    final studentEmail = auth.email;

    // Verificar elegibilidade
    final eligibility = CertificateEligibilityService.check(
      progressPercent: widget.progressPercent,
      quizScore: widget.quizScore,
      userCpf: studentCpf,
      userCompany: studentCompany,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Certificado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: eligibility.isEligible
            ? _buildCertificate(
                context, isDark, studentName, studentCpf, studentCompany,
                studentEmail, eligibility)
            : _buildBlocked(context, isDark, eligibility),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Certificado bloqueado
  // ═══════════════════════════════════════
  Widget _buildBlocked(BuildContext context, bool isDark,
      CertificateEligibilityResult eligibility) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.workspace_premium,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400]),
        const SizedBox(height: 16),
        Text('$_courseCode — $_courseTitle',
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        CertificateEligibilityCard(
          result: eligibility,
          onStartQuiz: () {
            Navigator.pop(context);
          },
          onCompleteProfile: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // Certificado completo
  // ═══════════════════════════════════════
  Widget _buildCertificate(
    BuildContext context,
    bool isDark,
    String studentName,
    String? cpf,
    String? company,
    String? email,
    CertificateEligibilityResult eligibility,
  ) {
    final now = DateTime.now();
    final validUntil = DateTime(now.year + 2, now.month, now.day);
    final certCode =
        'CRP-$_courseCode-${now.year}-${now.millisecond.toString().padLeft(4, '0')}';

    final certificate = Certificate(
      id: 'cert-${widget.courseId}',
      userId: AuthService.currentUser.userId ?? 'user-1',
      courseId: widget.courseId,
      enrollmentId: 'enroll-${widget.courseId}',
      certificateCode: certCode,
      issuedAt: now,
      validUntil: validUntil,
      studentName: studentName,
      courseTitle: '$_courseCode — $_courseTitle',
      courseCode: _courseCode,
      courseHours: _courseHours,
      instructorName: _instructorName,
      instructorCrea: _instructorCrea,
    );

    return Column(
      children: [
        // ===== CERTIFICADO CARD =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header CRP
              Text(
                'CRP ENGENHARIA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'CNPJ: 12.345.678/0001-00',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),

              // Certificamos que
              Text(
                'Certificamos que',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 6),

              // Nome do aluno
              Text(
                certificate.studentName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // CPF e Empresa
              if (cpf != null || company != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    if (cpf != null) 'CPF: $cpf',
                    if (company != null) company,
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],

              const SizedBox(height: 8),

              // concluiu com êxito
              Text(
                'concluiu com êxito o curso',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),

              // Título do curso
              Text(
                certificate.courseTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // Nota da avaliação
              if (eligibility.quizScore != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Aprovado com ${eligibility.quizScore}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CertStat(
                      value: '${certificate.courseHours}h',
                      label: 'Carga horária'),
                  _CertStat(
                      value: certificate.issuedLabel, label: 'Conclusão'),
                  _CertStat(
                      value: certificate.validityLabel, label: 'Validade'),
                ],
              ),
              const SizedBox(height: 16),

              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),

              // Instrutor
              Text(
                'Instrutor: ${certificate.instructorName} · ${certificate.instructorCrea}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              // URL de validação
              const SizedBox(height: 4),
              Text(
                'Valide em: crpengenharia.com.br/validar/$certCode',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ===== QR CODE SECTION =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data:
                      'https://crpengenharia.com.br/validar/$certCode',
                  size: 80,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.certificateCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Validade: ${certificate.validityLabel}',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          certificate.isValid
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color: certificate.isValid
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          certificate.isValid
                              ? 'Certificado válido'
                              : 'Certificado expirado',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: certificate.isValid
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Enviado para: $email',
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ===== ACTION BUTTONS =====
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.download,
                label: 'Baixar PDF',
                onTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download em breve!')),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.share,
                label: 'Compartilhar',
                onTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Compartilhamento em breve!')),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.launch,
                label: 'LinkedIn',
                onTap: () =>
                    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Integração LinkedIn em breve!')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CertStat extends StatelessWidget {
  final String value;
  final String label;

  const _CertStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkDivider : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }
}
