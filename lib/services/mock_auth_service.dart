import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_service_base.dart';

/// Implementação mock do AuthService.
///
/// Usa SharedPreferences para simular autenticação local.
/// Compatível com o fluxo existente do app (carlos / 123456).
class MockAuthService extends AuthServiceBase {
  UserModel? _currentUser;
  bool _isLoading = false;
  SharedPreferences? _prefs;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isLoading => _isLoading;

  SharedPreferences get _p => _prefs!;

  // ── Autenticação ──

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500)); // Simular rede

    _prefs ??= await SharedPreferences.getInstance();

    // Verificar credenciais: tenta por email e por username
    final input = email.trim().toLowerCase();
    String? userId;

    // Login por username (compat. existente)
    final storedPass = _p.getString('user_${input}_pass');
    if (storedPass == password) {
      userId = input;
    } else {
      // Login por email: buscar todos os users
      final keys = _p.getKeys().where((k) => k.startsWith('user_') && k.endsWith('_email'));
      for (final key in keys) {
        final storedEmail = _p.getString(key)?.toLowerCase();
        if (storedEmail == input) {
          final username = key.replaceFirst('user_', '').replaceFirst('_email', '');
          final pass = _p.getString('user_${username}_pass');
          if (pass == password) {
            userId = username;
            break;
          }
        }
      }
    }

    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error('Email ou senha inválidos');
    }

    // Criar sessão
    final userEmail = _p.getString('user_${userId}_email') ?? '$userId@email.com';
    final userCpf = _p.getString('user_${userId}_cpf');
    final userCompany = _p.getString('user_${userId}_company');

    _currentUser = UserModel(
      id: userId,
      name: userId,
      email: userEmail,
      cpf: userCpf,
      company: userCompany,
      role: 'student',
      emailVerified: true,
      createdAt: DateTime.now(),
    );

    // Salvar sessão
    await _p.setString('auth_user_id', userId);
    await _p.setString('auth_user', userId);
    await _p.setString('auth_email', userEmail);
    if (userCpf != null) await _p.setString('auth_cpf', userCpf);
    if (userCompany != null) await _p.setString('auth_company', userCompany);
    await _p.setString('auth_role', 'student');

    _isLoading = false;
    notifyListeners();

    return AuthResult.ok(_currentUser!);
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

    await Future.delayed(const Duration(milliseconds: 500));

    _prefs ??= await SharedPreferences.getInstance();

    final username = email.split('@').first.toLowerCase();

    // Verificar se já existe
    if (_p.getString('user_${username}_pass') != null) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error('Usuário já cadastrado');
    }

    // Salvar dados do usuário
    await _p.setString('user_${username}_pass', password);
    await _p.setString('user_${username}_email', email);
    if (cpf != null) await _p.setString('user_${username}_cpf', cpf);
    if (phone != null) await _p.setString('user_${username}_phone', phone);
    if (company != null) await _p.setString('user_${username}_company', company);

    // Auto-login após registro
    _currentUser = UserModel(
      id: username,
      name: name,
      email: email,
      cpf: cpf,
      phone: phone,
      company: company,
      role: 'student',
      emailVerified: true, // Mock: já verificado
      createdAt: DateTime.now(),
    );

    await _p.setString('auth_user_id', username);
    await _p.setString('auth_user', username);
    await _p.setString('auth_email', email);
    await _p.setString('auth_role', 'student');

    _isLoading = false;
    notifyListeners();

    return AuthResult.ok(_currentUser!);
  }

  @override
  Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _p.remove('auth_user_id');
    await _p.remove('auth_user');
    await _p.remove('auth_email');
    await _p.remove('auth_cpf');
    await _p.remove('auth_company');
    await _p.remove('auth_role');
    _currentUser = null;
    notifyListeners();

  }

  @override
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    _prefs ??= await SharedPreferences.getInstance();

    final userId = _p.getString('auth_user_id');
    if (userId != null) {
      _currentUser = UserModel(
        id: userId,
        name: userId,
        email: _p.getString('auth_email') ?? '',
        cpf: _p.getString('auth_cpf'),
        company: _p.getString('auth_company'),
        role: _p.getString('auth_role') ?? 'student',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Verificação de email (mock: aceita qualquer código) ──

  @override
  Future<AuthResult> verifyEmailCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(emailVerified: true);
      notifyListeners();
      return AuthResult.ok(_currentUser!);
    }
    return AuthResult.error('Nenhum usuário logado');
  }

  @override
  Future<bool> resendVerificationCode() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // Sempre sucesso no mock
  }

  // ── Esqueci senha (mock: sempre sucesso) ──

  @override
  Future<bool> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // ── 2FA (mock: simples) ──

  @override
  Future<AuthResult> verifyTwoFactor(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser != null) {
      return AuthResult.ok(_currentUser!);
    }
    return AuthResult.error('Código inválido');
  }

  @override
  Future<String?> enableTwoFactor() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'MOCK_2FA_SECRET_KEY_ABCD1234'; // Retorna secret mock
  }

  @override
  Future<bool> confirmTwoFactor(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(twoFactorEnabled: true);
      notifyListeners();
    }
    return true;
  }

  @override
  Future<bool> disableTwoFactor(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(twoFactorEnabled: false);
      notifyListeners();
    }
    return true;
  }

  // ── Perfil ──

  @override
  Future<bool> updateProfile({
    String? name,
    String? cpf,
    String? phone,
    String? company,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _prefs ??= await SharedPreferences.getInstance();

    if (_currentUser == null) return false;

    final userId = _currentUser!.id;

    if (cpf != null) {
      await _p.setString('user_${userId}_cpf', cpf);
      await _p.setString('auth_cpf', cpf);
    }
    if (phone != null) await _p.setString('user_${userId}_phone', phone);
    if (company != null) {
      await _p.setString('user_${userId}_company', company);
      await _p.setString('auth_company', company);
    }

    _currentUser = _currentUser!.copyWith(
      name: name,
      cpf: cpf,
      phone: phone,
      company: company,
    );
    notifyListeners();
    return true;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _prefs ??= await SharedPreferences.getInstance();

    if (_currentUser == null) return false;

    final userId = _currentUser!.id;
    final storedPass = _p.getString('user_${userId}_pass');

    if (storedPass != currentPassword) return false;

    await _p.setString('user_${userId}_pass', newPassword);
    return true;
  }
}
