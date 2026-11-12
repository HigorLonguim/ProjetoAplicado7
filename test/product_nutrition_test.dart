import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/product_model.dart';
import 'package:origem/screens/nutrition_details_screen.dart';
import 'package:origem/screens/product_result_screen.dart';

void main() {
  group('mapeamento nutricional da Open Food Facts', () {
    test('lê sódio em gramas e preserva o sal informado', () {
      final product = ProductModel.fromOpenFoodFacts('12345678', {
        'product': {
          'product_name': 'Produto',
          'brands': 'Marca',
          'nutriments': {'sodium_100g': 0.48, 'salt_100g': 1.2},
        },
      });

      expect(product.sodium, 0.48);
      expect(product.salt, 1.2);
    });

    test('converte sal em sódio com o fator usado pela OFF', () {
      final product = ProductModel.fromOpenFoodFacts('12345678', {
        'product': {
          'nutriments': {'salt_100g': 1.25},
        },
      });

      expect(product.sodium, 0.5);
      expect(product.salt, 1.25);
    });

    test('converte sódio em sal e não transforma ausência em zero', () {
      final withSodium = ProductModel.fromOpenFoodFacts('12345678', {
        'product': {
          'nutriments': {'sodium_100g': 0.2},
        },
      });
      final withoutEither = ProductModel.fromOpenFoodFacts('87654321', {
        'product': {'nutriments': <String, dynamic>{}},
      });

      expect(withSodium.salt, 0.5);
      expect(withoutEither.sodium, isNull);
      expect(withoutEither.salt, isNull);
    });
  });

  testWidgets('resumo e detalhes exibem o mesmo sódio e classificação', (
    tester,
  ) async {
    final product = ProductModel.fromOpenFoodFacts('12345678', {
      'product': {
        'product_name': 'Produto de teste',
        'brands': 'Marca',
        'nutriments': {'salt_100g': 1.25},
        'nutrient_levels': {'salt': 'high'},
      },
    });

    await tester.pumpWidget(
      MaterialApp(home: ProductResultScreen(product: product)),
    );
    await tester.pump();
    expect(find.text('500 mg'), findsOneWidget);
    expect(find.text('ALTO'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: NutritionDetailsScreen(product: product)),
    );
    expect(find.text('500 mg'), findsOneWidget);
    expect(find.text('ALTO'), findsOneWidget);
  });

  testWidgets('nutriente ausente aparece sem valor e sem classificação', (
    tester,
  ) async {
    const product = ProductModel(
      barcode: '12345678',
      name: 'Produto sem dados',
      brand: 'Marca',
      nutrientLevels: {'salt': 'high'},
    );

    await tester.pumpWidget(
      const MaterialApp(home: NutritionDetailsScreen(product: product)),
    );
    expect(find.text('Não informado'), findsWidgets);
    expect(find.text('ALTO'), findsNothing);
  });
}
