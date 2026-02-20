import 'package:flutter_test/flutter_test.dart';

import 'package:bandsync/main.dart';

void main() {
  testWidgets('BandSync app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BandSyncApp());
    expect(find.text('My Bands'), findsOneWidget);
  });
}