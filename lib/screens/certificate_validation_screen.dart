import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/certificate_hash_service.dart';

/// Tela publica de validacao de certificados.
/// Acessivel via /validar/:code — qualquer pessoa pode verificar
/// se um certificado e autentico via QR code ou link.
class CertificateValidationScreen extends StatefulWidget {
  final String code;
  const CertificateValidationScreen({super.key, required this.code});

  @override
  State<CertificateValidationScreen> createState() =>
      _CertificateValidationScreenState();
}

class _CertificateValidationScreenState
    extends State<CertificateValidationScreen> {
  bool _loading = true;
  Map<String, dynamic>? _cert;
  bool _hashValid = false;

  @override
  void initState() {
    super.initState();
    _lookupCertificate();
  }

  void _lookupCertificate() {
    final allCerts = LocalStorageService.getCertificates();
    Map<String, dynamic>? found;
    for (final c in allCerts) {
      if (c['cert_code'] == widget.code) {
        found = c;
        break;
      }
    }

    bool hashOk = false;
    if (found != null && found['hash'] != null) {
      hashOk = CertificateHashService.verifyHash(
        serial: found['cert_code'] ?? '',
        cpf: found['student_cpf'] ?? '',
        courseId: found['course_id'] ?? '',
        quizScore: found['quiz_score'] ?? 0,
        issuedAt: found['issued_at'] ?? '',
        storedHash: found['hash'] ?? '',
      );
    }

    setState(() {
      _cert = found;
      _hashValid = hashOk;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Validar Certificado'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _loading
              ? const CircularProgressIndicator()
              : _cert != null
                  ? _buildValid()
                  : _buildInvalid(),
        ),
      ),
    );
  }

  Widget _buildValid() {
    final cert = _cert!;
    final issuedAt = DateTime.tryParse(cert['issued_at'] ?? '');
    final validUntil = DateTime.tryParse(cert['valid_until'] ?? '');
    final status = cert['status'] ?? 'valid';
    final isExpired = status == 'expired' ||
        (validUntil != null && DateTime.now().isAfter(validUntil));
    final isRevoked = status == 'revoked';

    final courseTitle = cert['course_title'] ?? 'Curso';
    final courseCode = cert['course_code'] ?? '';
    final quizScore = cert['quiz_score'];
    final courseHours = cert['course_hours'] ?? 0;
    final studentName = cert['student_name'] ?? '';
    final studentCpf = cert['student_cpf'] ?? '';
    final company = cert['company'] ?? '';
    final instructorName = cert['instructor_name'] ?? '';
    final instructorCrea = cert['instructor_crea'] ?? '';
    final hash = cert['hash'] ?? '';
    final serial = cert['cert_code'] ?? '';

    // Determinar status visual
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (isRevoked) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusTitle = 'Certificado Revogado';
      statusSubtitle = 'Este certificado foi revogado pela CRP Engenharia.';
    } else if (isExpired) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusTitle = 'Certificado Expirado';
      statusSubtitle = 'A validade deste certificado expirou. Renovacao necessaria.';
    } else {
      statusColor = const Color(0xFF22C55E);
      statusIcon = Icons.verified;
      statusTitle = 'Certificado Valido';
      statusSubtitle = 'Autenticado pela CRP Engenharia.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ═══════════ STATUS BADGE ═══════════
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.12),
            ),
            child: Icon(statusIcon, size: 44, color: statusColor),
          ),
          const SizedBox(height: 16),
          Text(
            statusTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // ═══════════ HASH VERIFICATION ═══════════
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _hashValid
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hashValid
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _hashValid ? Icons.shield : Icons.shield_outlined,
                  color: _hashValid
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hashValid
                            ? 'Assinatura Digital Verificada'
                            : 'Assinatura Digital Invalida',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _hashValid
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SHA-256: ${CertificateHashService.shortHash(hash)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════ CERTIFICATE CARD ═══════════
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header CRP
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CRP ENGENHARIA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Treinamentos em Seguranca do Trabalho',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.amber.shade700, thickness: 1.5),
                const SizedBox(height: 16),

                // --- Dados do Certificado ---
                _sectionTitle('DADOS DO CERTIFICADO'),
                const SizedBox(height: 8),
                _infoRow('Serial', serial),
                _infoRow('Status', isRevoked
                    ? 'REVOGADO'
                    : isExpired
                        ? 'EXPIRADO'
                        : 'VALIDO'),

                const SizedBox(height: 16),
                _sectionTitle('DADOS DO ALUNO'),
                const SizedBox(height: 8),
                _infoRow('Nome', studentName),
                if (studentCpf.isNotEmpty)
                  _infoRow('CPF', CertificateHashService.maskCpf(studentCpf)),
                if (company.isNotEmpty)
                  _infoRow('Empresa', company),

                const SizedBox(height: 16),
                _sectionTitle('DADOS DO CURSO'),
                const SizedBox(height: 8),
                _infoRow('Curso', '$courseCode - $courseTitle'),
                _infoRow('Carga Horaria', '${courseHours}h'),
                if (quizScore != null)
                  _infoRow('Nota da Avaliacao', '$quizScore%'),

                if (issuedAt != null || validUntil != null) ...[
                  const SizedBox(height: 16),
                  _sectionTitle('DATAS'),
                  const SizedBox(height: 8),
                  if (issuedAt != null)
                    _infoRow('Emissao', _formatDate(issuedAt)),
                  if (validUntil != null)
                    _infoRow('Validade', _formatDate(validUntil)),
                ],

                if (instructorName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionTitle('RESPONSAVEL TECNICO'),
                  const SizedBox(height: 8),
                  _infoRow('Instrutor', instructorName),
                  if (instructorCrea.isNotEmpty)
                    _infoRow('CREA', instructorCrea),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ═══════════ FOOTER INFO ═══════════
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este certificado foi verificado digitalmente pela CRP Engenharia '
                    'atraves de assinatura criptografica SHA-256. '
                    'Em caso de duvidas, entre em contato: contato@crpengenharia.com.br',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 44,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Certificado Nao Encontrado',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O codigo "${widget.code}" nao corresponde a nenhum '
            'certificado emitido pela CRP Engenharia.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Possibilidades
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Possiveis causas:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _bulletPoint('Codigo digitado incorretamente'),
                _bulletPoint('Certificado emitido em outro dispositivo'),
                _bulletPoint('Certificado ainda nao foi processado'),
                _bulletPoint('Documento pode ser fraudulento'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.email_outlined, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Para verificacao manual, entre em contato:\n'
                    'contato@crpengenharia.com.br',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('- ', style: TextStyle(color: Colors.amber.shade800, fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
