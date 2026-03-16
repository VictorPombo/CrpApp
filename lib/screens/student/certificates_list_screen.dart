import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_storage_service.dart';

class CertificatesListScreen extends StatefulWidget {
  const CertificatesListScreen({super.key});

  @override
  State<CertificatesListScreen> createState() => _CertificatesListScreenState();
}

class _CertificatesListScreenState extends State<CertificatesListScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final certificates = LocalStorageService.getCertificates();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus certificados')),
      body: certificates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_outlined,
                      size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('Nenhum certificado disponível',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Conclua um curso e passe na avaliação para emitir.',
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[500] : Colors.grey[500])),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cert = certificates[index];
                final certCode = cert['cert_code'] as String? ?? '';
                final courseCode = cert['course_code'] as String? ?? '';
                final courseTitle = cert['course_title'] as String? ?? '';
                final courseId = cert['course_id'] as String? ?? '';
                final validUntil = cert['valid_until'] != null
                    ? DateTime.tryParse(cert['valid_until'] as String)
                    : null;
                final validLabel = validUntil != null
                    ? 'Válido até ${validUntil.day.toString().padLeft(2, '0')}/${validUntil.month.toString().padLeft(2, '0')}/${validUntil.year}'
                    : '';

                return GestureDetector(
                  onTap: () => context.push('/certificate/$courseId'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: AppColors.secondary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$courseCode — $courseTitle',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(certCode,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600])),
                              const SizedBox(height: 4),
                              if (validLabel.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.verified,
                                        size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(validLabel,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.success)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
