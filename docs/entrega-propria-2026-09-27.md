# Entrega propria - 2026-09-27

## Escopo entregue localmente

Gestor > Pedidos > Abrir pedido agora apresenta produtos, quantidades, valores,
cliente, contato, enderecos, etapa operacional, entregador e historico.

Fluxo de pedido pago: aceitar e preparar -> pronto -> entrega propria (nome e
telefone com DDD obrigatorios) -> confirmar entrega. Pedidos para retirada tem
confirmacao de retirada em vez de despacho. A etapa aparece no historico do
cliente atualizado. O acompanhamento e operacional, nao rastreamento GPS.

Interromper entrega exige justificativa de 10 a 500 caracteres e confirmacao
de que os produtos retornaram fisicamente a farmacia. Volta para pronto, sem
cancelar compra, alterar frete, estornar pagamento ou modificar estoque.
O estorno existente fica bloqueado enquanto o pedido esta em entrega.

## API e compatibilidade

- Novos GET/POST `/api/orders/:id/fulfillment` com autenticacao e escopo da farmacia.
- Somente app_admin ou pharmacy_admin da farmacia do pedido podem operar.
- Nenhuma acao operacional transforma pagamento pendente em pago.
- `ORDER.FULFILLMENT` JSONB e `FULFILLMENT_VERSION` inteiro sao aditivos.
  `server.js` cria colunas ausentes na inicializacao conforme o padrao existente.
- STATUS legado continua pending/confirmed/canceled. Etapas novas ficam no JSON.
- Atualizacao condicional por versao, status e pagamento bloqueia concorrencia.
- No aceite, enderecos e contato sao congelados; alteracoes posteriores na agenda
  do cliente nao mudam silenciosamente uma entrega em andamento.
- Historico mantem ultimos 100 eventos com ator, horario e justificativa de retorno.
- Atualizacao legada e estorno participam do controle de versao. Estorno reserva
  refund_pending antes da chamada externa; resultado incerto exige conferencia
  operacional antes de liberar novamente o pedido.

## Confirmacao por codigo

- Cliente abre Meus pedidos, expande o pedido e toca em Ver codigo.
- Codigo de 4 digitos disponivel somente para o comprador autenticado, em entrega
  propria a caminho ou retirada pronta, sempre com pagamento confirmado.
- Gestor exige o codigo para concluir entrega ou retirada. Erros permanecem no
  formulario; nao existe botao para ignorar a validacao.
- Cinco erros bloqueiam a validacao por 15 minutos. Retornar e despachar novamente
  nao elimina tentativas nem bloqueio, mas gera um codigo diferente.
- Conclusao invalida o codigo. Retorno a farmacia impede seu uso ate nova saida.
- API nao armazena o codigo em texto: deriva via HMAC de desafio aleatorio e segredo
  do servidor. Nao envia codigo ao gestor nem registra os digitos informados.
- GET `/api/orders/:id/delivery-code` exige cliente titular e usa Cache-Control
  no-store, private. POST de delivered/picked_up exige deliveryCode como string.
- Configurar DELIVERY_CODE_SECRET estavel com pelo menos 32 caracteres, por meio
  do gerenciador de segredos. Na ausencia, utiliza JWT_SECRET com o mesmo minimo.
  Nao rotacionar esse segredo durante entregas ativas sem plano de transicao.
- Apps antigos nao exibem o codigo. Disponibilizar o site atualizado para esses
  clientes e distribuir atualizacao mobile antes de generalizar a operacao.

## Verificacao

- API: 133 testes aprovados, incluindo isolamento entre farmacias, pedidos nao pagos,
  retirada, concorrencia, retorno, estorno, codigo, bloqueio, reutilizacao e cache.
- Flutter: 108 testes aprovados, incluindo formulario de entregador, confirmacoes,
  erro de concorrencia e layout em 320px com texto 200%, 390px e 1280px.
- Analise dos arquivos Dart envolvidos: sem problemas.
- Build web release com base /savemed/ concluido com sucesso.
- Capturas de referencia inspecionadas:
  `test/features/admin/goldens/order_390.png`, `order_1280.png`,
  `delivery_code_390.png` e `delivery_code_1280.png`.
- Sem chamadas de contratacao, cobrancas ou alteracoes no banco de producao.
- Nao houve teste com dispositivo APK real nem migracao em banco real nesta etapa.

## Publicacao pendente

Publicar primeiro a API com backup e revisao da migracao aditiva; verificar health
e permissoes em candidato sem trafego antes de promover. Depois publicar web e
distribuir as versoes mobile. Nao publicar somente o frontend: a tela exige os
novos endpoints. Apps antigos continuam com o contrato legado; nao recebem a
nova tela e protecoes locais sem atualizacao. Nenhum deploy foi feito nesta etapa.

## PedMoto: proxima etapa

Atualizacao posterior: o usuario pediu ajuste da PedMoto. Implementacao local e
novas evidencias estao em [pedmoto-2026-09-27.md](pedmoto-2026-09-27.md).
O registro abaixo descreve o limite da etapa anterior de entrega propria.

O usuario confirmou PedMoto e depois limitou esta entrega a entrega propria.
Nenhum endpoint novo de contratacao foi habilitado. O codigo legado do parceiro
foi preservado sem ativacao.

Material lido: conversa de WhatsApp fornecida pelo usuario.
O texto da conversa relata instancia SaveMed em Firebase Hosting e gerenciamento
de chaves na interface a partir de abril/2026. Em 29/04 o usuario confirmou cotacao
funcionando. Sao informacoes historicas, nao verificacao atual do ambiente.

O PDF de demonstracao documenta x-api-key, POST /api/v1/quote,
POST /api/v1/orders e GET /api/v1/orders/{orderId}. Exemplos usam coordenadas,
externalOrderId e paymentMethod=CASH. Nao documenta respostas completas,
cancelamento, idempotencia, webhooks ou responsabilidade pelo custo da corrida.
Uma chave chamada de teste tem prefixo live: nao usa-la para assumir sandbox.
Credenciais e senhas nao foram copiadas para o repositorio nem utilizadas.

Antes de integrar: confirmar ambiente/credencial atual, obter API_PUBLICA_INTEGRACAO.md
e versao atual do contrato, estados das respostas, cancelamento, garantia de nao
duplicacao e cobranca do frete. Audios .opus e APK anexados nao foram executados
nem usados para inferir requisitos; analise baseada no texto e no PDF.
