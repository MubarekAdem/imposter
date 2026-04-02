import 'package:flutter_test/flutter_test.dart';

import 'package:imposter/main.dart';

void main() {
  testWidgets('App starts on setup scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const ImposterApp());

    expect(find.text('Imposter Setup'), findsOneWidget);
    expect(find.text('Phase 1 Scaffold'), findsOneWidget);
  });
}
