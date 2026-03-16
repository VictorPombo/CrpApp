import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import 'payment_success_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final Course course;
  final double totalPaid;
  final String paymentMethod;
  const ProcessingScreen({
    super.key,
    required this.course,
    this.totalPaid = 0,
    this.paymentMethod = 'Pix',
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _statusText = 'Processando pagamento...';
  int _step = 0;

  final _steps = [
    'Processando pagamento...',
    'Verificando dados...',
    'Confirmando transação...',
    'Liberando acesso ao curso...',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _simulateProcessing();
  }

  Future<void> _simulateProcessing() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _step = i;
        _statusText = _steps[i];
      });
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          course: widget.course,
          totalPaid: widget.totalPaid,
          paymentMethod: widget.paymentMethod,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animação do loading
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animController.value * 6.28,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkBg : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              _statusText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Não feche esta tela',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            // Progress steps
            ...List.generate(4, (i) {
              final done = i <= _step;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: done ? AppColors.success : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _steps[i],
                      style: TextStyle(
                        fontSize: 13,
                        color: done
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey,
                        fontWeight: done ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
