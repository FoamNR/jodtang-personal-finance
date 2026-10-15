import 'package:flutter_test/flutter_test.dart';
import 'package:jod_tang/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JodTangApp());
    expect(find.byType(JodTangApp), findsOneWidget);
  });
}
