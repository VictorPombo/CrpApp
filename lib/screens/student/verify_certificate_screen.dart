import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Tela para verificar autenticidade de um certificado pelo serial.
/// Qualquer pessoa pode usar — não exige login.
class VerifyCertificateScreen extends StatefulWidget {
  const VerifyCertificateScreen({super.key});

  @override
  State<VerifyCertificateScreen> createState() =>
      _VerifyCertificateScreenState();
}

class _VerifyCertificateScreenState extends State<VerifyCertificateScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    setState(() => _hasError = false);
    // Navegar para a tela de validação pública
    context.push('/validar/$code');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Verificar certificado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Ícone
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user,
                      size: 40, color: AppColors.secondary),
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  'Verificar autenticidade',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),

                // Descrição
                Text(
                  'Digite o código serial do certificado para verificar '
                  'se ele é autêntico e foi emitido pela CRP Engenharia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Campo de serial
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Código do certificado',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                    hintText: 'CRP-2026-NR10-A3F2B1',
                    hintStyle: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    prefixIcon: Icon(Icons.qr_code_scanner,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 20,
                                color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _hasError = false);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _hasError
                            ? AppColors.error
                            : (isDark
                                ? Colors.grey[600]!
                                : Colors.grey[300]!),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 2,
                      ),
                    ),
                    errorText:
                        _hasError ? 'Digite o código do certificado' : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF2A2A3E)
                        : Colors.grey[50],
                  ),
                  onChanged: (_) {
                    if (_hasError) setState(() => _hasError = false);
                  },
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 20),

                // Botão verificar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.search, size: 22),
                    label: const Text(
                      'Verificar certificado',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Dica
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A2332)
                        : Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.blue.withValues(alpha: 0.3)
                          : Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 18,
                              color: isDark
                                  ? Colors.blue[300]
                                  : Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Onde encontrar o código?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.blue[300]
                                  : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'O código serial está no certificado digital, '
                        'abaixo do nome do aluno.\n'
                        'Formato: CRP-AAAA-CURSO-CÓDIGO',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
