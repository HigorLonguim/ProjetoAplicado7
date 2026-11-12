// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:origem/main.dart';

void main() {
  testWidgets('shows the Origem home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OrigemApp());

    expect(find.text('Escanear produto'), findsOneWidget);
    expect(find.text('Veja além\ndo rótulo.'), findsOneWidget);
  });

  testWidgets('keeps revealed products decorative on Hoje', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OrigemApp());
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('barcode-orbits')).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 5000));

    await tester.tap(find.byKey(const Key('origem-product-can')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('EXPLORE A CENA'), findsNothing);
    expect(find.text('Escanear um produto real'), findsNothing);
    expect(find.text('Escanear produto'), findsOneWidget);
  });
}
