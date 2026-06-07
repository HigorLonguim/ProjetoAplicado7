class ProductModel {
  final String name;
  final String brand;
  final String? imageUrl;
  final double calories;
  final double sugar;
  final double sodium;
  final double fat;
  final double protein;

  ProductModel({
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.calories,
    required this.sugar,
    required this.sodium,
    required this.fat,
    required this.protein,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final nutriments = product['nutriments'] ?? {};

    return ProductModel(
      name: product['product_name'] ?? 'Produto desconhecido',
      brand: product['brands'] ?? 'Marca desconhecida',
      imageUrl: product['image_url'],
      calories: (nutriments['energy-kcal_100g'] ?? 0.0).toDouble(),
      sugar: (nutriments['sugars_100g'] ?? 0.0).toDouble(),
      sodium: (nutriments['sodium_100g'] ?? 0.0).toDouble(),
      fat: (nutriments['fat_100g'] ?? 0.0).toDouble(),
      protein: (nutriments['proteins_100g'] ?? 0.0).toDouble(),
    );
  }
}
