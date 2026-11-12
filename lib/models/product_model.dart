class ProductModel {
  const ProductModel({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    this.calories,
    this.sugar,
    this.salt,
    this.sodium,
    this.fat,
    this.protein,
    this.carbohydrates,
    this.fiber,
    this.saturatedFat,
    this.caffeine,
    this.nutriscoreGrade,
    this.nutrientLevels,
    this.ecoScore,
    this.novaGroup,
  });

  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final double? calories;
  final double? sugar;
  /// Sal em gramas por 100 g/100 ml, na unidade normalizada da OFF.
  final double? salt;
  /// Sódio em gramas por 100 g/100 ml, na unidade normalizada da OFF.
  final double? sodium;
  final double? fat;
  final double? protein;
  final double? carbohydrates;
  final double? fiber;
  final double? saturatedFat;
  final double? caffeine;
  final String? nutriscoreGrade;
  final Map<String, String>? nutrientLevels;
  final String? ecoScore;
  final int? novaGroup;

  bool get hasNutritionData => [calories, sugar, sodium, fat, protein].any((value) => value != null);

  String? get validNutriscore {
    final grade = nutriscoreGrade?.toLowerCase();
    return const {'a', 'b', 'c', 'd', 'e'}.contains(grade) ? grade : null;
  }

  String? nutrientLevel(String key) => nutrientLevels?[key]?.toLowerCase();

  factory ProductModel.fromOpenFoodFacts(String barcode, Map<String, dynamic> json) {
    final product = json['product'] is Map ? Map<String, dynamic>.from(json['product']) : <String, dynamic>{};
    final nutrients = product['nutriments'] is Map ? Map<String, dynamic>.from(product['nutriments']) : <String, dynamic>{};

    double? number(String key) {
      final value = nutrients[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    String text(dynamic value, String fallback) {
      final result = value?.toString().trim() ?? '';
      return result.isEmpty ? fallback : result;
    }

    final energyKcal = number('energy-kcal_100g');
    final energyKj = number('energy-kj_100g');
    final sodiumFromApi = number('sodium_100g');
    final saltFromApi = number('salt_100g');
    // Os campos *_100g da Open Food Facts usam gramas para nutrientes por
    // peso. Quando apenas um dos dois existe, a própria OFF adota
    // sódio = sal / 2,5.
    final sodium = sodiumFromApi ??
        (saltFromApi == null ? null : saltFromApi / 2.5);
    final salt = saltFromApi ??
        (sodiumFromApi == null ? null : sodiumFromApi * 2.5);
    final levels = product['nutrient_levels'] is Map
        ? Map<String, String>.from((product['nutrient_levels'] as Map).map((key, value) => MapEntry(key.toString(), value.toString())))
        : null;
    final novaValue = product['nova_group'];

    return ProductModel(
      barcode: barcode,
      name: text(product['product_name_pt'] ?? product['product_name'], 'Produto sem nome informado'),
      brand: text(product['brands'], 'Marca não informada'),
      imageUrl: product['image_front_url']?.toString() ?? product['image_url']?.toString(),
      calories: energyKcal ?? (energyKj == null ? null : energyKj / 4.184),
      sugar: number('sugars_100g'),
      salt: salt,
      sodium: sodium,
      fat: number('fat_100g'),
      protein: number('proteins_100g'),
      carbohydrates: number('carbohydrates_100g'),
      fiber: number('fiber_100g'),
      saturatedFat: number('saturated-fat_100g'),
      caffeine: number('caffeine_100g') ?? number('caffeine_100ml'),
      nutriscoreGrade: product['nutriscore_grade']?.toString(),
      nutrientLevels: levels,
      ecoScore: product['ecoscore_grade']?.toString(),
      novaGroup: novaValue is num ? novaValue.toInt() : int.tryParse(novaValue?.toString() ?? ''),
    );
  }
}
