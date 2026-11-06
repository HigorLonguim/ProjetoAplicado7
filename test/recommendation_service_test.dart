import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/meal_plan.dart';
import 'package:origem/services/recommendation_service.dart';

void main() {
  final service = RecommendationService();

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

  test('remove receitas com ingredientes rejeitados', () {
    final plan = MealPlanAnswers(
      cookingDays: {'Seg'},
      dislikes: {'Atum'},
      weeklyBudget: 300,
    );

    final result = service.recommendForPlan(plan);

    expect(result.map((item) => item.id), isNot(contains('massa-atum')));
  });

  test('respeita a preferência vegetariana', () {
    final plan = MealPlanAnswers(
      cookingDays: {'Seg'},
      styles: {'Vegetariana'},
      weeklyBudget: 300,
    );

    final result = service.recommendForPlan(plan);

    expect(result, isNotEmpty);
    expect(result.every((item) => item.tags.contains('Vegetariana')), isTrue);
  });
}
