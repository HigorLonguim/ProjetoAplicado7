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
