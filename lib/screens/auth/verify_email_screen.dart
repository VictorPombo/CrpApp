import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/auth_button.dart';

/// Tela de verificação de email — input OTP de 6 dígitos.
class VerifyEmailScreen extends StatefulWidget {
  final String? email;

  const VerifyEmailScreen({super.key, this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;
  int _cooldown = 0;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Digite o código completo de 6 dígitos');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Mock: aceita qualquer código de 6 dígitos
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _loading = false);

    // Sucesso — ir para home
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verificado com sucesso! ✅'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/home');
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;

    setState(() => _cooldown = 60);

    // Countdown
    for (int i = 59; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _cooldown = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = widget.email ?? 'seu email';
    final subtextColor = isDark ? Colors.grey[300] : Colors.grey[600];
    final linkColor = isDark ? AppColors.secondaryLight : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Ícone — usa secondary (laranja) visível em dark mode
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined,
                      size: 48, color: AppColors.secondary),
                ),
                const SizedBox(height: 24),
                const Text('Verifique seu email',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Enviamos um código de 6 dígitos para\n$email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: subtextColor),
                ),
                const SizedBox(height: 32),

                // OTP input
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 48,
                      height: 56,
                      margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        cursorColor: isDark ? AppColors.secondaryLight : AppColors.primary,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: isDark ? AppColors.secondaryLight : AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? AppColors.darkCard : Colors.grey[50],
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            _focusNodes[i + 1].requestFocus();
                          }
                          if (v.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                          }
                          // Auto-submit quando preencher tudo
                          if (_code.length == 6) {
                            _verify();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Erro
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.error)),
                  ),

                const SizedBox(height: 8),
                AuthButton(
                  label: 'Verificar',
                  isLoading: _loading,
                  onPressed: _verify,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),

                // Reenviar
                TextButton(
                  onPressed: _cooldown > 0 ? null : _resend,
                  child: Text(
                    _cooldown > 0
                        ? 'Reenviar código em ${_cooldown}s'
                        : 'Não recebeu? Reenviar código',
                    style: TextStyle(
                      fontSize: 13,
                      color: _cooldown > 0 ? subtextColor : linkColor,
                    ),
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
