# Direção visual — Origem 3D Imersivo

## Princípios de direção

A direção combina experiência em produtos digitais de saúde, alimentação e comportamento com UX para Flutter, arte 3D, motion design e sistemas de design acessíveis.

Redesenhe o aplicativo **Origem**, um assistente que ajuda pessoas a compreender rótulos, planejar refeições, aprender sobre alimentação e organizar compras. O resultado deve abandonar qualquer aparência retrô ou genérica e evoluir a identidade azul já existente para uma estética contemporânea, imersiva e confiável: **tecnologia alimentar + 3D tátil premium**.

O produto precisa parecer inteligente sem ser clínico, saudável sem usar clichês fitness e sofisticado sem perder simplicidade. A experiência deve transmitir três valores em cada tela: **clareza, cuidado e descoberta**.

### 1. Direção de arte

- Use uma base azul-marinho profunda, com superfícies azul-ardósia, grade atmosférica quase imperceptível e bastante espaço de respiro.
- Preserve o azul como assinatura da marca. Use azul elétrico para interação e seleção, laranja-tangerina para a ação principal e verde somente para estados nutricionais positivos.
- Paleta-base: `#10192A` (azul-marinho), `#213045` (superfície), `#3A4C63` (borda), `#5C8DFF` (azul elétrico), `#9DBBFF` (azul claro), `#F28B3C` (tangerina), `#D96C45` (terracota) e `#6F8F55` (verde nutricional).
- Combine fotografia gastronômica hiper-realista com objetos 3D semi-realistas, materiais foscos, cerâmica, vidro translúcido, papel natural, metal escovado e sombras macias.
- Use cantos generosos entre 20 e 32 px, bordas discretas e elevação difusa. Evite cartões pesados, contornos escuros e blocos visualmente densos.
- Tipografia recomendada: **Manrope, Inter ou Sora**, com títulos compactos e expressivos, corpo extremamente legível e números tabulares para valores nutricionais.
- Ícones devem ser arredondados e coerentes; emojis não devem funcionar como ilustração principal.

### 2. Estrutura e composição

- Tela inicial: hero editorial 3D, texto curto, CTA primário para escanear e atalhos secundários para Planejar e Aprender.
- Organize o conteúdo em uma progressão clara: ação principal, contexto útil, histórico recente e próximo passo.
- Navegação inferior apoiada em superfície azul-marinho, com destino ativo destacado por forma suave, ícone e cor — nunca apenas por cor.
- No Planejar, substitua emojis por cards fotográficos ligados semanticamente à opção. A imagem deve ficar parcialmente opaca no estado disponível e ganhar nitidez, linha azul fina e check ao ser selecionada.
- Cards de receitas devem usar fotografia coerente com seus ingredientes, categoria e método de preparo; não use uma imagem gastronômica aleatória apenas para preencher espaço.
- Mantenha largura confortável em tablets e desktop; não estique textos ou cartões indefinidamente.
- Toda informação essencial deve continuar disponível sem depender da imagem decorativa.

### 3. Movimento e interação

- Crie uma sensação de profundidade ao percorrer o app: parallax muito sutil no hero, entrada escalonada de seções e mudança suave de elevação em cartões.
- Use transições de 180–320 ms com curvas naturais. O movimento deve confirmar ações, orientar foco e revelar hierarquia; nunca ser ruído decorativo.
- Ao tocar um cartão, aplique escala curta de aproximadamente `0.98`, sombra reduzida e retorno elástico discreto.
- Seleções devem animar cor, borda, ícone de confirmação e profundidade.
- Preserve `Reduce Motion`: quando o usuário preferir menos movimento, remova parallax, escala e animações não essenciais.
- Não crie carrosséis automáticos, loops chamativos, partículas constantes ou efeitos que prejudiquem leitura e bateria.

### 4. Aba Planejar — cozinha 3D interativa

Transforme o passo **“O que tem na sua cozinha?”** em uma cena 3D selecionável. Exiba uma cozinha moderna em perspectiva elevada, contendo fogão, forno, air fryer, micro-ondas, liquidificador e panela, todos claramente visíveis.

- Contorne a silhueta real de cada equipamento com paths vetoriais responsivos; não use círculos, emojis ou ícones flutuantes sobre os objetos.
- Toda a área interna do contorno deve funcionar como alvo de toque, com tolerância adicional invisível para conforto em telas pequenas.
- No estado disponível, use uma única linha azul elétrica fina, precisa e sem contorno branco. No estado selecionado, aumente sutilmente a intensidade, aplique preenchimento quase imperceptível, glow curto e check compacto.
- Fogão e panela devem ter silhuetas independentes. Evite bordas duplas, traços grossos e qualquer aparência de recorte adesivado.
- Fogão e panela devem permanecer seleções independentes mesmo quando suas silhuetas se sobrepõem.
- Ao selecionar um equipamento, atualize imediatamente uma lista de chips abaixo da cena e o conjunto de respostas do planejamento.
- Permita selecionar pelo próprio objeto contornado e também por cards fotográficos acessíveis abaixo da imagem. Cada card deve usar um recorte ampliado e centralizado do equipamento correspondente.
- Inclua instrução curta: “Toque nos itens contornados”.
- Mantenha os equipamentos selecionados ao avançar e voltar no fluxo.
- Em telas estreitas, preserve a proporção da cena e evite hotspots sobrepostos; caso necessário, use uma lista visual abaixo da imagem como controle principal.

### 5. Acessibilidade e qualidade

- Garanta contraste mínimo WCAG AA, foco visível, navegação por teclado e semântica para leitor de tela.
- Não comunique seleção somente por cor; use check, texto e alteração de forma.
- Imagens devem ter descrição semântica e fallback visual.
- Respeite Dynamic Type sem cortar títulos ou botões.
- Use imagens responsivas e versões otimizadas; a fonte 4K deve ser comprimida para o dispositivo sem perder nitidez.
- Preserve as regras de negócio, persistência, histórico, scanner e geração do plano existentes.

### 6. Restrições visuais

Evite: estética retrô, neon excessivo, gradientes roxos genéricos, glassmorphism em excesso, aparência infantil, skeuomorfismo pesado, sombras pretas duras, emojis como arte principal, excesso de cards iguais, texto sobre áreas ocupadas da imagem, animações gratuitas, ícones inconsistentes, marcas de terceiros e texto gerado dentro de imagens. O azul profundo deve criar atmosfera e hierarquia, não uma parede visual chapada.

### 7. Entregáveis esperados

1. Sistema de cores, tipografia, espaçamento, raios, sombras e estados.
2. Redesign responsivo da tela inicial e navegação global.
3. Fluxo Planejar com cozinha 3D interativa e fallback acessível.
4. Especificação de motion e estados de interação.
5. Assets 4K sem texto ou marcas, com enquadramento planejado para a interface.
6. Componentes Flutter reutilizáveis e preservação das regras de negócio atuais.

## Especificação do hero 4K

```text
Use case: stylized-concept
Asset type: hero 4K horizontal para a tela inicial de um app de inteligência alimentar
Primary request: criar uma natureza-morta editorial 3D premium sobre compreender rótulos e fazer escolhas alimentares seguras
Scene/backdrop: ambiente azul-marinho profundo com atmosfera tecnológica discreta, névoa azul suave e iluminação de estúdio cinematográfica
Subject: vegetais frescos, grãos em tigela de cerâmica, embalagem genérica de papel com pequeno código de barras abstrato e smartphone emitindo um feixe de leitura em vidro translúcido
Style/medium: render 3D fotorrealista combinado com fotografia gastronômica premium; contemporâneo, tátil e sofisticado
Composition/framing: paisagem 16:9; objetos concentrados na metade direita; amplo espaço negativo limpo na esquerda para título e CTA; perspectiva levemente baixa
Lighting/mood: luz cinematográfica suave, brilho volumétrico discreto, sensação fresca, inteligente e acolhedora
Color palette: azul-marinho, azul elétrico, azul-claro e pequeno acento tangerina
Materials/textures: cerâmica fosca, vidro translúcido, papel natural, alimentos realistas e sombras macias
Constraints: sem pessoas, sem texto legível, sem marcas, sem logotipos, sem watermark e sem interface incorporada
Avoid: aparência infantil, embalagem comercial, excesso de objetos, saturação forte, sombras duras
```

## Especificação da cozinha 3D interativa

```text
Use case: stylized-concept
Asset type: cena 4K horizontal para seletor interativo de equipamentos na aba Planejar
Primary request: criar uma cozinha contemporânea 3D, organizada em zonas claras, na qual seis equipamentos possam receber hotspots de interface
Scene/backdrop: cozinha compacta com armários marfim, bancada de pedra clara, backsplash sálvia, detalhes em madeira natural e poucas plantas
Subject: fogão, forno embutido, air fryer, micro-ondas, liquidificador e panela; todos completos, separados, reconhecíveis e sem obstruções
Style/medium: render 3D isométrico semi-realista e premium, visualização de interiores tátil, sem aparência de desenho animado
Composition/framing: paisagem ampla em ângulo elevado de três quartos; zonas equilibradas; respiro suficiente ao redor de cada equipamento para hotspots; sem sobreposição entre itens
Lighting/mood: luz natural suave vindo da esquerda, ambient occlusion delicada, atmosfera calma e convidativa
Color palette: marfim e madeira na cozinha, com azul-marinho, azul elétrico e pequenos acentos tangerina na interface sobreposta
Materials/textures: armários foscos, metal escovado, vidro, cerâmica, pedra clara e madeira natural
Constraints: sem pessoas, sem texto, sem rótulos, sem marcas, sem watermark, sem equipamentos duplicados, sem sujeira e sem perspectiva extrema
Avoid: cozinha escura, excesso de decoração, enquadramento cortado, reflexos fortes e itens visualmente ambíguos
```

## Critérios de aceite

- A tela inicial parece atual e reconhecível como Origem em até três segundos.
- A ação de escanear é imediatamente identificável.
- Os seis equipamentos da cozinha podem ser selecionados pela imagem e por um controle alternativo acessível.
- Todo estado selecionado é compreensível sem depender apenas de cor.
- Nenhuma microinteração bloqueia o conteúdo ou ultrapassa 320 ms sem necessidade funcional.
- O layout permanece utilizável em celular pequeno, celular grande, tablet e web.
