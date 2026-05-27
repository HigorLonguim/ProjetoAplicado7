import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'nutrition_details_screen.dart';

class ProductResultScreen extends StatelessWidget {
  final ProductModel product;

  const ProductResultScreen({super.key, required this.product});

  String _getBadge(double value, String type) {
    if (type == 'sugar') {
      if (value > 15) return 'ALTO';
      if (value > 5) return 'MÉDIO';
      return 'BAIXO';
    }
    if (type == 'sodium') {
      if (value > 0.6) return 'ALTO'; // 600mg
      if (value > 0.3) return 'MÉDIO';
      return 'BAIXO';
    }
    if (type == 'fat') {
      if (value > 20) return 'ALTO';
      if (value > 3) return 'MÉDIO';
      return 'BAIXO';
    }
    return 'MÉDIO';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Resultado do produto'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            size: 44,
                          ),
                        ),
                      )
                    : const Icon(Icons.image_outlined, size: 44),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionHeader(
              title: 'Resumo nutricional',
              subtitle: '(por 100g)',
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _NutritionCard(
                  value: product.calories.toStringAsFixed(0),
                  unit: 'kcal',
                  label: 'Calorias',
                  badge: product.calories > 400 ? 'ALTO' : 'NORMAL',
                ),
                _NutritionCard(
                  value: '${product.sugar.toStringAsFixed(1)}g',
                  unit: 'Açúcar',
                  label: 'Açúcar',
                  badge: _getBadge(product.sugar, 'sugar'),
                ),
                _NutritionCard(
                  value: '${(product.sodium * 1000).toStringAsFixed(0)}mg',
                  unit: 'Sódio',
                  label: 'Sódio',
                  badge: _getBadge(product.sodium, 'sodium'),
                ),
                _NutritionCard(
                  value: '${product.fat.toStringAsFixed(1)}g',
                  unit: 'Gorduras',
                  label: 'Gorduras',
                  badge: _getBadge(product.fat, 'fat'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NutritionDetailsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.expand_more),
              label: const Text('Ver informações completas'),
            ),
            const SizedBox(height: 8),
            if (product.sugar > 15 || product.sodium > 0.6)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_outlined,
                        color: colorScheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Atenção: Este produto possui altos níveis de nutrientes que devem ser consumidos com moderação.',
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
        children: [
          TextSpan(text: title),
          TextSpan(
            text: ' $subtitle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.badge,
  });

  final String value;
  final String unit;
  final String label;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
