import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import '../../services/local_storage_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Course course;
  final double totalPaid;
  final String paymentMethod;
  const PaymentSuccessScreen({
    super.key,
    required this.course,
    this.totalPaid = 0,
    this.paymentMethod = 'Pix',
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _registerPurchase();
  }

  Future<void> _registerPurchase() async {
    // BUG 3 — Criar enrollment
    await LocalStorageService.enrollCourse(
      courseId: widget.course.id,
      totalLessons: widget.course.lessonsCount,
    );
    // Registrar pagamento
    await LocalStorageService.addPayment(
      courseId: widget.course.id,
      courseTitle: '${widget.course.code} — ${widget.course.title}',
      amount: widget.totalPaid > 0 ? widget.totalPaid : widget.course.price,
      method: widget.paymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final course = widget.course;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Check animado
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.check_circle,
                      size: 64, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pagamento aprovado!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você já tem acesso ao curso',
                  style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Card do curso
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            course.code.replaceAll('NR-', ''),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${course.code} — ${course.title}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${course.hours}h · ${course.lessonsCount} aulas · Certificado incluso',
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Um recibo foi enviado para carlos@email.com',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botão
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navegar para o curso comprado
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                      context.push('/course/${course.id}');
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Começar agora',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  child: const Text('Voltar ao catálogo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
