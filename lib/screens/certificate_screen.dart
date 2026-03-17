import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/theme/app_theme.dart';
import '../models/certificate_model.dart';
import '../providers/auth_service.dart';
import '../services/certificate_eligibility_service.dart';
import '../services/certificate_hash_service.dart';
import '../services/course_service_mock.dart';
import '../services/local_storage_service.dart';
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
  int? _resolvedQuizScore;
  double _resolvedProgress = 1.0;

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

    // Resolver quizScore e progressPercent do enrollment se não vieram via extra
    int? quizScore = widget.quizScore;
    double progress = widget.progressPercent;
    final enrollment = LocalStorageService.getEnrollment(widget.courseId);
    if (enrollment != null) {
      quizScore ??= enrollment['quiz_score'] as int?;
      if (progress == 1.0 && enrollment['progress'] != null) {
        progress = (enrollment['progress'] as num).toDouble();
      }
    }

    setState(() {
      _courseTitle = course.title;
      _courseCode = course.code;
      _courseHours = course.hours;
      _instructorName = course.instructorName;
      _instructorCrea = course.instructorCrea;
      _resolvedQuizScore = quizScore;
      _resolvedProgress = progress;
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
      progressPercent: _resolvedProgress,
      quizScore: _resolvedQuizScore,
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
    // Usar cert_code armazenado se existir (consistência com validação)
    final storedCert = LocalStorageService.getCertificate(widget.courseId);
    final certCode = storedCert?['cert_code'] as String? ??
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
                'Valide em: localhost:8080/#/validar/$certCode',
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
                      'http://localhost:8080/#/validar/$certCode',
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
                                ? Colors.grey[400]
                                : Colors.grey[500]),
                      ),
                    ],
                    // SHA-256 hash badge
                    if (storedCert != null && storedCert['hash'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFF86EFAC), width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield,
                                size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              'SHA-256: ${CertificateHashService.shortHash(storedCert['hash'])}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'monospace',
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
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
                onTap: () => _downloadPdf(context, certificate, cpf, company),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.share,
                label: 'Compartilhar',
                onTap: () async {
                  try {
                    final bytes = await _buildPdfBytes(certificate, cpf, company);
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: 'Certificado_${certificate.certificateCode}.pdf',
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao compartilhar: $e')),
                      );
                    }
                  }
                },
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

  // ═══════════════════════════════════════
  // PDF — Geração profissional
  // ═══════════════════════════════════════

  /// Download/compartilhamento do PDF usando package printing.
  /// Funciona cross-platform: web abre diálogo de impressão/salvar,
  /// mobile abre share sheet nativo.
  void _downloadPdf(BuildContext context, Certificate cert, String? cpf, String? company) async {
    debugPrint('[PDF] _downloadPdf chamado!');
    try {
      debugPrint('[PDF] Gerando bytes...');
      final bytes = await _buildPdfBytes(cert, cpf, company);
      debugPrint('[PDF] Bytes gerados: ${bytes.length}');

      final fileName = 'Certificado_${cert.certificateCode}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );

      debugPrint('[PDF] PDF compartilhado: $fileName');
    } catch (e, stack) {
      debugPrint('[PDF] ERRO: $e');
      debugPrint('[PDF] Stack: $stack');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }
  }

  Future<Uint8List> _buildPdfBytes(Certificate cert, String? cpf, String? company) async {
    final pdf = pw.Document();
    final validationUrl = 'http://localhost:8080/#/validar/${cert.certificateCode}';

    // Sanitizar texto para fonte PDF padrão (sem suporte Unicode estendido)
    String sanitize(String text) {
      return text
        .replaceAll('\u2014', '-') // em dash
        .replaceAll('\u2013', '-') // en dash
        .replaceAll('\u2022', '|') // bullet
        .replaceAll('\u00e9', 'e') // é
        .replaceAll('\u00ea', 'e') // ê
        .replaceAll('\u00e1', 'a') // á
        .replaceAll('\u00e3', 'a') // ã
        .replaceAll('\u00f3', 'o') // ó
        .replaceAll('\u00ed', 'i') // í
        .replaceAll('\u00fa', 'u') // ú
        .replaceAll('\u00e7', 'c') // ç
        .replaceAll('\u00c3', 'A') // Ã
        .replaceAll('\u00c9', 'E') // É
        .replaceAll('\u00cd', 'I') // Í
        .replaceAll('\u00d3', 'O') // Ó
        .replaceAll('\u00da', 'U') // Ú
        .replaceAll('\u00c7', 'C') // Ç
        .replaceAll('\u00f4', 'o') // ô
        .replaceAll('\u00e0', 'a') // à
        .replaceAll('\u00e2', 'a') // â
        .replaceAll('\u00f5', 'o') // õ
        .replaceAll('\u00fc', 'u'); // ü
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber800, width: 3),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Header
                pw.Text('CRP ENGENHARIA',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold,
                        letterSpacing: 4, color: PdfColors.grey700)),
                pw.SizedBox(height: 2),
                pw.Text('Treinamentos em Seguranca do Trabalho',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.SizedBox(height: 20),

                // Divider
                pw.Container(height: 1, color: PdfColors.amber800),
                pw.SizedBox(height: 20),

                // CERTIFICADO
                pw.Text('CERTIFICADO DE CONCLUSAO',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800)),
                pw.SizedBox(height: 16),

                // Certificamos que
                pw.Text('Certificamos que',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 6),

                // Nome do aluno
                pw.Text(cert.studentName,
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900)),
                pw.SizedBox(height: 4),

                // CPF + Empresa
                if (cpf != null || company != null)
                  pw.Text(
                    [if (cpf != null) 'CPF: $cpf', if (company != null) company].join(' | '),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                pw.SizedBox(height: 10),

                // concluiu com êxito
                pw.Text('concluiu com exito o curso',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                pw.SizedBox(height: 6),

                // Curso
                pw.Text(sanitize(cert.courseTitle),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800)),
                pw.SizedBox(height: 8),

                // Nota
                if (_resolvedQuizScore != null)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(16),
                    ),
                    child: pw.Text('Aprovado com $_resolvedQuizScore%',
                        style: pw.TextStyle(
                            fontSize: 11, fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800)),
                  ),
                pw.SizedBox(height: 16),

                // Stats row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    _pdfStat('${cert.courseHours}h', 'Carga horaria'),
                    _pdfStat(cert.issuedLabel, 'Conclusao'),
                    _pdfStat(cert.validityLabel, 'Validade'),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Divider
                pw.Container(height: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 12),

                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Instrutor: ${sanitize(cert.instructorName)}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.Text(cert.instructorCrea,
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Codigo: ${cert.certificateCode}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700)),
                        pw.Text('Valide em: $validationUrl',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _pdfStat(String value, String label) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
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
            Icon(icon, size: 24,
                color: isDark ? AppColors.secondary : AppColors.primary),
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
