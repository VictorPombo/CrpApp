import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';

/// Tela de esqueci minha senha — envia email de redefinição.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark ? AppColors.secondaryLight : AppColors.primary;
    final subtextColor = isDark ? Colors.grey[300] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci minha senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _sent
                ? _buildSuccess(subtextColor, linkColor)
                : _buildForm(subtextColor, linkColor),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Color? subtextColor, Color linkColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset,
              size: 48, color: AppColors.secondary),
        ),
        const SizedBox(height: 24),
        const Text('Redefinir senha',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Informe seu email e enviaremos um link\npara redefinir sua senha.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _emailCtrl,
                label: 'Email',
                type: AuthFieldType.email,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              AuthButton(
                label: 'Enviar link',
                isLoading: _loading,
                onPressed: _submit,
                icon: Icons.send,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text('Voltar para o login',
              style: TextStyle(color: linkColor)),
        ),
      ],
    );
  }

  Widget _buildSuccess(Color? subtextColor, Color linkColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.check_circle, size: 48, color: Colors.green),
        ),
        const SizedBox(height: 24),
        const Text('Email enviado!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Enviamos um link de redefinição para\n${_emailCtrl.text}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 12),
        Text(
          'Verifique também a pasta de spam.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: subtextColor),
        ),
        const SizedBox(height: 32),
        AuthButton(
          label: 'Voltar para o login',
          onPressed: () => context.go('/login'),
          icon: Icons.login,
        ),
      ],
    );
  }
}
