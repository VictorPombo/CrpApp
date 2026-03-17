import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Resultado de autenticação.
///
/// Indica o próximo passo após login/registro.
enum AuthNextStep {
  none,        // Login completo, ir para home
  verifyEmail, // Precisa verificar email
  twoFactor,   // Precisa inserir código 2FA
}

/// Resultado de uma operação de autenticação.
class AuthResult {
  final bool success;
  final AuthNextStep nextStep;
  final String? errorMessage;
  final UserModel? user;

  const AuthResult({
    required this.success,
    this.nextStep = AuthNextStep.none,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.ok(UserModel user) =>
      AuthResult(success: true, user: user);

  factory AuthResult.needsVerification() =>
      const AuthResult(success: true, nextStep: AuthNextStep.verifyEmail);

  factory AuthResult.needsTwoFactor() =>
      const AuthResult(success: true, nextStep: AuthNextStep.twoFactor);

  factory AuthResult.error(String message) =>
      AuthResult(success: false, errorMessage: message);
}

/// AuthService abstrato — interface para autenticação.
///
/// Implementações:
/// - [MockAuthService] → dados locais (SharedPreferences)
/// - [SupabaseAuthService] → Supabase real (futuro)
abstract class AuthServiceBase extends ChangeNotifier {
  /// Usuário atual (null = não logado)
  UserModel? get currentUser;

  /// Se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Se está carregando (verificando sessão)
  bool get isLoading;

  // ── Autenticação ──

  /// Login com email e senha
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  /// Registro de novo usuário
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? cpf,
    String? phone,
    String? company,
  });

  /// Logout
  Future<void> logout();

  /// Restaurar sessão (chamado no app start)
  Future<void> restoreSession();

  // ── Verificação de email ──

  /// Verificar código de email (6 dígitos)
  Future<AuthResult> verifyEmailCode(String code);

  /// Reenviar código de verificação
  Future<bool> resendVerificationCode();

  // ── Esqueci senha ──

  /// Enviar email de redefinição de senha
  Future<bool> sendPasswordReset(String email);

  /// Redefinir senha com token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  });

  // ── Two-Factor ──

  /// Verificar código 2FA
  Future<AuthResult> verifyTwoFactor(String code);

  /// Ativar 2FA (retorna secret para QR code)
  Future<String?> enableTwoFactor();

  /// Confirmar ativação do 2FA com código
  Future<bool> confirmTwoFactor(String code);

  /// Desativar 2FA
  Future<bool> disableTwoFactor(String code);

  // ── Perfil ──

  /// Atualizar dados do perfil
  Future<bool> updateProfile({
    String? name,
    String? cpf,
    String? phone,
    String? company,
  });

  /// Alterar senha
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
