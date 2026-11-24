import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _preferenceKey = 'rtci_theme_mode';
  bool _chosen = false;

  @override
  ThemeMode build() {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    _chosen = false;
    ObsidianTheme.currentThemeMode = ThemeMode.system;
    Future<void>(() async {
      try {
        final preferences = await SharedPreferences.getInstance();
        if (disposed || _chosen) return;
        final saved = preferences.getString(_preferenceKey);
        final mode = ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
          orElse: () => ThemeMode.system,
        );
        state = mode;
        ObsidianTheme.currentThemeMode = mode;
      } catch (error) {
        debugPrint('Appearance preference unavailable: $error');
      }
    });
    return ThemeMode.system;
  }

  bool get isDarkMode => state == ThemeMode.system
      ? WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
      : state == ThemeMode.dark;

  void toggleTheme() =>
      setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    _chosen = true;
    state = mode;
    ObsidianTheme.currentThemeMode = mode;
    _save(mode);
  }

  Future<void> _save(ThemeMode mode) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_preferenceKey, mode.name);
    } catch (error) {
      debugPrint('Appearance preference could not be saved: $error');
    }
  }
}
