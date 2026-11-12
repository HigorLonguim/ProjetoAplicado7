import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/recommendation.dart';
import 'package:origem/services/recipe_image_resolver.dart';
import 'package:origem/services/recommendation_service.dart';

MealRecommendation imageRecipe({
  required String title,
  required Set<String> tags,
  List<String> ingredients = const [],
}) => MealRecommendation(
  id: title,
  title: title,
  description: 'Receita para testar a imagem ilustrativa.',
  estimatedCost: 20,
  minutes: 30,
  servings: 4,
  tags: tags,
  ingredients: ingredients,
  steps: const ['Prepare e sirva.'],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('escolhe categorias visuais pelo conteúdo da receita', () {
    expect(
      RecipeImageResolver.categoryFor(
        imageRecipe(
          title: 'Canja de frango',
          tags: {'Jantar'},
          ingredients: const ['400 g de frango', '1 xícara de arroz'],
        ),
      ),
      'soup',
    );
    expect(
      RecipeImageResolver.categoryFor(
        imageRecipe(
          title: 'Macarrão ao tomate',
          tags: {'Almoço'},
          ingredients: const ['300 g de macarrão'],
        ),
      ),
      'pasta',
    );
    expect(
      RecipeImageResolver.categoryFor(
        imageRecipe(
          title: 'Filé de tilápia',
          tags: {'Jantar'},
          ingredients: const ['500 g de tilápia'],
        ),
      ),
      'fish',
    );
    expect(
      RecipeImageResolver.categoryFor(
        imageRecipe(title: 'Omelete matinal', tags: {'Café da manhã'}),
      ),
      'breakfast',
    );
  });

  test('usa capas de lanche conforme o subtipo da receita', () {
    final cases = <String, String>{
      'Mousse rápida de banana e cacau': 'sweet',
      'Sanduíche quente de frango': 'sandwich',
      'Bolinho de arroz na air fryer': 'baked',
      'Omelete de caneca com legumes': 'breakfast',
      'Salada de frutas com iogurte': 'salad',
      'Sopa de pão com feijão-branco': 'soup',
    };

    for (final entry in cases.entries) {
      final recipe = imageRecipe(title: entry.key, tags: {'Lanches'});
      expect(
        RecipeImageResolver.categoryFor(recipe, meal: 'Lanches'),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('catálogo de lanches distribui receitas em capas contextuais', () async {
    final service = await RecommendationService.fromAssets();
    final snacks = service.catalog
        .where((recipe) => recipe.mealTypes.contains('Lanches'))
        .toList();
    final categories = snacks
        .map(
          (recipe) => RecipeImageResolver.categoryFor(recipe, meal: 'Lanches'),
        )
        .toList();
    const allowed = {
      'sandwich',
      'sweet',
      'breakfast',
      'baked',
      'salad',
      'soup',
    };

    expect(snacks, isNotEmpty);
    expect(categories.toSet(), containsAll(allowed));
    expect(categories.every(allowed.contains), isTrue);
    final largestGroup = allowed
        .map((category) => categories.where((item) => item == category).length)
        .reduce((a, b) => a > b ? a : b);
    expect(largestGroup / snacks.length, lessThan(.65));
  });

  test('todas as 400 receitas apontam para uma imagem empacotada', () async {
    final service = await RecommendationService.fromAssets();
    final paths = service.catalog
        .expand(
          (recipe) => recipe.mealTypes.map(
            (meal) => RecipeImageResolver.assetFor(recipe, meal: meal),
          ),
        )
        .toSet();

    expect(service.catalog, hasLength(400));
    expect(paths.length, greaterThanOrEqualTo(8));
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(1000), reason: path);
    }
  });
}
