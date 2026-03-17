import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_service.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cpfController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final auth = AuthService.currentUser;
    _nameController = TextEditingController(text: auth.username ?? 'Aluno');
    _cpfController = TextEditingController(text: auth.cpf ?? '');
    _phoneController = TextEditingController(text: '');
    _emailController = TextEditingController(text: auth.email ?? '');
    _companyController = TextEditingController(text: auth.company ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados pessoais'),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  // BUG 9 — Salvar no AuthService
                  AuthService.updateProfile(
                    cpf: _cpfController.text.trim(),
                    company: _companyController.text.trim(),
                  );
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados salvos com sucesso!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
            icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
            label: Text(_isEditing ? 'Salvar' : 'Editar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF1A1A1A),
                    child: Text('CA',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
              if (_isEditing)
                Center(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Alterar foto'),
                  ),
                ),
              const SizedBox(height: 24),

              _buildField('Nome completo', _nameController, Icons.person_outline),
              _buildField('CPF', _cpfController, Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_CpfInputFormatter()],
                  hintText: '000.000.000-00'),
              _buildField('Telefone', _phoneController, Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_PhoneInputFormatter()],
                  hintText: '(00) 00000-0000'),
              _buildField('E-mail', _emailController, Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress, enabled: false),
              _buildField('Empresa', _companyController, Icons.business_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, bool enabled = true,
       List<TextInputFormatter>? inputFormatters, String? hintText}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: _isEditing && enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20,
                  color: isDark ? AppColors.secondary : null),
              hintText: hintText,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
        ],
      ),
    );
  }
}

/// Máscara de CPF: 000.000.000-00
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 11) {
      return oldValue;
    }
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buf.write('.');
      if (i == 9) buf.write('-');
      buf.write(digits[i]);
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}

/// Máscara de telefone: (00) 00000-0000
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 11) {
      return oldValue;
    }
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buf.write('(');
      if (i == 2) buf.write(') ');
      if (i == 7) buf.write('-');
      buf.write(digits[i]);
    }
    return TextEditingValue(
      text: buf.toString(),
      selection: TextSelection.collapsed(offset: buf.length),
    );
  }
}
