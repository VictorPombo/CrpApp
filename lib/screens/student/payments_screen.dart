import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/local_storage_service.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'pago':
        return AppColors.success;
      case 'pendente':
        return AppColors.secondary;
      case 'reembolsado':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pago':
        return 'Pago';
      case 'pendente':
        return 'Pendente';
      case 'reembolsado':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  IconData _methodIcon(String method) {
    if (method.contains('Pix')) return Icons.qr_code;
    if (method.contains('Cartão')) return Icons.credit_card;
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payments = LocalStorageService.getPayments();

    // Calcular totais
    final totalPago = payments.where((p) => p['status'] == 'pago').length;
    final totalAmount = payments.fold<double>(0.0, (sum, p) {
      final raw = (p['amount'] as String? ?? 'R\$ 0,00')
          .replaceAll('R\$ ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return sum + (double.tryParse(raw) ?? 0.0);
    });
    final totalFormatted =
        'R\$ ${totalAmount.toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Pagamentos')),
      body: payments.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Nenhum pagamento registrado',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Seus pagamentos aparecerão aqui após a compra',
                      style: TextStyle(
                          fontSize: 13,
                          color:
                              isDark ? Colors.grey[600] : Colors.grey[500])),
                ],
              ),
            )
          : Column(
              children: [
                // Resumo financeiro
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total investido',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(totalFormatted,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${payments.length} transações',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$totalPago pagas',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de pagamentos
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = payments[index];
                      final color = _statusColor(p['status'] ?? '');

                      return GestureDetector(
                        onTap: () => _showReceipt(context, p, isDark),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.darkDivider
                                    : Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                    _methodIcon(p['method'] ?? ''),
                                    size: 20,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p['course'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${p['date']} · ${p['method']}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.grey[500]
                                                : Colors.grey[600])),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(p['amount'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                        _statusLabel(p['status'] ?? ''),
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showReceipt(
      BuildContext context, Map<String, dynamic> p, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recibo de pagamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _receiptRow('Curso', p['course'] ?? '', isDark),
            _receiptRow('Data', p['date'] ?? '', isDark),
            _receiptRow('Valor', p['amount'] ?? '', isDark),
            _receiptRow('Método', p['method'] ?? '', isDark),
            _receiptRow('Status', _statusLabel(p['status'] ?? ''), isDark),
            _receiptRow('ID da transação', p['txId'] ?? '', isDark),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Baixar recibo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[500] : Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
