import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Simple Notifier to handle Theme Mode
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _kThemeKey = 'theme_mode';

  void _loadTheme() async {
    final box = await Hive.openBox('settings');
    final modeIndex = box.get(_kThemeKey, defaultValue: ThemeMode.system.index);
    state = ThemeMode.values[modeIndex];
  }

  void setTheme(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox('settings');
    await box.put(_kThemeKey, mode.index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
