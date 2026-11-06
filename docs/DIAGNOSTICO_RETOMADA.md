# Origem — diagnóstico de retomada

Data: 29/09/2026. Análise da proposta em `Origem.pdf.txt`, código e verificações locais. Este documento propõe o trabalho; não representa funcionalidades já corrigidas.

## Atualização implementada em 29/09/2026

A primeira reestruturação foi concluída após este diagnóstico. O aplicativo agora possui identidade visual em azul-marinho, terracota e verde oliva; símbolos vetoriais próprios; home responsiva; consulta Open Food Facts separada em serviço; tratamento de nutrientes ausentes; histórico e lista persistentes; favoritos; cadastro e login local; digitação manual de código; guias educativos funcionais; e a aba Descobrir com filtros de custo, tempo e preferência. Receitas podem enviar seus ingredientes diretamente à lista.

Os dados de produto e Nutri-Score continuam vindo da Open Food Facts. Guias, receitas e valores estimados da aba Descobrir são um catálogo editorial local nesta etapa. O mecanismo está preparado para trocar esse catálogo por uma fonte remota. Geolocalização não foi implementada. Em ambientes que bloqueiam armazenamento local, como alguns navegadores internos, o app usa memória temporária durante a sessão; em Android, iOS e navegadores com armazenamento permitido, usa persistência local.

## Avaliação da proposta

O problema e o fluxo central são claros: ler código de barras, consultar informações nutricionais e ajudar a interpretar o rótulo. Para o TCC, a qualidade da informação e a avaliação de compreensão pelos usuários devem ser o centro. Vídeos revisados por profissionais complementam esse objetivo. Listas por mercado e geolocalização ampliam bastante o escopo e devem vir depois do núcleo estável.

A proposta precisa de requisitos explícitos para vídeos, dados nutricionais incompletos e origem das classificações. O prazo de três segundos deve definir condições de medição, tamanho da amostra e percentil, porque depende de uma API externa. O cronograma ainda pede conversão para sprints quinzenais. Estatísticas da fundamentação precisam de referências completas, ano e população pesquisada. O texto extraído não contém os gráficos/resultados da pesquisa; eles não foram avaliados.

## Estado observado no código

| Área | Situação |
| --- | --- |
| RF01 — câmera | MobileScanner e fluxo de permissão implementados; falta teste em dispositivo. |
| RF02 — consulta | Requisição real à Open Food Facts, diretamente na LoadingScreen, timeout de 15 s. |
| RF03–05 — resultado | Nome, imagem e nutrientes implementados, mas classificação e tratamento de ausência precisam de correção. |
| RF06 — histórico | Cinco registros fixos na tela; não recebe consultas reais. A home tem outro registro fixo. |
| RF07 — favoritos/lista a partir de produto | Coração com callback vazio; resultado não adiciona produto à lista. |
| RF08 — listas manuais | Adição, remoção e marcação implementadas em uma lista na memória; sem persistência nem gestão completa de múltiplas listas. |
| RF09 — mercados | Campo marketId no modelo, sem fluxo implementado. |
| RF10 — geolocalização | Não implementada. |
| RF11 — busca por nome | Não implementada; utilitário de busca em mocks não é busca real na interface. |
| RF12 — produto não encontrado | Mensagem prevista para status diferente de 1 em resposta HTTP 200; outros HTTP são tratados como erro genérico. |
| Vídeos | Títulos e durações fixos, sem reprodução nem filtros funcionais. |
| Login | Tela demonstrativa fora do fluxo inicial; sem autenticação. |
| Compartilhar lista | Apenas mensagem de funcionalidade futura. |

## Prioridades de correção

1. **Dados ausentes tratados como zero.** ProductModel converte nutrientes não informados em 0.0. Isso pode produzir classificação A indevida. Usar valores opcionais e exibir “não informado”; definir dados mínimos para cada interpretação.
2. **Perda de informações na classificação.** ProductResultScreen cria um Product temporário sem saturatedFat, nutriscoreGrade e nutrientLevels, entre outros campos. Assim, ignora Nutri-Score recebido e considera gordura saturada zero. A tela de detalhes pode anunciar Nutri-Score enquanto o resumo calcula outra nota.
3. **Critérios diferentes em pontos distintos.** Product, resumo e detalhes usam limites diferentes. O fallback A–F é próprio e não equivale a Nutri-Score. Valores inválidos do Nutri-Score são convertidos em F pelo modelo. Centralizar regras e separar claramente fonte externa, alertas por nutrientes e ausência de classificação.
4. **Base nutricional e unidades.** Não há distinção adequada de sólidos/líquidos nem campo de açúcares adicionados. Não usar açúcar total como substituto automático do adicionado. Conferir também unidades de cafeína no contrato da API antes de mostrar mg.
5. **Configuração mobile.** INTERNET está nos manifests debug/profile, mas não no principal. Corrigir e verificar manifest final da build release. Info.plist não declara NSCameraUsageDescription. Validar requisitos mínimos dos plugins ao preparar iOS.
6. **Persistência.** ShoppingListService mantém tudo em memória. Histórico e favoritos precisam de repositórios locais; testar encerramento completo e reabertura do app.
7. **Robustez da API.** Extrair serviço HTTP e mapeamento, preservar código de barras/identidade, aceitar respostas incompletas e números representados como texto, distinguir indisponibilidade, timeout, erro HTTP e produto inexistente. Configurar identificação do app e observar limites de chamadas.
8. **Lista manual.** Validar números positivos, vírgula decimal e nome sem espaços vazios. O parse atual transforma entrada inválida em 1. Remover preço estimado arbitrário por unidade ou permitir preço informado pelo usuário.
9. **Scanner.** Testar câmera negada/negada permanentemente, retorno das configurações, alternância de abas e retomada do app; oferecer digitação de código como alternativa.

## Remoção de simulações

- Home e histórico: substituir registros fixos pelo armazenamento real e estados vazios.
- Dicas: substituir cards fictícios por catálogo real; até haver conteúdo, apresentar estado vazio honesto.
- Favoritos e compartilhamento: implementar ou remover controles que parecem funcionais.
- Sugestões: assumir explicitamente que são sugestões estáticas ou derivá-las do histórico real.
- Estimativa monetária: remover os preços arbitrários por unidade.
- `lib/utils/mock_data.dart`: não é importado pelo fluxo atual. Seus dados podem virar fixtures de teste; apagar só esse arquivo não remove os mocks presentes nas telas.
- Login: não é necessário ao núcleo descrito. Recomenda-se começar sem conta, com dados locais, e só incluir autenticação se surgir requisito de sincronização.

## Arquitetura proposta

Interface → controladores/estado → repositórios → API e armazenamento local.

Consolidar um modelo de domínio Product, mantendo um mapeador explícito para o contrato Open Food Facts. Regras de interpretação não devem depender de widgets/cores. Um serviço de apresentação traduz resultados em textos e cores. Não há necessidade imediata de backend próprio para consulta e armazenamento local; vídeos podem começar com catálogo revisado e URLs reais.

## Backlog sugerido em sprints quinzenais

1. **Base confiável:** corrigir teste existente e avisos, configurar Android, consolidar produto/mapeamento, centralizar critérios e tratar dados ausentes. Aceite: consulta real por código digitado/câmera, dados coerentes e erros compreensíveis.
2. **Dados reais e persistência:** histórico, favoritos, adicionar produto à lista e armazenamento local. Aceite: consultar, salvar, encerrar e reabrir preservando dados; instalações novas sem histórico fictício.
3. **Experiência de compra:** pesquisa por nome com paginação/controle de chamadas, edição de quantidades, compartilhamento e múltiplas listas se necessário. Aceite: fluxos completos em celular, com validação de entradas e estados vazios.
4. **Conteúdo e validação acadêmica:** vídeos reais com autoria, revisão, legendas e reprodução; testes com usuários; medidas de compreensão e tempo de tarefas; documentação e build de demonstração.
5. **Expansão condicionada ao prazo:** associação a mercados e geolocalização. Se retiradas do escopo, atualizar RF09/RF10/RNF08 junto à orientação, em vez de mantê-las como entregas implícitas.

## Testes necessários

- Unitários: mapeamento de API completo/incompleto, unidades, campos inválidos, limites e ausência de classificação; operações e serialização das listas.
- Integração: API com respostas controladas, HTTP não 200, timeout, offline, cache e persistência após reabertura. Fixtures são úteis em testes e não devem aparecer como dados reais na produção.
- Widgets: resultado parcial, estados de erro/vazio, favoritos, lista, texto ampliado e telas pequenas.
- Dispositivo: permissões e ciclo de vida da câmera, vários códigos seguidos e APK release com rede.
- Usabilidade: usuários executam leitura, interpretação e salvamento; registrar erros, tempo, compreensão e observações com metodologia documentada.
- Desempenho: medir consulta fria e cache separadamente; relatar mediana/p95 e falhas, sem prometer disponibilidade da API externa.

## Verificações executadas

- Build web release concluída com sucesso. Aplicação executada em http://127.0.0.1:8765 e inspecionada no navegador. Home e navegação para lista renderizaram; adicionar “Produto de teste”, quantidade 2, funcionou. Após recarregar e voltar à lista, ela estava vazia, confirmando a ausência de persistência. A câmera e a consulta ponta a ponta não foram validadas nesta execução.
- Flutter 3.41.6 e Dart 3.11.4 instalados.
- flutter doctor: Android SDK 36.1.0 e Java do Android Studio presentes; algumas licenças Android pendentes. Nenhum dispositivo Android conectado e nenhum emulador configurado. Windows nativo sem Visual Studio/C++ instalado.
- Análise estática: 2 warnings (import e variável não usados na lista) e 1 info (value depreciado no DropdownButtonFormField), sem erro estático reportado.
- Teste existente: 1 executado, 1 falhou por não encontrar “Visão geral”. O componente transforma o título em maiúsculas e a lista pode exigir rolagem; o teste precisa acompanhar a renderização e o objetivo real da interface.
- TIER1_COMPLETION.md menciona seis suítes e lib/test_models.dart, mas o arquivo não está presente no checkout. Essas alegações não são evidência de testes executáveis atuais.
- A alteração preexistente em lib/screens/product_result_screen.dart foi preservada.

## Referências verificadas

- Anvisa, rotulagem nutricional: https://www.gov.br/anvisa/pt-br/assuntos/alimentos/rotulagem/rotulagem-nutricional/ — alertas consideram açúcares adicionados, gordura saturada e sódio, com critérios diferentes para sólidos e líquidos. Aplicação completa exige observar categoria e exceções.
- Open Food Facts, condições da API: https://support.openfoodfacts.org/help/en-gb/12-donnees-api/94-y-a-t-il-des-conditions-pour-utiliser-l-api — identificação por User-Agent e limites por endpoint.
