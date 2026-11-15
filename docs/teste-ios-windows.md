# Testar o Origem no iPhone usando Windows

## Compilar no Codemagic

1. Envie ao GitHub o commit com a correção e o arquivo `codemagic.yaml`.
2. No Codemagic, adicione um aplicativo e conecte o repositório `HigorLonguim/ProjetoAplicado7`.
3. Use a configuração por `codemagic.yaml` do repositório.
4. Inicie uma compilação na branch que contém o commit e selecione o workflow `ios-altstore` (Origem iOS - AltStore).
5. Quando terminar, baixe `Origem-unsigned.ipa` na lista de artefatos.

Esse workflow compila para um iPhone físico em modo release. Não exige certificado Apple, chave de App Store Connect ou assinatura paga. O IPA ainda precisa ser assinado pelo AltStore para ser instalado.

## Instalar pelo Windows

1. Instale o AltServer a partir de https://altstore.io/ e siga o guia oficial para Windows: https://faq.altstore.io/.
2. Instale os componentes Apple exigidos pelo guia (iTunes e iCloud), conecte o iPhone por USB e autorize a conexão no celular.
3. Use o AltServer para instalar o AltStore Classic no iPhone, autenticando sua conta Apple diretamente nessa ferramenta.
4. No iPhone, confie no perfil da sua conta e habilite o Modo de Desenvolvedor se solicitado.
5. Transfira `Origem-unsigned.ipa` para o app Arquivos do iPhone.
6. Abra o AltStore, entre em My Apps, toque em + e selecione o IPA.

Com a conta gratuita, renove a assinatura pelo AltStore antes de sete dias, mantendo acesso ao AltServer. Há limite de três apps ativos por esse método, incluindo o AltStore. Não coloque credenciais Apple no repositório ou no workflow.

## Validar a correção

Escaneie o código `7891000100103` (Leite Moça apresentado no vídeo), com acesso à internet. Confira também a entrada manual, a abertura do resultado e a volta para o scanner. A presença de um produto na base Open Food Facts pode mudar.

A compilação iOS só pode ser confirmada após a execução do workflow em macOS; os testes locais no Windows não substituem essa validação.
