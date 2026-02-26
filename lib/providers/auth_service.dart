import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool loggedIn;
  final String? username;
  AuthState({required this.loggedIn, this.username});
}

class AuthService {
  static const _keyUser = 'auth_user';
  static final notifier = ValueNotifier<AuthState>(AuthState(loggedIn: false, username: null));

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_keyUser);
    if (user != null) notifier.value = AuthState(loggedIn: true, username: user);
  }

  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user_${username}_pass');
    if (stored != null && stored == password) {
      await prefs.setString(_keyUser, username);
      notifier.value = AuthState(loggedIn: true, username: username);
      return true;
    }
    return false;
  }

  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_${username}_pass';
    if (prefs.containsKey(key)) return false;
    await prefs.setString(key, password);
    await prefs.setString(_keyUser, username);
    notifier.value = AuthState(loggedIn: true, username: username);
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    notifier.value = AuthState(loggedIn: false, username: null);
  }
}
