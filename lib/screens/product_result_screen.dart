import 'package:flutter/material.dart';

import 'nutrition_details_screen.dart';

class ProductResultScreen extends StatelessWidget {
  const ProductResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Resultado do produto'),
        actions: const [IconButton(onPressed: null, icon: Icon(Icons.favorite_border))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(Icons.image_outlined, size: 44, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  Text(
                    'Nome do Produto',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Marca',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'Resumo nutricional',
              subtitle: '(por porção)',
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _NutritionCard(value: '120', unit: 'kcal', label: 'Calorias', badge: 'ALTO'),
                _NutritionCard(value: '10g', unit: 'Açúcar', label: 'Açúcar', badge: 'ALTO'),
                _NutritionCard(value: '300mg', unit: 'Sódio', label: 'Sódio', badge: 'MÉDIO'),
                _NutritionCard(value: '5g', unit: 'Gorduras', label: 'Gorduras', badge: 'BAIXO'),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_outlined, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Alto em açúcar. Este produto possui alta quantidade de açúcar por porção.',
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
            child: Chip(
              label: Text(badge),
              labelStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.18)),
              backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(unit),
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