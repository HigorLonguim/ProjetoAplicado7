import '../models/recommendation.dart';

class RecipeImageResolver {
  const RecipeImageResolver._();

  static const _assetDirectory = 'assets/images/recipes';

  static String assetFor(MealRecommendation recipe, {String? meal}) =>
      '$_assetDirectory/${categoryFor(recipe, meal: meal)}.jpg';

  static String categoryFor(MealRecommendation recipe, {String? meal}) {
    final title = _normalize(recipe.title);
    final content = _normalize(
      '${recipe.title} ${recipe.description} '
      '${recipe.ingredients.join(' ')} ${recipe.tags.join(' ')}',
    );
    final context = meal ?? _inferredMealContext(recipe);

    if (context == 'Lanches') {
      return _snackCategory(recipe, title, content);
    }
    if (context == 'Café da manhã') {
      return _breakfastCategory(title);
    }
    return _mainMealCategory(recipe, title, content);
  }

  static String? _inferredMealContext(MealRecommendation recipe) {
    final isMainMeal =
        recipe.mealTypes.contains('Almoço') ||
        recipe.mealTypes.contains('Jantar');
    if (recipe.mealTypes.contains('Lanches') && !isMainMeal) return 'Lanches';
    if (recipe.mealTypes.contains('Café da manhã') && !isMainMeal) {
      return 'Café da manhã';
    }
    return null;
  }

  static String _snackCategory(
    MealRecommendation recipe,
    String title,
    String content,
  ) {
    if (_matches(title, _soupTerms)) return 'soup';
    if (_matches(title, _saladTerms)) return 'salad';
    if (_matches(title, _sweetTerms)) return 'sweet';
    if (_matches(title, _breakfastTerms)) return 'breakfast';
    if (_matches(title, _bakedSnackTerms) ||
        recipe.requiredEquipment.contains('Air fryer')) {
      return 'baked';
    }
    if (_matches(title, _sandwichTerms)) return 'sandwich';
    if (recipe.styles.contains('Fresco e leve') &&
        _matches(content, ['folhas', 'pepino', 'frutas', 'iogurte'])) {
      return 'salad';
    }
    return 'sandwich';
  }

  static String _breakfastCategory(String title) {
    if (_matches(title, _sweetTerms)) return 'sweet';
    if (_matches(title, _sandwichTerms)) return 'sandwich';
    return 'breakfast';
  }

  static String _mainMealCategory(
    MealRecommendation recipe,
    String title,
    String content,
  ) {
    if (_matches(title, _soupTerms)) return 'soup';
    if (_matches(title, _saladTerms)) return 'salad';
    if (_matches(title, _sandwichTerms)) return 'sandwich';
    if (_matches(title, _sweetTerms)) return 'sweet';
    if (_matches(title, _pastaTerms)) return 'pasta';
    if (recipe.allergens.contains('Peixe') ||
        recipe.allergens.contains('Atum') ||
        _matches(content, _fishTerms)) {
      return 'fish';
    }
    if (_matches(content, _beefTerms)) return 'beef';
    if (_matches(content, _chickenTerms)) return 'chicken';
    if (_matches(title, _riceTerms)) return 'rice';
    if (recipe.styles.contains('Vegetariana')) return 'vegetarian';
    if (recipe.requiredEquipment.contains('Forno') ||
        recipe.requiredEquipment.contains('Air fryer')) {
      return 'baked';
    }
    if (_matches(content, _riceTerms)) return 'rice';
    return 'vegetarian';
  }

  static const _soupTerms = ['sopa', 'caldo', 'canja', 'ensopado', 'creme'];
  static const _saladTerms = ['salada', 'vinagrete', 'caponata'];
  static const _sweetTerms = [
    'bolo',
    'doce',
    'cookie',
    'muffin',
    'sobremesa',
    'mousse',
    'sorvete',
    'crumble',
    'rabanada',
    'pudim de chia',
    'maca assada',
    'banana assada',
  ];
  static const _breakfastTerms = [
    'vitamina',
    'mingau',
    'omelete',
    'panqueca',
    'crepioca',
    'cuscuz',
    'ovos',
    'iogurte',
    'frutas',
  ];
  static const _bakedSnackTerms = [
    'bolinho',
    'chips',
    'croquete',
    'falafel',
    'pastel',
    'torta',
    'quiche',
    'assado',
    'crocante',
    'minipizza',
  ];
  static const _sandwichTerms = [
    'sanduiche',
    'torrada',
    'wrap',
    'tapioca',
    'pao',
    'pizza',
    'pate',
    'pasta de',
  ];
  static const _pastaTerms = [
    'macarrao',
    'penne',
    'espaguete',
    'lasanha',
    'nhoque',
  ];
  static const _fishTerms = [
    'peixe',
    'atum',
    'sardinha',
    'salmao',
    'tilapia',
    'pescada',
    'merluza',
  ];
  static const _beefTerms = ['carne bovina', 'patinho', 'acem', 'carne moida'];
  static const _chickenTerms = ['frango', 'sobrecoxa', 'peito de frango'];
  static const _riceTerms = ['arroz', 'risoto', 'graos'];

  static bool _matches(String content, List<String> terms) =>
      terms.any((term) => content.contains(_normalize(term)));

  static String _normalize(String value) {
    const accents = 'áàãâäéèêëíìîïóòõôöúùûüç';
    const plain = 'aaaaaeeeeiiiiooooouuuuc';
    var result = value.toLowerCase();
    for (var index = 0; index < accents.length; index++) {
      result = result.replaceAll(accents[index], plain[index]);
    }
    return result;
  }
}
