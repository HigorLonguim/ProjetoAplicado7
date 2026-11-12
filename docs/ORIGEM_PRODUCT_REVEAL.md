# OrigemProductReveal — direção, storyboard e arquitetura

## Diagnóstico da versão anterior

- A embalagem era uma imagem única recortada por `ClipPath`; os recortes se afastavam sem dobradiças, espessura ou relação física entre as faces.
- A sequência durava 3,6 s e pulava a linguagem de scanner: não havia segmentos de foco, busca, confirmação ou leitura sequencial do código.
- Os produtos provinham de uma composição única. Isso limitava profundidade, ordem de saída, ambientação e tratamento de falha por item.
- A curva `easeOutBack` criava elasticidade maior que a direção premium solicitada.
- O retorno à tela Hoje saltava diretamente ao estado final; não existia a leitura curta de aproximadamente 900 ms.
- O modo de redução de movimento mostrava apenas o último frame, sem o poster inicial de 150 ms e crossfade.

## Storyboard implementado

| Tempo | Estado | Ação |
| --- | --- | --- |
| 0–700 ms | `entering` | Carton em escala 0,88, leve perspectiva, sombra progressiva e quatro segmentos de lente. |
| 700–1.300 ms | `searching` / `scanning` | A lente ajusta o enquadramento; feixe damasco cruza a área correta; barras acendem em sequência; foco confirma em azul. |
| 1.300–1.900 ms | `decoding` | Grupos do código percorrem curvas e se convertem em linhas de dados. |
| 1.800–3.000 ms | `opening` | Tampa, fundo, frente, laterais e abas articulam em tempos diferentes, com perspectiva e sombra próprias. |
| 2.300–3.600 ms | `revealing` | Lata, iogurte, massa, tomate e folha saem em ordem, com Z simulado, curva curta e overshoot limitado a 3,5%. |
| 3.200–4.100 ms | `dissolving` | Superfícies viram contornos, contornos percorrem curvas; o logo desaparece por último. |
| 4.000–4.600 ms | `settled` | Restam somente produtos e órbitas; um brilho percorre a linha frontal uma única vez. |

## Arquitetura de camadas

1. Sombra de chão colorida e barata (sem blur animado grande).
2. Órbitas traseiras e trilhas nascidas no código de barras (`CustomPainter`).
3. Painel traseiro, laterais, tampa e abas, todos com `Matrix4` e dobradiças independentes.
4. Produtos, cada um em `RepaintBoundary` próprio.
5. Painel frontal com wordmark SVG e código de barras procedural.
6. Contornos de dissolução.
7. Órbita frontal e brilho único.
8. Segmentos da lente e confirmação de leitura.

O componente usa um controller principal de 4,6 s e um controller de repouso de 6,8 s. O segundo só inicia no estado final e aplica uma respiração vertical de até 1,2 px. A composição não reage ao ponteiro nem ao gesto de arrastar, evitando parallax inverso e mantendo o repouso visual leve.

## Inventário de assets

- `assets/brand/origem_wordmark_transparent_v2.png`: assinatura oficial rasterizada com alpha, independente de fontes instaladas.
- `origem_product_can_v4.png`: lata isolada transparente.
- `origem_product_yogurt_v4.png`: iogurte isolado transparente.
- `origem_product_pasta_v4.png`: massa isolada transparente.
- `origem_product_tomato_v4.png`: tomate isolado transparente.
- `origem_product_leaf_v4.png`: folha isolada transparente.
- `origem_product_sprite_v4.png`: prancha-fonte gerada; não é carregada em runtime.
- A embalagem é code-native: marfim, azul-petróleo, damasco, textura fibrosa, tampa, frente, fundo, laterais, abas, logo e código são camadas independentes.

Os cinco recortes foram produzidos a partir da composição visual de referência, isolando lata, iogurte, massa, tomate e folha em uma prancha transparente. O tratamento preserva materiais, cores e iluminação, sem anéis, texto, logos, fundo ou sobreposição.

## Estados alternativos

- **Carregamento:** poster vetorial imediato enquanto os PNGs são pré-carregados.
- **Asset ausente:** cada produto possui um fallback procedural independente e a sequência continua.
- **Reduce Motion:** poster por 150 ms, crossfade de 150 ms e composição final estática; scanner, parallax e abertura são omitidos.
- **Retorno recente:** sequência condensada de 900 ms, com confirmação rápida e reorganização dos produtos. Após oito minutos ou nova sessão, a apresentação completa volta a ser permitida.
- **CTA durante a apresentação:** `OrigemProductRevealController.completePresentation()` resolve o visual em 160 ms, mas a navegação para o scanner ocorre imediatamente e nunca aguarda a animação.

## Performance

- Imagens pré-carregadas antes da timeline e poster imediato.
- `RepaintBoundary` no conjunto e em cada produto/painel.
- Um shader de blur pequeno apenas no feixe e no brilho transitório.
- Sem vídeo, GIF, WebGL, partículas ou controllers ativos fora da tela Hoje.
- Controllers descartados no `dispose`; estado final com apenas 1,2 px de deslocamento vertical lento.
