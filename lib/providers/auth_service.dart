import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado de autenticação do usuário.
/// Preparado para migração futura para Supabase Auth.
class AuthState {
  final bool loggedIn;
  final String? userId;
  final String? username;
  final String? email;
  final String? cpf;
  final String? company;
  final String role; // 'student' | 'admin'

  AuthState({
    required this.loggedIn,
    this.userId,
    this.username,
    this.email,
    this.cpf,
    this.company,
    this.role = 'student',
  });

  /// Cria estado não autenticado
  factory AuthState.unauthenticated() =>
      AuthState(loggedIn: false);

  /// Cria estado autenticado a partir de dados
  factory AuthState.authenticated({
    required String userId,
    required String username,
    String? email,
    String? cpf,
    String? company,
    String role = 'student',
  }) =>
      AuthState(
        loggedIn: true,
        userId: userId,
        username: username,
        email: email,
        cpf: cpf,
        company: company,
        role: role,
      );
}

/// Serviço de autenticação com ValueNotifier.
/// Usa SharedPreferences para persistência local.
/// Interface preparada para trocar por Supabase Auth sem retrabalho.
class AuthService {
  // Chaves de persistência
  static const _keyUserId = 'auth_user_id';
  static const _keyUser = 'auth_user';
  static const _keyEmail = 'auth_email';
  static const _keyCpf = 'auth_cpf';
  static const _keyCompany = 'auth_company';
  static const _keyRole = 'auth_role';

  /// Notifier global do estado de autenticação
  static final notifier =
      ValueNotifier<AuthState>(AuthState.unauthenticated());

  /// Atalho para verificar se está logado
  static bool get isAuthenticated => notifier.value.loggedIn;

  /// Atalho para o estado atual
  static AuthState get currentUser => notifier.value;

  /// Restaura sessão persistida (chamar antes do runApp)
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUser);
    if (username != null) {
      notifier.value = AuthState.authenticated(
        userId: prefs.getString(_keyUserId) ?? username,
        username: username,
        email: prefs.getString(_keyEmail),
        cpf: prefs.getString(_keyCpf),
        company: prefs.getString(_keyCompany),
        role: prefs.getString(_keyRole) ?? 'student',
      );
    }
  }

  /// Login com credenciais mock
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user_${username}_pass');
    if (stored != null && stored == password) {
      await _persistSession(prefs, username);
      return true;
    }
    return false;
  }

  /// Registro de nova conta mock
  static Future<bool> register({
    required String username,
    required String password,
    String? email,
    String? cpf,
    String? company,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_${username}_pass';
    if (prefs.containsKey(key)) return false;

    await prefs.setString(key, password);
    if (email != null) await prefs.setString('user_${username}_email', email);
    if (cpf != null) await prefs.setString('user_${username}_cpf', cpf);
    if (company != null) {
      await prefs.setString('user_${username}_company', company);
    }

    await _persistSession(prefs, username, email: email, cpf: cpf, company: company);
    return true;
  }

  /// Atualiza dados de perfil do usuário logado
  static Future<void> updateProfile({
    String? email,
    String? cpf,
    String? company,
  }) async {
    final state = notifier.value;
    if (!state.loggedIn || state.username == null) return;

    final prefs = await SharedPreferences.getInstance();
    final username = state.username!;

    if (email != null) {
      await prefs.setString(_keyEmail, email);
      await prefs.setString('user_${username}_email', email);
    }
    if (cpf != null) {
      await prefs.setString(_keyCpf, cpf);
      await prefs.setString('user_${username}_cpf', cpf);
    }
    if (company != null) {
      await prefs.setString(_keyCompany, company);
      await prefs.setString('user_${username}_company', company);
    }

    notifier.value = AuthState.authenticated(
      userId: state.userId ?? username,
      username: username,
      email: email ?? state.email,
      cpf: cpf ?? state.cpf,
      company: company ?? state.company,
      role: state.role,
    );
  }

  /// Encerra sessão
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyCpf);
    await prefs.remove(_keyCompany);
    await prefs.remove(_keyRole);
    notifier.value = AuthState.unauthenticated();
  }

  /// Persiste sessão no SharedPreferences
  static Future<void> _persistSession(
    SharedPreferences prefs,
    String username, {
    String? email,
    String? cpf,
    String? company,
  }) async {
    final userId = username; // mock: usar username como ID
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUser, username);

    // Carregar dados extras do perfil se existirem
    final savedEmail =
        email ?? prefs.getString('user_${username}_email');
    final savedCpf = cpf ?? prefs.getString('user_${username}_cpf');
    final savedCompany =
        company ?? prefs.getString('user_${username}_company');

    if (savedEmail != null) await prefs.setString(_keyEmail, savedEmail);
    if (savedCpf != null) await prefs.setString(_keyCpf, savedCpf);
    if (savedCompany != null) {
      await prefs.setString(_keyCompany, savedCompany);
    }
    await prefs.setString(_keyRole, 'student');

    notifier.value = AuthState.authenticated(
      userId: userId,
      username: username,
      email: savedEmail,
      cpf: savedCpf,
      company: savedCompany,
    );
  }
}
