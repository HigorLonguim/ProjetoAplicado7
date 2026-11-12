import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../models/recommendation.dart';
import '../services/local_store.dart';
import '../services/recipe_image_resolver.dart';
import '../services/recipe_shopping_interpreter.dart';
import '../services/recommendation_service.dart';
import '../services/shopping_list_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key, this.recommendationService});

  final RecommendationService? recommendationService;
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  static const _storageKey = 'meal_plan_answers_v2';
  static const _steps = 9;
  final _store = LocalStore();
  RecommendationService? _recommendations;
  Object? _catalogError;
  var _answers = MealPlanAnswers();
  var _step = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _recommendations = widget.recommendationService;
    if (_recommendations == null) _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final service = await RecommendationService.fromAssets();
      if (mounted) {
        setState(() {
          _recommendations = service;
          _catalogError = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _catalogError = error);
    }
  }

  Future<void> _load() async {
    final saved = await _store.getString(_storageKey);
    if (saved == null) return;
    try {
      final decoded = jsonDecode(saved);
      if (decoded is Map<String, dynamic> && mounted) {
        setState(() => _answers = MealPlanAnswers.fromJson(decoded));
      }
    } catch (_) {}
  }

  Future<void> _save() =>
      _store.setString(_storageKey, jsonEncode(_answers.toJson()));

  String _formatWholeReais(double value) {
    final whole = value.round();
    if (whole < 1000) return '$whole';
    return '${whole ~/ 1000}.${(whole % 1000).toString().padLeft(3, '0')}';
  }

  void _next() {
    if (!_canContinue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione pelo menos uma opção.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }
    _save();
    setState(() => _step = (_step + 1).clamp(0, _steps));
  }

  bool get _canContinue {
    if (_step == 0) return _answers.portions > 0;
    if (_step == 1) return _answers.meals.isNotEmpty;
    if (_step == 2) return _answers.cookingDays.isNotEmpty;
    if (_step == 3) return _answers.equipment.isNotEmpty;
    if (_step == 4) return _answers.styles.isNotEmpty;
    if (_step == 5) return _answers.allergies.isNotEmpty;
    return true;
  }

  void _toggle(Set<String> values, String value, {String? exclusive}) {
    setState(() {
      if (exclusive != null && value == exclusive) {
        values
          ..clear()
          ..add(value);
      } else {
        values.remove(exclusive);
        values.contains(value) ? values.remove(value) : values.add(value);
      }
    });
  }

  Future<void> _addRecipe(MealRecommendation item) async {
    final shopping = ShoppingListService();
    final plan = RecipeShoppingInterpreter.build(
      recipe: item,
      servings: _answers.portions,
      pantry: _answers.pantry,
    );
    await shopping.initialize();
    shopping.addOrMergeItems(
      plan.toBuy.map(
        (ingredient) => (
          name: ingredient.name,
          brand: 'Planejamento de receitas',
          quantity: ingredient.quantity,
          unit: ingredient.unit,
        ),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            plan.toBuy.isEmpty
                ? 'Você já tem os ingredientes principais desta receita.'
                : '${plan.toBuy.length} ${plan.toBuy.length == 1 ? 'item adicionado' : 'itens adicionados'} à lista.',
          ),
        ),
      );
    }
  }

  Future<void> _addWeekToShoppingList(List<_PlannedRecipe> week) async {
    final items = RecipeShoppingInterpreter.merge(
      week.expand(
        (entry) => RecipeShoppingInterpreter.build(
          recipe: entry.item,
          servings: _answers.portions,
          pantry: _answers.pantry,
        ).toBuy,
      ),
    );
    final shopping = ShoppingListService();
    await shopping.initialize();
    shopping.addOrMergeItems(
      items.map(
        (item) => (
          name: item.name,
          brand: 'Planejamento semanal',
          quantity: item.quantity,
          unit: item.unit,
        ),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${items.length} ${items.length == 1 ? 'item adicionado' : 'itens adicionados'} à lista semanal.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _step == _steps;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy.withValues(alpha: .96),
        leading: _step > 0
            ? IconButton(
                onPressed: () => setState(() => _step--),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Voltar',
              )
            : null,
        title: const Text('Planejar'),
        actions: [
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text(
                'Recomeçar',
                style: TextStyle(color: AppColors.sky),
              ),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, Color(0xFF0A1425)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              if (!result)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 7,
                            value: (_step + 1) / _steps,
                            backgroundColor: AppColors.border,
                            color: AppColors.electricBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_step + 1}/$_steps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: const Interval(.12, 1),
                    ),
                    child: ScaleTransition(
                      scale: Tween(begin: .975, end: 1.0).animate(animation),
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(.045, .015),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _stepContent(),
                  ),
                ),
              ),
              if (!result)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: _step == _steps - 1
                          ? 'Criar meu planejamento'
                          : 'Próximo',
                      icon: _step == _steps - 1
                          ? Icons.auto_awesome_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _peopleStep();
      case 1:
        return _choiceStep(
          title: 'Que refeições?',
          subtitle: 'Escolha o que devemos planejar para cada semana.',
          values: _answers.meals,
          options: const {
            'Café da manhã': '☕',
            'Almoço': '🍛',
            'Jantar': '🍲',
            'Lanches': '🥪',
          },
        );
      case 2:
        return _daysStep();
      case 3:
        return _kitchenStep();
      case 4:
        return _choiceStep(
          title: 'Que tipo de comida combina com você?',
          subtitle: 'Pode marcar mais de uma ideia para variar o cardápio.',
          values: _answers.styles,
          displayLabels: const {
            'Rápido e fácil': 'Receitas rápidas',
            'Uma só panela': 'Uma panela',
            'Cozinhar em lote': 'Comida para a semana',
            'Pratos da família': 'Para a família',
            'Fresco e leve': 'Leve e fresco',
            'Mais fibras': 'Rico em fibras',
          },
          options: const {
            'Rápido e fácil': '⚡',
            'Uma só panela': '🥘',
            'Cozinhar em lote': '🍱',
            'Pratos da família': '👨‍👩‍👧',
            'Comida caseira': '🏡',
            'Fresco e leve': '🥗',
            'Mais fibras': '🌾',
            'Vegetariana': '🥦',
          },
        );
      case 5:
        return _choiceStep(
          title: 'Você tem alergias ou restrições?',
          subtitle: 'Esses itens serão retirados das recomendações.',
          values: _answers.allergies,
          exclusive: 'Sem alergias',
          options: const {
            'Sem alergias': '✅',
            'Amendoim': '🥜',
            'Castanhas': '🌰',
            'Laticínios': '🥛',
            'Ovos': '🥚',
            'Glúten': '🌾',
            'Soja': '🫘',
            'Marisco': '🦐',
            'Peixe': '🐟',
            'Gergelim': '🌱',
            'Mostarda': '🟡',
            'Aipo': '🥬',
          },
        );
      case 6:
        return _choiceStep(
          title: 'Tem algo que você não gosta?',
          subtitle: 'Marque os alimentos que devem ficar fora das sugestões.',
          values: _answers.dislikes,
          options: const {
            'Pimentão': '🫑',
            'Cebola': '🧅',
            'Tomate': '🍅',
            'Atum': '🐟',
            'Peixe': '🐠',
            'Brócolis': '🥦',
            'Cogumelos': '🍄',
            'Azeitona': '🫒',
            'Berinjela': '🍆',
            'Ovos': '🥚',
            'Milho': '🌽',
            'Abacate': '🥑',
          },
        );
      case 7:
        return _choiceStep(
          title: 'O que você já tem?',
          subtitle: 'Isso ajuda a reduzir a compra e aproveitar a despensa.',
          values: _answers.pantry,
          options: const {
            'Ovos': '🥚',
            'Leite': '🥛',
            'Banana': '🍌',
            'Pão': '🍞',
            'Arroz': '🍚',
            'Macarrão': '🍝',
            'Frango': '🍗',
            'Tomate': '🍅',
            'Cebola': '🧅',
            'Batata': '🥔',
            'Iogurte': '🥣',
            'Atum': '🐟',
          },
        );
      case 8:
        return _budgetStep();
      default:
        return _resultStep();
    }
  }

  Widget _frame({
    required String title,
    required String subtitle,
    required Widget child,
  }) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 24),
      child,
    ],
  );

  Widget _peopleStep() => _frame(
    title: 'Quem vai comer?',
    subtitle: 'A quantidade de pessoas ajusta as porções e o valor estimado.',
    child: Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _CounterRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Adultos',
                  subtitle: '1 porção por adulto',
                  value: _answers.adults,
                  onRemove: _answers.adults > 0
                      ? () => setState(() => _answers.adults--)
                      : null,
                  onAdd: () => setState(() => _answers.adults++),
                ),
                const Divider(height: 1),
                _CounterRow(
                  icon: Icons.child_care_rounded,
                  title: 'Crianças',
                  subtitle: 'Porção infantil',
                  value: _answers.children,
                  onRemove: _answers.children > 0
                      ? () => setState(() => _answers.children--)
                      : null,
                  onAdd: () => setState(() => _answers.children++),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.electricBlue.withValues(alpha: .16),
                AppColors.olive.withValues(alpha: .13),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sky.withValues(alpha: .28)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: .18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  color: AppColors.sky,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PLANEJAMENTO ATUAL',
                      style: TextStyle(
                        color: AppColors.sky,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_answers.adults} ${_answers.adults == 1 ? 'adulto' : 'adultos'}  •  ${_answers.children} ${_answers.children == 1 ? 'criança' : 'crianças'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_answers.portions} ${_answers.portions == 1 ? 'pessoa' : 'pessoas'} por refeição',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _choiceStep({
    required String title,
    required String subtitle,
    required Set<String> values,
    required Map<String, String> options,
    Map<String, String> displayLabels = const {},
    String? exclusive,
  }) => _frame(
    title: title,
    subtitle: subtitle,
    child: GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: options.entries
          .map(
            (entry) => _OptionCard(
              label: displayLabels[entry.key] ?? entry.key,
              imageAsset: _plannerImageFor(entry.key),
              selected: values.contains(entry.key),
              onTap: () => _toggle(values, entry.key, exclusive: exclusive),
            ),
          )
          .toList(),
    ),
  );

  Widget _kitchenStep() {
    return _frame(
      title: 'Monte sua cozinha real',
      subtitle:
          'Toque diretamente nos equipamentos contornados. As receitas serão adaptadas ao que você tem em casa.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) => Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .9),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .32),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/cozinha_interativa_separada_v2.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      semanticLabel:
                          'Cozinha moderna com seis equipamentos selecionáveis',
                    ),
                    Positioned.fill(
                      child: Semantics(
                        label:
                            'Cozinha interativa. Toque nos equipamentos contornados ou use os botões abaixo.',
                        image: true,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) {
                              for (final region
                                  in _kitchenEquipmentRegions.reversed) {
                                if (region.hitTest(
                                  details.localPosition,
                                  constraints.biggest,
                                )) {
                                  Feedback.forTap(context);
                                  _toggle(_answers.equipment, region.label);
                                  break;
                                }
                              }
                            },
                            child: CustomPaint(
                              painter: _KitchenEquipmentPainter(
                                selected: _answers.equipment,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ..._kitchenEquipmentRegions
                        .where(
                          (region) => _answers.equipment.contains(region.label),
                        )
                        .map(
                          (region) => Positioned(
                            left: region.labelAnchor.dx * constraints.maxWidth,
                            top: region.labelAnchor.dy * constraints.maxHeight,
                            child: FractionalTranslation(
                              translation: const Offset(-.5, -1),
                              child: IgnorePointer(
                                child: _KitchenSelectedLabel(
                                  label: region.label,
                                ),
                              ),
                            ),
                          ),
                        ),
                    const Positioned(left: 12, top: 12, child: _KitchenHint()),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: AppColors.sky,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                _answers.equipment.isEmpty
                    ? 'Nenhum equipamento selecionado'
                    : 'Selecionados: ${(_answers.equipment.toList()..sort()).join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => GridView.count(
              crossAxisCount: constraints.maxWidth > 560 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: _kitchenEquipmentRegions.map((region) {
                final selected = _answers.equipment.contains(region.label);
                return _EquipmentImageCard(
                  region: region,
                  selected: selected,
                  onTap: () => _toggle(_answers.equipment, region.label),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _daysStep() => _frame(
    title: 'Em quais dias você cozinha?',
    subtitle: 'Planejaremos refeições apenas para os dias selecionados.',
    child: GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.35,
      children:
          const {
                'Seg': 'Segunda',
                'Ter': 'Terça',
                'Qua': 'Quarta',
                'Qui': 'Quinta',
                'Sex': 'Sexta',
                'Sáb': 'Sábado',
                'Dom': 'Domingo',
              }.entries
              .map(
                (entry) => _DayCard(
                  shortName: entry.key,
                  fullName: entry.value,
                  selected: _answers.cookingDays.contains(entry.key),
                  onTap: () => _toggle(_answers.cookingDays, entry.key),
                ),
              )
              .toList(),
    ),
  );

  Widget _budgetStep() => _frame(
    title: 'Qual é o orçamento semanal?',
    subtitle: 'Vamos priorizar ideias que caibam no valor informado.',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              'R\$ ${_formatWholeReais(_answers.weeklyBudget)}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Text('por semana'),
            const SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                activeTrackColor: AppColors.apricot,
                inactiveTrackColor: AppColors.border.withValues(alpha: .58),
                thumbColor: AppColors.warmYellow,
                overlayColor: AppColors.apricot.withValues(alpha: .14),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              ),
              child: Slider(
                value: _answers.weeklyBudget.clamp(40, 1000),
                min: 40,
                max: 1000,
                divisions: 48,
                semanticFormatterCallback: (value) =>
                    'R\$ ${_formatWholeReais(value)} por semana',
                onChanged: (value) =>
                    setState(() => _answers.weeklyBudget = value),
                onChangeEnd: (_) => _save(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ 40',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
                  ),
                  Text(
                    'R\$ 1.000',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Notice(
              icon: Icons.calculate_outlined,
              text:
                  'Cerca de R\$ ${(_answers.weeklyBudget / _answers.cookingDays.length).toStringAsFixed(0)} para cada dia de preparo.',
            ),
          ],
        ),
      ),
    ),
  );

  List<_PlannedRecipe> _buildWeek(
    RecommendationService service,
    List<MealRecommendation> candidates,
    List<String> days,
  ) {
    const mealOrder = ['Café da manhã', 'Almoço', 'Jantar', 'Lanches'];
    final meals = mealOrder.where(_answers.meals.contains).toList();
    final usedIds = <String>{};
    final week = <_PlannedRecipe>[];
    var remainingBudget = _answers.weeklyBudget;
    var remainingSlots = days.length * meals.length;

    for (final day in days) {
      for (final meal in meals) {
        final forMeal = candidates
            .where((item) => item.mealTypes.contains(meal))
            .toList();
        if (forMeal.isEmpty) {
          remainingSlots--;
          continue;
        }
        final unused = forMeal
            .where((item) => !usedIds.contains(item.id))
            .toList();
        final pool = unused.isEmpty ? forMeal : unused;
        final target = remainingSlots > 0
            ? remainingBudget / remainingSlots
            : remainingBudget;
        final withinBudget = pool
            .where(
              (item) => service.costForPlan(item, _answers) <= target * 1.15,
            )
            .toList();
        final item = withinBudget.isNotEmpty
            ? withinBudget.first
            : pool.reduce(
                (best, candidate) =>
                    service.costForPlan(candidate, _answers) <
                        service.costForPlan(best, _answers)
                    ? candidate
                    : best,
              );
        final cost = service.costForPlan(item, _answers);
        week.add(_PlannedRecipe(day: day, meal: meal, item: item, cost: cost));
        usedIds.add(item.id);
        remainingBudget -= cost;
        remainingSlots--;
      }
    }
    return week;
  }

  Widget _resultStep() {
    final service = _recommendations;
    if (service == null) {
      if (_catalogError != null) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _Notice(
              icon: Icons.error_outline_rounded,
              text:
                  'Não foi possível abrir o catálogo de receitas. Tente carregar novamente.',
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _loadCatalog,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Carregar novamente'),
            ),
          ],
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    final results = service.recommendForPlan(_answers);
    const dayOrder = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final days = dayOrder.where(_answers.cookingDays.contains).toList();
    final week = _buildWeek(service, results, days);
    final totalCost = week.fold<double>(0, (sum, entry) => sum + entry.cost);
    final weeklyShopping = RecipeShoppingInterpreter.merge(
      week.expand(
        (entry) => RecipeShoppingInterpreter.build(
          recipe: entry.item,
          servings: _answers.portions,
          pantry: _answers.pantry,
        ).toBuy,
      ),
    );
    final shoppingItems = weeklyShopping.length;
    final balance = _answers.weeklyBudget - totalCost;
    final expectedSlots = days.length * _answers.meals.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.navyLight, AppColors.border],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.peach),
              const SizedBox(height: 13),
              Text(
                'Sua semana está pronta',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${_answers.portions} ${_answers.portions == 1 ? 'pessoa' : 'pessoas'} • '
                '${_answers.cookingDays.length} ${_answers.cookingDays.length == 1 ? 'dia' : 'dias'} • '
                '${_answers.meals.length} ${_answers.meals.length == 1 ? 'tipo' : 'tipos'} de refeição',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Gasto estimado',
                      value: 'R\$ ${totalCost.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryMetric(
                      label: balance >= 0
                          ? 'Saldo estimado'
                          : 'Acima do limite',
                      value: 'R\$ ${balance.abs().toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryMetric(
                      label: 'Lista de compras',
                      value: '$shoppingItems itens',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (week.isNotEmpty && weeklyShopping.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _addWeekToShoppingList(week),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                'Adicionar $shoppingItems ${shoppingItems == 1 ? 'item' : 'itens'} da semana à lista',
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
        Text(
          'Cardápio da semana',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Toque em um prato para ver porção, calorias, macros e preparo.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (week.isEmpty)
          const _Notice(
            icon: Icons.search_off_rounded,
            text:
                'Nenhuma receita do catálogo atual atende a todas as restrições. Volte e ajuste uma resposta.',
          )
        else ...[
          if (week.length < expectedSlots)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _Notice(
                icon: Icons.info_outline_rounded,
                text:
                    'Alguns horários ficaram sem receita porque nenhum item atende simultaneamente a todos os filtros selecionados.',
              ),
            ),
          if (balance < 0)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _Notice(
                icon: Icons.account_balance_wallet_outlined,
                text:
                    'O conjunto compatível ultrapassa o orçamento informado. As opções mais econômicas disponíveis foram priorizadas.',
              ),
            ),
          ...week.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanRecipeCard(
                day: entry.day,
                meal: entry.meal,
                item: entry.item,
                cost: entry.cost,
                portions: _answers.portions,
                pantry: _answers.pantry,
                onAdd: () => _addRecipe(entry.item),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        const _Notice(
          icon: Icons.receipt_long_outlined,
          text:
              'Valores estimados para o protótipo. Os preços podem variar conforme o mercado, a região e as ofertas disponíveis.',
        ),
      ],
    );
  }
}

class _PlannedRecipe {
  const _PlannedRecipe({
    required this.day,
    required this.meal,
    required this.item,
    required this.cost,
  });

  final String day;
  final String meal;
  final MealRecommendation item;
  final double cost;
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onRemove,
    required this.onAdd,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final int value;
  final VoidCallback? onRemove;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.olive.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.forest, size: 23),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 1),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.navy.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CounterButton(icon: Icons.remove_rounded, onPressed: onRemove),
              SizedBox(
                width: 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Text(
                    '$value',
                    key: ValueKey(value),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add_rounded,
                onPressed: onAdd,
                emphasized: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
    padding: EdgeInsets.zero,
    style: IconButton.styleFrom(
      backgroundColor: emphasized ? AppColors.olive : AppColors.navyLight,
      disabledBackgroundColor: AppColors.navyLight.withValues(alpha: .45),
      foregroundColor: emphasized ? Colors.white : AppColors.sky,
      disabledForegroundColor: AppColors.border,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    icon: Icon(icon, size: 19),
  );
}

class _KitchenHint extends StatelessWidget {
  const _KitchenHint();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(99),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.touch_app_rounded, size: 15, color: AppColors.navy),
        SizedBox(width: 5),
        Text(
          'TOQUE NOS ITENS CONTORNADOS',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
          ),
        ),
      ],
    ),
  );
}

class _KitchenEquipmentRegion {
  const _KitchenEquipmentRegion(this.label, this.outline);

  final String label;
  final List<Offset> outline;

  Alignment get focus {
    final left = outline
        .map((point) => point.dx)
        .reduce((a, b) => a < b ? a : b);
    final right = outline
        .map((point) => point.dx)
        .reduce((a, b) => a > b ? a : b);
    final top = outline
        .map((point) => point.dy)
        .reduce((a, b) => a < b ? a : b);
    final bottom = outline
        .map((point) => point.dy)
        .reduce((a, b) => a > b ? a : b);
    return Alignment((left + right) - 1, (top + bottom) - 1);
  }

  Offset get center => Offset((focus.x + 1) / 2, (focus.y + 1) / 2);

  double get previewScale => switch (label) {
    'Liquidificador' => 3.15,
    'Air fryer' || 'Panela' => 2.8,
    'Micro-ondas' => 2.6,
    'Forno' => 2.15,
    _ => 2.25,
  };

  Offset get labelAnchor => switch (label) {
    'Fogão' => const Offset(.46, .48),
    'Panela' => const Offset(.69, .45),
    'Forno' => const Offset(.88, .40),
    'Air fryer' => const Offset(.24, .37),
    'Micro-ondas' => const Offset(.88, .15),
    'Liquidificador' => const Offset(.09, .33),
    _ => center,
  };

  Path pathFor(Size size) {
    final path = Path();
    for (var index = 0; index < outline.length; index++) {
      final point = outline[index];
      final scaled = Offset(point.dx * size.width, point.dy * size.height);
      if (index == 0) {
        path.moveTo(scaled.dx, scaled.dy);
      } else {
        path.lineTo(scaled.dx, scaled.dy);
      }
    }
    return path..close();
  }

  bool hitTest(Offset position, Size size) {
    final path = pathFor(size);
    if (path.contains(position)) return true;
    final extra = (size.width / 450 * 11).clamp(8.0, 18.0).toDouble();
    return path.getBounds().inflate(extra).contains(position);
  }
}

const _kitchenEquipmentRegions = [
  _KitchenEquipmentRegion('Fogão', [
    Offset(.388, .503),
    Offset(.543, .503),
    Offset(.557, .521),
    Offset(.572, .614),
    Offset(.562, .622),
    Offset(.356, .622),
    Offset(.349, .607),
    Offset(.366, .526),
  ]),
  _KitchenEquipmentRegion('Forno', [
    Offset(.788, .409),
    Offset(.974, .409),
    Offset(.974, .761),
    Offset(.788, .761),
  ]),
  _KitchenEquipmentRegion('Air fryer', [
    Offset(.211, .378),
    Offset(.266, .378),
    Offset(.282, .390),
    Offset(.290, .417),
    Offset(.292, .514),
    Offset(.286, .551),
    Offset(.271, .570),
    Offset(.255, .582),
    Offset(.214, .582),
    Offset(.198, .572),
    Offset(.189, .548),
    Offset(.185, .514),
    Offset(.186, .420),
    Offset(.196, .393),
  ]),
  _KitchenEquipmentRegion('Micro-ondas', [
    Offset(.801, .159),
    Offset(.961, .159),
    Offset(.961, .339),
    Offset(.801, .339),
  ]),
  _KitchenEquipmentRegion('Liquidificador', [
    Offset(.069, .354),
    Offset(.114, .354),
    Offset(.122, .365),
    Offset(.126, .389),
    Offset(.129, .468),
    Offset(.122, .491),
    Offset(.115, .501),
    Offset(.115, .520),
    Offset(.124, .543),
    Offset(.122, .575),
    Offset(.113, .596),
    Offset(.100, .607),
    Offset(.074, .607),
    Offset(.062, .598),
    Offset(.057, .576),
    Offset(.057, .544),
    Offset(.066, .520),
    Offset(.066, .501),
    Offset(.058, .488),
    Offset(.055, .466),
    Offset(.056, .389),
    Offset(.061, .368),
  ]),
  _KitchenEquipmentRegion('Panela', [
    Offset(.691, .474),
    Offset(.707, .474),
    Offset(.713, .487),
    Offset(.730, .495),
    Offset(.740, .503),
    Offset(.750, .509),
    Offset(.751, .528),
    Offset(.743, .539),
    Offset(.734, .541),
    Offset(.730, .568),
    Offset(.718, .588),
    Offset(.704, .596),
    Offset(.675, .596),
    Offset(.661, .588),
    Offset(.652, .570),
    Offset(.650, .543),
    Offset(.641, .539),
    Offset(.637, .526),
    Offset(.640, .510),
    Offset(.650, .504),
    Offset(.669, .496),
    Offset(.686, .487),
  ]),
];

String _plannerImageFor(String label) {
  final itemImage = _plannerItemImages[label];
  if (itemImage != null) return itemImage;

  final normalized = label.toLowerCase();
  if (RegExp(
    r'café|lanche|ovo|leite|banana|pão|iogurte',
  ).hasMatch(normalized)) {
    return 'assets/images/recipe_breakfast_v1.png';
  }
  if (RegExp(
    r'panela|caseira|lote|feijão|macarrão|cebola|batata',
  ).hasMatch(normalized)) {
    return 'assets/images/recipe_one_pot_v1.png';
  }
  if (RegExp(
    r'vegetar|fresco|fibra|brócolis|cogumelo|azeitona|berinjela|abacate|tomate|soja|aipo',
  ).hasMatch(normalized)) {
    return 'assets/images/recipe_fresh_bowl_v1.png';
  }
  return 'assets/images/recipe_family_plate_v1.png';
}

const _plannerItemImages = <String, String>{
  'Jantar': 'assets/images/planner_dinner_v1.png',
  'Lanches': 'assets/images/planner_snacks_v1.png',
  'Uma só panela': 'assets/images/planner_one_pan_v1.png',
  'Cozinhar em lote': 'assets/images/planner_batch_cooking_v1.png',
  'Pratos da família': 'assets/images/planner_family_v1.png',
  'Mais fibras': 'assets/images/planner_high_fiber_v1.png',
  'Vegetariana': 'assets/images/planner_vegetarian_v1.png',
  'Sem alergias': 'assets/images/recipe_fresh_bowl_v1.png',
  'Amendoim': 'assets/images/item_amendoim.jpg',
  'Castanhas': 'assets/images/item_castanhas.jpg',
  'Laticínios': 'assets/images/item_laticinios.jpg',
  'Ovos': 'assets/images/item_ovos.jpg',
  'Glúten': 'assets/images/item_gluten.jpg',
  'Soja': 'assets/images/item_soja.jpg',
  'Marisco': 'assets/images/item_marisco.jpg',
  'Peixe': 'assets/images/item_peixe.jpg',
  'Gergelim': 'assets/images/item_gergelim.jpg',
  'Mostarda': 'assets/images/item_mostarda.jpg',
  'Aipo': 'assets/images/item_aipo.jpg',
  'Pimentão': 'assets/images/item_pimentao.jpg',
  'Cebola': 'assets/images/item_cebola.jpg',
  'Tomate': 'assets/images/item_tomate.jpg',
  'Atum': 'assets/images/item_atum.jpg',
  'Brócolis': 'assets/images/item_brocolis.jpg',
  'Cogumelos': 'assets/images/item_cogumelos.jpg',
  'Azeitona': 'assets/images/item_azeitona.jpg',
  'Berinjela': 'assets/images/item_berinjela.jpg',
  'Milho': 'assets/images/item_milho.jpg',
  'Abacate': 'assets/images/item_abacate.jpg',
  'Leite': 'assets/images/item_leite.jpg',
  'Banana': 'assets/images/item_banana.jpg',
  'Pão': 'assets/images/item_pao.jpg',
  'Arroz': 'assets/images/item_arroz.jpg',
  'Macarrão': 'assets/images/item_macarrao.jpg',
  'Frango': 'assets/images/item_frango.jpg',
  'Batata': 'assets/images/item_batata.jpg',
  'Iogurte': 'assets/images/item_iogurte.jpg',
};

const _plannerBackdropSeamAssets = <String>{
  'assets/images/recipe_breakfast_v1.png',
  'assets/images/recipe_family_plate_v1.png',
};

String _recipeImageFor(MealRecommendation item, {String? meal}) =>
    RecipeImageResolver.assetFor(item, meal: meal);

class _EquipmentImageCard extends StatelessWidget {
  const _EquipmentImageCard({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final _KitchenEquipmentRegion region;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: region.label,
    child: AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? .98 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.sky : AppColors.border,
                width: selected ? 1.7 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: .2),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: selected ? .92 : .62,
                  child: _KitchenPreviewImage(region: region),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.navy.withValues(alpha: selected ? .65 : .82),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 11,
                  bottom: 9,
                  child: Text(
                    region.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (selected)
                  const Positioned(right: 8, top: 8, child: _SelectionMark()),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _KitchenPreviewImage extends StatelessWidget {
  const _KitchenPreviewImage({required this.region});

  final _KitchenEquipmentRegion region;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = region.previewScale;
      final center = region.center;
      return ClipRect(
        child: Transform.translate(
          offset: Offset(
            (.5 - center.dx) * constraints.maxWidth * scale,
            (.5 - center.dy) * constraints.maxHeight * scale,
          ),
          child: Transform.scale(
            scale: scale,
            child: Image.asset(
              'assets/images/cozinha_interativa_separada_v2.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      );
    },
  );
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 25,
    height: 25,
    decoration: BoxDecoration(
      color: AppColors.electricBlue,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.sky),
      boxShadow: [
        BoxShadow(
          color: AppColors.electricBlue.withValues(alpha: .35),
          blurRadius: 10,
        ),
      ],
    ),
    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
  );
}

const _kitchenOutlineBlue = Color(0xFF58A6FF);
const _kitchenOutlineBlueLight = Color(0xFFC5E2FF);

class _KitchenEquipmentPainter extends CustomPainter {
  _KitchenEquipmentPainter({required Set<String> selected})
    : selected = Set.unmodifiable(selected);

  final Set<String> selected;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 450).clamp(.82, 1.55).toDouble();

    for (final region in _kitchenEquipmentRegions) {
      final path = region.pathFor(size);
      final isSelected = selected.contains(region.label);
      final color = isSelected ? _kitchenOutlineBlueLight : _kitchenOutlineBlue;

      if (isSelected) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = _kitchenOutlineBlue.withValues(alpha: .12),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4 * scale
            ..color = _kitchenOutlineBlue.withValues(alpha: .38)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * scale),
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..strokeWidth = (isSelected ? 2.25 : 1.35) * scale
          ..color = color.withValues(alpha: isSelected ? .98 : .88),
      );

      if (isSelected) _paintCheck(canvas, path.getBounds(), size, scale);
    }
  }

  void _paintCheck(Canvas canvas, Rect bounds, Size size, double scale) {
    final radius = 8.5 * scale;
    final center = Offset(
      (bounds.right - 7 * scale).clamp(radius, size.width - radius),
      (bounds.top + 7 * scale).clamp(radius, size.height - radius),
    );

    canvas.drawCircle(
      center,
      radius + 1.25 * scale,
      Paint()..color = _kitchenOutlineBlueLight,
    );
    canvas.drawCircle(center, radius, Paint()..color = _kitchenOutlineBlue);

    final check = Path()
      ..moveTo(center.dx - 4 * scale, center.dy)
      ..lineTo(center.dx - 1 * scale, center.dy + 3 * scale)
      ..lineTo(center.dx + 4.5 * scale, center.dy - 4 * scale);
    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 1.8 * scale
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _KitchenEquipmentPainter oldDelegate) =>
      oldDelegate.selected.length != selected.length ||
      selected.any((item) => !oldDelegate.selected.contains(item));
}

class _KitchenSelectedLabel extends StatelessWidget {
  const _KitchenSelectedLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 112),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.navy.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: _kitchenOutlineBlueLight, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: _kitchenOutlineBlue.withValues(alpha: .32),
          blurRadius: 10,
        ),
      ],
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: .15,
      ),
    ),
  );
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.imageAsset,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String imageAsset;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cropBackdropSeam = _plannerBackdropSeamAssets.contains(imageAsset);
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: selected ? .98 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.sky : AppColors.border,
                width: selected ? 1.8 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: .22),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: selected ? .88 : .56,
                  child: Transform.scale(
                    scale: cropBackdropSeam ? 1.15 : 1,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      alignment: cropBackdropSeam
                          ? Alignment.bottomCenter
                          : Alignment.center,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.navy.withValues(alpha: .08),
                        AppColors.navy.withValues(alpha: selected ? .55 : .82),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 11,
                  child: Text(
                    label,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                ),
                if (selected)
                  const Positioned(right: 9, top: 9, child: _SelectionMark()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.shortName,
    required this.fullName,
    required this.selected,
    required this.onTap,
  });
  final String shortName;
  final String fullName;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Ink(
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [AppColors.electricBlue, AppColors.navyLight],
              )
            : null,
        color: selected ? null : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? AppColors.olive
              : AppColors.navy.withValues(alpha: .12),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .18)
                      : AppColors.olive.withValues(alpha: .11),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  shortName.substring(0, 1),
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.olive,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  fullName,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.textDark,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.terracotta.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.terracotta, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _PlanRecipeCard extends StatelessWidget {
  const _PlanRecipeCard({
    required this.day,
    required this.meal,
    required this.item,
    required this.cost,
    required this.portions,
    required this.pantry,
    required this.onAdd,
  });
  final String day;
  final String meal;
  final MealRecommendation item;
  final double cost;
  final int portions;
  final Set<String> pantry;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final shoppingPlan = RecipeShoppingInterpreter.build(
      recipe: item,
      servings: portions,
      pantry: pantry,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _RecipeSheet(
            item: item,
            meal: meal,
            cost: cost,
            portions: portions,
            pantry: pantry,
            onAdd: onAdd,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 6.7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'recipe-${item.id}-$day-$meal',
                    child: Image.asset(
                      _recipeImageFor(item, meal: meal),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.navy.withValues(alpha: .72),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: .78),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.sky.withValues(alpha: .55),
                        ),
                      ),
                      child: Text(
                        '$day • ${meal.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: .7,
                          color: AppColors.sky,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 12,
                    top: 10,
                    child: _IllustrativeImageBadge(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        color: AppColors.sky,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DataPill(
                        icon: Icons.payments_outlined,
                        text: 'R\$ ${cost.toStringAsFixed(0)}',
                      ),
                      _DataPill(
                        icon: Icons.schedule_rounded,
                        text: 'cerca de ${item.minutes} min',
                      ),
                      _DataPill(
                        icon: Icons.local_fire_department_outlined,
                        text: '${item.calories} kcal',
                      ),
                      _DataPill(
                        icon: Icons.favorite_outline_rounded,
                        text: '${item.healthScore}/10',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (shoppingPlan.atHome.isNotEmpty)
                        _DataPill(
                          icon: Icons.kitchen_outlined,
                          text:
                              'Já tem: ${shoppingPlan.atHome.map((item) => item.name).join(', ')}',
                        ),
                      _DataPill(
                        icon: Icons.shopping_cart_outlined,
                        text:
                            '${shoppingPlan.toBuy.length} ${shoppingPlan.toBuy.length == 1 ? 'item para comprar' : 'itens para comprar'}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeSheet extends StatelessWidget {
  const _RecipeSheet({
    required this.item,
    required this.meal,
    required this.cost,
    required this.portions,
    required this.pantry,
    required this.onAdd,
  });
  final MealRecommendation item;
  final String meal;
  final double cost;
  final int portions;
  final Set<String> pantry;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final scaledIngredients = item.ingredientsForServings(portions);
    final shoppingPlan = RecipeShoppingInterpreter.build(
      recipe: item,
      servings: portions,
      pantry: pantry,
    );
    final equipment = item.requiredEquipment.toList()..sort();
    final allergens = item.allergens.where((value) => value != 'Atum').toList()
      ..sort();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 7.5,
                child: Image.asset(
                  _recipeImageFor(item, meal: meal),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Imagem ilustrativa',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DataPill(
                  icon: Icons.schedule_rounded,
                  text: '${item.minutes} min',
                ),
                _DataPill(
                  icon: Icons.people_outline_rounded,
                  text:
                      '$portions ${portions == 1 ? 'porção planejada' : 'porções planejadas'}',
                ),
                if (equipment.isNotEmpty)
                  _DataPill(
                    icon: Icons.kitchen_outlined,
                    text: equipment.join(' + '),
                  ),
              ],
            ),
            if (allergens.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Notice(
                icon: Icons.warning_amber_rounded,
                text: 'Atenção: contém ${allergens.join(', ')}.',
              ),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.olive.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    item.healthScore >= 8
                        ? Icons.thumb_up_alt_rounded
                        : Icons.balance_rounded,
                    color: AppColors.olive,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.healthScore >= 8
                              ? 'Ótima composição'
                              : 'Boa opção com equilíbrio',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Avaliação estimada: ${item.healthScore}/10',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Valores por porção',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                _NutritionMetric(
                  icon: Icons.bolt_rounded,
                  label: 'Energia',
                  value: '${item.calories}',
                  unit: 'kcal',
                  accent: AppColors.orange,
                ),
                _NutritionMetric(
                  icon: Icons.scale_outlined,
                  label: 'Porção',
                  value: '${item.portionGrams}',
                  unit: 'g',
                  accent: AppColors.sky,
                ),
                _NutritionMetric(
                  icon: Icons.fitness_center_rounded,
                  label: 'Proteínas',
                  value: '${item.proteinGrams}',
                  unit: 'g',
                  accent: AppColors.forest,
                ),
                _NutritionMetric(
                  icon: Icons.grain_rounded,
                  label: 'Carboidratos',
                  value: '${item.carbGrams}',
                  unit: 'g',
                  accent: AppColors.peach,
                ),
                _NutritionMetric(
                  icon: Icons.water_drop_outlined,
                  label: 'Gorduras',
                  value: '${item.fatGrams}',
                  unit: 'g',
                  accent: AppColors.terracotta,
                ),
                _NutritionMetric(
                  icon: Icons.payments_outlined,
                  label: 'Custo planejado',
                  value: 'R\$ ${cost.toStringAsFixed(0)}',
                  unit: 'estimados',
                  accent: AppColors.mint,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _RecipeDetailTabs(
              item: item,
              portions: portions,
              scaledIngredients: scaledIngredients,
              shoppingPlan: shoppingPlan,
              onAdd: onAdd,
            ),
            const SizedBox(height: 12),
            Text(
              'Dados nutricionais e preços são estimativas do catálogo nesta etapa do projeto.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeDetailTabs extends StatefulWidget {
  const _RecipeDetailTabs({
    required this.item,
    required this.portions,
    required this.scaledIngredients,
    required this.shoppingPlan,
    required this.onAdd,
  });

  final MealRecommendation item;
  final int portions;
  final List<String> scaledIngredients;
  final RecipeShoppingPlan shoppingPlan;
  final VoidCallback onAdd;

  @override
  State<_RecipeDetailTabs> createState() => _RecipeDetailTabsState();
}

class _RecipeDetailTabsState extends State<_RecipeDetailTabs> {
  var _selectedTab = 0;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.shopping_basket_outlined),
              label: Text('Ingredientes'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.soup_kitchen_outlined),
              label: Text('Modo de preparo'),
            ),
          ],
          selected: {_selectedTab},
          onSelectionChanged: (selection) =>
              setState(() => _selectedTab = selection.first),
        ),
      ),
      const SizedBox(height: 18),
      if (_selectedTab == 0)
        _ingredientsTab(context)
      else
        _preparationTab(context),
    ],
  );

  Widget _ingredientsTab(BuildContext context) => Column(
    key: const ValueKey('ingredients-tab'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Itens para a receita',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      Text(
        widget.portions == widget.item.servings
            ? 'Quantidades para ${widget.portions} porções.'
            : 'Quantidades ajustadas de ${widget.item.servings} para ${widget.portions} porções.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      if (widget.shoppingPlan.atHome.isNotEmpty) ...[
        const SizedBox(height: 12),
        _ShoppingIngredientGroup(
          title: 'Você já tem em casa',
          subtitle: 'Estes itens não entrarão na lista de compras.',
          icon: Icons.kitchen_outlined,
          color: AppColors.olive,
          items: widget.shoppingPlan.atHome,
        ),
      ],
      const SizedBox(height: 12),
      _ShoppingIngredientGroup(
        title: widget.shoppingPlan.toBuy.isEmpty
            ? 'Nada principal para comprar'
            : 'Ainda precisa comprar',
        subtitle: widget.shoppingPlan.toBuy.isEmpty
            ? 'Os ingredientes principais já estão na sua despensa.'
            : 'Quantidades arredondadas para facilitar a compra.',
        icon: Icons.shopping_cart_outlined,
        color: AppColors.terracotta,
        items: widget.shoppingPlan.toBuy,
      ),
      if (widget.shoppingPlan.ignoredStaples.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(
          'Água e temperos básicos não são adicionados automaticamente à lista.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      const SizedBox(height: 8),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: const Text('Ver ingredientes completos'),
        subtitle: const Text('Medidas culinárias usadas no preparo'),
        children: widget.scaledIngredients
            .map(
              (text) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.olive,
                ),
                title: Text(text),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: widget.shoppingPlan.toBuy.isEmpty
              ? null
              : () {
                  widget.onAdd();
                  Navigator.pop(context);
                },
          icon: const Icon(Icons.playlist_add_rounded),
          label: Text(
            widget.shoppingPlan.toBuy.isEmpty
                ? 'Tudo principal já está em casa'
                : 'Adicionar ${widget.shoppingPlan.toBuy.length} ${widget.shoppingPlan.toBuy.length == 1 ? 'item' : 'itens'} à lista',
          ),
        ),
      ),
    ],
  );

  Widget _preparationTab(BuildContext context) => Column(
    key: const ValueKey('preparation-tab'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Notice(
        icon: Icons.schedule_rounded,
        text:
            'Tempo estimado de preparo: cerca de ${widget.item.minutes} minutos.',
      ),
      const SizedBox(height: 16),
      Text('Modo de preparo', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      ...widget.item.steps.indexed.map(
        (entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.terracotta.withValues(alpha: .16),
            child: Text(
              '${entry.$1 + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ),
          title: Text(entry.$2),
        ),
      ),
    ],
  );
}

class _ShoppingIngredientGroup extends StatelessWidget {
  const _ShoppingIngredientGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<RecipeShoppingItem> items;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withValues(alpha: .22)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: color),
                  const SizedBox(width: 9),
                  Expanded(child: Text(item.name)),
                  Text(
                    item.readableQuantity,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _IllustrativeImageBadge extends StatelessWidget {
  const _IllustrativeImageBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.navy.withValues(alpha: .76),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: Colors.white24),
    ),
    child: const Text(
      'Imagem ilustrativa',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    ),
  );
}

class _DataPill extends StatelessWidget {
  const _DataPill({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.navy.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.navy),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _NutritionMetric extends StatelessWidget {
  const _NutritionMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    width: 104,
    height: 108,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.navyLight, AppColors.darkSurface],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .18),
          blurRadius: 14,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: accent),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.15,
                  color: Color(0xFFCAD3E0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            height: 1,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFBAC6D6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
