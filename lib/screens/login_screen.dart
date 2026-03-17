import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_service.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok =
        await AuthService.login(_userCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      final redirect =
          GoRouterState.of(context).uri.queryParameters['redirect'];
      if (redirect != null) {
        context.go(Uri.decodeComponent(redirect));
      } else {
        context.go('/home');
      }
    } else {
      setState(() =>
          _error = 'Usuário ou senha incorretos. Verifique os dados.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Cor para links/destaques — visível em ambos os modos
    final linkColor = isDark ? AppColors.secondaryLight : AppColors.primary;
    // Cor para subtextos
    final subtextColor = isDark ? Colors.grey[300] : Colors.grey[600];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Logo — usa versão dark no modo escuro
                  Center(
                    child: Image.asset(
                      isDark
                          ? 'assets/images/crp_logo_dark.png'
                          : 'assets/images/crp_logo.png',
                      height: 80,
                      errorBuilder: (_, __, ___) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('CRP',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text('Bem-vindo de volta!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Entre na sua conta para continuar',
                        style: TextStyle(fontSize: 14, color: subtextColor)),
                  ),
                  const SizedBox(height: 36),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _userCtrl,
                          label: 'Usuário ou Email',
                          type: AuthFieldType.text,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Informe seu usuário'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _passCtrl,
                          label: 'Senha',
                          type: AuthFieldType.password,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Informe sua senha'
                              : null,
                        ),
                        const SizedBox(height: 8),

                        // Esqueci senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/auth/forgot-password'),
                            child: Text('Esqueci minha senha',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: linkColor)),
                          ),
                        ),

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
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 18, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        AuthButton(
                          label: 'Entrar',
                          isLoading: _loading,
                          onPressed: _submit,
                          icon: Icons.login,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Registrar
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Não tem conta?',
                            style: TextStyle(
                                fontSize: 14, color: subtextColor)),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text('Criar conta',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: linkColor)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
