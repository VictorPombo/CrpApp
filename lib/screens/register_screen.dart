import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_service.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/password_strength.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _agreedTerms = false;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cpfCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedTerms) {
      setState(() => _error = 'Você precisa aceitar os Termos de Uso.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await AuthService.register(
      username: _nameCtrl.text.trim(),
      password: _passCtrl.text,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      cpf: _cpfCtrl.text.trim().isNotEmpty ? _cpfCtrl.text.trim() : null,
      company: _companyCtrl.text.trim().isNotEmpty ? _companyCtrl.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/home');
    } else {
      setState(() => _error = 'Este usuário já existe. Tente outro nome.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  const SizedBox(height: 8),
                  // Voltar
                  IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 8),
                  // Logo
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/crp_logo.png',
                        height: 64,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text('CRP',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text('Criar conta',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Cadastre-se para acessar os cursos',
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600])),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _nameCtrl,
                          label: 'Nome completo',
                          type: AuthFieldType.name,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe seu nome';
                            }
                            if (v.length < 3) return 'Mínimo 3 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _emailCtrl,
                          label: 'E-mail',
                          type: AuthFieldType.email,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _cpfCtrl,
                          label: 'CPF',
                          hint: '000.000.000-00',
                          type: AuthFieldType.cpf,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _phoneCtrl,
                          label: 'Telefone',
                          hint: '(00) 00000-0000',
                          type: AuthFieldType.phone,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _companyCtrl,
                          label: 'Empresa (opcional)',
                          type: AuthFieldType.text,
                          validator: (_) => null, // Opcional
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _passCtrl,
                          label: 'Senha',
                          type: AuthFieldType.password,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe uma senha';
                            }
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        PasswordStrengthIndicator(password: _passCtrl.text),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _confirmPassCtrl,
                          label: 'Confirmar senha',
                          type: AuthFieldType.password,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v != _passCtrl.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Termos de uso
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreedTerms,
                              onChanged: (v) =>
                                  setState(() => _agreedTerms = v ?? false),
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _agreedTerms = !_agreedTerms),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Li e aceito os ',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600]),
                                    children: [
                                      TextSpan(
                                        text: 'Termos de Uso',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const TextSpan(text: ' e '),
                                      TextSpan(
                                        text: 'Política de Privacidade',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

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
                        AuthButton(
                          label: 'Criar conta',
                          isLoading: _loading,
                          onPressed: _submit,
                          icon: Icons.person_add,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Já tem conta?',
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Entrar',
                              style: TextStyle(fontWeight: FontWeight.w600)),
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
