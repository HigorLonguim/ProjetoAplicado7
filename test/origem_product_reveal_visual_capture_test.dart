import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/theme/app_theme.dart';
import 'package:origem/widgets/origem_product_reveal.dart';

Widget _captureHost({
  OrigemRevealReplayPolicy policy = OrigemRevealReplayPolicy.always,
}) => MaterialApp(
  home: Scaffold(
    backgroundColor: AppColors.petroleum,
    body: SizedBox.expand(child: OrigemProductReveal(replayPolicy: policy)),
  ),
);

Future<void> _waitForComposition(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byKey(const Key('barcode-orbits')).evaluate().isNotEmpty) return;
  }
}

void main() {
  testWidgets('captures scanner, opening and final composition', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 580);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_captureHost());
    await _waitForComposition(tester);

    await tester.pump(const Duration(milliseconds: 1050));
    await expectLater(
      find.byType(OrigemProductReveal),
      matchesGoldenFile('../docs/qa/origem_reveal_scanning.png'),
    );

    await tester.pump(const Duration(milliseconds: 1500));
    await expectLater(
      find.byType(OrigemProductReveal),
      matchesGoldenFile('../docs/qa/origem_reveal_opening.png'),
    );

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 1000));
    await expectLater(
      find.byType(OrigemProductReveal),
      matchesGoldenFile('../docs/qa/origem_reveal_final.png'),
    );
  });

  testWidgets('captures the exact static final state', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 580);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _captureHost(policy: OrigemRevealReplayPolicy.finalState),
    );
    await _waitForComposition(tester);
    await tester.pump();
    await expectLater(
      find.byType(OrigemProductReveal),
      matchesGoldenFile('../docs/qa/origem_reveal_final_static.png'),
    );
  });
}
