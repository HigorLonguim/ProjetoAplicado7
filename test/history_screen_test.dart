import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/history_item.dart';
import 'package:origem/screens/history_screen.dart';

void main() {
  testWidgets('abre novamente um produto selecionado no histórico', (
    tester,
  ) async {
    final item = HistoryItem(
      id: 'registro-1',
      productId: '7891000100103',
      productName: 'Produto salvo',
      productBrand: 'Marca',
      scannedAt: DateTime.now(),
    );
    HistoryItem? openedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          itemsLoader: () async => [item],
          onOpenProduct: (value) => openedItem = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Produto salvo'));
    await tester.pump();

    expect(openedItem, same(item));
    expect(openedItem?.productId, '7891000100103');
  });
}
