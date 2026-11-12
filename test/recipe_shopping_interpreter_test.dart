import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/recommendation.dart';
import 'package:origem/services/recipe_shopping_interpreter.dart';

MealRecommendation shoppingRecipe({
  required List<String> ingredients,
  int servings = 2,
}) => MealRecommendation(
  id: 'shopping-test',
  title: 'Receita de teste',
  description: 'Receita usada para validar a lista de compras.',
  estimatedCost: 10,
  minutes: 15,
  servings: servings,
  tags: const {'Lanches'},
  ingredients: ingredients,
  steps: const ['Prepare e sirva.'],
);

void main() {
  test('transforma medidas culinárias em itens possíveis de comprar', () {
    final plan = RecipeShoppingInterpreter.build(
      recipe: shoppingRecipe(
        ingredients: const [
          '1 banana madura em rodelas',
          '2 colheres de sopa de pasta de amendoim integral',
        ],
      ),
      servings: 1,
      pantry: const {},
    );

    expect(plan.toBuy, hasLength(2));
    expect(plan.toBuy[0].name, 'Banana');
    expect(plan.toBuy[0].quantity, 1);
    expect(plan.toBuy[0].unit, 'un');
    expect(plan.toBuy[1].name, 'Pasta de amendoim');
    expect(plan.toBuy[1].quantity, 1);
    expect(plan.toBuy[1].unit, 'pote');
  });

  test('separa o que já existe na despensa do que precisa comprar', () {
    final plan = RecipeShoppingInterpreter.build(
      recipe: shoppingRecipe(
        ingredients: const ['2 bananas maduras', '2 potes de iogurte natural'],
      ),
      servings: 2,
      pantry: const {'Banana'},
    );

    expect(plan.atHome.single.name, 'Banana');
    expect(plan.toBuy.single.name, 'Iogurte');
  });

  test('arredonda frações e remove água e temperos básicos', () {
    final plan = RecipeShoppingInterpreter.build(
      recipe: shoppingRecipe(
        ingredients: const [
          '1/2 cebola picada',
          '1/2 xícara de arroz cru',
          '1 litro de água',
          'Sal e pimenta a gosto',
        ],
        servings: 1,
      ),
      servings: 1,
      pantry: const {},
    );

    expect(
      plan.toBuy.any(
        (item) =>
            item.name == 'Cebola' && item.quantity == 1 && item.unit == 'un',
      ),
      isTrue,
    );
    expect(
      plan.toBuy.any(
        (item) =>
            item.name == 'Arroz' && item.quantity == 100 && item.unit == 'g',
      ),
      isTrue,
    );
    expect(plan.ignoredStaples, hasLength(2));
  });

  test('agrupa o mesmo produto vindo de receitas diferentes', () {
    const first = RecipeShoppingItem(
      name: 'Tomate',
      quantity: 2,
      unit: 'un',
      original: '2 tomates',
    );
    const second = RecipeShoppingItem(
      name: 'Tomate',
      quantity: 1,
      unit: 'un',
      original: '1 tomate',
    );

    final merged = RecipeShoppingInterpreter.merge([first, second]);

    expect(merged, hasLength(1));
    expect(merged.single.quantity, 3);
  });
}
