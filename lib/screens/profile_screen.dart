import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_service.dart';
import '../core/app_spacing.dart';
import '../providers/auth_service.dart';
import '../services/local_storage_service.dart';
import 'student/personal_data_screen.dart';
import 'student/course_history_screen.dart';
import 'student/certificates_list_screen.dart';
import 'student/payments_screen.dart';
import 'auth/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth(context)),
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),

            // ===== CARD PERFIL =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.brandGradient,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF1A1A1A),
                      child: Text('CA',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Carlos Alberto Silva',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('carlos@email.com',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== MENU ITEMS =====
            _MenuSection(
              isDark: isDark,
              children: [
                _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Dados pessoais',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalDataScreen()))),
                _MenuItem(
                    icon: Icons.school_outlined,
                    title: 'Histórico de cursos',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseHistoryScreen()))),
                _MenuItem(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Certificados',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificatesListScreen()))),
                _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Pagamentos',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen()))),
              ],
            ),
            const SizedBox(height: 16),

            // ===== CONFIGURAÇÕES =====
            _MenuSection(
              isDark: isDark,
              children: [
                _MenuItem(
                    icon: Icons.lock_outline,
                    title: 'Alterar senha',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
                // Tema
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeService.notifier,
                  builder: (context, mode, _) {
                    return _MenuItem(
                      icon: ThemeService.isDark
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,
                      title: 'Tema do aplicativo',
                      subtitle: ThemeService.isDark ? 'Escuro' : 'Claro',
                      trailing: Switch(
                        value: ThemeService.isDark,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) => ThemeService.toggle(),
                      ),
                      onTap: () => ThemeService.toggle(),
                    );
                  },
                ),
                _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificações em breve!')),
                      );
                    }),
              ],
            ),
            const SizedBox(height: 16),

            // ===== SOBRE =====
            _MenuSection(
              isDark: isDark,
              children: [
                _MenuItem(
                    icon: Icons.info_outline,
                    title: 'Sobre a CRP Engenharia',
                    onTap: () => _showAboutDialog(context, isDark)),
                _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Ajuda e suporte',
                    onTap: () => _showSupportDialog(context, isDark)),
                _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'Termos de uso',
                    onTap: () => _showTermsDialog(context, isDark)),
              ],
            ),
            const SizedBox(height: 24),

            // ===== LOGOUT =====
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  // BUG 15 — Logout completo
                  await AuthService.logout();
                  await LocalStorageService.clearAll();
                  if (!context.mounted) return;
                  context.go('/home');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Text('CRP Cursos v1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('CRP Engenharia'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A CRP Engenharia é especialista em segurança do trabalho e medicina ocupacional, '
              'oferecendo cursos e treinamentos certificados para profissionais da indústria.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            SizedBox(height: 12),
            Text('CNPJ: 12.345.678/0001-90', style: TextStyle(fontSize: 13)),
            SizedBox(height: 4),
            Text('Fundada em 2015', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajuda e suporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Em caso de dúvidas ou problemas:', style: TextStyle(fontSize: 14)),
            SizedBox(height: 12),
            Row(children: [
              Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('suporte@crpengenharia.com.br', style: TextStyle(fontSize: 13)),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('(11) 3456-7890', style: TextStyle(fontSize: 13)),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.access_time, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Seg-Sex, 8h às 18h', style: TextStyle(fontSize: 13)),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Termos de uso'),
        content: const SizedBox(
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              'TERMOS DE USO — CRP CURSOS\n\n'
              '1. ACEITAÇÃO DOS TERMOS\n'
              'Ao utilizar o aplicativo CRP Cursos, você concorda com estes termos de uso.\n\n'
              '2. USO DO SERVIÇO\n'
              'O conteúdo dos cursos é para uso pessoal e intransferível. '
              'É proibida a reprodução, distribuição ou compartilhamento do material.\n\n'
              '3. PAGAMENTOS\n'
              'Os pagamentos são processados pelo Mercado Pago. '
              'Política de reembolso: até 7 dias após a compra.\n\n'
              '4. CERTIFICADOS\n'
              'Os certificados são emitidos após a conclusão de 100% do conteúdo. '
              'Possuem validade de 2 anos conforme normas regulamentadoras.\n\n'
              '5. PRIVACIDADE\n'
              'Seus dados são protegidos conforme a LGPD (Lei 13.709/2018).\n\n'
              '6. CONTATO\n'
              'suporte@crpengenharia.com.br',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _MenuSection({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Divider(
                height: 1,
                indent: 56,
                color: isDark ? AppColors.darkDivider : Colors.grey[200]);
          }
          return children[i ~/ 2];
        }),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle:
          subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}