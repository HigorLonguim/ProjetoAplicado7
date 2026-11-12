import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/widgets/origem_product_reveal.dart';

const _semanticLabel =
    'Produto Origem escaneado e revelado em alimentos frescos e embalados, representando a análise do conteúdo nutricional.';

Widget _host({
  bool reduceMotion = false,
  double width = 390,
  OrigemRevealReplayPolicy policy = OrigemRevealReplayPolicy.finalState,
  OrigemProductRevealController? controller,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: Size(width, 760),
      disableAnimations: reduceMotion,
    ),
    child: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          height: 420,
          child: OrigemProductReveal(
            replayPolicy: policy,
            controller: controller,
          ),
        ),
      ),
    ),
  ),
);

Future<void> _loadAssets(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byKey(const Key('barcode-orbits')).evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  setUp(OrigemProductReveal.debugResetReplayHistory);

  testWidgets('exposes the complete reveal semantics and visual layers', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await _loadAssets(tester);

    expect(find.bySemanticsLabel(_semanticLabel), findsOneWidget);
    expect(find.byKey(const Key('barcode-orbits')), findsOneWidget);
    expect(find.byKey(const Key('origem-focus-lens')), findsOneWidget);
    expect(find.byKey(const Key('origem-package-top')), findsOneWidget);
    expect(find.byKey(const Key('origem-package-left')), findsOneWidget);
    expect(find.byKey(const Key('origem-package-right')), findsOneWidget);
    expect(find.byKey(const Key('origem-package-front')), findsOneWidget);
    expect(find.byKey(const Key('origem-product-can')), findsOneWidget);
    expect(find.byKey(const Key('origem-product-yogurt')), findsOneWidget);
    expect(find.byKey(const Key('origem-product-pasta')), findsOneWidget);
    expect(find.byKey(const Key('origem-product-tomato')), findsOneWidget);
    expect(find.byKey(const Key('origem-product-leaf')), findsOneWidget);
  });

  testWidgets('reduce motion crossfades to final state and then stops', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(reduceMotion: true, policy: OrigemRevealReplayPolicy.always),
    );
    await _loadAssets(tester);
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byKey(const Key('origem-reveal-replay')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at 320 logical pixels', (tester) async {
    await tester.pumpWidget(_host(width: 320));
    await _loadAssets(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(OrigemProductReveal), findsOneWidget);
  });

  testWidgets('renders the expanded desktop composition without errors', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(width: 1180));
    await _loadAssets(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('barcode-orbits')), findsOneWidget);
  });

  testWidgets('controller completes without blocking scanner navigation', (
    tester,
  ) async {
    final controller = OrigemProductRevealController();
    await tester.pumpWidget(
      _host(policy: OrigemRevealReplayPolicy.always, controller: controller),
    );
    await _loadAssets(tester);

    controller.completePresentation();
    await tester.pump(const Duration(milliseconds: 180));

    expect(find.bySemanticsLabel(_semanticLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settled state ignores pointer parallax and only drifts subtly', (
    tester,
  ) async {
    await tester.pumpWidget(_host(policy: OrigemRevealReplayPolicy.always));
    await _loadAssets(tester);
    await tester.pump(const Duration(milliseconds: 4600));

    final product = find.byKey(const Key('origem-product-can'));
    final initial = tester.getTopLeft(product);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(product));
    await mouse.moveTo(tester.getCenter(product) + const Offset(80, 40));
    await tester.pump(const Duration(milliseconds: 1700));
    final settled = tester.getTopLeft(product);

    expect(settled.dx, closeTo(initial.dx, .01));
    expect((settled.dy - initial.dy).abs(), lessThanOrEqualTo(1.21));
    expect(find.byKey(const Key('origem-explore-hint')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('debug replay restarts the full presentation', (tester) async {
    await tester.pumpWidget(_host(policy: OrigemRevealReplayPolicy.always));
    await _loadAssets(tester);
    await tester.pump(const Duration(milliseconds: 4600));

    final replay = find.byKey(const Key('origem-reveal-replay'));
    expect(replay, findsOneWidget);
    await tester.tap(replay);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
  });
}
