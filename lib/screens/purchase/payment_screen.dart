import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import 'processing_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Course course;
  final double total;
  const PaymentScreen({super.key, required this.course, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  void _processPayment() {
    final methods = ['Cartão de crédito', 'Pix', 'Boleto'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          course: widget.course,
          totalPaid: widget.total,
          paymentMethod: methods[_tabController.index],
        ),
      ),
    );
  }

  String get _priceFormatted =>
      'R\$ ${widget.total.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento')),
      body: Column(
        children: [
          // Valor
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Valor total',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(_priceFormatted,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.course.title,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                    textAlign: TextAlign.center),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  isDark ? Colors.grey[400] : Colors.grey[600],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              tabs: const [
                Tab(text: '💳 Cartão'),
                Tab(text: '📱 Pix'),
                Tab(text: '📄 Boleto'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardTab(isDark),
                _buildPixTab(isDark),
                _buildBoletoTab(isDark),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Finalizar pagamento · $_priceFormatted',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _inputField('Número do cartão', _cardNumberCtrl,
              Icons.credit_card, isDark,
              hint: '0000 0000 0000 0000',
              keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _inputField('Nome no cartão', _cardNameCtrl,
              Icons.person_outline, isDark,
              hint: 'CARLOS A SILVA'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _inputField('Validade', _cardExpCtrl,
                    Icons.calendar_month, isDark,
                    hint: 'MM/AA', keyboard: TextInputType.datetime),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField('CVV', _cardCvvCtrl,
                    Icons.lock_outline, isDark,
                    hint: '123', keyboard: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Pagamento seguro e criptografado',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPixTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // QR Code mock
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, size: 120, color: Colors.grey[800]),
                  const SizedBox(height: 8),
                  Text('QR Code Pix',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Código copia-e-cola
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? AppColors.darkDivider : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '00020126580014br.gov.bcb.pix0136crp-cursos-mock-key520400005303986...',
                    style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark ? Colors.grey[400] : Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Código copiado!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('• O pagamento via Pix é confirmado em segundos',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Text('• Validade: 30 minutos',
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBoletoTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? AppColors.darkDivider : Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48,
                    color: isDark ? AppColors.secondary : AppColors.primary),
                const SizedBox(height: 12),
                const Text('Boleto bancário',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'O boleto será gerado após confirmar o pagamento. '
                  'O prazo de compensação é de 1 a 3 dias úteis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: isDark ? Colors.grey[500] : Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'O acesso ao curso será liberado após a confirmação do pagamento',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl,
      IconData icon, bool isDark,
      {String? hint, TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkDivider : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
