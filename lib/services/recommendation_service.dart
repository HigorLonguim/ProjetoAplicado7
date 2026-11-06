import '../models/recommendation.dart';
import '../models/meal_plan.dart';

class RecommendationService {
  static const catalog = <MealRecommendation>[
    MealRecommendation(
      id: 'bowl-grao',
      title: 'Bowl de grão-de-bico',
      description: 'Uma refeição completa com legumes, grãos e molho de limão.',
      estimatedCost: 22,
      minutes: 25,
      servings: 2,
      tags: {'Vegetariana', 'Sem lactose'},
      ingredients: [
        '1 xícara de grão-de-bico cozido',
        '1 cenoura',
        '1 tomate',
        'Folhas verdes',
        'Limão e azeite',
      ],
      steps: [
        'Corte os legumes.',
        'Aqueça o grão-de-bico com temperos.',
        'Monte o bowl e finalize com limão e azeite.',
      ],
      portionGrams: 420,
      calories: 465,
      proteinGrams: 19,
      carbGrams: 61,
      fatGrams: 15,
      healthScore: 9,
    ),
    MealRecommendation(
      id: 'omelete',
      title: 'Omelete de forno com legumes',
      description:
          'Prática, econômica e fácil de adaptar ao que já existe em casa.',
      estimatedCost: 18,
      minutes: 30,
      servings: 3,
      tags: {'Vegetariana', 'Sem glúten'},
      ingredients: [
        '5 ovos',
        '1 tomate',
        '1/2 abobrinha',
        'Cebola',
        'Ervas frescas',
      ],
      steps: [
        'Bata os ovos.',
        'Misture os legumes picados.',
        'Asse por cerca de 20 minutos.',
      ],
      portionGrams: 310,
      calories: 350,
      proteinGrams: 23,
      carbGrams: 14,
      fatGrams: 22,
      healthScore: 8,
    ),
    MealRecommendation(
      id: 'frango-arroz',
      title: 'Frango, arroz e legumes',
      description:
          'Combinação simples para preparar porções para mais de um dia.',
      estimatedCost: 34,
      minutes: 40,
      servings: 4,
      tags: {'Sem lactose', 'Sem glúten', 'Proteica'},
      ingredients: [
        '500 g de peito de frango',
        '2 xícaras de arroz',
        'Cenoura',
        'Brócolis',
        'Alho e cebola',
      ],
      steps: [
        'Cozinhe o arroz.',
        'Grelhe o frango em cubos.',
        'Cozinhe os legumes e distribua em porções.',
      ],
      portionGrams: 480,
      calories: 585,
      proteinGrams: 42,
      carbGrams: 68,
      fatGrams: 14,
      healthScore: 9,
    ),
    MealRecommendation(
      id: 'massa-atum',
      title: 'Massa rápida com atum',
      description: 'Opção de despensa para quando o tempo está curto.',
      estimatedCost: 27,
      minutes: 20,
      servings: 3,
      tags: {'Proteica'},
      ingredients: [
        '250 g de macarrão',
        '1 lata de atum',
        'Tomate',
        'Cebola',
        'Cheiro-verde',
      ],
      steps: [
        'Cozinhe a massa.',
        'Refogue tomate, cebola e atum.',
        'Misture e finalize com cheiro-verde.',
      ],
      portionGrams: 390,
      calories: 530,
      proteinGrams: 31,
      carbGrams: 67,
      fatGrams: 15,
      healthScore: 7,
    ),
  ];

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
    final blocked = {...plan.allergies, ...plan.dislikes}
        .where((item) => item != 'Sem alergias')
        .map((item) => item.toLowerCase())
        .toSet();
    final availablePerCookingDay = plan.weeklyBudget / plan.cookingDays.length;

    final result = catalog.where((item) {
      final content =
          '${item.title} ${item.ingredients.join(' ')} ${item.tags.join(' ')}'
              .toLowerCase();
      final violatesRestriction = blocked.any((value) {
        if (value == 'laticínios') {
          return content.contains('leite') ||
              content.contains('iogurte') ||
              content.contains('queijo') ||
              content.contains('lactose');
        }
        if (value == 'glúten') {
          return content.contains('macarrão') ||
              content.contains('pão') ||
              content.contains('trigo');
        }
        if (value == 'ovos') return content.contains('ovo');
        return content.contains(value);
      });
      final vegetarian =
          !plan.styles.contains('Vegetariana') ||
          item.tags.contains('Vegetariana');
      return !violatesRestriction &&
          vegetarian &&
          item.estimatedCost <= availablePerCookingDay * 1.25;
    }).toList();

    int pantryMatches(MealRecommendation item) => plan.pantry
        .where(
          (owned) => item.ingredients.any(
            (ingredient) =>
                ingredient.toLowerCase().contains(owned.toLowerCase()),
          ),
        )
        .length;
    result.sort((a, b) {
      final pantry = pantryMatches(b).compareTo(pantryMatches(a));
      if (pantry != 0) return pantry;
      if (plan.styles.contains('Rápido e fácil')) {
        return a.minutes.compareTo(b.minutes);
      }
      return a.estimatedCost.compareTo(b.estimatedCost);
    });
    return result;
  }
}
