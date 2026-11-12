import fs from 'node:fs';
import path from 'node:path';

const plans = new Map(Array.from({ length: 6 }, (_, index) => [index + 3, []]));

function group(batch, method, entries, options = {}) {
  for (const [title, main, secondary, flavor = 'ervas'] of entries) {
    plans.get(batch).push({ title, main, secondary, flavor, method, ...options });
  }
}

const lunch = ['Almoço', 'Jantar'];
const breakfast = ['Café da manhã'];
const snack = ['Lanches'];
const bothSnack = ['Café da manhã', 'Lanches'];

// Lote 3 — pratos brasileiros e regionais.
group(3, 'rice', [
  ['Arroz de costela com agrião', 'costela bovina desfiada', 'agrião', 'alho e louro'],
  ['Arroz com pequi e frango', 'frango em cubos', 'pequi', 'açafrão e cheiro-verde'],
  ['Arroz maria-isabel', 'carne-seca dessalgada', 'arroz', 'cebola e cheiro-verde'],
  ['Arroz de suã com couve', 'suã suína', 'couve', 'alho e páprica'],
  ['Arroz paraense com jambu', 'frango desfiado', 'jambu', 'coentro e limão'],
], { meals: lunch, styles: ['Uma só panela', 'Comida caseira', 'Pratos da família'] });
group(3, 'stew', [
  ['Vaca atolada caseira', 'carne bovina em cubos', 'mandioca', 'alho e louro'],
  ['Rabada simples com agrião', 'rabada bovina', 'agrião', 'tomate e louro'],
  ['Ensopado de bode com batata', 'carne de bode em cubos', 'batata', 'cominho e coentro'],
  ['Frango com quiabo mineiro', 'frango em pedaços', 'quiabo', 'alho e colorau'],
  ['Carne de sol com abóbora', 'carne de sol dessalgada', 'abóbora', 'coentro e pimenta-de-cheiro'],
], { meals: lunch, styles: ['Uma só panela', 'Cozinhar em lote', 'Comida caseira'] });
group(3, 'bake', [
  ['Tainha assada com ervas', 'tainha inteira limpa', 'batata', 'limão e coentro'],
  ['Frango assado com quiabo', 'sobrecoxa de frango', 'quiabo', 'alho e páprica'],
  ['Pernil assado com abacaxi', 'pernil suíno', 'abacaxi', 'alho e alecrim'],
  ['Abóbora recheada com carne-seca', 'carne-seca desfiada', 'abóbora cabotiá', 'cebola e cheiro-verde'],
  ['Pacu assado com tomate', 'pacu em postas', 'tomate', 'limão e ervas'],
], { meals: lunch, styles: ['Pratos da família', 'Comida caseira'] });
group(3, 'couscous', [
  ['Cuscuz paulista de sardinha', 'sardinha', 'farinha de milho', 'tomate e cheiro-verde'],
  ['Cuscuz nordestino com carne de sol', 'carne de sol desfiada', 'flocão de milho', 'cebola e coentro'],
  ['Cuscuz de legumes com queijo coalho', 'legumes picados', 'queijo coalho', 'coentro e orégano'],
  ['Cuscuz com frango e abóbora', 'frango desfiado', 'abóbora', 'açafrão e cheiro-verde'],
  ['Cuscuz de feijão-fradinho', 'feijão-fradinho cozido', 'flocão de milho', 'cebola e coentro'],
], { meals: ['Café da manhã', 'Almoço', 'Jantar'], styles: ['Comida caseira'] });
group(3, 'soup', [
  ['Caldo de mandioca com carne', 'carne bovina desfiada', 'mandioca', 'alho e cheiro-verde'],
  ['Caldo de feijão com couve', 'feijão cozido', 'couve', 'alho e cominho'],
  ['Caldo de abóbora com carne-seca', 'carne-seca desfiada', 'abóbora', 'cebola e coentro'],
  ['Sopa de milho com frango', 'frango desfiado', 'milho', 'cebola e cúrcuma'],
  ['Caldo verde com linguiça', 'linguiça suína', 'batata e couve', 'alho e louro'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Comida caseira'] });
group(3, 'skillet', [
  ['Virado de feijão com couve', 'feijão cozido', 'couve', 'alho e farinha de mandioca'],
  ['Carne de sol acebolada', 'carne de sol em tiras', 'cebola', 'manteiga e coentro'],
  ['Moela ensopada com tomate', 'moela de frango', 'tomate', 'alho e louro'],
  ['Fígado acebolado com pimentão', 'fígado bovino em tiras', 'pimentão', 'alho e limão'],
  ['Picadinho de porco com abacaxi', 'lombo suíno em cubos', 'abacaxi', 'gengibre e limão'],
], { meals: lunch, styles: ['Rápido e fácil', 'Comida caseira'] });
group(3, 'pressure', [
  ['Dobradinha simples com feijão-branco', 'dobradinha limpa', 'feijão-branco', 'tomate e louro'],
  ['Mocotó com legumes', 'mocotó bovino', 'legumes picados', 'coentro e cominho'],
  ['Cupim com mandioca na pressão', 'cupim bovino', 'mandioca', 'alho e louro'],
  ['Costelinha com canjiquinha', 'costelinha suína', 'canjiquinha de milho', 'cebola e cheiro-verde'],
  ['Feijão gordo com abóbora', 'feijão carioca', 'abóbora', 'louro e páprica'],
], { meals: lunch, styles: ['Uma só panela', 'Cozinhar em lote', 'Comida caseira'] });
group(3, 'salad', [
  ['Salada de feijão-verde com queijo coalho', 'feijão-verde cozido', 'queijo coalho', 'coentro e limão'],
  ['Salada de maxixe com tomate', 'maxixe fatiado', 'tomate', 'limão e cheiro-verde'],
  ['Salada de grão-de-bico com carne-seca', 'grão-de-bico cozido', 'carne-seca desfiada', 'cebola e limão'],
  ['Salada de palmito com manga', 'palmito', 'manga', 'limão e hortelã'],
  ['Vinagrete de polvo com feijão-fradinho', 'polvo cozido', 'feijão-fradinho', 'tomate e coentro'],
], { meals: lunch, styles: ['Fresco e leve', 'Mais fibras'] });
group(3, 'pie', [
  ['Empadão de palmito', 'palmito picado', 'ervilha', 'tomate e salsinha'],
  ['Torta de carne-seca com abóbora', 'carne-seca desfiada', 'abóbora', 'cebola e coentro'],
  ['Torta de sardinha com milho', 'sardinha', 'milho', 'tomate e orégano'],
  ['Torta de frango com quiabo', 'frango desfiado', 'quiabo', 'cebola e cheiro-verde'],
  ['Torta de legumes com queijo minas', 'legumes picados', 'queijo minas', 'orégano e salsinha'],
], { meals: ['Almoço', 'Jantar', 'Lanches'], styles: ['Pratos da família'] });
group(3, 'bowl', [
  ['Bowl de arroz, feijão e couve', 'arroz cozido', 'feijão e couve', 'alho e limão'],
  ['Bowl nordestino de macaxeira e frango', 'frango desfiado', 'mandioca cozida', 'coentro e limão'],
  ['Bowl caiçara de peixe e banana', 'peixe grelhado', 'banana-da-terra', 'limão e coentro'],
  ['Bowl mineiro de abóbora e feijão', 'feijão cozido', 'abóbora assada', 'alho e cheiro-verde'],
  ['Bowl de quinoa com carne de sol', 'carne de sol desfiada', 'quinoa cozida', 'cebola e coentro'],
], { meals: lunch, styles: ['Fresco e leve', 'Mais fibras'] });

// Lote 4 — cafés da manhã e lanches.
group(4, 'smoothie', [
  ['Vitamina de manga com linhaça', 'manga', 'linhaça', 'canela'],
  ['Vitamina de morango com chia', 'morango', 'chia', 'baunilha'],
  ['Vitamina de abacate com cacau', 'abacate', 'cacau', 'canela'],
  ['Vitamina de goiaba com aveia', 'goiaba', 'aveia', 'canela'],
  ['Vitamina de abacaxi com hortelã', 'abacaxi', 'hortelã', 'gengibre'],
], { meals: bothSnack, styles: ['Rápido e fácil', 'Fresco e leve', 'Vegetariana'] });
group(4, 'porridge', [
  ['Mingau de aveia com pera', 'aveia', 'pera', 'canela'],
  ['Mingau de quinoa com maçã', 'quinoa em flocos', 'maçã', 'canela'],
  ['Canjica rápida com coco', 'milho para canjica cozido', 'coco ralado', 'canela'],
  ['Mingau de tapioca com maracujá', 'tapioca granulada', 'maracujá', 'baunilha'],
  ['Creme quente de arroz com banana', 'farinha de arroz', 'banana', 'canela'],
], { meals: bothSnack, styles: ['Comida caseira', 'Vegetariana'] });
group(4, 'eggBreakfast', [
  ['Ovos mexidos com espinafre', 'ovos', 'espinafre', 'pimenta-do-reino'],
  ['Ovos assados no tomate', 'ovos', 'tomate', 'orégano'],
  ['Fritada de abobrinha e ervas', 'ovos', 'abobrinha', 'salsinha'],
  ['Omelete de cenoura com queijo minas', 'ovos', 'cenoura e queijo minas', 'orégano'],
  ['Ovos mexidos com cogumelos', 'ovos', 'cogumelos', 'cebolinha'],
], { meals: breakfast, styles: ['Rápido e fácil', 'Vegetariana'] });
group(4, 'sandwich', [
  ['Sanduíche de ricota com cenoura', 'ricota', 'cenoura ralada', 'salsinha'],
  ['Sanduíche de rosbife com rúcula', 'rosbife fatiado', 'rúcula', 'mostarda'],
  ['Sanduíche de grão-de-bico amassado', 'grão-de-bico cozido', 'pepino', 'limão e páprica'],
  ['Sanduíche de queijo minas com goiabada', 'queijo minas', 'goiabada', 'canela'],
  ['Sanduíche de sardinha com cenoura', 'sardinha', 'cenoura ralada', 'limão e cheiro-verde'],
], { meals: bothSnack, styles: ['Rápido e fácil'] });
group(4, 'microwave', [
  ['Cuscuz de caneca com queijo', 'flocão de milho', 'queijo minas', 'orégano'],
  ['Pão de aveia de micro-ondas', 'aveia', 'ovos', 'sal e ervas'],
  ['Batata-doce com canela no micro-ondas', 'batata-doce', 'banana', 'canela'],
  ['Creme de maçã com aveia', 'maçã', 'aveia', 'canela'],
  ['Tapioca de caneca com coco', 'goma de tapioca', 'coco ralado', 'canela'],
], { meals: bothSnack, styles: ['Rápido e fácil', 'Vegetariana'] });
group(4, 'snackBake', [
  ['Muffin de cenoura e aveia', 'cenoura ralada', 'aveia', 'canela'],
  ['Bolo integral de maçã', 'maçã', 'farinha de trigo integral', 'canela'],
  ['Broa assada de fubá e erva-doce', 'fubá', 'erva-doce', 'canela'],
  ['Biscoito de banana e coco', 'banana', 'coco ralado', 'canela'],
  ['Muffin salgado de abobrinha', 'abobrinha ralada', 'queijo minas', 'orégano'],
], { meals: bothSnack, styles: ['Cozinhar em lote', 'Vegetariana'] });
group(4, 'bowlSweet', [
  ['Bowl de iogurte com mamão e chia', 'iogurte natural', 'mamão e chia', 'canela'],
  ['Bowl de açaí com banana e aveia', 'polpa de açaí', 'banana e aveia', 'canela'],
  ['Bowl de frutas com cottage', 'queijo cottage', 'frutas picadas', 'hortelã'],
  ['Bowl de iogurte com manga e coco', 'iogurte natural', 'manga e coco', 'canela'],
  ['Bowl de banana com cacau e amendoim', 'banana', 'cacau e amendoim', 'canela'],
], { meals: bothSnack, styles: ['Rápido e fácil', 'Fresco e leve', 'Vegetariana'] });
group(4, 'patty', [
  ['Bolinho de mandioca com queijo', 'mandioca cozida', 'queijo minas', 'orégano'],
  ['Bolinho de abóbora com aveia', 'abóbora cozida', 'aveia', 'páprica'],
  ['Bolinho de milho com cheiro-verde', 'milho', 'ovos', 'cheiro-verde'],
  ['Croquete de lentilha', 'lentilha cozida', 'cenoura', 'cominho'],
  ['Bolinho de feijão-branco e ervas', 'feijão-branco cozido', 'cebola', 'salsinha'],
], { meals: snack, styles: ['Mais fibras', 'Vegetariana'] });
group(4, 'tapioca', [
  ['Tapioca de queijo com orégano', 'goma de tapioca', 'queijo minas', 'orégano'],
  ['Tapioca de banana com canela', 'goma de tapioca', 'banana', 'canela'],
  ['Tapioca de frango com cenoura', 'goma de tapioca', 'frango desfiado', 'cenoura e cheiro-verde'],
  ['Tapioca de coco com manga', 'goma de tapioca', 'manga e coco', 'canela'],
  ['Tapioca de ovo com espinafre', 'goma de tapioca', 'ovos e espinafre', 'pimenta-do-reino'],
], { meals: bothSnack, styles: ['Rápido e fácil'] });
group(4, 'air', [
  ['Banana assada com aveia na air fryer', 'banana', 'aveia', 'canela'],
  ['Pão recheado com ricota na air fryer', 'pão', 'ricota', 'orégano'],
  ['Grão-de-bico crocante na air fryer', 'grão-de-bico cozido', 'páprica', 'cominho'],
  ['Cubos de queijo coalho com tomate', 'queijo coalho', 'tomate-cereja', 'orégano'],
  ['Pastel assado de palmito', 'massa de pastel', 'palmito', 'salsinha'],
], { meals: snack, styles: ['Rápido e fácil'] });

// Lote 5 — refeições vegetarianas variadas.
group(5, 'stew', [
  ['Ensopado de feijão-branco com espinafre', 'feijão-branco cozido', 'espinafre', 'alho e páprica'],
  ['Ensopado de grão-de-bico com batata-doce', 'grão-de-bico cozido', 'batata-doce', 'cominho e coentro'],
  ['Ensopado de ervilha com abóbora', 'ervilha seca', 'abóbora', 'gengibre e cúrcuma'],
  ['Ensopado de lentilha com couve-flor', 'lentilha cozida', 'couve-flor', 'curry e coentro'],
  ['Ensopado de feijão-preto com mandioca', 'feijão-preto cozido', 'mandioca', 'cominho e cheiro-verde'],
], { meals: lunch, styles: ['Uma só panela', 'Mais fibras', 'Vegetariana', 'Cozinhar em lote'] });
group(5, 'curry', [
  ['Curry de tofu com espinafre', 'tofu', 'espinafre', 'curry e gengibre'],
  ['Curry de lentilha vermelha', 'lentilha vermelha', 'tomate', 'curry e coentro'],
  ['Curry de couve-flor e ervilha', 'couve-flor', 'ervilha', 'curry e cúrcuma'],
  ['Curry de batata-doce com grão-de-bico', 'grão-de-bico cozido', 'batata-doce', 'curry e gengibre'],
  ['Curry de abobrinha com feijão-branco', 'feijão-branco cozido', 'abobrinha', 'curry e manjericão'],
], { meals: lunch, styles: ['Uma só panela', 'Vegetariana', 'Mais fibras'] });
group(5, 'bake', [
  ['Abóbora recheada com quinoa e espinafre', 'quinoa cozida', 'abóbora', 'espinafre e noz-moscada'],
  ['Couve-flor assada com molho de tahine', 'couve-flor', 'tahine', 'limão e páprica'],
  ['Berinjela assada com feijão-branco', 'feijão-branco cozido', 'berinjela', 'tomate e manjericão'],
  ['Batata-doce recheada com lentilha', 'lentilha cozida', 'batata-doce', 'cominho e limão'],
  ['Tomate recheado com cuscuz marroquino', 'cuscuz marroquino', 'tomate', 'hortelã e limão'],
], { meals: lunch, styles: ['Fresco e leve', 'Vegetariana', 'Mais fibras'] });
group(5, 'salad', [
  ['Salada de quinoa com manga', 'quinoa cozida', 'manga', 'limão e hortelã'],
  ['Salada de lentilha com beterraba', 'lentilha cozida', 'beterraba', 'limão e salsinha'],
  ['Salada de feijão-branco com rúcula', 'feijão-branco cozido', 'rúcula', 'tomate e limão'],
  ['Salada de grão-de-bico com abacate', 'grão-de-bico cozido', 'abacate', 'tomate e coentro'],
  ['Salada de ervilha com cenoura e hortelã', 'ervilha cozida', 'cenoura', 'limão e hortelã'],
], { meals: lunch, styles: ['Rápido e fácil', 'Fresco e leve', 'Vegetariana', 'Mais fibras'] });
group(5, 'soup', [
  ['Sopa de tomate com feijão-branco', 'feijão-branco cozido', 'tomate', 'manjericão e alho'],
  ['Sopa de cenoura com lentilha vermelha', 'lentilha vermelha', 'cenoura', 'gengibre e cominho'],
  ['Sopa de couve-flor com grão-de-bico', 'grão-de-bico cozido', 'couve-flor', 'noz-moscada e alho'],
  ['Sopa de beterraba com feijão', 'feijão cozido', 'beterraba', 'limão e endro'],
  ['Sopa de abobrinha com ervilha', 'ervilha cozida', 'abobrinha', 'hortelã e alho'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Vegetariana', 'Mais fibras'] });
group(5, 'pasta', [
  ['Macarrão com lentilha à bolonhesa', 'lentilha cozida', 'macarrão', 'tomate e manjericão'],
  ['Macarrão com creme de couve-flor', 'couve-flor', 'macarrão', 'alho e noz-moscada'],
  ['Macarrão com abóbora e espinafre', 'abóbora', 'macarrão', 'espinafre e sálvia'],
  ['Macarrão com grão-de-bico e limão', 'grão-de-bico cozido', 'macarrão', 'limão e salsinha'],
  ['Macarrão com ervilha e hortelã', 'ervilha', 'macarrão', 'hortelã e limão'],
], { meals: lunch, styles: ['Vegetariana', 'Pratos da família'] });
group(5, 'rice', [
  ['Arroz com lentilha e cebola dourada', 'lentilha cozida', 'arroz', 'cebola e cominho'],
  ['Arroz com grão-de-bico e açafrão', 'grão-de-bico cozido', 'arroz', 'açafrão e salsinha'],
  ['Arroz com tofu e legumes', 'tofu', 'arroz', 'gengibre e cebolinha'],
  ['Arroz com feijão-verde e abóbora', 'feijão-verde cozido', 'arroz e abóbora', 'coentro e cúrcuma'],
  ['Arroz integral com cogumelos e ervilha', 'cogumelos', 'arroz integral e ervilha', 'tomilho e alho'],
], { meals: lunch, styles: ['Uma só panela', 'Vegetariana', 'Mais fibras'] });
group(5, 'patty', [
  ['Hambúrguer de lentilha e cenoura', 'lentilha cozida', 'cenoura', 'cominho'],
  ['Hambúrguer de grão-de-bico e espinafre', 'grão-de-bico cozido', 'espinafre', 'páprica'],
  ['Hambúrguer de ervilha e aveia', 'ervilha cozida', 'aveia', 'hortelã'],
  ['Bolinho de quinoa com abóbora', 'quinoa cozida', 'abóbora', 'cúrcuma'],
  ['Croquete de feijão-branco e alho-poró', 'feijão-branco cozido', 'alho-poró', 'salsinha'],
], { meals: lunch, styles: ['Vegetariana', 'Mais fibras'] });
group(5, 'gratin', [
  ['Gratinado de batata com espinafre', 'batata', 'espinafre', 'noz-moscada'],
  ['Gratinado de couve-flor com queijo', 'couve-flor', 'queijo minas', 'orégano'],
  ['Gratinado de abóbora com ricota', 'abóbora', 'ricota', 'sálvia'],
  ['Gratinado de berinjela com lentilha', 'lentilha cozida', 'berinjela', 'tomate e manjericão'],
  ['Gratinado de chuchu com milho', 'chuchu', 'milho', 'salsinha e noz-moscada'],
], { meals: lunch, styles: ['Vegetariana', 'Pratos da família'] });
group(5, 'skillet', [
  ['Tofu mexido com tomate e cúrcuma', 'tofu', 'tomate', 'cúrcuma e cebolinha'],
  ['Grão-de-bico salteado com couve', 'grão-de-bico cozido', 'couve', 'alho e limão'],
  ['Lentilha salteada com abobrinha', 'lentilha cozida', 'abobrinha', 'cominho e hortelã'],
  ['Feijão-branco com tomate e manjericão', 'feijão-branco cozido', 'tomate', 'alho e manjericão'],
  ['Ervilha com cogumelos e cebola', 'ervilha cozida', 'cogumelos', 'tomilho e cebola'],
], { meals: lunch, styles: ['Rápido e fácil', 'Vegetariana', 'Mais fibras'] });

// Lote 6 — receitas centradas nos equipamentos do questionário.
group(6, 'air', [
  ['Kafta de frango na air fryer', 'frango moído', 'cebola', 'hortelã e cominho'],
  ['Almôndega de peru na air fryer', 'peru moído', 'aveia', 'salsinha e páprica'],
  ['Couve-flor empanada na air fryer', 'couve-flor', 'farinha de rosca', 'páprica'],
  ['Berinjela crocante na air fryer', 'berinjela', 'farinha de rosca', 'orégano'],
  ['Quibe de carne na air fryer', 'carne moída', 'trigo para quibe', 'hortelã'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(6, 'air', [
  ['Espetinho de frango e pimentão', 'frango em cubos', 'pimentão', 'limão e páprica'],
  ['Filé suíno com maçã na air fryer', 'filé suíno', 'maçã', 'alecrim'],
  ['Pescada empanada na air fryer', 'filé de pescada', 'farinha de rosca', 'limão e ervas'],
  ['Abóbora crocante com gergelim', 'abóbora', 'gergelim', 'páprica'],
  ['Palitos de mandioca na air fryer', 'mandioca cozida', 'azeite', 'alho e alecrim'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(6, 'microwave', [
  ['Arroz de micro-ondas com legumes', 'arroz', 'legumes picados', 'cúrcuma'],
  ['Peixe com tomate no micro-ondas', 'filé de peixe', 'tomate', 'limão e ervas'],
  ['Abóbora recheada de micro-ondas', 'abóbora', 'frango desfiado', 'páprica'],
  ['Cuscuz de legumes no micro-ondas', 'flocão de milho', 'legumes picados', 'cheiro-verde'],
  ['Lentilha rápida com cenoura', 'lentilha cozida', 'cenoura', 'cominho'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(6, 'microwave', [
  ['Macarrão de caneca com tomate', 'macarrão', 'tomate', 'orégano'],
  ['Quibe de caneca com abóbora', 'trigo para quibe', 'abóbora', 'hortelã'],
  ['Escondidinho individual de frango', 'frango desfiado', 'batata', 'páprica'],
  ['Legumes ao vapor com molho de iogurte', 'legumes picados', 'iogurte natural', 'limão e ervas'],
  ['Polenta de micro-ondas com queijo', 'fubá', 'queijo minas', 'orégano'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(6, 'blendSoup', [
  ['Creme de cenoura com gengibre', 'cenoura', 'batata', 'gengibre'],
  ['Creme de ervilha com hortelã', 'ervilha cozida', 'batata', 'hortelã'],
  ['Creme de beterraba com iogurte', 'beterraba', 'iogurte natural', 'limão'],
  ['Creme de couve-flor com alho', 'couve-flor', 'batata', 'alho e noz-moscada'],
  ['Creme de tomate com manjericão', 'tomate', 'feijão-branco cozido', 'manjericão'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Fresco e leve'] });
group(6, 'pie', [
  ['Torta cremosa de palmito', 'palmito', 'ervilha', 'salsinha'],
  ['Torta de abobrinha com milho', 'abobrinha', 'milho', 'orégano'],
  ['Torta de carne moída com cenoura', 'carne moída', 'cenoura', 'páprica'],
  ['Torta de alho-poró com ricota', 'alho-poró', 'ricota', 'noz-moscada'],
  ['Torta de peixe com tomate', 'peixe desfiado', 'tomate', 'coentro'],
], { meals: lunch, styles: ['Pratos da família'] });
group(6, 'bake', [
  ['Sobrecoxa assada com mostarda', 'sobrecoxa de frango', 'batata', 'mostarda e alecrim'],
  ['Merluza assada com abobrinha', 'filé de merluza', 'abobrinha', 'limão e ervas'],
  ['Carne moída assada com legumes', 'carne moída', 'legumes picados', 'páprica'],
  ['Lentilha assada com abóbora', 'lentilha cozida', 'abóbora', 'cominho'],
  ['Frango assado com maçã e cebola', 'sobrecoxa de frango', 'maçã e cebola', 'alecrim'],
], { meals: lunch, styles: ['Pratos da família'] });
group(6, 'gratin', [
  ['Gratinado de frango com couve-flor', 'frango desfiado', 'couve-flor', 'noz-moscada'],
  ['Gratinado de peixe com batata', 'peixe desfiado', 'batata', 'salsinha'],
  ['Gratinado de carne com abóbora', 'carne moída', 'abóbora', 'páprica'],
  ['Gratinado de lentilha com mandioca', 'lentilha cozida', 'mandioca', 'tomilho'],
  ['Gratinado de brócolis com arroz', 'brócolis', 'arroz cozido', 'orégano'],
], { meals: lunch, styles: ['Pratos da família', 'Cozinhar em lote'] });
group(6, 'onePan', [
  ['Frango com ervilha e cenoura de uma panela', 'frango em cubos', 'ervilha e cenoura', 'páprica'],
  ['Carne com repolho de uma panela', 'carne bovina em tiras', 'repolho', 'cominho'],
  ['Peixe com leite de coco de uma panela', 'filé de peixe', 'leite de coco', 'coentro'],
  ['Tofu com abóbora de uma panela', 'tofu', 'abóbora', 'gengibre'],
  ['Linguiça com feijão-branco de uma panela', 'linguiça suína', 'feijão-branco cozido', 'louro'],
], { meals: lunch, styles: ['Uma só panela'] });
group(6, 'onePan', [
  ['Macarrão com carne e espinafre', 'carne moída', 'macarrão e espinafre', 'tomate e orégano'],
  ['Arroz com camarão e ervilha', 'camarão', 'arroz e ervilha', 'coentro'],
  ['Quinoa com frango e brócolis', 'frango em cubos', 'quinoa e brócolis', 'limão'],
  ['Cevadinha com cogumelos', 'cevadinha', 'cogumelos', 'tomilho'],
  ['Canjiquinha com legumes', 'canjiquinha de milho', 'legumes picados', 'cheiro-verde'],
], { meals: lunch, styles: ['Uma só panela', 'Mais fibras'] });

// Lote 7 — preparo em lote e refeições familiares.
group(7, 'pressure', [
  ['Acém desfiado com tomate', 'acém bovino', 'tomate', 'alho e louro'],
  ['Frango desfiado com legumes', 'peito de frango', 'legumes picados', 'páprica'],
  ['Pernil desfiado com cebola', 'pernil suíno', 'cebola', 'alho e alecrim'],
  ['Feijão-branco com carne magra', 'carne bovina em cubos', 'feijão-branco', 'louro'],
  ['Grão-de-bico com músculo', 'músculo bovino', 'grão-de-bico', 'cominho'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Comida caseira'] });
group(7, 'bake', [
  ['Frango assado com raízes', 'sobrecoxa de frango', 'raízes variadas', 'alecrim'],
  ['Carne assada com cenoura e alho', 'lagarto bovino', 'cenoura', 'alho e tomilho'],
  ['Peixe inteiro com legumes', 'peixe inteiro limpo', 'legumes picados', 'limão e coentro'],
  ['Pernil com batata-doce', 'pernil suíno', 'batata-doce', 'páprica e alecrim'],
  ['Rocambole de carne com espinafre', 'carne moída', 'espinafre', 'alho e orégano'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Pratos da família'] });
group(7, 'soup', [
  ['Sopa de cevada com carne', 'carne bovina em cubos', 'cevada', 'louro'],
  ['Sopa de frango com grão-de-bico', 'frango desfiado', 'grão-de-bico', 'cúrcuma'],
  ['Sopa de legumes com feijão-branco', 'feijão-branco cozido', 'legumes picados', 'tomilho'],
  ['Sopa de lentilha com carne moída', 'carne moída', 'lentilha', 'cominho'],
  ['Sopa de mandioca com alho-poró', 'mandioca', 'alho-poró', 'noz-moscada'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Mais fibras'] });
group(7, 'pasta', [
  ['Macarrão ao ragu de carne', 'carne bovina desfiada', 'macarrão', 'tomate e louro'],
  ['Macarrão com frango e abóbora', 'frango desfiado', 'macarrão e abóbora', 'sálvia'],
  ['Macarrão com almôndegas de peru', 'almôndegas de peru', 'macarrão', 'tomate e manjericão'],
  ['Macarrão com atum e ervilha', 'atum', 'macarrão e ervilha', 'limão e salsinha'],
  ['Macarrão com carne suína e repolho', 'lombo suíno em tiras', 'macarrão e repolho', 'gengibre'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Pratos da família'] });
group(7, 'rice', [
  ['Arroz com carne moída e cenoura', 'carne moída', 'arroz e cenoura', 'páprica'],
  ['Arroz com frango e lentilha', 'frango em cubos', 'arroz e lentilha', 'cominho'],
  ['Arroz com porco e abóbora', 'lombo suíno em cubos', 'arroz e abóbora', 'sálvia'],
  ['Arroz com peixe e ervilha', 'peixe em cubos', 'arroz e ervilha', 'limão'],
  ['Arroz com carne-seca e feijão-verde', 'carne-seca desfiada', 'arroz e feijão-verde', 'coentro'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Uma só panela', 'Pratos da família'] });
group(7, 'pie', [
  ['Torta familiar de carne e milho', 'carne moída', 'milho', 'páprica'],
  ['Torta familiar de peixe e ervilha', 'peixe desfiado', 'ervilha', 'salsinha'],
  ['Torta familiar de frango e palmito', 'frango desfiado', 'palmito', 'tomate'],
  ['Torta familiar de lentilha e cenoura', 'lentilha cozida', 'cenoura', 'cominho'],
  ['Torta familiar de abóbora e ricota', 'abóbora', 'ricota', 'sálvia'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Pratos da família'] });
group(7, 'stew', [
  ['Ensopado de carne com feijão-verde', 'carne bovina em cubos', 'feijão-verde', 'louro'],
  ['Ensopado de frango com lentilha', 'frango em cubos', 'lentilha', 'cúrcuma'],
  ['Ensopado de peixe com mandioca', 'peixe em cubos', 'mandioca', 'coentro'],
  ['Ensopado suíno com feijão-branco', 'lombo suíno em cubos', 'feijão-branco', 'tomilho'],
  ['Ensopado de peru com batata-doce', 'peru em cubos', 'batata-doce', 'páprica'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Uma só panela'] });
group(7, 'gratin', [
  ['Gratinado familiar de frango e batata', 'frango desfiado', 'batata', 'orégano'],
  ['Gratinado familiar de carne e mandioca', 'carne moída', 'mandioca', 'páprica'],
  ['Gratinado familiar de peixe e abóbora', 'peixe desfiado', 'abóbora', 'salsinha'],
  ['Gratinado familiar de lentilha e arroz', 'lentilha cozida', 'arroz cozido', 'tomilho'],
  ['Gratinado familiar de peru e couve-flor', 'peru desfiado', 'couve-flor', 'noz-moscada'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Pratos da família'] });
group(7, 'casserole', [
  ['Caçarola de frango com milho', 'frango desfiado', 'milho', 'páprica'],
  ['Caçarola de carne com feijão', 'carne moída', 'feijão cozido', 'cominho'],
  ['Caçarola de peixe com arroz', 'peixe desfiado', 'arroz cozido', 'limão'],
  ['Caçarola de legumes com grão-de-bico', 'grão-de-bico cozido', 'legumes picados', 'cúrcuma'],
  ['Caçarola de porco com batata', 'lombo suíno em cubos', 'batata', 'alecrim'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Pratos da família'] });
group(7, 'bowl', [
  ['Marmita de frango, arroz integral e brócolis', 'frango grelhado', 'arroz integral e brócolis', 'limão'],
  ['Marmita de carne, feijão e abóbora', 'carne bovina em tiras', 'feijão e abóbora', 'páprica'],
  ['Marmita de peixe, quinoa e cenoura', 'peixe grelhado', 'quinoa e cenoura', 'limão'],
  ['Marmita de lentilha, arroz e couve', 'lentilha cozida', 'arroz e couve', 'alho'],
  ['Marmita de porco, batata-doce e repolho', 'lombo suíno', 'batata-doce e repolho', 'mostarda'],
], { meals: lunch, styles: ['Cozinhar em lote', 'Fresco e leve'] });

// Lote 8 — aproveitamento da despensa e de preparações já cozidas.
group(8, 'leftoverRice', [
  ['Arroz crocante com legumes', 'arroz cozido', 'legumes picados', 'gengibre'],
  ['Arroz refogado com ovo e couve', 'arroz cozido', 'ovos e couve', 'alho'],
  ['Arroz com feijão e abóbora salteada', 'arroz cozido', 'feijão e abóbora', 'cominho'],
  ['Arroz frio com pepino e cenoura', 'arroz cozido', 'pepino e cenoura', 'limão'],
  ['Panela de arroz com sardinha', 'arroz cozido', 'sardinha', 'tomate e cheiro-verde'],
], { meals: lunch, styles: ['Rápido e fácil', 'Uma só panela'] });
group(8, 'leftoverBeans', [
  ['Tutú rápido de feijão', 'feijão cozido', 'farinha de mandioca', 'alho e cheiro-verde'],
  ['Pasta de feijão-branco com limão', 'feijão-branco cozido', 'limão', 'alho e salsinha'],
  ['Salada de feijão com tomate e milho', 'feijão cozido', 'tomate e milho', 'limão'],
  ['Feijão refogado com ovo', 'feijão cozido', 'ovos', 'cebola e cominho'],
  ['Bolinho assado de feijão e aveia', 'feijão cozido', 'aveia', 'páprica'],
], { meals: ['Almoço', 'Jantar', 'Lanches'], styles: ['Rápido e fácil', 'Mais fibras'] });
group(8, 'leftoverBread', [
  ['Pudim salgado de pão e legumes', 'pão amanhecido', 'legumes picados', 'orégano'],
  ['Farofa de pão com ervas', 'pão amanhecido', 'cebola', 'salsinha'],
  ['Torrada de pão com tomate assado', 'pão amanhecido', 'tomate', 'manjericão'],
  ['Sopa de pão com feijão-branco', 'pão amanhecido', 'feijão-branco', 'alho e tomilho'],
  ['Croquete de pão com queijo', 'pão amanhecido', 'queijo minas', 'orégano'],
], { meals: ['Café da manhã', 'Lanches', 'Jantar'], styles: ['Rápido e fácil'] });
group(8, 'leftoverEggs', [
  ['Ovos ao forno com arroz e legumes', 'ovos', 'arroz cozido e legumes', 'orégano'],
  ['Salada de batata com ovo e iogurte', 'ovos cozidos', 'batata e iogurte', 'mostarda'],
  ['Cuscuz mexido com ovos', 'ovos', 'flocão de milho', 'cheiro-verde'],
  ['Panela de ovos com espinafre e feijão', 'ovos', 'espinafre e feijão', 'cominho'],
  ['Patê de ovo com cenoura', 'ovos cozidos', 'cenoura e iogurte', 'salsinha'],
], { meals: ['Café da manhã', 'Almoço', 'Jantar', 'Lanches'], styles: ['Rápido e fácil'] });
group(8, 'leftoverBanana', [
  ['Bolo de banana madura e aveia', 'banana madura', 'aveia', 'canela'],
  ['Doce rápido de banana com cacau', 'banana madura', 'cacau', 'canela'],
  ['Sorvete de banana com amendoim', 'banana congelada', 'amendoim', 'canela'],
  ['Pão de banana de frigideira', 'banana madura', 'ovos', 'canela'],
  ['Crumble de banana com castanhas', 'banana madura', 'castanhas e aveia', 'canela'],
], { meals: bothSnack, styles: ['Vegetariana'] });
group(8, 'leftoverMilk', [
  ['Creme de milho com leite', 'milho', 'leite', 'noz-moscada'],
  ['Sopa branca de couve-flor', 'couve-flor', 'leite', 'alho e noz-moscada'],
  ['Arroz cremoso com leite e legumes', 'arroz cozido', 'leite e legumes', 'orégano'],
  ['Pudim de chia com manga', 'chia', 'leite e manga', 'baunilha'],
  ['Molho branco leve com espinafre', 'espinafre', 'leite', 'noz-moscada'],
], { meals: ['Café da manhã', 'Almoço', 'Jantar', 'Lanches'], styles: ['Rápido e fácil'] });
group(8, 'leftoverPasta', [
  ['Fritada de macarrão com legumes', 'macarrão cozido', 'ovos e legumes', 'orégano'],
  ['Salada de macarrão com feijão-branco', 'macarrão cozido', 'feijão-branco', 'limão'],
  ['Macarrão assado com abóbora', 'macarrão cozido', 'abóbora', 'sálvia'],
  ['Sopa de macarrão com lentilha', 'macarrão cozido', 'lentilha', 'cominho'],
  ['Macarrão salteado com ovo e repolho', 'macarrão cozido', 'ovos e repolho', 'gengibre'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(8, 'leftoverChicken', [
  ['Salpicão leve de frango', 'frango cozido e desfiado', 'cenoura e iogurte', 'limão'],
  ['Panqueca recheada de frango e espinafre', 'frango cozido e desfiado', 'espinafre', 'orégano'],
  ['Sopa cremosa de frango e milho', 'frango cozido e desfiado', 'milho', 'cúrcuma'],
  ['Cuscuz de frango com tomate', 'frango cozido e desfiado', 'flocão e tomate', 'coentro'],
  ['Bolinho de frango com mandioca', 'frango cozido e desfiado', 'mandioca', 'páprica'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(8, 'leftoverPotato', [
  ['Salada morna de batata e lentilha', 'batata cozida', 'lentilha', 'mostarda'],
  ['Ninho de batata com ovo', 'batata cozida', 'ovos', 'orégano'],
  ['Purê de batata com couve-flor', 'batata cozida', 'couve-flor', 'noz-moscada'],
  ['Bolinho de batata com espinafre', 'batata cozida', 'espinafre', 'páprica'],
  ['Sopa rústica de batata e feijão', 'batata cozida', 'feijão', 'alho e louro'],
], { meals: lunch, styles: ['Rápido e fácil'] });
group(8, 'leftoverTuna', [
  ['Arroz frio com atum e pepino', 'atum', 'arroz cozido e pepino', 'limão'],
  ['Batata recheada fria com atum', 'atum', 'batata e iogurte', 'salsinha'],
  ['Omelete de atum com tomate', 'atum', 'ovos e tomate', 'orégano'],
  ['Feijão-branco com atum e cebola', 'atum', 'feijão-branco', 'limão e salsinha'],
  ['Patê de atum com cenoura e limão', 'atum', 'cenoura e iogurte', 'limão'],
], { meals: ['Almoço', 'Jantar', 'Lanches'], styles: ['Rápido e fácil', 'Fresco e leve'] });

function findPlan(batch, title) {
  const plan = plans.get(batch).find((item) => item.title === title);
  if (!plan) throw new Error(`Plan not found in batch ${batch}: ${title}`);
  return plan;
}

function addExtra(batch, titles, ingredient) {
  for (const title of titles) {
    const plan = findPlan(batch, title);
    plan.extraIngredients = [...(plan.extraIngredients ?? []), ingredient];
  }
}

function replacePlan(batch, oldTitle, replacement) {
  Object.assign(findPlan(batch, oldTitle), replacement);
}

// Completa a cobertura mínima de ingredientes da despensa sem criar receitas duplicadas.
addExtra(4, ['Vitamina de manga com linhaça', 'Vitamina de morango com chia', 'Vitamina de abacate com cacau', 'Vitamina de goiaba com aveia', 'Vitamina de abacaxi com hortelã', 'Mingau de aveia com pera', 'Mingau de quinoa com maçã'], '1 banana madura');
addExtra(3, ['Caldo de mandioca com carne', 'Caldo de feijão com couve', 'Caldo de abóbora com carne-seca', 'Sopa de milho com frango', 'Caldo verde com linguiça'], '5 fatias de pão integral para acompanhar');
addExtra(5, ['Sopa de tomate com feijão-branco', 'Sopa de cenoura com lentilha vermelha', 'Sopa de couve-flor com grão-de-bico', 'Sopa de beterraba com feijão', 'Sopa de abobrinha com ervilha'], '5 fatias de pão integral para acompanhar');
addExtra(6, ['Creme de cenoura com gengibre', 'Creme de ervilha com hortelã', 'Creme de beterraba com iogurte'], '5 fatias de pão integral para acompanhar');
addExtra(3, ['Caldo de mandioca com carne', 'Caldo de feijão com couve', 'Sopa de milho com frango'], '1 xícara de macarrão pequeno');
addExtra(5, ['Sopa de tomate com feijão-branco', 'Sopa de cenoura com lentilha vermelha', 'Sopa de couve-flor com grão-de-bico'], '1 xícara de macarrão pequeno');
addExtra(5, ['Salada de quinoa com manga', 'Salada de lentilha com beterraba', 'Salada de feijão-branco com rúcula', 'Salada de grão-de-bico com abacate', 'Salada de ervilha com cenoura e hortelã'], '1 pote de iogurte natural para o molho');
addExtra(6, ['Couve-flor empanada na air fryer', 'Berinjela crocante na air fryer', 'Abóbora crocante com gergelim'], '1 pote de iogurte natural para o molho');

// Amplia o conjunto de receitas com atum para que o filtro de despensa tenha variedade real.
replacePlan(3, 'Salada de maxixe com tomate', { title: 'Salada de maxixe com atum e tomate', main: 'atum', secondary: 'maxixe e tomate' });
replacePlan(3, 'Salada de palmito com manga', { title: 'Salada de palmito, manga e atum', main: 'atum', secondary: 'palmito e manga' });
replacePlan(3, 'Bowl de arroz, feijão e couve', { title: 'Bowl de arroz, atum e couve', main: 'atum', secondary: 'arroz cozido e couve' });
replacePlan(3, 'Bowl de quinoa com carne de sol', { title: 'Bowl de quinoa, atum e cebola', main: 'atum', secondary: 'quinoa cozida e cebola' });
replacePlan(3, 'Torta de legumes com queijo minas', { title: 'Torta de atum com legumes', main: 'atum', secondary: 'legumes picados' });
replacePlan(4, 'Sanduíche de ricota com cenoura', { title: 'Sanduíche de atum, ricota e cenoura', main: 'atum', secondary: 'ricota e cenoura ralada' });
replacePlan(4, 'Sanduíche de grão-de-bico amassado', { title: 'Sanduíche de atum com grão-de-bico', main: 'atum', secondary: 'grão-de-bico amassado' });
replacePlan(4, 'Tapioca de queijo com orégano', { title: 'Tapioca de atum com queijo', main: 'atum', secondary: 'queijo minas' });
replacePlan(4, 'Tapioca de ovo com espinafre', { title: 'Tapioca de atum com espinafre', main: 'atum', secondary: 'espinafre' });
replacePlan(6, 'Arroz de micro-ondas com legumes', { title: 'Arroz de micro-ondas com atum e legumes', main: 'atum', secondary: 'arroz e legumes picados' });
replacePlan(6, 'Abóbora recheada de micro-ondas', { title: 'Abóbora de micro-ondas recheada com atum', main: 'atum', secondary: 'abóbora' });
replacePlan(6, 'Cuscuz de legumes no micro-ondas', { title: 'Flocão temperado com atum e legumes', main: 'atum', secondary: 'flocão e legumes picados' });
replacePlan(6, 'Macarrão de caneca com tomate', { title: 'Macarrão de caneca com atum e tomate', main: 'atum', secondary: 'macarrão e tomate' });
replacePlan(7, 'Macarrão com frango e abóbora', { title: 'Macarrão com atum e abóbora', main: 'atum', secondary: 'macarrão e abóbora' });
replacePlan(7, 'Torta familiar de peixe e ervilha', { title: 'Torta familiar de atum e ervilha', main: 'atum', secondary: 'ervilha' });
replacePlan(7, 'Caçarola de peixe com arroz', { title: 'Caçarola de atum com arroz', main: 'atum', secondary: 'arroz cozido' });
replacePlan(7, 'Marmita de peixe, quinoa e cenoura', { title: 'Marmita de atum, quinoa e cenoura', main: 'atum', secondary: 'quinoa e cenoura' });

// Uma preparação originalmente de fogão também funciona integralmente no micro-ondas.
findPlan(8, 'Doce rápido de banana com cacau').method = 'microwave';

const methodConfig = {
  rice: { equipment: ['Fogão', 'Panela'], minutes: 42, styles: ['Uma só panela'] },
  stew: { equipment: ['Fogão', 'Panela'], minutes: 48, styles: ['Uma só panela'] },
  bake: { equipment: ['Forno'], minutes: 50, styles: [] },
  couscous: { equipment: ['Fogão', 'Panela'], minutes: 25, styles: [] },
  soup: { equipment: ['Fogão', 'Panela'], minutes: 42, styles: ['Uma só panela'] },
  skillet: { equipment: ['Fogão'], minutes: 25, styles: ['Rápido e fácil'] },
  pressure: { equipment: ['Fogão', 'Panela'], minutes: 65, styles: ['Uma só panela'] },
  salad: { equipment: [], minutes: 18, styles: ['Rápido e fácil', 'Fresco e leve'] },
  pie: { equipment: ['Liquidificador', 'Forno'], minutes: 55, styles: ['Pratos da família'] },
  bowl: { equipment: [], minutes: 20, styles: ['Rápido e fácil', 'Fresco e leve'] },
  smoothie: { equipment: ['Liquidificador'], minutes: 5, styles: ['Rápido e fácil'] },
  porridge: { equipment: ['Fogão', 'Panela'], minutes: 18, styles: [] },
  eggBreakfast: { equipment: ['Fogão'], minutes: 15, styles: ['Rápido e fácil'] },
  sandwich: { equipment: [], minutes: 10, styles: ['Rápido e fácil'] },
  microwave: { equipment: ['Micro-ondas'], minutes: 12, styles: ['Rápido e fácil'] },
  snackBake: { equipment: ['Forno'], minutes: 40, styles: [] },
  bowlSweet: { equipment: [], minutes: 8, styles: ['Rápido e fácil', 'Fresco e leve'] },
  patty: { equipment: ['Air fryer'], minutes: 32, styles: [] },
  tapioca: { equipment: ['Fogão'], minutes: 12, styles: ['Rápido e fácil'] },
  air: { equipment: ['Air fryer'], minutes: 30, styles: [] },
  curry: { equipment: ['Fogão', 'Panela'], minutes: 38, styles: ['Uma só panela'] },
  pasta: { equipment: ['Fogão', 'Panela'], minutes: 32, styles: [] },
  gratin: { equipment: ['Forno'], minutes: 45, styles: [] },
  onePan: { equipment: ['Fogão', 'Panela'], minutes: 38, styles: ['Uma só panela'] },
  blendSoup: { equipment: ['Fogão', 'Panela', 'Liquidificador'], minutes: 38, styles: ['Cozinhar em lote'] },
  casserole: { equipment: ['Forno'], minutes: 50, styles: ['Pratos da família'] },
  leftoverRice: { equipment: ['Fogão', 'Panela'], minutes: 18, styles: ['Rápido e fácil'] },
  leftoverBeans: { equipment: ['Fogão', 'Panela'], minutes: 20, styles: ['Rápido e fácil'] },
  leftoverBread: { equipment: ['Forno'], minutes: 25, styles: ['Rápido e fácil'] },
  leftoverEggs: { equipment: ['Fogão'], minutes: 18, styles: ['Rápido e fácil'] },
  leftoverBanana: { equipment: ['Fogão'], minutes: 20, styles: [] },
  leftoverMilk: { equipment: ['Fogão', 'Panela'], minutes: 22, styles: [] },
  leftoverPasta: { equipment: ['Fogão', 'Panela'], minutes: 24, styles: [] },
  leftoverChicken: { equipment: ['Fogão', 'Panela'], minutes: 25, styles: [] },
  leftoverPotato: { equipment: ['Fogão', 'Panela'], minutes: 25, styles: [] },
  leftoverTuna: { equipment: [], minutes: 15, styles: ['Rápido e fácil'] },
};

const normalize = (value) => value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
const slug = (value) => normalize(value).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

function measured(value, role = 'main') {
  const text = normalize(value);
  if (text.includes('ovos')) return role === 'main' ? '4 ovos' : `3 ovos com ${value.replace(/ovos(?: cozidos)?/i, '').trim()}`;
  if (/(frango|carne|lombo|pernil|peixe|pescada|merluza|salmao|tainha|pacu|camarao|polvo|bode|figado|moela|costela|rabada|mocoto|cupim|linguica|peru|sardinha|atum)/.test(text)) return `500 g de ${value}`;
  if (/(arroz|feijao|lentilha|grao-de-bico|ervilha|quinoa|cevada|canjiquinha|cuscuz|flocao|macarrao|aveia|fuba|tapioca|trigo)/.test(text)) return `2 xícaras de ${value}`;
  if (/(leite|iogurte)/.test(text)) return `2 xícaras de ${value}`;
  return role === 'main' ? `3 xícaras de ${value}` : `2 xícaras de ${value}`;
}

function ingredientsFor(plan) {
  const main = measured(plan.main, 'main');
  const secondary = measured(plan.secondary, 'secondary');
  const common = ['1 cebola pequena picada', '1 colher de sopa de azeite', `Sal, alho, ${plan.flavor} a gosto`];
  switch (plan.method) {
    case 'smoothie': return [measured(plan.main), measured(plan.secondary), '2 xícaras de leite gelado', '1 colher de sopa de sementes de chia'];
    case 'porridge': return [measured(plan.main), measured(plan.secondary), '3 xícaras de leite', 'Canela a gosto'];
    case 'eggBreakfast': return ['4 ovos', secondary, '1 colher de chá de azeite', `Sal e ${plan.flavor} a gosto`];
    case 'sandwich': return ['8 fatias de pão integral', main, secondary, `Sal e ${plan.flavor} a gosto`];
    case 'microwave': return [main, secondary, '1/2 xícara de água ou leite, conforme necessário', `Sal ou canela e ${plan.flavor} a gosto`];
    case 'snackBake': return [main, secondary, '2 ovos', '1 xícara de leite', '1 xícara de farinha de trigo', '1 colher de sopa de fermento químico'];
    case 'bowlSweet': return [main, secondary, '1 colher de sopa de sementes de chia', 'Canela a gosto'];
    case 'tapioca': return ['8 colheres de sopa de goma de tapioca hidratada', main, secondary, `Sal ou canela e ${plan.flavor} a gosto`];
    case 'pie': return [main, secondary, '2 xícaras de farinha de trigo', '2 xícaras de leite', '3 ovos', '1/2 xícara de óleo', '1 colher de sopa de fermento químico'];
    case 'salad': return [main, secondary, '2 tomates picados', '1/2 cebola fatiada', 'Suco de 1 limão', '1 colher de sopa de azeite', `Sal e ${plan.flavor} a gosto`];
    case 'bowl': return [main, secondary, '1 tomate picado', '1 cenoura ralada', 'Suco de 1 limão', `Sal e ${plan.flavor} a gosto`];
    case 'pasta': return [main, secondary, '350 g de macarrão', '2 tomates picados', ...common];
    case 'rice': return [main, secondary, '2 xícaras de arroz cru', '4 xícaras de água quente', ...common];
    case 'couscous': return [main, secondary, '1 e 1/2 xícara de flocão de milho', '3/4 de xícara de água', ...common];
    case 'pressure': return [main, secondary, '4 xícaras de água quente', '2 tomates picados', ...common];
    case 'soup':
    case 'blendSoup': return [main, secondary, '1,5 litro de água', '1 cenoura em cubos', ...common];
    case 'gratin': return [main, secondary, '1 xícara de leite', '1/2 xícara de queijo muçarela ralado', `Sal e ${plan.flavor} a gosto`];
    case 'patty': return [main, secondary, '1/2 xícara de aveia em flocos', '1 colher de sopa de azeite', `Sal e ${plan.flavor} a gosto`];
    case 'air': return [main, secondary, '1 colher de sopa de azeite', `Sal e ${plan.flavor} a gosto`];
    case 'bake':
    case 'casserole': return [main, secondary, '2 tomates picados', '1 colher de sopa de azeite', `Sal e ${plan.flavor} a gosto`];
    case 'leftoverBread': return [main, secondary, '2 ovos', '1 xícara de leite', `Sal e ${plan.flavor} a gosto`];
    case 'leftoverBanana': return [main, secondary, '2 ovos', '4 colheres de sopa de aveia', 'Canela a gosto'];
    case 'leftoverMilk': return [main, secondary, '2 xícaras de leite', `Sal ou canela e ${plan.flavor} a gosto`];
    default: return [main, secondary, '2 tomates picados', ...common];
  }
}

function stepsFor(plan) {
  const m = plan.method;
  if (m === 'smoothie') return ['Higienize e corte os ingredientes.', 'Bata tudo no liquidificador até ficar homogêneo.', 'Sirva imediatamente.'];
  if (m === 'salad' || m === 'bowl' || m === 'bowlSweet' || m === 'leftoverTuna') return ['Prepare e resfrie previamente os ingredientes que exigem cozimento.', 'Misture os ingredientes em uma tigela grande.', `Tempere com ${plan.flavor} e sirva.`];
  if (m === 'sandwich') return ['Prepare o recheio e ajuste os temperos.', 'Distribua o recheio entre as fatias de pão.', 'Feche os sanduíches e sirva.'];
  if (m === 'microwave') return ['Misture os ingredientes em recipiente grande próprio para micro-ondas.', 'Cozinhe em intervalos de 2 minutos, mexendo entre eles.', 'Continue até todos os ingredientes estarem macios e completamente cozidos.'];
  if (m === 'air' || m === 'patty') return ['Misture ou tempere os ingredientes e modele quando necessário.', 'Preaqueça a air fryer a 190 °C.', 'Asse por 15 a 25 minutos, virando na metade, até dourar e cozinhar por completo.'];
  if (m === 'bake' || m === 'gratin' || m === 'casserole' || m === 'snackBake' || m === 'leftoverBread') return ['Preaqueça o forno a 200 °C e prepare uma assadeira.', 'Misture e tempere os ingredientes e distribua na assadeira.', 'Asse por 25 a 40 minutos, até o centro estar cozido e a superfície dourada.'];
  if (m === 'pie') return ['Preaqueça o forno a 180 °C e prepare o recheio.', 'Bata os ingredientes da massa no liquidificador e misture o fermento.', 'Monte massa, recheio e massa em uma assadeira.', 'Asse por 35 a 40 minutos, até o centro ficar firme.'];
  if (m === 'pressure') return ['Doure os ingredientes principais e refogue os temperos na panela de pressão.', 'Adicione a água, tampe e cozinhe sob pressão pelo tempo adequado ao ingrediente.', 'Aguarde a pressão sair naturalmente, abra e cozinhe sem tampa até o caldo encorpar.'];
  if (m === 'soup' || m === 'blendSoup') return ['Refogue a cebola e o alho no azeite.', 'Junte os demais ingredientes e a água e cozinhe até ficarem macios.', ...(m === 'blendSoup' ? ['Bata com cuidado no liquidificador, devolva à panela e aqueça.'] : ['Ajuste os temperos e sirva quente.'])];
  if (m === 'porridge') return ['Dissolva o ingrediente seco em parte do leite frio.', 'Junte os demais ingredientes e cozinhe em fogo baixo.', 'Mexa até engrossar e sirva quente.'];
  if (m === 'eggBreakfast' || m === 'tapioca' || m === 'skillet' || m.startsWith('leftover')) return ['Prepare e tempere os ingredientes.', 'Aqueça uma frigideira ou panela e cozinhe em fogo médio, mexendo quando necessário.', 'Finalize quando tudo estiver aquecido e completamente cozido.'];
  if (m === 'pasta') return ['Cozinhe o macarrão até ficar al dente e reserve parte da água.', 'Prepare o molho com os demais ingredientes em uma panela.', 'Misture a massa ao molho, ajuste a textura com a água reservada e sirva.'];
  if (m === 'rice' || m === 'couscous') return ['Refogue os ingredientes e os temperos no azeite.', 'Junte o cereal e a água e cozinhe em fogo baixo.', 'Desligue quando o líquido for absorvido, descanse por 5 minutos e solte com um garfo.'];
  return ['Refogue a cebola e os temperos no azeite.', 'Adicione os ingredientes principais e cozinhe em fogo médio.', 'Junte água aos poucos quando necessário e cozinhe até tudo ficar macio e seguro para consumo.'];
}

function tagsFor(plan, ingredients) {
  const config = methodConfig[plan.method];
  const tags = [...plan.meals, ...new Set([...(plan.styles ?? []), ...config.styles])];
  for (const item of config.equipment) tags.push(`Equipamento:${item}`);
  const text = normalize(ingredients.join(' ')).replaceAll('leite de coco', '');
  const pantry = { Ovos: 'ovo', Leite: 'leite', Banana: 'banana', Pão: 'pao', Arroz: 'arroz', Macarrão: 'macarrao', Frango: 'frango', Tomate: 'tomate', Cebola: 'cebola', Batata: 'batata', Iogurte: 'iogurte', Atum: 'atum' };
  for (const [name, term] of Object.entries(pantry)) if (text.includes(term)) tags.push(`Aproveita:${name}`);
  const allergens = {
    Amendoim: ['amendoim'], Castanhas: ['castanha', 'nozes', 'amendoa'],
    Laticínios: ['leite', 'iogurte', 'queijo', 'manteiga', 'ricota', 'cottage'],
    Ovos: ['ovo'], Glúten: ['pao', 'farinha de trigo', 'farinha de rosca', 'macarrao', 'aveia', 'cevada', 'trigo', 'massa de pastel'],
    Soja: ['tofu', 'shoyu', 'soja'], Marisco: ['camarao', 'polvo', 'siri', 'caranguejo'],
    Peixe: ['peixe', 'pescada', 'merluza', 'salmao', 'tainha', 'pacu', 'sardinha', 'atum'],
    Gergelim: ['gergelim', 'tahine'], Mostarda: ['mostarda'], Aipo: ['aipo'],
  };
  for (const [name, terms] of Object.entries(allergens)) if (terms.some((term) => text.includes(term))) tags.push(`Contém:${name}`);
  if (text.includes('atum')) tags.push('Contém:Atum');
  return [...new Set(tags)];
}

function estimates(plan, index) {
  const text = normalize(`${plan.main} ${plan.secondary}`);
  let cost = 17 + (index % 8) * 1.7;
  let protein = 14;
  if (/(carne|frango|lombo|pernil|peixe|pescada|merluza|salmao|tainha|pacu|camarao|polvo|atum|sardinha|peru|linguica|figado|moela)/.test(text)) { cost += 15; protein = 33; }
  if (/(feijao|lentilha|grao-de-bico|ervilha|tofu)/.test(text)) protein = Math.max(protein, 18);
  if (/(salmao|camarao|polvo|pacu|tainha)/.test(text)) cost += 14;
  const calories = 320 + (index % 6) * 35;
  return { cost: Number(cost.toFixed(2)), calories, protein, carbs: 42 + (index % 5) * 8, fat: 8 + (index % 6) * 2, score: 7 + (index % 3) };
}

function makeRecipe(plan, index) {
  const ingredients = [...ingredientsFor(plan), ...(plan.extraIngredients ?? [])];
  const stats = estimates(plan, index);
  const config = methodConfig[plan.method];
  const servings = plan.meals.includes('Café da manhã') && !plan.meals.includes('Almoço') ? 3 : 5;
  return {
    id: slug(plan.title), title: plan.title,
    description: `${plan.title} com ingredientes acessíveis e preparo adequado à rotina doméstica.`,
    estimatedCost: stats.cost, minutes: config.minutes + (index % 3) * 3, servings,
    tags: tagsFor(plan, ingredients), ingredients, steps: stepsFor(plan),
    portionGrams: servings === 3 ? 260 : 390,
    calories: stats.calories, proteinGrams: stats.protein, carbGrams: stats.carbs,
    fatGrams: stats.fat, healthScore: stats.score,
  };
}

const existing = [1, 2].flatMap((batch) => JSON.parse(fs.readFileSync(path.resolve('assets', 'data', `recipes_batch_0${batch}.json`), 'utf8')).recipes);
const allIds = new Set(existing.map((recipe) => recipe.id));
const allTitles = new Set(existing.map((recipe) => normalize(recipe.title)));
const outputDir = path.resolve('assets', 'data');
fs.mkdirSync(outputDir, { recursive: true });

for (const [batch, batchPlans] of plans) {
  if (batchPlans.length !== 50) throw new Error(`Batch ${batch} has ${batchPlans.length} plans instead of 50.`);
  const recipes = batchPlans.map(makeRecipe);
  for (const recipe of recipes) {
    if (allIds.has(recipe.id)) throw new Error(`Duplicate id: ${recipe.id}`);
    if (allTitles.has(normalize(recipe.title))) throw new Error(`Duplicate title: ${recipe.title}`);
    allIds.add(recipe.id);
    allTitles.add(normalize(recipe.title));
  }
  const output = { schemaVersion: 1, batch, totalBatches: 8, currency: 'BRL', recipes };
  fs.writeFileSync(path.join(outputDir, `recipes_batch_0${batch}.json`), `${JSON.stringify(output, null, 2)}\n`, 'utf8');
  console.log(`Generated batch ${batch}: ${recipes.length} recipes.`);
}

console.log(`Catalog total: ${allIds.size} unique recipes.`);
