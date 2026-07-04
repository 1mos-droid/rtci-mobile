import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/ui/features/auth/startup_loader_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Neumorphic Theme Tests', () {
    test('Light theme background matches Neumorphic soft grey', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFAFAFC));
    });

    test('Dark theme background matches Neumorphic soft slate', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0B0F19));
    });

    test('Neumorphic decoration returns shadows in normal state', () {
      final lightDec = Neumorphic.decoration(isDark: false);
      expect(lightDec.boxShadow, isNotNull);
      expect(lightDec.boxShadow!.length, equals(2));
      expect(lightDec.boxShadow![0].offset, const Offset(6, 6)); // Dark shadow offset
      expect(lightDec.boxShadow![1].offset, const Offset(-6, -6)); // Light shadow offset

      final darkDec = Neumorphic.decoration(isDark: true);
      expect(darkDec.boxShadow, isNotNull);
      expect(darkDec.boxShadow!.length, equals(2));
    });

    test('Neumorphic decoration returns gradient/border in pressed state', () {
      final pressedDec = Neumorphic.decoration(isDark: false, isPressed: true);
      expect(pressedDec.boxShadow, isNull);
      expect(pressedDec.gradient, isNotNull);
    });
  });

  group('StartupLoaderScreen Tests', () {
    testWidgets('renders loading messages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StartupLoaderScreen(message: 'Testing initialization...'),
          ),
        ),
      );

      expect(find.text('TESTING INITIALIZATION...'), findsOneWidget);
    });
  });
}
