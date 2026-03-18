import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Estado de autenticação do usuário.
/// Funciona tanto com mock (SharedPreferences) quanto com Supabase real.
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

/// Serviço de autenticação unificado.
///
/// Quando [SupabaseConfig.useSupabaseAuth] é `false`:
///   → Usa SharedPreferences (mock local, dados de demonstração)
///
/// Quando [SupabaseConfig.useSupabaseAuth] é `true`:
///   → Usa Supabase Auth real (tabela profiles no PostgreSQL)
///
/// A interface externa (AuthService.login, AuthService.isAuthenticated, etc.)
/// permanece idêntica — nenhuma tela precisa mudar.
class AuthService {
  // Chaves de persistência (mock)
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

  /// Helper: Supabase client (só quando useSupabaseAuth = true)
  static SupabaseClient get _supa => Supabase.instance.client;

  // ═══════════════════════════════════════════════
  // LOAD / RESTORE SESSION
  // ═══════════════════════════════════════════════

  /// Restaura sessão persistida (chamar antes do runApp)
  static Future<void> load() async {
    if (SupabaseConfig.useSupabaseAuth) {
      await _supaRestoreSession();
    } else {
      await _mockRestoreSession();
    }
  }

  // ═══════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════

  /// Login com credenciais.
  ///
  /// Mock: `username` + `password`
  /// Supabase: `username` é tratado como email + `password`
  static Future<bool> login(String username, String password) async {
    if (SupabaseConfig.useSupabaseAuth) {
      return _supaLogin(username, password);
    } else {
      return _mockLogin(username, password);
    }
  }

  // ═══════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════

  /// Registro de nova conta.
  static Future<bool> register({
    required String username,
    required String password,
    String? email,
    String? cpf,
    String? company,
  }) async {
    if (SupabaseConfig.useSupabaseAuth) {
      return _supaRegister(
        name: username,
        email: email ?? username,
        password: password,
        cpf: cpf,
        company: company,
      );
    } else {
      return _mockRegister(
        username: username,
        password: password,
        email: email,
        cpf: cpf,
        company: company,
      );
    }
  }

  // ═══════════════════════════════════════════════
  // PROFILE UPDATE
  // ═══════════════════════════════════════════════

  /// Atualiza dados de perfil do usuário logado
  static Future<void> updateProfile({
    String? email,
    String? cpf,
    String? company,
  }) async {
    if (SupabaseConfig.useSupabaseAuth) {
      await _supaUpdateProfile(cpf: cpf, company: company);
    } else {
      await _mockUpdateProfile(email: email, cpf: cpf, company: company);
    }
  }

  // ═══════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════

  /// Encerra sessão
  static Future<void> logout() async {
    if (SupabaseConfig.useSupabaseAuth) {
      try {
        await _supa.auth.signOut();
      } catch (e) {
        debugPrint('[AUTH] Logout erro: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyCpf);
    await prefs.remove(_keyCompany);
    await prefs.remove(_keyRole);
    notifier.value = AuthState.unauthenticated();
  }

  // ═══════════════════════════════════════════════
  // PASSWORD RESET (Supabase only)
  // ═══════════════════════════════════════════════

  /// Enviar email de redefinição de senha
  static Future<bool> sendPasswordReset(String email) async {
    if (!SupabaseConfig.useSupabaseAuth) return true; // mock: always success
    try {
      await _supa.auth.resetPasswordForEmail(email.trim());
      return true;
    } catch (e) {
      debugPrint('[AUTH] Reset password erro: $e');
      return false;
    }
  }

  /// Alterar senha (requer sessão ativa)
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!SupabaseConfig.useSupabaseAuth) return true; // mock: always success
    try {
      await _supa.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      debugPrint('[AUTH] Change password erro: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════
  // ═══ SUPABASE IMPLEMENTATION ═══════════════════
  // ═══════════════════════════════════════════════

  static Future<void> _supaRestoreSession() async {
    try {
      final session = _supa.auth.currentSession;
      final user = _supa.auth.currentUser;

      if (session != null && user != null) {
        final profile = await _supa
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        notifier.value = AuthState.authenticated(
          userId: user.id,
          username: profile?['name'] as String? ?? user.email ?? '',
          email: user.email,
          cpf: profile?['cpf'] as String?,
          company: profile?['company'] as String?,
          role: profile?['role'] as String? ?? 'student',
        );

      }
    } catch (e) {
      debugPrint('[AUTH] Restore session erro: $e');
    }
  }

  static Future<bool> _supaLogin(String email, String password) async {
    try {
      final response = await _supa.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) return false;

      final profile = await _supa
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      notifier.value = AuthState.authenticated(
        userId: response.user!.id,
        username: profile?['name'] as String? ?? response.user!.email ?? '',
        email: response.user!.email,
        cpf: profile?['cpf'] as String?,
        company: profile?['company'] as String?,
        role: profile?['role'] as String? ?? 'student',
      );


      return true;
    } catch (e) {
      debugPrint('[AUTH] Login Supabase erro: $e');
      return false;
    }
  }

  static Future<bool> _supaRegister({
    required String name,
    required String email,
    required String password,
    String? cpf,
    String? company,
  }) async {
    try {
      final response = await _supa.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'cpf': cpf,
          'company': company,
        },
      );

      if (response.user == null) return false;

      // Se email não precisa de confirmação, fazer login direto
      if (response.user!.emailConfirmedAt != null || response.session != null) {
        notifier.value = AuthState.authenticated(
          userId: response.user!.id,
          username: name,
          email: email,
          cpf: cpf,
          company: company,
        );
      }


      return true;
    } catch (e) {
      debugPrint('[AUTH] Register Supabase erro: $e');
      return false;
    }
  }

  static Future<void> _supaUpdateProfile({
    String? cpf,
    String? company,
  }) async {
    final state = notifier.value;
    if (!state.loggedIn || state.userId == null) return;

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (cpf != null) updates['cpf'] = cpf;
      if (company != null) updates['company'] = company;

      await _supa
          .from('profiles')
          .update(updates)
          .eq('id', state.userId!);

      notifier.value = AuthState.authenticated(
        userId: state.userId!,
        username: state.username ?? '',
        email: state.email,
        cpf: cpf ?? state.cpf,
        company: company ?? state.company,
        role: state.role,
      );
    } catch (e) {
      debugPrint('[AUTH] Update profile erro: $e');
    }
  }

  // ═══════════════════════════════════════════════
  // ═══ MOCK IMPLEMENTATION ═══════════════════════
  // ═══════════════════════════════════════════════

  static Future<void> _mockRestoreSession() async {
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

  static Future<bool> _mockLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user_${username}_pass');
    if (stored != null && stored == password) {
      await _mockPersistSession(prefs, username);
      return true;
    }
    return false;
  }

  static Future<bool> _mockRegister({
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

    await _mockPersistSession(prefs, username, email: email, cpf: cpf, company: company);
    return true;
  }

  static Future<void> _mockUpdateProfile({
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

  /// Persiste sessão no SharedPreferences (mock only)
  static Future<void> _mockPersistSession(
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
