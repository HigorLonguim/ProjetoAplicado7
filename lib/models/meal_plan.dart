class MealPlanAnswers {
  MealPlanAnswers({
    this.market = 'Qualquer mercado',
    this.adults = 0,
    this.children = 0,
    Set<String>? meals,
    Set<String>? cookingDays,
    Set<String>? equipment,
    Set<String>? styles,
    Set<String>? allergies,
    Set<String>? dislikes,
    Set<String>? pantry,
    this.weeklyBudget = 365,
  }) : meals = meals ?? {},
       cookingDays = cookingDays ?? {},
       equipment = equipment ?? {},
       styles = styles ?? {},
       allergies = allergies ?? {},
       dislikes = dislikes ?? {},
       pantry = pantry ?? {};

  String market;
  int adults;
  int children;
  Set<String> meals;
  Set<String> cookingDays;
  Set<String> equipment;
  Set<String> styles;
  Set<String> allergies;
  Set<String> dislikes;
  Set<String> pantry;
  double weeklyBudget;

  int get portions => adults + children;

  Map<String, dynamic> toJson() => {
    'market': market,
    'adults': adults,
    'children': children,
    'meals': meals.toList(),
    'cookingDays': cookingDays.toList(),
    'equipment': equipment.toList(),
    'styles': styles.toList(),
    'allergies': allergies.toList(),
    'dislikes': dislikes.toList(),
    'pantry': pantry.toList(),
    'weeklyBudget': weeklyBudget,
  };

  factory MealPlanAnswers.fromJson(Map<String, dynamic> json) {
    Set<String> values(String key, Set<String> fallback) {
      final raw = json[key];
      return raw is List
          ? raw.map((value) => value.toString()).toSet()
          : fallback;
    }

    return MealPlanAnswers(
      market: 'Qualquer mercado',
      adults: (json['adults'] as num?)?.toInt() ?? 0,
      children: (json['children'] as num?)?.toInt() ?? 0,
      meals: values('meals', {}),
      cookingDays: values('cookingDays', {}),
      equipment: values('equipment', {}),
      styles: values('styles', {}),
      allergies: values('allergies', {}),
      dislikes: values('dislikes', {}),
      pantry: values('pantry', {}),
      weeklyBudget: (json['weeklyBudget'] as num?)?.toDouble() ?? 365,
    );
  }
}
