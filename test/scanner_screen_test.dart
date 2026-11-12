import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:origem/models/product_model.dart';
import 'package:origem/screens/scanner_screen.dart';
import 'package:origem/services/product_service.dart';

const _product = ProductModel(
  barcode: '7891234567890',
  name: 'Produto encontrado',
  brand: 'Marca teste',
  calories: 120,
);

Widget _camera(
  BuildContext context,
  MobileScannerController controller,
  ValueChanged<BarcodeCapture> onDetect,
) => ColoredBox(
  color: const Color(0xFF17363A),
  child: Center(
    child: FilledButton(
      key: const Key('debug-detect-barcode'),
      onPressed: () => onDetect(
        const BarcodeCapture(
          size: Size(1000, 700),
          barcodes: [
            Barcode(
              rawValue: '7891234567890',
              format: BarcodeFormat.ean13,
              corners: [
                Offset(250, 270),
                Offset(750, 270),
                Offset(750, 420),
                Offset(250, 420),
              ],
            ),
          ],
        ),
      ),
      child: const Text('Simular código'),
    ),
  ),
);

Widget _host({
  ScannerPermissionKind permission = ScannerPermissionKind.granted,
  ScannerProductLookup? lookup,
  bool reduceMotion = false,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: ScannerScreen(
      showBackButton: false,
      permissionReader: () async => permission,
      permissionRequester: () async => ScannerPermissionKind.granted,
      cameraBuilder: _camera,
      productLookup: lookup ?? (_) async => _product,
      historyWriter: (_) async {},
    ),
  ),
);

Future<void> _ready(WidgetTester tester, {Widget? host}) async {
  await tester.pumpWidget(host ?? _host());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 450));
}

void main() {
  testWidgets('shows a ready scanner with manual alternative', (tester) async {
    await _ready(tester);

    expect(find.text('Aponte para o código de barras'), findsOneWidget);
    expect(find.byKey(const Key('debug-detect-barcode')), findsOneWidget);
    expect(find.byTooltip('Digitar código'), findsOneWidget);
  });

  testWidgets('explains denied permission and keeps manual entry', (
    tester,
  ) async {
    await _ready(tester, host: _host(permission: ScannerPermissionKind.denied));

    expect(find.text('Use a câmera para encontrar o código'), findsOneWidget);
    expect(find.byKey(const Key('scanner-permission-manual')), findsOneWidget);
  });

  testWidgets('offers settings when permission is permanently denied', (
    tester,
  ) async {
    await _ready(
      tester,
      host: _host(permission: ScannerPermissionKind.permanentlyDenied),
    );

    expect(find.text('Abrir configurações'), findsOneWidget);
    expect(find.text('Precisamos da câmera para ler o código'), findsOneWidget);
  });

  testWidgets('manual entry validates empty and malformed codes', (
    tester,
  ) async {
    await _ready(tester, host: _host(permission: ScannerPermissionKind.denied));
    await tester.tap(find.byKey(const Key('scanner-permission-manual')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('manual-barcode-submit')));
    await tester.pump();
    expect(find.text('Digite os números do código de barras.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('manual-barcode-field')),
      '123-45',
    );
    await tester.tap(find.byKey(const Key('manual-barcode-submit')));
    await tester.pump();
    expect(find.text('Use um código entre 8 e 14 números.'), findsOneWidget);
  });

  testWidgets('manual entry can complete the lookup without camera access', (
    tester,
  ) async {
    await _ready(tester, host: _host(permission: ScannerPermissionKind.denied));
    await tester.tap(find.byKey(const Key('scanner-permission-manual')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('manual-barcode-field')),
      '7891-2345-6789-0',
    );
    await tester.tap(find.byKey(const Key('manual-barcode-submit')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Produto encontrado'), findsOneWidget);
  });

  testWidgets('locks duplicate detections into a single lookup', (
    tester,
  ) async {
    final completer = Completer<ProductModel>();
    var lookups = 0;
    await _ready(
      tester,
      host: _host(
        lookup: (_) {
          lookups++;
          return completer.future;
        },
      ),
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('debug-detect-barcode')),
    );
    button.onPressed!();
    button.onPressed!();
    await tester.pump(const Duration(milliseconds: 150));

    expect(lookups, 1);
    expect(find.text('Encontrando o produto'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete(_product);
    await tester.pump();
  });

  testWidgets('advances the real loading narrative without percentages', (
    tester,
  ) async {
    final completer = Completer<ProductModel>();
    await _ready(tester, host: _host(lookup: (_) => completer.future));
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(find.text('Encontrando o produto'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Lendo os dados disponíveis'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);

    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('Preparando o resumo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete(_product);
    await tester.pump();
  });

  testWidgets('navigates to product result and returns to scanner', (
    tester,
  ) async {
    await _ready(tester);
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Produto encontrado'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Aponte para o código de barras'), findsOneWidget);
  });

  testWidgets('shows a specific not-found recovery state', (tester) async {
    await _ready(
      tester,
      host: _host(lookup: (_) async => throw const ProductNotFoundException()),
    );
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump();

    expect(
      find.text('Este produto ainda não apareceu na nossa fonte.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('scanner-error-manual')), findsOneWidget);
  });

  testWidgets('shows a network recovery state', (tester) async {
    await _ready(
      tester,
      host: _host(
        lookup: (_) async => throw const ProductConnectionException(),
      ),
    );
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump();

    expect(
      find.text('Não foi possível consultar o produto agora.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('scanner-error-retry')), findsOneWidget);
  });

  testWidgets('shows offline only when lookup reports offline', (tester) async {
    await _ready(
      tester,
      host: _host(lookup: (_) async => throw const ProductOfflineException()),
    );
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump();

    expect(find.text('Você está sem conexão.'), findsOneWidget);
    expect(
      find.text(
        'A câmera pode identificar o código, mas a consulta depende da internet.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('offers manual entry when camera is unavailable', (tester) async {
    await _ready(
      tester,
      host: _host(permission: ScannerPermissionKind.unavailable),
    );

    expect(find.text('A câmera não está disponível.'), findsOneWidget);
    expect(find.byKey(const Key('scanner-error-manual')), findsOneWidget);
  });

  testWidgets('reduce motion keeps the complete functional flow', (
    tester,
  ) async {
    await _ready(tester, host: _host(reduceMotion: true));
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('Produto encontrado'), findsOneWidget);
  });

  testWidgets('disposing during a pending lookup is safe', (tester) async {
    final completer = Completer<ProductModel>();
    await _ready(tester, host: _host(lookup: (_) => completer.future));
    await tester.tap(find.byKey(const Key('debug-detect-barcode')));
    await tester.pump(const Duration(milliseconds: 180));
    await tester.pumpWidget(const SizedBox.shrink());
    completer.complete(_product);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
