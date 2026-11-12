# Origem — conceito de experiência 3D

## Leitura estratégica do produto atual

O Origem já é um produto funcional de inteligência alimentar, não apenas um scanner. O aplicativo reúne:

- início com ação principal de escanear e histórico recente;
- scanner por câmera e entrada manual de código de barras;
- consulta de produto, nota nutricional de 0 a 10, nutrientes, alertas, favoritos e detalhes;
- histórico de produtos consultados;
- planejamento semanal de refeições em nove etapas;
- seleção de pessoas, refeições, dias, equipamentos, estilos, alergias, rejeições, despensa e orçamento;
- cozinha interativa com seis equipamentos selecionáveis;
- catálogo local de receitas, cálculo de custo, porções, macros, ingredientes, preparo e geração de lista;
- lista de compras persistente, com quantidades, estados, adição, remoção, limpeza e cópia;
- área Aprender com filtros, vídeo publicado e conteúdos futuros;
- conta local e persistência no dispositivo.

A implementação atual já usa fundo azul-marinho, cards Material 3 escuros, acentos laranja/azul/verde, transições suaves, um hero 3D estático e uma cena de cozinha interativa. O problema não é ausência de acabamento: é que a experiência ainda se organiza como um aplicativo convencional de cards. O 3D aparece principalmente como imagem dentro da interface, em vez de ser a própria estrutura da experiência. Há muitos containers semelhantes, bordas constantes, ícones Material e grids que diluem a personalidade. A navegação tem cinco destinos com o mesmo peso e o fluxo Planejar, embora poderoso, parece um formulário longo.

O novo conceito deve unir dois princípios:

1. **More Nutrition — 3D Concept:** direção editorial, objeto central flutuante, tipografia de grande escala, cenas monocromáticas, composição assimétrica e movimento com intenção.
2. **PlateLens:** produto nutricional confiável, dados explicados com clareza, sensação de inteligência, transparência sobre a origem e a incerteza dos dados e interações orientadas à correção e à decisão.

Não copiar layout, marca, assets ou textos dessas referências. Traduzir seus princípios para uma identidade própria do Origem.

---

## Direção de produto

A direção do produto reúne design de experiência, arte editorial, motion design, informação nutricional, acessibilidade e performance mobile/web em Flutter.

Redesenhe completamente o aplicativo **Origem**, uma plataforma brasileira de inteligência alimentar que ajuda pessoas a entender produtos pelo código de barras, interpretar informações nutricionais, planejar refeições, aprender sobre alimentação e transformar receitas em uma lista de compras.

O objetivo não é aplicar uma nova paleta sobre os componentes existentes. Crie uma nova linguagem de produto, com estrutura, composição, navegação, motion e componentes próprios. A experiência deve parecer uma fusão autoral entre um site editorial 3D premiado e um instrumento de saúde confiável: **imersiva no primeiro contato, clara durante a decisão e silenciosa quando o usuário precisa ler dados**.

Use como referência conceitual a presença de produto, as cenas monocromáticas, a tipografia monumental e o motion da experiência More Nutrition — 3D Concept; e a clareza, a confiança, a visualização de dados e a inteligência nutricional do PlateLens. Não reproduza telas, logotipos, embalagens, cores, textos, animações ou modelos 3D dessas marcas.

### 1. Conceito criativo: “Veja além do rótulo”

A identidade do Origem deve nascer da ideia de que o aplicativo revela camadas invisíveis dos alimentos.

- O código de barras se transforma em uma linha viva que percorre a interface, conecta telas, desenha gráficos e revela informações.
- Alimentos, embalagens neutras, pratos e utensílios aparecem como objetos 3D táteis, suspensos em um espaço editorial.
- Cada interação revela uma camada: origem do dado, composição nutricional, impacto na escolha, possibilidade de receita e item necessário para comprar.
- O 3D não é decoração genérica. Ele deve comunicar produto, ingrediente, porção, equipamento ou transformação.
- A sensação geral deve ser futurista, humana, apetitosa e confiável — nunca clínica, gamer, cyberpunk ou “fitness neon”.

### 2. Nova assinatura visual

Crie um sistema visual com quatro ambientes cromáticos conectados pela marca:

- **Base Origem:** azul petróleo quase preto `#071A1D`, usado na navegação, scanner e superfícies de dados.
- **Sálvia digital:** verde matcha `#A8C99A` e verde profundo `#294C3B`, usados em cenas de descoberta e planejamento.
- **Energia cítrica:** laranja damasco `#FF8A4C` e amarelo quente `#FFD36A`, reservados para ações e pontos de atenção.
- **Papel mineral:** marfim `#F3F0E8` e areia `#D9D0C1`, usados em áreas editoriais e de leitura.

Evite espalhar todas as cores em todas as telas. Cada seção deve ter uma atmosfera dominante e transições cromáticas cinematográficas entre contextos. A marca continua reconhecível pelo azul petróleo, pela linha-código de barras e pelo acento cítrico.

Tipografia:

- use uma fonte grotesca expressiva e larga para títulos, como **Space Grotesk, Sora ou Manrope**;
- use **Inter** ou equivalente altamente legível para interface e dados;
- use números tabulares para nutrientes, custos e quantidades;
- títulos podem ocupar duas ou três linhas, com escala editorial e contraste forte;
- microtextos técnicos devem permanecer claros e discretos, sem caixa alta excessiva.

Formas e materiais:

- superfícies grandes, orgânicas e contínuas, evitando uma tela formada por dezenas de cards;
- cantos entre 24 e 40 px apenas onde houver uma superfície real;
- objetos 3D com cerâmica fosca, vidro leitoso, metal escovado, papel fibroso, alimentos fotorrealistas e plástico translúcido;
- sombras coloridas suaves e ambient occlusion, sem sombras pretas duras;
- usar blur e transparência apenas para profundidade, nunca como glassmorphism onipresente;
- substituir ícones Material genéricos nos pontos principais por um conjunto próprio de símbolos lineares inspirado em código de barras, folhas, pratos e ondas nutricionais.

### 3. Arquitetura da experiência

Mantenha todas as funcionalidades atuais, mas reorganize a experiência em quatro territórios:

1. **Hoje:** visão inicial e continuidade do usuário.
2. **Explorar:** scanner, produto, histórico e favoritos.
3. **Planejar:** questionário, cozinha, cardápio e receitas.
4. **Minha Origem:** lista de compras, aprendizado e conta.

No celular, use uma dock flutuante compacta com quatro destinos e uma ação central contextual de escanear. No desktop/web, transforme-a em uma rail lateral mínima que se expande no hover/foco. Não use cinco itens igualmente destacados em uma barra Material padrão.

O scanner deve continuar acessível em um toque a partir de qualquer tela. Preserve rotas, regras de negócio, persistência, serviços, modelos e fluxos atuais; refatore somente a apresentação e a navegação necessária para a nova experiência.

### 4. Tela Hoje

Crie uma abertura editorial em tela quase cheia:

- título grande: **“Veja além do rótulo.”**
- subtítulo curto sobre escanear, entender e planejar;
- objeto 3D central formado por uma embalagem neutra, alimentos frescos e um feixe de leitura;
- botão principal “Escanear produto” integrado à cena, como uma lente ou alvo de leitura;
- o objeto reage sutilmente ao ponteiro, giroscópio ou arraste, com limite de movimento e fallback estático;
- benefícios como Planejar e Aprender não devem parecer botões secundários soltos: devem surgir como dois caminhos editoriais conectados pela linha-código.

Ao rolar, a embalagem se desloca e revela “Últimas leituras” em uma faixa horizontal com miniaturas dos produtos. Se não houver histórico, mostrar uma composição vazia útil, não um card genérico.

No desktop, explorar composição assimétrica e espaço negativo. No celular, manter o título e a ação acima da dobra, reduzir a complexidade da cena e não sobrepor texto a alimentos detalhados.

### 5. Explorar e scanner

Transforme o scanner em uma experiência de “raio nutricional”:

- câmera em tela ampla, com moldura mínima formada por quatro segmentos da linha-código;
- fundo e controles escuros, com alto contraste;
- animação de varredura única e curta ao detectar um código, sem loop luminoso constante;
- feedback háptico e transição em que as barras do código se expandem e viram os gráficos da tela de resultado;
- acesso claro a lanterna, câmera e digitação manual;
- estados explícitos para permissão, carregamento, falha, produto não encontrado e modo offline.

O carregamento deve narrar o que está acontecendo: “Encontrando o produto”, “Lendo os dados disponíveis”, “Preparando o resumo”. Não inventar precisão ou dados que a API não forneceu.

### 6. Resultado nutricional

A tela de resultado é a tela mais importante do produto. Ela deve ser visualmente forte, mas priorizar leitura e confiança.

- Mostrar a embalagem do produto como objeto recortado em uma plataforma 3D simples, com rotação opcional apenas quando houver asset adequado; caso contrário, usar a imagem real sem simular volume falso.
- Nome, marca e ações de favoritar/adicionar à lista devem estar imediatamente visíveis.
- A nota nutricional deve aparecer em escala de 0 a 10, acompanhada de orientação textual clara e sem caráter de diagnóstico.
- Transformar energia, açúcares, sódio e gordura saturada em quatro “órbitas” ou arcos compactos ao redor de um núcleo, mas sempre acompanhar cada visual com número, unidade e estado textual.
- Estados “alto”, “moderado”, “baixo”, “informado” e “sem dado” nunca podem depender apenas de cor.
- Usar intervalos, ausência ou origem do dado com honestidade; não substituir falta de informação por zero.
- Criar um modo “Entender este resultado” que revela explicações em camadas, sem inundar a primeira visão.
- A seção detalhada deve usar tabela limpa e acessível, com números alinhados, filtros ou agrupamento, e não uma sequência de cards iguais.
- Manter a orientação de que os dados podem estar incompletos e devem ser conferidos na embalagem.

### 7. Planejar como jornada espacial

O fluxo atual tem nove etapas. Transforme-o em uma jornada contínua chamada **“Monte sua semana”**, com progresso visual através de uma bancada 3D. Cada resposta adiciona um elemento à cena e deixa o planejamento mais completo.

- Pessoas: pratos e talheres aparecem na bancada conforme adultos e crianças são adicionados.
- Refeições: o dia é dividido em quatro momentos visuais — café, almoço, jantar e lanche.
- Dias: usar uma linha semanal contínua, não sete cards independentes.
- Cozinha: preservar os seis equipamentos selecionáveis — fogão, forno, air fryer, micro-ondas, liquidificador e panela — com contornos precisos, alvo de toque confortável e controle alternativo acessível.
- Estilo: trocar emojis por pequenas cenas gastronômicas coerentes para rápido, uma panela, lote, família, caseira, leve, fibras e vegetariana.
- Alergias: adotar tom sério e calmo; usar rótulos claros, confirmação explícita e opção “Sem alergias”. Não usar emojis como sinal primário de segurança.
- Não gosta: usar ingredientes recortados e legíveis, com remoção visual suave.
- Despensa: transformar os itens que a pessoa já possui em uma prateleira virtual compacta.
- Orçamento: usar uma régua contínua com projeção por dia e alertas honestos sobre o catálogo disponível.

Em telas pequenas, não exigir manipulação 3D precisa. Toda interação espacial deve ter um equivalente em lista, chips ou controles nativos acessíveis. Salvar respostas ao avançar e permitir retorno sem perda.

### 8. Resultado do planejamento e receitas

Apresentar o cardápio semanal como uma mesa editorial vista de cima:

- cada dia é uma faixa; cada refeição é um prato visual, não um card retangular repetido;
- ao tocar em um prato, ele se aproxima com transição compartilhada e abre a receita;
- mostrar custo, tempo e macros como informações secundárias organizadas, não como badges em excesso;
- destacar gasto estimado, saldo e itens de compra em uma única faixa-resumo;
- manter a ação de adicionar a semana inteira ou uma receita à lista;
- quando filtros impedirem recomendações, explicar quais restrições reduziram o resultado e oferecer voltar à etapa relevante;
- não prometer geração por IA: o catálogo é local e editorial na implementação atual.

Na receita, usar uma fotografia coerente como hero, informações nutricionais legíveis, abas Ingredientes/Preparo e uma progressão de etapas que possa ser usada com as mãos ocupadas. Os ingredientes que o usuário já tem devem aparecer separados dos itens a comprar.

### 9. Lista de compras

Transformar a lista em uma “esteira de preparo”:

- agrupar visualmente itens por categoria quando os dados permitirem, sem quebrar o modelo atual;
- checkbox amplo, quantidade editável, unidade e origem do item;
- itens concluídos deslizam para uma área inferior recolhida, sem desaparecer de forma ambígua;
- resumo de itens, pendentes e progresso em uma única composição visual;
- manter adicionar, desfazer, limpar comprados, limpar lista e copiar;
- evitar gamificação infantil, confetes ou pontuação.

### 10. Aprender

Criar uma revista audiovisual do Origem:

- hero editorial em fundo marfim ou sálvia, com título grande e um objeto 3D relacionado ao conteúdo em destaque;
- filtros Rótulos, Nutrição e Compras como índice editorial, não chips Material genéricos;
- episódio publicado com capa real e botão de reprodução claro;
- conteúdos ainda não publicados devem ser identificados honestamente como “em produção”, sem parecer clicáveis ou disponíveis;
- no player, priorizar vídeo, título, autor, descrição e origem externa.

### 11. Conta, histórico, favoritos e estados vazios

- Conta local deve parecer segura e simples, deixando claro que os dados permanecem no dispositivo.
- Histórico deve ter busca visual e agrupamento temporal quando houver volume, mantendo a lista simples no estado atual.
- Favoritos devem estar acessíveis dentro de Explorar, mesmo que a implementação atual os use apenas no fluxo de produto.
- Todo estado vazio deve ensinar a próxima ação com uma microcomposição própria; não usar apenas um ícone grande dentro de um card.
- Criar estados completos para carregamento, skeleton, erro de rede, permissão negada, dado ausente, catálogo vazio e conteúdo futuro.

### 12. Motion e interação

Defina motion como parte da narrativa:

- transições principais entre 280 e 520 ms; microinterações entre 120 e 220 ms;
- curvas físicas suaves, sem elasticidade exagerada;
- shared-axis e shared-element para produto, prato e equipamento;
- parallax máximo de 12–20 px em celular e 24–40 px no desktop;
- hover com pequena rotação e deslocamento, nunca zoom brusco;
- objetos devem responder ao arraste com inércia limitada e voltar ao repouso;
- a linha-código funciona como elemento de continuidade entre telas;
- respeitar `prefers-reduced-motion`/Reduce Motion, removendo parallax, rotação, sequência de frames e transições não essenciais;
- não usar carrossel automático, partículas contínuas, ruído, scanline constante, cursor customizado obrigatório ou animação que impeça o toque imediato.

### 13. Estratégia 3D e performance em Flutter

Não transformar todo o aplicativo em um canvas 3D. Usar profundidade progressiva:

- **nível 1:** imagens 3D pré-renderizadas em AVIF/WebP/PNG com transparência;
- **nível 2:** camadas 2.5D com parallax, máscaras e sombras dinâmicas;
- **nível 3:** Rive ou sequência curta de frames para objetos principais;
- **nível 4:** modelo GLB interativo somente nas cenas em que a rotação agrega entendimento e somente em dispositivos compatíveis.

Carregar assets pesados sob demanda, oferecer poster estático imediato, limitar texturas, reduzir resolução por breakpoint e nunca bloquear scanner, leitura nutricional ou lista por causa de 3D. Meta: primeira ação disponível rapidamente, rolagem estável e interação a 60 fps em aparelhos intermediários. Evitar dependência de WebGL para a navegação essencial.

### 14. Responsividade

Projetar explicitamente para:

- celular compacto de 320–375 px;
- celular grande de 390–480 px;
- tablet em retrato e paisagem;
- desktop/web entre 1024 e 1920 px.

No mobile, priorizar uma cena por vez, controles próximos ao polegar e textos curtos. No desktop, usar espaço negativo, composição assimétrica, rail lateral e objetos que respondem ao ponteiro. Limitar largura de leitura, não apenas esticar os cards existentes.

### 15. Acessibilidade e confiança

- WCAG AA para texto e controles;
- foco de teclado visível e ordem lógica;
- alvos de toque com pelo menos 44–48 px;
- semântica completa para imagens, gráficos, objetos e hotspots;
- toda visualização de dado deve ter equivalente textual;
- estados não podem depender apenas de cor, movimento ou posição 3D;
- Dynamic Type sem corte de conteúdo;
- contraste seguro sobre fotografias, preferindo áreas de respiro reais em vez de overlays escuros improvisados;
- não apresentar recomendações como diagnóstico médico;
- preservar a origem dos dados, limites do catálogo e ausência de informação.

### 16. Restrições

Evite:

- copiar a identidade verde, a embalagem ou a composição exata da More Nutrition;
- copiar telas, promessas, corpo 3D ou recursos do PlateLens que o Origem não possui;
- aparência de template Flutter, dashboard SaaS ou e-commerce;
- excesso de cards, chips e badges;
- cyberpunk, neon roxo/azul, hologramas gratuitos e estética gamer;
- glassmorphism em toda parte;
- emojis como ilustração principal;
- modelos 3D genéricos sem relação com o conteúdo;
- texto incorporado em imagens;
- motion constante, pesado ou obrigatório;
- esconder dados nutricionais atrás de interações experimentais;
- inventar IA, geolocalização, precisão, dados remotos ou funcionalidades inexistentes.

### 17. Entregáveis obrigatórios

Entregue nesta ordem:

1. conceito criativo e moodboard verbal;
2. mapa da nova arquitetura e correspondência com as telas atuais;
3. design tokens completos: cor, tipografia, grid, spacing, radius, borda, sombra, materiais, ícones e motion;
4. wireframes responsivos das quatro áreas principais;
5. telas finais mobile e desktop para Hoje, Scanner, Resultado, Planejar, Cozinha, Cardápio, Receita, Lista, Aprender e Conta;
6. estados vazios, carregamento, erro, permissão, sem dados e Reduce Motion;
7. especificação de componentes Flutter reutilizáveis;
8. inventário de assets 3D e estratégia de carregamento/fallback;
9. protótipo navegável com interações essenciais;
10. plano de implementação incremental que preserve o funcionamento atual.

### 18. Critérios de aceite

- Em três segundos, o usuário entende que o Origem lê rótulos e ajuda a decidir.
- Escanear permanece a ação mais fácil de encontrar em qualquer tela.
- O produto parece autoral mesmo sem animação ou 3D ativo.
- Cada cena 3D tem uma função informacional ou interativa clara.
- Resultado nutricional continua legível, honesto e acessível.
- As nove etapas do planejamento parecem uma jornada, não um formulário longo.
- A cozinha funciona por imagem e por controles alternativos.
- Todos os recursos atuais permanecem disponíveis.
- A experiência funciona em aparelho intermediário, teclado, leitor de tela e Reduce Motion.
- Nenhuma tela parece uma cópia literal das referências.

## Frase de direção

**Origem não é um app escuro com imagens 3D. É uma lente viva que transforma rótulos, ingredientes e escolhas em uma experiência espacial clara.**
