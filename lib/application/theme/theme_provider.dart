import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rtc_mobile/theme/app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    ref.listenSelf((previous, next) {
      ObsidianTheme.currentThemeMode = next;
    });
    // Initialize standard value
    ObsidianTheme.currentThemeMode = ThemeMode.system;
    return ThemeMode.system;
  }

  bool get isDarkMode {
    if (state == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    ObsidianTheme.currentThemeMode = next;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ObsidianTheme.currentThemeMode = mode;
  }
}
