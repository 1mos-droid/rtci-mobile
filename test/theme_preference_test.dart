import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rtc_mobile/application/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Appearance is restored on a new app session', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    final subscription = first.listen(themeNotifierProvider, (_, _) {});
    first.read(themeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);
    subscription.close();
    first.dispose();
    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.listen(themeNotifierProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    expect(second.read(themeNotifierProvider), ThemeMode.dark);
  });

  test('Restoring preferences cannot override a new selection', () async {
    SharedPreferences.setMockInitialValues({'rtci_theme_mode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(themeNotifierProvider, (_, _) {});
    container
        .read(themeNotifierProvider.notifier)
        .setThemeMode(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(themeNotifierProvider), ThemeMode.light);
  });
}
