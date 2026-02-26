import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'theme_mode';
  static final notifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key) ?? 'light';
    notifier.value = (s == 'dark') ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggle() async {
    final next = notifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifier.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }
}
