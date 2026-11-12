import fs from 'node:fs';

const file = process.argv[2];
if (!file) throw new Error('Usage: node tool/validate_recipes.mjs <json-file>');

const catalog = JSON.parse(fs.readFileSync(file, 'utf8'));
const recipes = catalog.recipes;
const errors = [];

const required = [
  'id',
  'title',
  'description',
  'estimatedCost',
  'minutes',
  'servings',
  'tags',
  'ingredients',
  'steps',
  'portionGrams',
  'calories',
  'proteinGrams',
  'carbGrams',
  'fatGrams',
  'healthScore',
];

const exactTags = new Set([
  'Café da manhã', 'Almoço', 'Jantar', 'Lanches',
  'Rápido e fácil', 'Uma só panela', 'Cozinhar em lote', 'Pratos da família',
  'Comida caseira', 'Fresco e leve', 'Mais fibras', 'Vegetariana',
]);
const equipment = new Set(['Fogão', 'Forno', 'Air fryer', 'Micro-ondas', 'Liquidificador', 'Panela']);
const pantry = new Set(['Ovos', 'Leite', 'Banana', 'Pão', 'Arroz', 'Macarrão', 'Frango', 'Tomate', 'Cebola', 'Batata', 'Iogurte', 'Atum']);
const allergens = new Set(['Amendoim', 'Castanhas', 'Laticínios', 'Ovos', 'Glúten', 'Soja', 'Marisco', 'Peixe', 'Gergelim', 'Mostarda', 'Aipo', 'Atum']);

const normalize = (value) => value
  .normalize('NFD')
  .replace(/[\u0300-\u036f]/g, '')
  .toLowerCase();

const pantryTerms = {
  Ovos: ['ovo'],
  Leite: ['leite'],
  Banana: ['banana'],
  Pão: ['pao'],
  Arroz: ['arroz'],
  Macarrão: ['macarrao'],
  Frango: ['frango'],
  Tomate: ['tomate'],
  Cebola: ['cebola'],
  Batata: ['batata'],
  Iogurte: ['iogurte'],
  Atum: ['atum'],
};

const allergenRules = [
  { tag: 'Contém:Ovos', terms: [' ovo', 'ovos'] },
  { tag: 'Contém:Laticínios', terms: ['leite', 'iogurte', 'queijo', 'manteiga', 'creme de leite'] },
  { tag: 'Contém:Glúten', terms: ['farinha de trigo', 'pao ', 'pão ', 'macarrao', 'macarrão', 'aveia', 'tortilha de trigo', 'farinha de rosca', 'trigo para quibe'] },
  { tag: 'Contém:Soja', terms: ['shoyu', 'soja'] },
  { tag: 'Contém:Peixe', terms: ['atum', 'tilapia', 'tilápia', 'file de peixe', 'filé de peixe'] },
  { tag: 'Contém:Gergelim', terms: ['gergelim'] },
  { tag: 'Contém:Mostarda', terms: ['mostarda'] },
  { tag: 'Contém:Amendoim', terms: ['amendoim'] },
  { tag: 'Contém:Castanhas', terms: ['castanha', 'nozes', 'amendoas', 'amêndoas'] },
  { tag: 'Contém:Marisco', terms: ['camarao', 'camarão', 'siri', 'caranguejo', 'marisco'] },
  { tag: 'Contém:Aipo', terms: ['aipo'] },
];

if (!Array.isArray(recipes)) errors.push('recipes must be an array');
if (catalog.batch === 1 && recipes.length !== 50) errors.push(`batch 1 must contain 50 recipes, found ${recipes.length}`);

const ids = new Set();
for (const [index, recipe] of recipes.entries()) {
  const label = `recipes[${index}] (${recipe.id ?? 'missing-id'})`;
  for (const field of required) {
    if (!(field in recipe) || recipe[field] === null) errors.push(`${label}: missing ${field}`);
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(recipe.id)) errors.push(`${label}: id is not kebab-case ASCII`);
  if (ids.has(recipe.id)) errors.push(`${label}: duplicate id`);
  ids.add(recipe.id);
  if (recipe.description.length > 160) errors.push(`${label}: description exceeds 160 characters`);
  for (const field of ['estimatedCost', 'minutes', 'servings', 'portionGrams', 'calories', 'proteinGrams', 'carbGrams', 'fatGrams']) {
    if (typeof recipe[field] !== 'number' || recipe[field] <= 0) errors.push(`${label}: ${field} must be a positive number`);
  }
  if (!Number.isInteger(recipe.healthScore) || recipe.healthScore < 1 || recipe.healthScore > 10) errors.push(`${label}: invalid healthScore`);
  if (!Array.isArray(recipe.ingredients) || recipe.ingredients.length < 2) errors.push(`${label}: too few ingredients`);
  if (!Array.isArray(recipe.steps) || recipe.steps.length < 2) errors.push(`${label}: too few steps`);

  const ingredientText = normalize(recipe.ingredients.join(' '));
  for (const tag of recipe.tags) {
    if (exactTags.has(tag)) continue;
    const [prefix, value] = tag.split(':');
    if (prefix === 'Equipamento' && equipment.has(value)) continue;
    if (prefix === 'Aproveita' && pantry.has(value)) {
      if (!pantryTerms[value].some((term) => ingredientText.includes(normalize(term)))) {
        errors.push(`${label}: ${tag} has no matching ingredient`);
      }
      continue;
    }
    if (prefix === 'Contém' && allergens.has(value)) continue;
    errors.push(`${label}: invalid tag ${tag}`);
  }

  const allergenText = ingredientText.replaceAll('leite de coco', '');
  for (const rule of allergenRules) {
    const present = rule.terms.some((term) => allergenText.includes(normalize(term)));
    if (present && !recipe.tags.includes(rule.tag)) errors.push(`${label}: missing ${rule.tag}`);
  }
  if (ingredientText.includes('atum') && !recipe.tags.includes('Contém:Atum')) errors.push(`${label}: missing Contém:Atum`);
}

if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}

const counts = {
  recipes: recipes.length,
  uniqueIds: ids.size,
  breakfast: recipes.filter((recipe) => recipe.tags.includes('Café da manhã')).length,
  lunch: recipes.filter((recipe) => recipe.tags.includes('Almoço')).length,
  dinner: recipes.filter((recipe) => recipe.tags.includes('Jantar')).length,
  snacks: recipes.filter((recipe) => recipe.tags.includes('Lanches')).length,
  vegetarian: recipes.filter((recipe) => recipe.tags.includes('Vegetariana')).length,
  quick: recipes.filter((recipe) => recipe.tags.includes('Rápido e fácil')).length,
};

console.log(JSON.stringify(counts));
