import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:origem/models/recommendation.dart';
import 'package:origem/screens/discover_screen.dart';
import 'package:origem/services/recommendation_service.dart';
import 'package:origem/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'pessoa com alergia a ovos conclui o planejamento pela interface',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MealPlannerScreen(
            recommendationService: RecommendationService(
              catalog: const [
                MealRecommendation(
                  id: 'arroz-seguro',
                  title: 'Arroz seguro',
                  description: 'Receita sem ovos.',
                  estimatedCost: 10,
                  minutes: 20,
                  servings: 2,
                  tags: {
                    'Almoço',
                    'Rápido e fácil',
                    'Equipamento:Fogão',
                    'Equipamento:Panela',
                  },
                  ingredients: ['1 xícara de arroz', '2 xícaras de água'],
                  steps: ['Cozinhe.', 'Sirva.'],
                ),
                MealRecommendation(
                  id: 'omelete-insegura',
                  title: 'Omelete insegura',
                  description: 'Receita com ovos.',
                  estimatedCost: 8,
                  minutes: 10,
                  servings: 2,
                  tags: {
                    'Almoço',
                    'Rápido e fácil',
                    'Equipamento:Fogão',
                    'Equipamento:Panela',
                    'Contém:Ovos',
                  },
                  ingredients: ['2 ovos', '1 pitada de sal'],
                  steps: ['Bata os ovos.', 'Cozinhe.'],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> choose(String label) async {
        final target = find.text(label);
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pump(const Duration(milliseconds: 350));
      }

      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.tap(find.byIcon(Icons.add_rounded).last);
      await tester.pump(const Duration(milliseconds: 220));
      expect(find.text('2 adultos  •  1 criança'), findsOneWidget);
      await choose('Próximo');
      await choose('Almoço');
      await choose('Próximo');
      await choose('Segunda');
      await choose('Próximo');
      await choose('Fogão');
      await choose('Panela');
      await choose('Próximo');
      await choose('Receitas rápidas');
      await choose('Próximo');
      await choose('Ovos');
      await choose('Próximo');
      await choose('Próximo');
      await choose('Próximo');
      await choose('Criar meu planejamento');

      for (var attempt = 0; attempt < 20; attempt++) {
        if (find.text('Sua semana está pronta').evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 250));
      }

      expect(find.text('Sua semana está pronta'), findsOneWidget);
      expect(find.textContaining('Seg • ALMOÇO'), findsWidgets);
      expect(find.text('Arroz seguro'), findsOneWidget);
      expect(find.text('Omelete insegura'), findsNothing);
      expect(find.textContaining('Não foi possível abrir'), findsNothing);
    },
  );
}
