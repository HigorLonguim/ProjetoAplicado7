import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

class NutritionDetailsScreen extends StatelessWidget {
  const NutritionDetailsScreen({super.key, required this.product});
  final ProductModel product;

  String _grams(double? value) =>
      value == null ? 'Não informado' : '${value.toStringAsFixed(1)} g';
  String _status(String key, double? value) {
    if (value == null) return '';
    return switch (product.nutrientLevel(key)) {
      'high' => 'ALTO',
      'moderate' => 'MODERADO',
      'low' => 'BAIXO',
      _ => '',
    };
  }

  Color _color(String status) => switch (status) {
    'ALTO' => const Color(0xFFC8443E),
    'MODERADO' => AppColors.terracotta,
    'BAIXO' => AppColors.olive,
    _ => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, String)>[
      (
        'Energia',
        product.calories == null
            ? 'Não informado'
            : '${product.calories!.toStringAsFixed(0)} kcal',
        '',
      ),
      ('Carboidratos', _grams(product.carbohydrates), ''),
      (
        'Açúcares totais',
        _grams(product.sugar),
        _status('sugars', product.sugar),
      ),
      ('Proteínas', _grams(product.protein), ''),
      ('Gorduras totais', _grams(product.fat), _status('fat', product.fat)),
      (
        'Gordura saturada',
        _grams(product.saturatedFat),
        _status('saturated-fat', product.saturatedFat),
      ),
      ('Fibra alimentar', _grams(product.fiber), ''),
      (
        'Sódio',
        product.sodium == null
            ? 'Não informado'
            : '${(product.sodium! * 1000).toStringAsFixed(0)} mg',
        _status('salt', product.sodium),
      ),
      if (product.caffeine != null)
        ('Cafeína', '${product.caffeine!.toStringAsFixed(1)} g', ''),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Informações nutricionais')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(
            'Valores por 100 g ou 100 ml, conforme as informações disponíveis para o produto.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: rows.indexed.map((entry) {
                final index = entry.$1;
                final row = entry.$2;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(row.$1)),
                          Text(
                            row.$2,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (row.$3.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _color(row.$3).withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                row.$3,
                                style: TextStyle(
                                  color: _color(row.$3),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (index < rows.length - 1) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        product.nutritionScore == null
                            ? Icons.info_outline_rounded
                            : Icons.recommend_outlined,
                        color: AppColors.olive,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Como interpretar a nota',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.nutritionScore == null
                        ? 'Não há informação suficiente para atribuir uma nota. Analise os nutrientes e confira a embalagem.'
                        : '${product.nutritionScore}/10 — ${product.nutritionScoreLabel}\n${product.nutritionScoreGuidance}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '“Açúcares totais” não é o mesmo que “açúcares adicionados”. Os alertas regulatórios brasileiros dependem do tipo de nutriente, da categoria e da base de comparação. Confira sempre a embalagem.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
