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
import 'student/verify_certificate_screen.dart';
import 'student/payments_screen.dart';
import 'auth/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService.currentUser;
    final userName = user.username ?? 'Usuário';
    final userEmail = user.email ?? '';
    final initials = userName.isNotEmpty
        ? userName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

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
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(userName,
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(userEmail,
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
                    icon: Icons.verified_user_outlined,
                    title: 'Verificar certificado',
                    subtitle: 'Valide a autenticidade pelo serial',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerifyCertificateScreen()))),
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
        backgroundColor: isDark ? AppColors.darkSurface : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('CRP Engenharia', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fundada em 2014, a CRP Engenharia e Medicina do Trabalho é '
                'especializada em soluções de saúde e segurança ocupacional, '
                'atuando com excelência técnica junto a empresas de todos os portes.',
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
              SizedBox(height: 16),
              Text('Missão', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Atender clientes, colaboradores e fornecedores com excelência em '
                'saúde, segurança e qualidade de vida no trabalho, garantindo '
                'conformidade legal.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text('Visão', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Ser referência no cumprimento das Normas Regulamentadoras (NRs) '
                'e prevenção de riscos, buscando excelência técnica e satisfação total.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text('Valores', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                '• Ética\n• Transparência\n• Responsabilidade\n• Competência',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              SizedBox(height: 12),
              Text('Serviços', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                '• Perícias Trabalhistas\n'
                '• Medicina e Saúde Ocupacional\n'
                '• Engenharia de Segurança\n'
                '• Gestão de eSocial\n'
                '• Licenciamentos (AVCB/CLCB)\n'
                '• Cursos e Treinamentos NR',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondary : AppColors.primary,
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark) {
    final iconColor = isDark ? AppColors.secondary : AppColors.primary;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajuda e Suporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estamos prontos para ajudar! Entre em contato:',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.phone_outlined, size: 18, color: iconColor),
              const SizedBox(width: 8),
              const Text('(11) 2347-0240', style: TextStyle(fontSize: 14)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.message_outlined, size: 18, color: Color(0xFF25D366)),
              const SizedBox(width: 8),
              const Text('(11) 93412-7048', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              const Text('(WhatsApp)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.email_outlined, size: 18, color: iconColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('crpengenharia@crpengenharia.com',
                    style: TextStyle(fontSize: 14)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.location_on_outlined, size: 18, color: iconColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Rua Virgílio, 120 - Vila Prudente\nSão Paulo - SP, CEP: 03138-050',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.access_time, size: 18, color: iconColor),
              const SizedBox(width: 8),
              const Text('Seg - Sex, 8h às 18h', style: TextStyle(fontSize: 14)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFFFD1D1D), Color(0xFFE1306C), Color(0xFFC13584), Color(0xFF833AB4)],
                  ),
                ),
                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('@crpengenhariaemedicina',
                  style: TextStyle(fontSize: 13)),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondary : AppColors.primary,
            ),
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
        backgroundColor: isDark ? AppColors.darkSurface : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Termos de Uso'),
        content: const SizedBox(
          height: 400,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              'TERMOS DE USO — CURSOS CRP ENGENHARIA\n'
              'Última atualização: Março de 2026\n\n'
              '1. ACEITAÇÃO DOS TERMOS\n'
              'Ao utilizar o aplicativo "Cursos CRP Engenharia", desenvolvido pela '
              'CRP Engenharia e Medicina do Trabalho Ltda., o usuário declara que '
              'leu, compreendeu e aceita integralmente os presentes Termos de Uso.\n\n'
              '2. PROPRIEDADE INTELECTUAL\n'
              'Todo o conteúdo disponibilizado neste aplicativo — incluindo, mas não '
              'se limitando a textos, vídeos, imagens, logotipos, materiais didáticos '
              'e certificados — é protegido por direitos autorais nos termos da Lei '
              'nº 9.610/98 e pertence exclusivamente à CRP Engenharia.\n\n'
              '3. LICENÇA DE USO\n'
              'O acesso e uso do conteúdo dos cursos é pessoal e intransferível. '
              'É expressamente vedada a reprodução, distribuição, modificação ou '
              'compartilhamento total ou parcial do material, sob pena de sanções '
              'civis e penais previstas em lei.\n\n'
              '4. CADASTRO E DADOS\n'
              'O usuário é responsável pela veracidade das informações fornecidas '
              'no cadastro. Dados falsos ou inexatos podem resultar na suspensão '
              'do acesso e invalidação de certificados emitidos.\n\n'
              '5. CERTIFICADOS\n'
              'Os certificados digitais são emitidos após a conclusão de 100% do '
              'conteúdo programático e aprovação na avaliação (nota mínima de 70%). '
              'Possuem validade de 2 anos conforme as Normas Regulamentadoras '
              'aplicáveis. A CRP Engenharia garante a autenticidade dos certificados '
              'por meio de código de verificação digital com hash SHA-256.\n\n'
              '6. PAGAMENTOS E REEMBOLSO\n'
              'Os pagamentos são processados por meio de plataforma de pagamento '
              'integrada. O usuário poderá solicitar reembolso integral em até 7 '
              '(sete) dias corridos após a compra, conforme o Código de Defesa do '
              'Consumidor (Lei nº 8.078/90).\n\n'
              '7. RESPONSABILIDADE\n'
              'A CRP Engenharia garante a qualidade técnica e a conformidade dos '
              'conteúdos com as Normas Regulamentadoras vigentes. O usuário é '
              'responsável pela correta aplicação prática dos conhecimentos '
              'adquiridos em seus respectivos ambientes de trabalho.\n\n'
              '8. PRIVACIDADE E PROTEÇÃO DE DADOS\n'
              'Os dados pessoais dos usuários são tratados em conformidade com a '
              'Lei Geral de Proteção de Dados (Lei nº 13.709/2018 — LGPD). Os '
              'dados são utilizados exclusivamente para gestão acadêmica, emissão '
              'de certificados e comunicações relacionadas aos cursos. O usuário '
              'poderá solicitar a exclusão de seus dados a qualquer momento.\n\n'
              '9. DISPONIBILIDADE\n'
              'A CRP Engenharia envidará seus melhores esforços para manter o '
              'aplicativo disponível e funcional. Eventuais interrupções para '
              'manutenção serão comunicadas previamente.\n\n'
              '10. FORO\n'
              'Fica eleito o foro da comarca de São Paulo — SP para dirimir '
              'quaisquer controvérsias decorrentes destes Termos de Uso.\n\n'
              'CRP Engenharia e Medicina do Trabalho Ltda.\n'
              'Rua Virgílio, 120 — Vila Prudente, São Paulo — SP\n'
              'crpengenharia@crpengenharia.com\n'
              '(11) 2347-0240',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppColors.secondary : AppColors.primary,
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon,
          color: isDark ? AppColors.secondary : AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle:
          subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
      trailing:
          trailing ?? Icon(Icons.chevron_right,
              color: isDark ? Colors.grey[400] : Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}