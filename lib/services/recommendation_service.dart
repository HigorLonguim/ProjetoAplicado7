import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../models/meal_plan.dart';
import '../models/recommendation.dart';

class RecommendationService {
  RecommendationService({required Iterable<MealRecommendation> catalog})
    : catalog = List.unmodifiable(catalog);

  static const assetPaths = [
    'assets/data/recipes_batch_01.json',
    'assets/data/recipes_batch_02.json',
    'assets/data/recipes_batch_03.json',
    'assets/data/recipes_batch_04.json',
    'assets/data/recipes_batch_05.json',
    'assets/data/recipes_batch_06.json',
    'assets/data/recipes_batch_07.json',
    'assets/data/recipes_batch_08.json',
  ];

  final List<MealRecommendation> catalog;

  static Future<RecommendationService> fromAssets({AssetBundle? bundle}) async {
    final source = bundle ?? rootBundle;
    final recipes = <MealRecommendation>[];
    final ids = <String>{};
    for (final path in assetPaths) {
      final raw = await source.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['recipes'] is! List) {
        throw FormatException('Catálogo inválido: $path');
      }
      for (final value in decoded['recipes'] as List) {
        if (value is! Map<String, dynamic>) {
          throw FormatException('Receita inválida em $path');
        }
        final recipe = MealRecommendation.fromJson(value);
        if (recipe.id.isEmpty || recipe.title.isEmpty || !ids.add(recipe.id)) {
          throw FormatException(
            'Receita duplicada ou sem identificação: $path',
          );
        }
        recipes.add(recipe);
      }
    }
    return RecommendationService(catalog: recipes);
  }

  List<MealRecommendation> recommend(RecommendationFilters filters) {
    final result = catalog.where((item) {
      final matchesPreference =
          filters.preference == 'Todos' ||
          item.tags.contains(filters.preference);
      return item.estimatedCost <= filters.maxCost &&
          item.minutes <= filters.maxMinutes &&
          matchesPreference;
    }).toList();
    result.sort((a, b) {
      final cost = a.estimatedCost.compareTo(b.estimatedCost);
      return cost != 0 ? cost : a.minutes.compareTo(b.minutes);
    });
    return result;
  }

  List<MealRecommendation> recommendForPlan(MealPlanAnswers plan) {
    final result = catalog.where((item) {
      if (plan.meals.isNotEmpty &&
          item.mealTypes.intersection(plan.meals).isEmpty) {
        return false;
      }
      if (!plan.equipment.containsAll(item.requiredEquipment)) return false;
      if (_violatesAllergies(item, plan.allergies)) return false;
      if (_violatesDislikes(item, plan.dislikes)) return false;
      if (plan.styles.contains('Vegetariana') &&
          !item.styles.contains('Vegetariana')) {
        return false;
      }
      final preferredStyles = {...plan.styles}..remove('Vegetariana');
      if (preferredStyles.isNotEmpty &&
          item.styles.intersection(preferredStyles).isEmpty) {
        return false;
      }
      return true;
    }).toList();

    final slots = math.max(1, plan.cookingDays.length * plan.meals.length);
    final targetCost = plan.weeklyBudget / slots;
    result.sort((a, b) {
      final pantry = pantryMatchCount(
        b,
        plan,
      ).compareTo(pantryMatchCount(a, plan));
      if (pantry != 0) return pantry;
      final aOver = costForPlan(a, plan) > targetCost ? 1 : 0;
      final bOver = costForPlan(b, plan) > targetCost ? 1 : 0;
      final budget = aOver.compareTo(bOver);
      if (budget != 0) return budget;
      final cost = costForPlan(a, plan).compareTo(costForPlan(b, plan));
      return cost != 0 ? cost : a.minutes.compareTo(b.minutes);
    });
    return result;
  }

  double costForPlan(MealRecommendation item, MealPlanAnswers plan) =>
      item.costForServings(math.max(1, plan.portions));

  int pantryMatchCount(MealRecommendation item, MealPlanAnswers plan) {
    if (plan.pantry.isEmpty) return 0;
    final content = _normalize('${item.title} ${item.ingredients.join(' ')}');
    var matches = 0;
    for (final pantryItem in plan.pantry) {
      if (item.pantryMatches.contains(pantryItem)) {
        matches++;
        continue;
      }
      final terms = _pantryTerms[pantryItem] ?? [_normalize(pantryItem)];
      if (terms.any((term) => _containsTerm(content, term))) matches++;
    }
    return matches;
  }

  static const _pantryTerms = <String, List<String>>{
    'Ovos': ['ovo', 'ovos'],
    'Leite': ['leite'],
    'Banana': ['banana', 'bananas'],
    'Pão': ['pao', 'paes'],
    'Arroz': ['arroz'],
    'Macarrão': ['macarrao', 'massa'],
    'Frango': ['frango', 'sobrecoxa'],
    'Tomate': ['tomate', 'tomates'],
    'Cebola': ['cebola', 'cebolas'],
    'Batata': ['batata', 'batatas'],
    'Iogurte': ['iogurte'],
    'Atum': ['atum'],
  };

  static bool _violatesAllergies(
    MealRecommendation item,
    Set<String> allergies,
  ) {
    final blocked = {...allergies}..remove('Sem alergias');
    if (blocked.isEmpty) return false;

    if (item.allergens.intersection(blocked).isNotEmpty) return true;
    // Atum é uma marcação mais específica do catálogo, mas deve ser
    // tratado como peixe para quem selecionou essa alergia.
    if (blocked.contains('Peixe') && item.allergens.contains('Atum')) {
      return true;
    }

    // Defesa adicional para catálogos importados ou editados manualmente: uma
    // tag ausente nunca deve fazer um ingrediente alergênico passar no filtro.
    var content = _normalize(item.ingredients.join(' '));
    content = content
        .replaceAll('leite de coco', '')
        .replaceAll('leite de amendoas', '')
        .replaceAll('leite de castanhas', '');
    for (final allergy in blocked) {
      final terms = _allergenTerms[allergy] ?? const <String>[];
      if (terms.any((term) => _containsTerm(content, term))) return true;
    }
    return false;
  }

  static const _allergenTerms = <String, List<String>>{
    'Amendoim': ['amendoim', 'pasta de amendoim'],
    'Castanhas': [
      'castanha',
      'castanhas',
      'nozes',
      'noz',
      'amendoa',
      'amendoas',
    ],
    'Laticínios': [
      'leite',
      'iogurte',
      'queijo',
      'manteiga',
      'requeijao',
      'ricota',
      'cottage',
      'nata',
    ],
    'Ovos': ['ovo', 'ovos'],
    'Glúten': [
      'trigo',
      'pao',
      'macarrao',
      'farinha de rosca',
      'aveia',
      'cevada',
      'centeio',
    ],
    'Soja': ['soja', 'tofu', 'shoyu'],
    'Marisco': ['camarao', 'marisco', 'siri', 'caranguejo', 'polvo', 'lula'],
    'Peixe': [
      'peixe',
      'atum',
      'sardinha',
      'salmao',
      'tilapia',
      'pescada',
      'merluza',
      'tainha',
      'pacu',
    ],
    'Gergelim': ['gergelim', 'tahine'],
    'Mostarda': ['mostarda'],
    'Aipo': ['aipo', 'salsao'],
  };

  static bool _containsTerm(String content, String term) {
    final escaped = RegExp.escape(_normalize(term));
    return RegExp('(^|[^a-z0-9])$escaped([^a-z0-9]|\$)').hasMatch(content);
  }

  static bool _violatesDislikes(MealRecommendation item, Set<String> dislikes) {
    if (dislikes.isEmpty) return false;
    final content = _normalize('${item.title} ${item.ingredients.join(' ')}');
    for (final dislike in dislikes) {
      final normalized = _normalize(dislike);
      if (normalized == 'peixe' && item.allergens.contains('Peixe')) {
        return true;
      }
      if (normalized == 'atum' && item.allergens.contains('Atum')) return true;
      if (normalized == 'ovos' && item.allergens.contains('Ovos')) return true;
      if (content.contains(normalized)) return true;
    }
    return false;
  }

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
