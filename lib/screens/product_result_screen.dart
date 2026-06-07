import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/product.dart';
import 'nutrition_details_screen.dart';

class ProductResultScreen extends StatefulWidget {
  final ProductModel product;

  const ProductResultScreen({super.key, required this.product});

  @override
  State<ProductResultScreen> createState() => _ProductResultScreenState();
}

class _ProductResultScreenState extends State<ProductResultScreen> {
  late Product _classificationProduct;

  @override
  void initState() {
    super.initState();
    // Criar um Product temporário apenas para calcular a classificação
    _classificationProduct = Product(
      id: 'temp',
      barcode: 'temp',
      name: widget.product.name,
      brand: widget.product.brand,
      imageUrl: widget.product.imageUrl,
      calories: widget.product.calories,
      sugar: widget.product.sugar,
      sodium: widget.product.sodium,
      fat: widget.product.fat,
      protein: widget.product.protein,
      portion: 100,
    );
  }

  String _getClassificationDescription(String label) {
    const descriptions = {
      'A': 'Excelente',
      'B': 'Muito Bom',
      'C': 'Bom',
      'D': 'Regular',
      'E': 'Pobre',
      'F': 'Muito Pobre',
    };
    return descriptions[label] ?? 'Desconhecido';
  }

  String _getNutrientBadge(double value, String type) {
    if (type == 'sugar') {
      if (value > 15) return 'CRÍTICO';
      if (value > 10) return 'ALTO';
      if (value > 5) return 'MÉDIO';
      return 'BAIXO';
    }
    if (type == 'sodium') {
      if (value > 0.8) return 'CRÍTICO';
      if (value > 0.6) return 'ALTO';
      if (value > 0.3) return 'MÉDIO';
      return 'BAIXO';
    }
    if (type == 'fat') {
      if (value > 20) return 'CRÍTICO';
      if (value > 5) return 'ALTO';
      if (value > 3) return 'MÉDIO';
      return 'BAIXO';
    }
    if (type == 'protein') {
      if (value > 10) return 'ALTO';
      if (value > 5) return 'BOM';
      if (value > 2) return 'MÉDIO';
      return 'BAIXO';
    }
    return 'NORMAL';
  }

  Color _getBadgeColor(String badge) {
    switch (badge) {
      case 'CRÍTICO':
        return const Color(0xFFD32F2F); // Vermelho
      case 'ALTO':
        return const Color(0xFFF57C00); // Laranja escuro
      case 'MÉDIO':
        return const Color(0xFFF9A825); // Laranja
      case 'BOM':
        return const Color(0xFF558B2F); // Verde claro
      case 'BAIXO':
        return const Color(0xFF2E7D32); // Verde escuro
      default:
        return const Color(0xFF666666); // Cinza
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final classification = _classificationProduct.getClassification();
    final classificationColor = _classificationProduct.getClassificationColor();

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
            // Imagem do Produto
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: widget.product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          widget.product.imageUrl!,
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

            // Informações do Produto
            Center(
              child: Column(
                children: [
                  Text(
                    widget.product.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.brand,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Classificação Nutricional (Destaque)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    classificationColor.withValues(alpha: 0.9),
                    classificationColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: classificationColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Classificação Nutricional',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        classification.label,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getClassificationDescription(classification.label),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Resumo Nutricional
            const _SectionHeader(
              title: 'Resumo nutricional',
              subtitle: '(por 100g)',
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _NutritionCard(
                  value: widget.product.calories.toStringAsFixed(0),
                  unit: 'kcal',
                  label: 'Calorias',
                  badge: _getNutrientBadge(widget.product.calories, 'calories'),
                  badgeColor: _getBadgeColor(
                    _getNutrientBadge(widget.product.calories, 'calories'),
                  ),
                ),
                _NutritionCard(
                  value: '${widget.product.sugar.toStringAsFixed(1)}g',
                  unit: 'Açúcar',
                  label: 'Açúcar',
                  badge: _getNutrientBadge(widget.product.sugar, 'sugar'),
                  badgeColor: _getBadgeColor(
                    _getNutrientBadge(widget.product.sugar, 'sugar'),
                  ),
                ),
                _NutritionCard(
                  value: '${(widget.product.sodium * 1000).toStringAsFixed(0)}mg',
                  unit: 'Sódio',
                  label: 'Sódio',
                  badge: _getNutrientBadge(widget.product.sodium, 'sodium'),
                  badgeColor: _getBadgeColor(
                    _getNutrientBadge(widget.product.sodium, 'sodium'),
                  ),
                ),
                _NutritionCard(
                  value: '${widget.product.fat.toStringAsFixed(1)}g',
                  unit: 'Gordura',
                  label: 'Gordura',
                  badge: _getNutrientBadge(widget.product.fat, 'fat'),
                  badgeColor: _getBadgeColor(
                    _getNutrientBadge(widget.product.fat, 'fat'),
                  ),
                ),
                _NutritionCard(
                  value: '${widget.product.protein.toStringAsFixed(1)}g',
                  unit: 'Proteína',
                  label: 'Proteína',
                  badge: _getNutrientBadge(widget.product.protein, 'protein'),
                  badgeColor: _getBadgeColor(
                    _getNutrientBadge(widget.product.protein, 'protein'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botão para informações completas
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NutritionDetailsScreen(product: widget.product),
                  ),
                );
              },
              icon: const Icon(Icons.expand_more),
              label: const Text('Ver informações completas'),
            ),
            const SizedBox(height: 12),

            // Aviso se houver nutrientes críticos
            if (widget.product.sugar > 15 ||
                widget.product.sodium > 0.8 ||
                widget.product.fat > 20)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este produto possui altos níveis de nutrientes críticos. Consuma com moderação.',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
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
    required this.badgeColor,
  });

  final String value;
  final String unit;
  final String label;
  final String badge;
  final Color badgeColor;

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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
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
