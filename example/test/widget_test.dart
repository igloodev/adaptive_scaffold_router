// Smoke test for the adaptive_scaffold_router example app.

import 'package:adaptive_scaffold_router_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app builds and shows the initial branch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // The Inbox branch is shown on launch (its AppBar title).
    expect(find.text('Inbox'), findsWidgets);
    // The counter body starts at zero.
    expect(find.text('Tapped 0 times'), findsOneWidget);
  });
}
