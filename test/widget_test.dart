import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterweaken/screens/setting_screen.dart';

void main() {
  testWidgets('Settings screen shows theme and accent color controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingScreen()),
      ),
    );

    expect(find.text('Night Mode'), findsOneWidget);
    expect(find.text('Accent color'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
