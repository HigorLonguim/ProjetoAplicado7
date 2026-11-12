import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/screens/shopping_list_screen.dart';
import 'package:origem/services/shopping_list_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('mantém ordem alfabética ao marcar um item como comprado', () async {
    SharedPreferences.setMockInitialValues({});
    final service = ShoppingListService();
    await service.initialize();
    service.clearList();

    for (final name in ['Tomate', 'Cebola', 'arroz', 'Água']) {
      service.addItem(
        productName: name,
        productBrand: '',
        quantity: 1,
        unit: 'un',
      );
    }

    final before = service.getItemsSorted();
    expect(before.map((item) => item.productName), [
      'Água',
      'arroz',
      'Cebola',
      'Tomate',
    ]);

    service.toggleItem(
      before.singleWhere((item) => item.productName == 'Cebola').id,
    );
    final after = service.getItemsSorted();

    expect(after.map((item) => item.productName), [
      'Água',
      'arroz',
      'Cebola',
      'Tomate',
    ]);
    expect(
      after.singleWhere((item) => item.productName == 'Cebola').checked,
      isTrue,
    );
  });

  testWidgets('exibe ações de limpeza e pede confirmação', (tester) async {
    final service = ShoppingListService();
    service.clearList();
    service.addItem(
      productName: 'Arroz',
      productBrand: '',
      quantity: 1,
      unit: 'kg',
    );
    service.addItem(
      productName: 'Tomate',
      productBrand: '',
      quantity: 2,
      unit: 'un',
    );
    service.toggleItem(service.getItemsSorted().first.id);

    await tester.pumpWidget(const MaterialApp(home: ShoppingListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Remover comprados (1)'), findsOneWidget);
    expect(find.text('Limpar lista'), findsOneWidget);

    await tester.tap(find.text('Limpar lista'));
    await tester.pumpAndSettle();

    expect(find.text('Limpar toda a lista?'), findsOneWidget);
    expect(
      find.textContaining('inclusive os que ainda estão pendentes'),
      findsOneWidget,
    );
    expect(find.text('Cancelar'), findsOneWidget);
  });
}
