class MealRecommendation {
  const MealRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedCost,
    required this.minutes,
    required this.servings,
    required this.tags,
    required this.ingredients,
    required this.steps,
    this.portionGrams = 400,
    this.calories = 480,
    this.proteinGrams = 24,
    this.carbGrams = 55,
    this.fatGrams = 16,
    this.healthScore = 8,
  });
  final String id;
  final String title;
  final String description;
  final double estimatedCost;
  final int minutes;
  final int servings;
  final Set<String> tags;
  final List<String> ingredients;
  final List<String> steps;
  final int portionGrams;
  final int calories;
  final int proteinGrams;
  final int carbGrams;
  final int fatGrams;
  final int healthScore;

  factory MealRecommendation.fromJson(Map<String, dynamic> json) {
    int integer(String key) {
      final value = json[key];
      if (value is num) return value.toInt();
      throw FormatException('Campo numérico inválido: $key');
    }

    double decimal(String key) {
      final value = json[key];
      if (value is num) return value.toDouble();
      throw FormatException('Campo numérico inválido: $key');
    }

    List<String> strings(String key) {
      final value = json[key];
      if (value is! List) throw FormatException('Lista inválida: $key');
      return value.map((item) => item.toString()).toList(growable: false);
    }

    return MealRecommendation(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      estimatedCost: decimal('estimatedCost'),
      minutes: integer('minutes'),
      servings: integer('servings'),
      tags: strings('tags').toSet(),
      ingredients: strings('ingredients'),
      steps: strings('steps'),
      portionGrams: integer('portionGrams'),
      calories: integer('calories'),
      proteinGrams: integer('proteinGrams'),
      carbGrams: integer('carbGrams'),
      fatGrams: integer('fatGrams'),
      healthScore: integer('healthScore'),
    );
  }

  static const mealTags = {'Café da manhã', 'Almoço', 'Jantar', 'Lanches'};
  static const styleTags = {
    'Rápido e fácil',
    'Uma só panela',
    'Cozinhar em lote',
    'Pratos da família',
    'Comida caseira',
    'Fresco e leve',
    'Mais fibras',
    'Vegetariana',
  };

  Set<String> get mealTypes => tags.intersection(mealTags);
  Set<String> get styles => tags.intersection(styleTags);
  Set<String> get requiredEquipment => _valuesWithPrefix('Equipamento:');
  Set<String> get allergens => _valuesWithPrefix('Contém:');
  Set<String> get pantryMatches => _valuesWithPrefix('Aproveita:');

  Set<String> _valuesWithPrefix(String prefix) => tags
      .where((tag) => tag.startsWith(prefix))
      .map((tag) => tag.substring(prefix.length))
      .toSet();

  double costForServings(int requestedServings) {
    if (requestedServings <= 0 || servings <= 0) return estimatedCost;
    return estimatedCost * requestedServings / servings;
  }

  List<String> ingredientsForServings(int requestedServings) {
    if (requestedServings <= 0 || requestedServings == servings) {
      return ingredients;
    }
    final factor = requestedServings / servings;
    return ingredients
        .map((ingredient) => _scaleLeadingQuantity(ingredient, factor))
        .toList(growable: false);
  }

  static String _scaleLeadingQuantity(String text, double factor) {
    final mixed = RegExp(r'^(\d+)\s+e\s+(\d+)\/(\d+)');
    final fraction = RegExp(r'^(\d+)\/(\d+)');
    final decimal = RegExp(r'^(\d+(?:[\.,]\d+)?)');

    final mixedMatch = mixed.firstMatch(text);
    if (mixedMatch != null) {
      final value =
          double.parse(mixedMatch.group(1)!) +
          double.parse(mixedMatch.group(2)!) /
              double.parse(mixedMatch.group(3)!);
      return text.replaceRange(
        0,
        mixedMatch.end,
        _formatQuantity(value * factor),
      );
    }

    final fractionMatch = fraction.firstMatch(text);
    if (fractionMatch != null) {
      final value =
          double.parse(fractionMatch.group(1)!) /
          double.parse(fractionMatch.group(2)!);
      return text.replaceRange(
        0,
        fractionMatch.end,
        _formatQuantity(value * factor),
      );
    }

    final decimalMatch = decimal.firstMatch(text);
    if (decimalMatch == null) return text;
    final value = double.parse(decimalMatch.group(1)!.replaceAll(',', '.'));
    return text.replaceRange(
      0,
      decimalMatch.end,
      _formatQuantity(value * factor),
    );
  }

  static String _formatQuantity(double value) {
    if ((value - value.round()).abs() < .01) return '${value.round()}';
    return value
        .toStringAsFixed(value < 1 ? 2 : 1)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }
}

class RecommendationFilters {
  const RecommendationFilters({
    this.maxCost = 35,
    this.maxMinutes = 45,
    this.preference = 'Todos',
  });
  final double maxCost;
  final int maxMinutes;
  final String preference;
  RecommendationFilters copyWith({
    double? maxCost,
    int? maxMinutes,
    String? preference,
  }) => RecommendationFilters(
    maxCost: maxCost ?? this.maxCost,
    maxMinutes: maxMinutes ?? this.maxMinutes,
    preference: preference ?? this.preference,
  );
}
