import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PaymentFailedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const PaymentFailedScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.cancel,
                      size: 64, color: AppColors.error),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pagamento não aprovado',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Houve um problema ao processar seu pagamento.\nVerifique seus dados e tente novamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5),
                ),
                const SizedBox(height: 32),

                // Dicas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Possíveis motivos:',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[300] : Colors.grey[700])),
                      const SizedBox(height: 8),
                      _tipRow('Cartão sem limite suficiente', isDark),
                      _tipRow('Dados do cartão incorretos', isDark),
                      _tipRow('Cartão bloqueado pelo banco', isDark),
                      _tipRow('Problema de conexão', isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRetry();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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

  Widget _tipRow(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6,
              color: isDark ? Colors.grey[500] : Colors.grey[400]),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }
}
