import 'package:flutter/material.dart';

class NutritionDetailsScreen extends StatelessWidget {
  const NutritionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final rows = [
      ('Valor energético', '120 kcal', '6%'),
      ('Carboidratos', '15 g', '5%'),
      ('Açúcares totais', '10 g', '10%'),
      ('Açúcares adicionados', '10 g', 'ALTO'),
      ('Proteínas', '2 g', '4%'),
      ('Gorduras totais', '5 g', '8%'),
      ('Gorduras saturadas', '1.5 g', '8%'),
      ('Fibra alimentar', '0 g', '0%'),
      ('Sódio', '300 mg', '13%'),
    ];

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
            'Porção de 30 g (1 unidade)',
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
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(child: Text(row.$1)),
                        Text(
                          row.$2,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(row.$3),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    '* Valores Diários de referência com base em uma dieta de 2.000 kcal.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}