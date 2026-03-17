import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_service_base.dart';

/// Implementação real do AuthService com Supabase.
///
/// Para ativar, trocar MockAuthService por SupabaseAuthService
/// no Provider do main.dart.
///
/// TODO: Implementar quando o banco Supabase estiver configurado.
class SupabaseAuthService extends AuthServiceBase {
  UserModel? _currentUser;
  bool _isLoading = false;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isLoading => _isLoading;

  // ── Autenticação ──

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        _isLoading = false;
        notifyListeners();
        return AuthResult.error('Credenciais inválidas');
      }

      // Buscar perfil completo da tabela profiles
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      _currentUser = UserModel(
        id: response.user!.id,
        name: profile?['name'] as String? ?? '',
        email: response.user!.email ?? email,
        cpf: profile?['cpf'] as String?,
        phone: profile?['phone'] as String?,
        company: profile?['company'] as String?,
        role: profile?['role'] as String? ?? 'student',
        avatarUrl: profile?['avatar_url'] as String?,
        emailVerified: response.user!.emailConfirmedAt != null,
        twoFactorEnabled: false,
        createdAt: DateTime.parse(
            response.user!.createdAt),
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('[SupaAuth] Login OK: ${_currentUser!.email}');
      return AuthResult.ok(_currentUser!);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('[SupaAuth] Login erro: $e');
      return AuthResult.error(_parseError(e));
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? cpf,
    String? phone,
    String? company,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'cpf': cpf,
          'phone': phone,
          'company': company,
        },
      );

      if (response.user == null) {
        _isLoading = false;
        notifyListeners();
        return AuthResult.error('Erro ao criar conta');
      }

      // Se email precisa ser confirmado
      if (response.user!.emailConfirmedAt == null) {
        _isLoading = false;
        notifyListeners();
        return AuthResult.needsVerification();
      }

      _currentUser = UserModel(
        id: response.user!.id,
        name: name,
        email: email,
        cpf: cpf,
        phone: phone,
        company: company,
        role: 'student',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return AuthResult.ok(_currentUser!);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(_parseError(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[SupaAuth] Logout erro: $e');
    }
    _currentUser = null;
    notifyListeners();
  }

  @override
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _client.auth.currentSession;
      final user = _client.auth.currentUser;

      if (session != null && user != null) {
        final profile = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        _currentUser = UserModel(
          id: user.id,
          name: profile?['name'] as String? ?? '',
          email: user.email ?? '',
          cpf: profile?['cpf'] as String?,
          phone: profile?['phone'] as String?,
          company: profile?['company'] as String?,
          role: profile?['role'] as String? ?? 'student',
          avatarUrl: profile?['avatar_url'] as String?,
          emailVerified: user.emailConfirmedAt != null,
          twoFactorEnabled: false,
          createdAt: DateTime.parse(user.createdAt),
        );
        debugPrint('[SupaAuth] Sessão restaurada: ${_currentUser!.email}');
      }
    } catch (e) {
      debugPrint('[SupaAuth] Restore session erro: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Verificação de email ──

  @override
  Future<AuthResult> verifyEmailCode(String code) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.email,
        token: code,
        email: _currentUser?.email ?? '',
      );
      if (response.user != null) {
        _currentUser = _currentUser?.copyWith(emailVerified: true);
        notifyListeners();
        return AuthResult.ok(_currentUser!);
      }
      return AuthResult.error('Código inválido');
    } catch (e) {
      return AuthResult.error(_parseError(e));
    }
  }

  @override
  Future<bool> resendVerificationCode() async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: _currentUser?.email ?? '',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Esqueci senha ──

  @override
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── 2FA (TODO: implementar com Supabase MFA) ──

  @override
  Future<AuthResult> verifyTwoFactor(String code) async {
    // TODO: Implementar quando Supabase MFA estiver configurado
    return AuthResult.error('2FA não configurado');
  }

  @override
  Future<String?> enableTwoFactor() async {
    // TODO: Implementar com supabase.auth.mfa.enroll()
    return null;
  }

  @override
  Future<bool> confirmTwoFactor(String code) async {
    // TODO: Implementar com supabase.auth.mfa.verify()
    return false;
  }

  @override
  Future<bool> disableTwoFactor(String code) async {
    // TODO: Implementar com supabase.auth.mfa.unenroll()
    return false;
  }

  // ── Perfil ──

  @override
  Future<bool> updateProfile({
    String? name,
    String? cpf,
    String? phone,
    String? company,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updates['name'] = name;
      if (cpf != null) updates['cpf'] = cpf;
      if (phone != null) updates['phone'] = phone;
      if (company != null) updates['company'] = company;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', _currentUser!.id);

      _currentUser = _currentUser!.copyWith(
        name: name,
        cpf: cpf,
        phone: phone,
        company: company,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[SupaAuth] Update profile erro: $e');
      return false;
    }
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Helpers ──

  String _parseError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email ou senha inválidos';
        case 'Email not confirmed':
          return 'Email não confirmado. Verifique sua caixa de entrada.';
        case 'User already registered':
          return 'Este email já está cadastrado';
        default:
          return error.message;
      }
    }
    return 'Erro de conexão. Tente novamente.';
  }
}
