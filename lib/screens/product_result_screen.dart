import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/favorites_service.dart';
import '../services/shopping_list_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'nutrition_details_screen.dart';

class ProductResultScreen extends StatefulWidget {
  const ProductResultScreen({super.key, required this.product, this.heroTag});
  final ProductModel product;
  final String? heroTag;
  @override
  State<ProductResultScreen> createState() => _ProductResultScreenState();
}

class _ProductResultScreenState extends State<ProductResultScreen> {
  bool _favorite = false;
  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final value = await FavoritesService().contains(widget.product.barcode);
    if (mounted) setState(() => _favorite = value);
  }

  Future<void> _toggleFavorite() async {
    final value = await FavoritesService().toggle(widget.product.barcode);
    if (!mounted) return;
    setState(() => _favorite = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Produto salvo nos favoritos.'
              : 'Produto removido dos favoritos.',
        ),
      ),
    );
  }

  Future<void> _addToList() async {
    await ShoppingListService().initialize();
    ShoppingListService().addItem(
      productName: widget.product.name,
      productBrand: widget.product.brand,
      quantity: 1,
      unit: 'un',
      productId: widget.product.barcode,
      productImage: widget.product.imageUrl,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto adicionado à lista.')),
      );
    }
  }

  Color _gradeColor(String grade) => switch (grade) {
    'a' => const Color(0xFF2E7D32),
    'b' => const Color(0xFF619C3B),
    'c' => const Color(0xFFF2B134),
    'd' => const Color(0xFFE67E36),
    _ => const Color(0xFFC8443E),
  };

  String _statusFor(String key, double? value) {
    // Não mostre uma classificação sem o valor que ela descreve. Isso
    // evita, por exemplo, "ALTO" ao lado de um nutriente não informado.
    if (value == null) return 'SEM DADO';
    final apiLevel = widget.product.nutrientLevel(key);
    if (apiLevel == 'high') return 'ALTO';
    if (apiLevel == 'moderate') return 'MODERADO';
    if (apiLevel == 'low') return 'BAIXO';
    return 'INFORMADO';
  }

  Color _statusColor(String status) => switch (status) {
    'ALTO' => const Color(0xFFC8443E),
    'MODERADO' => const Color(0xFFD98255),
    'BAIXO' => AppColors.olive,
    _ => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final grade = product.validNutriscore;
    final hasHigh = [
      'sugars',
      'salt',
      'fat',
      'saturated-fat',
    ].any((key) => product.nutrientLevel(key) == 'high');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        actions: [
          IconButton(
            tooltip: _favorite
                ? 'Remover dos favoritos'
                : 'Salvar nos favoritos',
            onPressed: _toggleFavorite,
            icon: Icon(
              _favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _favorite ? AppColors.terracotta : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: HeroMode(
              enabled: widget.heroTag != null,
              child: Hero(
                tag: widget.heroTag ?? 'product-result-static',
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.imageUrl == null
                      ? const Icon(
                          Icons.inventory_2_outlined,
                          size: 54,
                          color: AppColors.olive,
                        )
                      : Image.network(
                          product.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.inventory_2_outlined, size: 54),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            product.brand,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          if (grade != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _gradeColor(grade),
                    _gradeColor(grade).withValues(alpha: .78),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      grade.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutri-Score',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Classificação informada pela Open Food Facts',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.olive,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Este produto não possui Nutri-Score disponível. Os dados abaixo são exibidos sem atribuir uma nota.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Resumo por 100 g',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NutritionDetailsScreen(product: product),
                  ),
                ),
                child: const Text('Ver detalhes'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 650 ? 4 : 2,
            childAspectRatio: 1.28,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _NutritionCard(
                label: 'Energia',
                value: product.calories == null
                    ? '—'
                    : '${product.calories!.toStringAsFixed(0)} kcal',
                status: product.calories == null ? 'SEM DADO' : 'INFORMADO',
                color: _statusColor(
                  product.calories == null ? 'SEM DADO' : 'INFORMADO',
                ),
              ),
              _NutritionCard(
                label: 'Açúcares totais',
                value: product.sugar == null
                    ? '—'
                    : '${product.sugar!.toStringAsFixed(1)} g',
                status: _statusFor('sugars', product.sugar),
                color: _statusColor(_statusFor('sugars', product.sugar)),
              ),
              _NutritionCard(
                label: 'Sódio',
                value: product.sodium == null
                    ? '—'
                    : '${(product.sodium! * 1000).toStringAsFixed(0)} mg',
                status: _statusFor('salt', product.sodium),
                color: _statusColor(_statusFor('salt', product.sodium)),
              ),
              _NutritionCard(
                label: 'Gordura saturada',
                value: product.saturatedFat == null
                    ? '—'
                    : '${product.saturatedFat!.toStringAsFixed(1)} g',
                status: _statusFor('saturated-fat', product.saturatedFat),
                color: _statusColor(
                  _statusFor('saturated-fat', product.saturatedFat),
                ),
              ),
            ],
          ),
          if (!product.hasNutritionData) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.terracotta,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'A base consultada não possui dados nutricionais suficientes para este produto.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (hasHigh) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFC8443E).withValues(alpha: .18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFC8443E).withValues(alpha: .5),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded, color: Color(0xFFFF9A8B)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A base consultada indica nível alto em um ou mais nutrientes. Confira os detalhes do rótulo.',
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          GradientButton(
            label: 'Adicionar à lista',
            icon: Icons.add_shopping_cart_rounded,
            onPressed: _addToList,
          ),
          const SizedBox(height: 12),
          Text(
            'Dados colaborativos fornecidos pela Open Food Facts. Confirme as informações na embalagem.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });
  final String label, value, status;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            maxLines: 2,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
