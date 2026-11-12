import fs from 'node:fs';
import path from 'node:path';
import { recipes } from './generate_recipes_batch_01.mjs';

const batchRecipes = recipes.slice(50, 100);
if (batchRecipes.length !== 50) {
  throw new Error(`Batch 2 must contain 50 recipes, found ${batchRecipes.length}.`);
}

const output = {
  schemaVersion: 1,
  batch: 2,
  totalBatches: 8,
  currency: 'BRL',
  recipes: batchRecipes,
};

const outputDir = path.resolve('assets', 'data');
fs.mkdirSync(outputDir, { recursive: true });
fs.writeFileSync(
  path.join(outputDir, 'recipes_batch_02.json'),
  `${JSON.stringify(output, null, 2)}\n`,
  'utf8',
);

console.log(`Generated ${batchRecipes.length} recipes for batch 2.`);
