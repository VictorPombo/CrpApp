import 'package:flutter/material.dart';

/// Indicador visual da força da senha.
///
/// 4 níveis: Fraca (vermelho), Razoável (laranja), Boa (azul), Forte (verde).
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength(password);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Barras de progresso
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < strength.level
                      ? strength.color
                      : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Label
        Text(
          strength.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: strength.color,
          ),
        ),
      ],
    );
  }

  _PasswordStrength _calculateStrength(String pwd) {
    int score = 0;

    if (pwd.length >= 6) score++;
    if (pwd.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd)) score++;
    if (pwd.length >= 12) score++;

    if (score <= 1) {
      return _PasswordStrength(1, 'Fraca', Colors.red);
    } else if (score <= 2) {
      return _PasswordStrength(2, 'Razoável', Colors.orange);
    } else if (score <= 4) {
      return _PasswordStrength(3, 'Boa', Colors.blue);
    } else {
      return _PasswordStrength(4, 'Forte', Colors.green);
    }
  }
}

class _PasswordStrength {
  final int level; // 1-4
  final String label;
  final Color color;

  _PasswordStrength(this.level, this.label, this.color);
}
