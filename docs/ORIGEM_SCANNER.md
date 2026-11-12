# Scanner Origem

## Diagnóstico anterior

O fluxo antigo tratava leitura, permissão e carregamento com poucos booleanos. A câmera recebia uma linha de varredura genérica, a consulta abria uma tela separada e o mesmo código podia disparar mais de uma busca. Permissão negada, produto não encontrado e falha de rede também convergiam para respostas parecidas, sem uma recuperação clara.

## Arquitetura atual

`ScannerScreen` concentra a orquestração e usa componentes visuais de `origem_scanner.dart`. A busca continua no `ProductService`, o histórico no `HistoryService` e o resultado em `ProductResultScreen`. Dependências críticas podem ser injetadas para testes sem ativar uma câmera real.

Estados do fluxo:

| Estado | Papel | Saída esperada |
| --- | --- | --- |
| `preparing` | Verifica permissão e prepara câmera | Permissão, scanner ou indisponibilidade |
| `permissionRequired` | Explica por que a câmera é útil antes de solicitar | Autorizar, voltar ou digitar |
| `permissionDenied` | Recuperação após recusa | Tentar novamente, configurações ou digitar |
| `ready` | Câmera ativa e enquadramento livre | Detectar código ou ação do usuário |
| `locating` | Reservado para localização gradual do código | Travar ou voltar ao enquadramento |
| `locked` | Moldura converge para o código detectado | Confirmar leitura |
| `confirmed` | Pulso tátil e transformação visual | Iniciar consulta |
| `fetching` | Consulta real com narrativa progressiva | Sucesso, cancelar ou erro específico |
| `success` | Prepara a continuidade visual | Resultado do produto |
| `notFound` | Código válido sem produto cadastrado | Tentar novamente ou digitar |
| `networkError` | Serviço respondeu com falha de conexão | Repetir ou digitar |
| `offline` | Falha confirmada de conectividade local | Repetir ou digitar |
| `unavailable` | Câmera inexistente, ocupada ou indisponível | Digitar ou voltar |

## Storyboard e tempos

- Entrada: `420 ms`, com fade e escala curta a partir do acionador.
- Detecção: a geometria real de `Barcode.corners` ajusta a moldura quando disponível.
- Travamento: `120 ms` antes da confirmação, evitando sensação de leitura acidental.
- Confirmação: pulso tátil e animação única de `900 ms`; não bloqueiam a busca.
- Carregamento: mensagens reais em `0 ms`, `550 ms` e `1250 ms`; orientação de demora após `7 s`, sem porcentagem inventada.
- Saída: transição para o resultado com `Hero` na imagem do produto; ao voltar, a câmera é reiniciada de forma limpa.
- Reduce Motion: entrada e transformação tornam-se imediatas; nenhuma animação essencial fica repetindo.

## Honestidade dos estados

- `notFound` só aparece para a exceção de produto ausente.
- `offline` só aparece para `SocketException` confirmada.
- Falhas HTTP, timeout e demais problemas do serviço usam `networkError`.
- Câmera ocupada recebe texto próprio quando o SDK fornece essa causa.
- Não há aviso falso de pouca luz ou movimento: a versão usada do scanner não entrega telemetria confiável para essas afirmações.
- A digitação manual está disponível desde o primeiro estado, aceita espaços e hífens e valida códigos com 8 a 14 dígitos.

## Performance e acessibilidade

- Formatos limitados a EAN-8, EAN-13, UPC-A e UPC-E.
- Janela de detecção de `350 ms` e trava contra o mesmo código por `2 s`.
- Apenas uma consulta pode ficar ativa; callbacks antigos são invalidados por geração.
- Alvos de toque têm no mínimo `48 px`, rótulos visíveis, tooltips e semântica.
- O overlay escurece apenas cerca de 9% fora da área útil para preservar o contexto da câmera.
- Layout responsivo: scanner em tela cheia no mobile e painel lateral de apoio no desktop.

## Cobertura automatizada

`test/scanner_screen_test.dart` cobre 14 cenários: pronto, permissão negada, negação permanente, validação e sucesso manual, bloqueio de duplicidade, estágios reais de carregamento, sucesso e retorno, não encontrado, rede, offline, câmera indisponível, Reduce Motion e descarte durante consulta pendente.
