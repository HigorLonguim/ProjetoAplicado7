import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../models/recommendation.dart';
import '../services/local_store.dart';
import '../services/recommendation_service.dart';
import '../services/shopping_list_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  static const _storageKey = 'meal_plan_answers_v2';
  static const _steps = 9;
  final _store = LocalStore();
  final _recommendations = RecommendationService();
  var _answers = MealPlanAnswers();
  var _step = 0;

  @override
  void initState() {
    super.initState();
    _load();
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

  void _next() {
    if (!_canContinue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma opção.')),
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
    await shopping.initialize();
    shopping.addItems(
      item.ingredients.map(
        (ingredient) => (
          name: ingredient,
          brand: 'Planejamento: ${item.title}',
          quantity: 1.0,
          unit: 'un',
        ),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredientes adicionados à lista.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _step == _steps;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy, AppColors.navyLight],
            ),
          ),
        ),
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
              child: const Text('Recomeçar'),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.navyLight],
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
                            backgroundColor: AppColors.navy.withValues(
                              alpha: .1,
                            ),
                            color: AppColors.olive,
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
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(.06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
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
        return _choiceStep(
          title: 'O que tem na sua cozinha?',
          subtitle: 'Vamos sugerir receitas que você realmente consegue fazer.',
          values: _answers.equipment,
          options: const {
            'Fogão': '🔥',
            'Forno': '♨️',
            'Air fryer': '🍟',
            'Micro-ondas': '📻',
            'Liquidificador': '🥤',
            'Panela': '🍲',
          },
        );
      case 4:
        return _choiceStep(
          title: 'Que tipo de comida combina com você?',
          subtitle: 'Pode marcar mais de uma ideia para variar o cardápio.',
          values: _answers.styles,
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
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _CounterRow(
              icon: Icons.person_outline_rounded,
              title: 'Adultos',
              subtitle: 'Dose inteira',
              value: _answers.adults,
              onRemove: _answers.adults > 0
                  ? () => setState(() => _answers.adults--)
                  : null,
              onAdd: () => setState(() => _answers.adults++),
            ),
            const Divider(height: 30),
            _CounterRow(
              icon: Icons.child_care_rounded,
              title: 'Crianças',
              subtitle: 'Porção reduzida',
              value: _answers.children,
              onRemove: _answers.children > 0
                  ? () => setState(() => _answers.children--)
                  : null,
              onAdd: () => setState(() => _answers.children++),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.olive.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_answers.portions} ${_answers.portions == 1 ? 'pessoa' : 'pessoas'} no planejamento',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _choiceStep({
    required String title,
    required String subtitle,
    required Set<String> values,
    required Map<String, String> options,
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
              label: entry.key,
              illustration: entry.value,
              selected: values.contains(entry.key),
              onTap: () => _toggle(values, entry.key, exclusive: exclusive),
            ),
          )
          .toList(),
    ),
  );

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
              'R\$ ${_answers.weeklyBudget.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Text('por semana'),
            const SizedBox(height: 18),
            Slider(
              value: _answers.weeklyBudget,
              min: 100,
              max: 800,
              divisions: 28,
              label: 'R\$ ${_answers.weeklyBudget.toStringAsFixed(0)}',
              onChanged: (value) =>
                  setState(() => _answers.weeklyBudget = value),
            ),
            const SizedBox(height: 12),
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

  Widget _resultStep() {
    final results = _recommendations.recommendForPlan(_answers);
    const dayOrder = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final days = dayOrder.where(_answers.cookingDays.contains).toList();
    final week = results.isEmpty
        ? <MealRecommendation>[]
        : List.generate(
            days.length,
            (index) => results[index % results.length],
          );
    double adjustedCost(MealRecommendation item) =>
        item.estimatedCost * (_answers.portions / item.servings).clamp(1, 10);
    final totalCost = week.fold<double>(
      0,
      (sum, item) => sum + adjustedCost(item),
    );
    final shoppingItems = week
        .expand((item) => item.ingredients)
        .toSet()
        .length;
    final saving = (_answers.weeklyBudget - totalCost).clamp(
      0,
      _answers.weeklyBudget,
    );
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
                '${_answers.portions} pessoas • ${_answers.cookingDays.length} dias • compras em qualquer mercado',
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
                      label: 'Dentro do orçamento',
                      value: 'R\$ ${saving.toStringAsFixed(0)}',
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
        if (results.isEmpty)
          const _Notice(
            icon: Icons.search_off_rounded,
            text:
                'Nenhuma receita do catálogo atual atende a todas as restrições. Volte e ajuste uma resposta.',
          )
        else
          ...week.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanRecipeCard(
                day: days[entry.$1],
                item: entry.$2,
                cost: adjustedCost(entry.$2),
                portions: _answers.portions,
                onAdd: () => _addRecipe(entry.$2),
              ),
            ),
          ),
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
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        backgroundColor: AppColors.olive.withValues(alpha: .13),
        child: Icon(icon, color: AppColors.olive),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      IconButton(
        onPressed: onRemove,
        constraints: const BoxConstraints.tightFor(width: 30, height: 30),
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: const Icon(Icons.remove_circle_outline),
      ),
      const SizedBox(width: 4),
      Text('$value', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(width: 4),
      IconButton.filled(
        onPressed: onAdd,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
        iconSize: 18,
        style: IconButton.styleFrom(backgroundColor: AppColors.olive),
        icon: const Icon(Icons.add_rounded),
      ),
    ],
  );
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.illustration,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String illustration;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: selected ? AppColors.olive : Colors.transparent,
        width: 1.5,
      ),
    ),
    child: Ink(
      decoration: BoxDecoration(
        color: selected ? null : Theme.of(context).colorScheme.surface,
        gradient: selected
            ? const LinearGradient(colors: [AppColors.olive, AppColors.forest])
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: selected ? 1.12 : 1,
                child: Text(illustration, style: const TextStyle(fontSize: 31)),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.textDark : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
            ? const LinearGradient(colors: [AppColors.olive, AppColors.mint])
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
                      ? AppColors.textDark.withValues(alpha: .12)
                      : AppColors.olive.withValues(alpha: .11),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  shortName.substring(0, 1),
                  style: TextStyle(
                    color: selected ? AppColors.textDark : AppColors.olive,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  fullName,
                  style: TextStyle(
                    color: selected ? AppColors.textDark : AppColors.ink,
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
    required this.item,
    required this.cost,
    required this.portions,
    required this.onAdd,
  });
  final String day;
  final MealRecommendation item;
  final double cost;
  final int portions;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _RecipeSheet(
          item: item,
          cost: cost,
          portions: portions,
          onAdd: onAdd,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.olive.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.olive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$day • ${_mealLabel(item)}',
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: .7,
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description),
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
                  icon: Icons.local_fire_department_outlined,
                  text: '${item.calories} kcal',
                ),
                _DataPill(
                  icon: Icons.scale_outlined,
                  text: '${item.portionGrams} g',
                ),
                _DataPill(
                  icon: Icons.favorite_outline_rounded,
                  text: '${item.healthScore}/10',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  String _mealLabel(MealRecommendation item) =>
      item.minutes <= 25 ? 'REFEIÇÃO RÁPIDA' : 'REFEIÇÃO PRINCIPAL';
}

class _RecipeSheet extends StatelessWidget {
  const _RecipeSheet({
    required this.item,
    required this.cost,
    required this.portions,
    required this.onAdd,
  });
  final MealRecommendation item;
  final double cost;
  final int portions;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(item.description),
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
                label: 'Energia',
                value: '${item.calories}',
                unit: 'kcal',
              ),
              _NutritionMetric(
                label: 'Porção',
                value: '${item.portionGrams}',
                unit: 'g',
              ),
              _NutritionMetric(
                label: 'Proteínas',
                value: '${item.proteinGrams}',
                unit: 'g',
              ),
              _NutritionMetric(
                label: 'Carboidratos',
                value: '${item.carbGrams}',
                unit: 'g',
              ),
              _NutritionMetric(
                label: 'Gorduras',
                value: '${item.fatGrams}',
                unit: 'g',
              ),
              _NutritionMetric(
                label: '$portions porções',
                value: 'R\$ ${cost.toStringAsFixed(0)}',
                unit: 'estimados',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...item.ingredients.map(
            (text) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppColors.olive,
              ),
              title: Text(text),
            ),
          ),
          const SizedBox(height: 12),
          Text('Preparo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...item.steps.indexed.map(
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                onAdd();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Adicionar ingredientes à lista'),
            ),
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
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) => Container(
    width: 96,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.terracotta,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.navy,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
