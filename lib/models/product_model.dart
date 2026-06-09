class ProductModel {
  final String name;
  final String brand;
  final String? imageUrl;
  final double calories;
  final double sugar;
  final double sodium;
  final double fat;
  final double protein;
  // Campos nutricionais adicionais (por 100g)
  final double carbohydrates;
  final double fiber;
  final double saturatedFat;
  final double caffeine;
  // Classificações fornecidas pela API
  final String? nutriscoreGrade; // 'a', 'b', 'c', 'd', 'e'
  final Map<String, String>? nutrientLevels; // ex: {'salt': 'low', 'sugars': 'high'}
  final String? ecoScore; // ecoscore_grade
  final int? novaGroup; // 1, 2, 3, 4

  ProductModel({
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.calories,
    required this.sugar,
    required this.sodium,
    required this.fat,
    required this.protein,
    this.carbohydrates = 0.0,
    this.fiber = 0.0,
    this.saturatedFat = 0.0,
    this.caffeine = 0.0,
    this.nutriscoreGrade,
    this.nutrientLevels,
    this.ecoScore,
    this.novaGroup,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final nutriments = product['nutriments'] ?? {};
    
    // Energia: usar kcal se disponível, senão converter kJ para kcal
    double caloriesVal = 0.0;
    if (nutriments.containsKey('energy-kcal_100g')) {
      caloriesVal = (nutriments['energy-kcal_100g'] ?? 0.0).toDouble();
    } else if (nutriments.containsKey('energy-kj_100g')) {
      final kj = (nutriments['energy-kj_100g'] ?? 0.0).toDouble();
      caloriesVal = kj / 4.184; // conversão: 1 kcal = 4.184 kJ
    }
    
    // Sódio: tentar sodium_100g antes de salt_100g
    double sodiumVal = 0.0;
    if (nutriments.containsKey('sodium_100g')) {
      sodiumVal = (nutriments['sodium_100g'] ?? 0.0).toDouble();
    } else if (nutriments.containsKey('salt_100g')) {
      final salt = (nutriments['salt_100g'] ?? 0.0).toDouble();
      sodiumVal = salt * 0.393; // conversão: ~39.3% do sal é sódio
    }
    
    // Cafeína: buscar por 100g ou 100ml
    double caffeineVal = 0.0;
    if (nutriments.containsKey('caffeine_100g')) {
      caffeineVal = (nutriments['caffeine_100g'] ?? 0.0).toDouble();
    } else if (nutriments.containsKey('caffeine_100ml')) {
      caffeineVal = (nutriments['caffeine_100ml'] ?? 0.0).toDouble();
    }
    
    // Extrair nutrient_levels da API (ex: {'salt': 'low', 'sugars': 'high', ...})
    Map<String, String>? nutrientLevelsMap;
    if (product.containsKey('nutrient_levels') && product['nutrient_levels'] is Map) {
      nutrientLevelsMap = Map<String, String>.from(product['nutrient_levels']);
    }

    return ProductModel(
      name: product['product_name'] ?? 'Produto desconhecido',
      brand: product['brands'] ?? 'Marca desconhecida',
      imageUrl: product['image_url'],
      calories: caloriesVal,
      sugar: (nutriments['sugars_100g'] ?? 0.0).toDouble(),
      sodium: sodiumVal,
      fat: (nutriments['fat_100g'] ?? 0.0).toDouble(),
      protein: (nutriments['proteins_100g'] ?? 0.0).toDouble(),
      carbohydrates: (nutriments['carbohydrates_100g'] ?? 0.0).toDouble(),
      fiber: (nutriments['fiber_100g'] ?? 0.0).toDouble(),
      saturatedFat: (nutriments['saturated-fat_100g'] ?? 0.0).toDouble(),
      caffeine: caffeineVal,
      nutriscoreGrade: product['nutriscore_grade'] as String?,
      nutrientLevels: nutrientLevelsMap,
      ecoScore: product['ecoscore_grade'] as String?,
      novaGroup: product['nova_group'] as int?,
    );
  }
}
