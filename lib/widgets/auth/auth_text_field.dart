import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Campo de texto reutilizável para telas de autenticação.
///
/// Suporta tipos: email, password, name, cpf, phone, text.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final AuthFieldType type;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.type = AuthFieldType.text,
    this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

enum AuthFieldType { email, password, name, cpf, phone, text }

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: widget.type == AuthFieldType.password && _obscure,
      keyboardType: _keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      inputFormatters: _formatters,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textBody,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(_prefixIcon, size: 20),
        suffixIcon: widget.type == AuthFieldType.password
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }

  IconData get _prefixIcon {
    switch (widget.type) {
      case AuthFieldType.email:
        return Icons.email_outlined;
      case AuthFieldType.password:
        return Icons.lock_outlined;
      case AuthFieldType.name:
        return Icons.person_outlined;
      case AuthFieldType.cpf:
        return Icons.badge_outlined;
      case AuthFieldType.phone:
        return Icons.phone_outlined;
      case AuthFieldType.text:
        return Icons.edit_outlined;
    }
  }

  TextInputType get _keyboardType {
    switch (widget.type) {
      case AuthFieldType.email:
        return TextInputType.emailAddress;
      case AuthFieldType.phone:
      case AuthFieldType.cpf:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? get _formatters {
    switch (widget.type) {
      case AuthFieldType.cpf:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
          _CpfFormatter(),
        ];
      case AuthFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
          _PhoneFormatter(),
        ];
      default:
        return null;
    }
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${widget.label} é obrigatório';
    }
    switch (widget.type) {
      case AuthFieldType.email:
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
          return 'Email inválido';
        }
        break;
      case AuthFieldType.password:
        if (value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        break;
      case AuthFieldType.cpf:
        final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (clean.length != 11) {
          return 'CPF deve ter 11 dígitos';
        }
        break;
      case AuthFieldType.phone:
        final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (clean.length < 10) {
          return 'Telefone inválido';
        }
        break;
      default:
        break;
    }
    return null;
  }
}

/// Máscara CPF: 000.000.000-00
class _CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Máscara telefone: (00) 00000-0000
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
