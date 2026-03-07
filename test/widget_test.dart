import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RiskMobile app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('RiskMobile')),
        ),
      ),
    );

    expect(find.text('RiskMobile'), findsOneWidget);
  });
}
