import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GlobalThemeNotifier extends ValueNotifier<ThemeMode>{
  static final GlobalThemeNotifier _instance = GlobalThemeNotifier._();
  factory GlobalThemeNotifier() => _instance;

  GlobalThemeNotifier._() : super(ThemeMode.system) {
    _loadTheme();
  }

  final _storage = const FlutterSecureStorage();

  static const _key = 'APP_THEME_MODE';


  Future<void> _loadTheme() async {
    final stored = await _storage.read(key: _key);
    value = _fromString(stored);
  }

  Future<void> setTheme(ThemeMode theme) async {
    value = theme;
    await _storage.write(key: _key, value: _toString(theme));
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      return 'system';
    }
  }

  ThemeMode _fromString(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}