import 'package:flutter/material.dart';
import '../models/product_model.dart';

class NutritionDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const NutritionDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dados nutricionais por 100g
    final nutritionData = [
      ('Energia', '${product.calories.toStringAsFixed(0)} kcal', ''),
      ('Açúcares totais', '${product.sugar.toStringAsFixed(1)}g', _getNutrientStatus('sugars', product.sugar > 10, product.sugar > 5)),
      ('Carboidratos', '${product.carbohydrates.toStringAsFixed(1)}g', ''),
      ('Fibra', '${product.fiber.toStringAsFixed(1)}g', product.fiber > 3 ? 'BOM' : ''),
      ('Proteínas', '${product.protein.toStringAsFixed(1)}g', product.protein > 10 ? 'ALTO' : (product.protein > 5 ? 'BOM' : 'MÉDIO')),
      ('Gorduras totais', '${product.fat.toStringAsFixed(1)}g', _getNutrientStatus('fat', product.fat > 20, product.fat > 5)),
      ('Gordura saturada', '${product.saturatedFat.toStringAsFixed(1)}g', _getNutrientStatus('saturated-fat', product.saturatedFat > 5, product.saturatedFat > 1.5)),
      ('Sódio', '${(product.sodium * 1000).toStringAsFixed(0)}mg', _getNutrientStatus('salt', product.sodium > 0.8, product.sodium > 0.6)),
      if (product.caffeine > 0) ('Cafeína', '${product.caffeine.toStringAsFixed(1)}mg', product.caffeine > 100 ? 'ALTO' : ''),
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case 'CRÍTICO':
          return const Color(0xFFD32F2F);
        case 'ALTO':
          return const Color(0xFFF57C00);
        case 'BOM':
          return const Color(0xFF558B2F);
        default:
          return const Color(0xFF666666);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Informações completas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Informações Nutricionais',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Valores por 100g',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                for (int i = 0; i < nutritionData.length; i++)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                nutritionData[i].$1,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              nutritionData[i].$2,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 12),
                            if (nutritionData[i].$3.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(nutritionData[i].$3)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: getStatusColor(nutritionData[i].$3)
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  nutritionData[i].$3,
                                  style: TextStyle(
                                    color: getStatusColor(nutritionData[i].$3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (i < nutritionData.length - 1)
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sobre a Classificação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          // Indicação de origem da classificação
          if (product.nutriscoreGrade != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Classificação Nutri-Score (Open Food Facts)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Classificação calculada localmente (cálculo customizado)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nutriscoreGrade != null 
                      ? 'Nutri-Score (Open Food Facts):'
                      : 'Algoritmo local de classificação:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _ClassificationPoint(
                  icon: Icons.water_drop_outlined,
                  label: 'Açúcar',
                  description: product.nutriscoreGrade != null 
                      ? 'Considera ingestão diária' 
                      : 'Crítico acima de 15g/100g',
                ),
                const SizedBox(height: 8),
                _ClassificationPoint(
                  icon: Icons.grain_outlined,
                  label: 'Sódio',
                  description: product.nutriscoreGrade != null 
                      ? 'Considera ingestão diária' 
                      : 'Crítico acima de 800mg/100g',
                ),
                const SizedBox(height: 8),
                _ClassificationPoint(
                  icon: Icons.water_drop_outlined,
                  label: 'Gordura',
                  description: product.nutriscoreGrade != null 
                      ? 'Inclui gordura saturada' 
                      : 'Crítica acima de 20g/100g',
                ),
                const SizedBox(height: 8),
                _ClassificationPoint(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Calorias',
                  description: product.nutriscoreGrade != null 
                      ? 'Valor energético total' 
                      : 'Alta acima de 400 kcal/100g',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Helper para obter status de nutriente usando nutrient_levels da API ou fallback
  String _getNutrientStatus(String nutrientKey, bool isCritical, bool isHigh) {
    if (product.nutrientLevels != null && product.nutrientLevels!.containsKey(nutrientKey)) {
      final level = product.nutrientLevels![nutrientKey]?.toLowerCase() ?? '';
      switch (level) {
        case 'high':
          return 'ALTO';
        case 'low':
          return 'BAIXO';
        case 'moderate':
          return 'MODERADO';
        default:
          return '';
      }
    }
    // Fallback para lógica local
    if (isCritical) return 'CRÍTICO';
    if (isHigh) return 'ALTO';
    return '';
  }
}

class _ClassificationPoint extends StatelessWidget {
  const _ClassificationPoint({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}