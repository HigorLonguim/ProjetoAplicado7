import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/meal_plan.dart';
import 'package:origem/models/recommendation.dart';
import 'package:origem/services/recommendation_service.dart';

MealRecommendation recipe({
  required String id,
  required Set<String> tags,
  List<String> ingredients = const ['1 tomate', '1 xícara de arroz'],
  double cost = 20,
  int servings = 4,
}) => MealRecommendation(
  id: id,
  title: id,
  description: 'Receita de teste',
  estimatedCost: cost,
  minutes: 25,
  servings: servings,
  tags: tags,
  ingredients: ingredients,
  steps: const ['Prepare os ingredientes.', 'Cozinhe e sirva.'],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final catalog = [
    recipe(
      id: 'vegetariana-forno',
      tags: {
        'Almoço',
        'Vegetariana',
        'Comida caseira',
        'Equipamento:Forno',
        'Aproveita:Tomate',
      },
    ),
    recipe(
      id: 'atum-rapido',
      tags: {
        'Almoço',
        'Rápido e fácil',
        'Equipamento:Fogão',
        'Contém:Atum',
        'Contém:Peixe',
      },
      ingredients: const ['1 lata de atum', '1 tomate'],
    ),
    recipe(
      id: 'massa-com-queijo',
      tags: {
        'Jantar',
        'Comida caseira',
        'Equipamento:Fogão',
        'Equipamento:Panela',
        'Contém:Glúten',
        'Contém:Laticínios',
      },
      ingredients: const ['300 g de macarrão', '100 g de queijo'],
    ),
  ];
  final service = RecommendationService(catalog: catalog);

  test('carrega os oito lotes com 400 receitas únicas', () async {
    final loaded = await RecommendationService.fromAssets();

    expect(loaded.catalog, hasLength(400));
    expect(loaded.catalog.map((item) => item.id).toSet(), hasLength(400));
  });

  test('novo planejamento começa sem opções selecionadas', () {
    final plan = MealPlanAnswers();

    expect(plan.adults, 0);
    expect(plan.children, 0);
    expect(plan.meals, isEmpty);
    expect(plan.cookingDays, isEmpty);
    expect(plan.equipment, isEmpty);
    expect(plan.styles, isEmpty);
    expect(plan.allergies, isEmpty);
  });

  test('aplica refeição, equipamento e estilo simultaneamente', () {
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Almoço'},
      cookingDays: {'Seg'},
      equipment: {'Forno'},
      styles: {'Vegetariana', 'Comida caseira'},
      allergies: {'Sem alergias'},
    );

    final result = service.recommendForPlan(plan);

    expect(result.map((item) => item.id), ['vegetariana-forno']);
  });

  test('remove receitas com ingrediente rejeitado', () {
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Almoço'},
      cookingDays: {'Seg'},
      equipment: {'Fogão'},
      styles: {'Rápido e fácil'},
      allergies: {'Sem alergias'},
      dislikes: {'Atum'},
    );

    expect(service.recommendForPlan(plan), isEmpty);
  });

  test('bloqueia alergênico pelas tags explícitas', () {
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Jantar'},
      cookingDays: {'Seg'},
      equipment: {'Fogão', 'Panela'},
      styles: {'Comida caseira'},
      allergies: {'Laticínios'},
    );

    expect(service.recommendForPlan(plan), isEmpty);
  });

  test('bloqueia alergênico presente no ingrediente mesmo sem tag', () {
    final unsafeCatalog = RecommendationService(
      catalog: [
        recipe(
          id: 'bolo-sem-tag',
          tags: {'Lanches', 'Vegetariana'},
          ingredients: const ['2 ovos', '1 xícara de farinha'],
        ),
      ],
    );
    final plan = MealPlanAnswers(
      adults: 1,
      meals: {'Lanches'},
      cookingDays: {'Seg'},
      allergies: {'Ovos'},
    );

    expect(unsafeCatalog.recommendForPlan(plan), isEmpty);
  });

  test('cenários de pessoas alérgicas nunca retornam o ingrediente', () {
    final cases = <String, String>{
      'Amendoim': '2 colheres de pasta de amendoim',
      'Castanhas': '1 xícara de castanhas',
      'Laticínios': '200 ml de leite',
      'Ovos': '2 ovos',
      'Glúten': '1 xícara de farinha de trigo',
      'Soja': '2 colheres de shoyu',
      'Marisco': '300 g de camarão',
      'Peixe': '1 lata de atum',
      'Gergelim': '1 colher de gergelim',
      'Mostarda': '1 colher de mostarda',
      'Aipo': '1 talo de aipo',
    };

    for (final entry in cases.entries) {
      final humanScenario = RecommendationService(
        catalog: [
          recipe(
            id: 'receita-${entry.key}',
            tags: {'Almoço'},
            ingredients: [entry.value, '1 tomate'],
          ),
        ],
      );
      final plan = MealPlanAnswers(
        adults: 2,
        meals: {'Almoço'},
        cookingDays: {'Dom'},
        allergies: {entry.key},
      );

      expect(
        humanScenario.recommendForPlan(plan),
        isEmpty,
        reason: 'Falhou para uma pessoa com alergia a ${entry.key}',
      );
    }
  });

  test('leite de coco não é tratado como laticínio', () {
    final coconutService = RecommendationService(
      catalog: [
        recipe(
          id: 'moqueca-vegetal',
          tags: {'Almoço'},
          ingredients: const ['200 ml de leite de coco', '1 tomate'],
        ),
      ],
    );
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Almoço'},
      cookingDays: {'Sáb'},
      allergies: {'Laticínios'},
    );

    expect(coconutService.recommendForPlan(plan), hasLength(1));
  });

  test('Sem alergias não bloqueia receitas', () {
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Jantar'},
      cookingDays: {'Sex'},
      equipment: {'Fogão', 'Panela'},
      styles: {'Comida caseira'},
      allergies: {'Sem alergias'},
    );

    expect(service.recommendForPlan(plan).map((item) => item.id), [
      'massa-com-queijo',
    ]);
  });

  test('ajusta custo e quantidade para as porções do plano', () {
    final item = recipe(
      id: 'porcoes',
      tags: {'Almoço'},
      ingredients: const ['2 xícaras de arroz', '1/2 cebola'],
      cost: 40,
      servings: 4,
    );

    expect(item.costForServings(2), 20);
    expect(item.ingredientsForServings(2), [
      '1 xícaras de arroz',
      '0,25 cebola',
    ]);
  });

  test('despensa também é reconhecida pelo ingrediente, mesmo sem tag', () {
    final pantryService = RecommendationService(
      catalog: [
        recipe(
          id: 'com-frango-sem-tag',
          tags: {'Almoço'},
          ingredients: const ['400 g de peito de frango', '1 cebola'],
        ),
        recipe(
          id: 'sem-frango',
          tags: {'Almoço'},
          ingredients: const ['2 xícaras de arroz', '1 cenoura'],
        ),
      ],
    );
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Almoço'},
      cookingDays: {'Seg'},
      pantry: {'Frango'},
      weeklyBudget: 200,
    );

    final result = pantryService.recommendForPlan(plan);

    expect(result.first.id, 'com-frango-sem-tag');
    expect(pantryService.pantryMatchCount(result.first, plan), 1);
    expect(result, hasLength(2), reason: 'Despensa prioriza, mas não exclui.');
  });

  test(
    'catálogo real respeita simultaneamente todos os filtros rígidos',
    () async {
      final loaded = await RecommendationService.fromAssets();
      final plan = MealPlanAnswers(
        adults: 2,
        meals: {'Almoço'},
        cookingDays: {'Seg', 'Qua'},
        equipment: {'Fogão', 'Panela'},
        styles: {'Comida caseira'},
        allergies: {'Peixe'},
        dislikes: {'Tomate'},
        pantry: {'Frango'},
      );

      final result = loaded.recommendForPlan(plan);

      expect(result, isNotEmpty);
      for (final item in result) {
        expect(item.mealTypes, contains('Almoço'), reason: item.title);
        expect(
          plan.equipment.containsAll(item.requiredEquipment),
          isTrue,
          reason: item.title,
        );
        expect(item.styles, contains('Comida caseira'), reason: item.title);
        expect(
          item.allergens.intersection({'Peixe', 'Atum'}),
          isEmpty,
          reason: item.title,
        );
        expect(
          '${item.title} ${item.ingredients.join(' ')}'.toLowerCase(),
          isNot(contains('tomate')),
          reason: item.title,
        );
      }
    },
  );

  test('despensa prioriza receitas compatíveis no catálogo real', () async {
    final loaded = await RecommendationService.fromAssets();
    final plan = MealPlanAnswers(
      adults: 2,
      meals: {'Almoço', 'Jantar'},
      cookingDays: {'Seg', 'Ter'},
      equipment: {
        'Fogão',
        'Forno',
        'Air fryer',
        'Micro-ondas',
        'Liquidificador',
        'Panela',
      },
      allergies: {'Sem alergias'},
      pantry: {'Frango'},
      weeklyBudget: 500,
    );

    final result = loaded.recommendForPlan(plan);

    expect(result, isNotEmpty);
    expect(loaded.pantryMatchCount(result.first, plan), greaterThan(0));
    expect(
      result.any((item) => loaded.pantryMatchCount(item, plan) == 0),
      isTrue,
      reason: 'Ter frango deve priorizar, não bloquear toda a variedade.',
    );
  });
}
