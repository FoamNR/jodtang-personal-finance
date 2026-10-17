import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jod_tang/ui/features/splash/views/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders branding elements and calls onFinished',
      (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    // Verify initial branding and typography render
    expect(find.text('จดตัง'), findsOneWidget);
    expect(find.text('J O D  T A N G'), findsOneWidget);
    expect(find.text('จัดการเงินง่ายๆ สไตล์คุณ'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);

    // Fast-forward animation timeline in increments
    for (int i = 0; i < 35; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // After animation sequence completes, onFinished should have been triggered
    expect(finished, isTrue);
  });
}
