import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/ui/features/auth/welcome_screen.dart';
import 'package:rtc_mobile/widgets/custom_logo_loader.dart';
import 'package:rtc_mobile/widgets/modern_widgets.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1200, 900),
  ]) {
    for (final dark in [false, true]) {
      testWidgets('Welcome fits $size, dark=$dark, enlarged text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(1.4),
              ),
              child: const WelcomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('A place to belong.'), findsOneWidget);
        await tester.ensureVisible(find.text('New here? Become a member'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Loader stays still with reduced motion and exposes its status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: CustomLogoLoader(message: 'Connecting…')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Connecting…'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Primary button prevents repeated submits while loading', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomPrimaryButton(
            text: 'Continue',
            isLoading: true,
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton));
    expect(presses, 0);
  });
}
