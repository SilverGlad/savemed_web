# Diagnostico de tokenizacao de cartao - 2026-10-02

## Fluxo observado

- `lib/features/payment/payment_page.dart` encaminha numero, titular, validade e CVV ao `PaymentController`.
- `lib/core/services/payment_service.dart` serializa o mapa `card` para `POST /pay`.
- A rota local `G:/GitHub/api-savemed/routes/pay.js` usa os campos abertos no payload de pagamento da Pagar.me.
- O modal de cartao solicitava CPF, mas o modelo descartava o campo; a API deriva `customer.document` do usuario autenticado. A coleta sem uso foi removida do modal e e coberta por teste.
- A entrada do cartao agora valida comprimento de 13 a 19 digitos e checksum Luhn, nome presente (maximo de 64 caracteres), validade MM/AA nao vencida e CVV com 3 ou 4 digitos. Essas verificacoes melhoram o feedback local, mas nao substituem a validacao Pagar.me nem reduzem a exposicao do PAN no endpoint SaveMed.
- O frontend nao persiste PAN/CVV em `SharedPreferences`; `CardStorage` remove o payload legado e mantem os cartoes apenas na memoria da sessao. Logout e expiracao da sessao limpam esse armazenamento. Apos iniciar qualquer tentativa de pagamento com cartao, o controlador e seu cache de sessao sao limpos; uma nova tentativa exige informar os dados novamente. Isso reduz persistencia local, mas nao elimina o trafego dos dados pelo backend nem garante zeracao de copias transitarias na memoria do runtime.

## Contrato Pagar.me

A documentacao oficial recomenda enviar `card_token` ou `card_id`, evitando dados abertos no servidor. A criacao de token usa `POST https://api.pagar.me/core/v5/tokens?appId=<public_key>`, sem header de autorizacao; somente a chave publica pode ser exposta ao cliente. O dominio de origem precisa estar liberado na conta. O token e de uso unico e expira em ate 60 segundos. A referencia de pedidos documenta `card_token` diretamente para Gateway; para PSP, usar o fluxo de criacao de cartao/token e enviar `card_id`. O modelo da conta SaveMed e a configuracao do dominio nao foram confirmados.

Referencias oficiais:

- [Criar token de cartao](https://docs.pagar.me/reference/criar-token-cart%C3%A3o-1)
- [Criar pedido](https://docs.pagar.me/reference/criar-pedido-2)
- [Cartao de debito](https://docs.pagar.me/reference/cart%C3%A3o-de-d%C3%A9bito-2)
- [Criar cartao](https://docs.pagar.me/reference/criar-cart%C3%A3o)

## Rollout necessario

1. Confirmar no painel Pagar.me se a conta e Gateway ou PSP e se os dominios web usados estao liberados para tokenizacao.
2. Disponibilizar a chave publica `pk_*` ao cliente sem incluir qualquer `sk_*` no bundle, no app ou em logs.
3. Adicionar suporte aditivo a token/cartao tokenizado na API. Manter o contrato legado de `card` durante a transicao para que os aplicativos ja publicados continuem operando; nao tornar o campo legado obrigatorio para novos clientes.
4. Atualizar Web e aplicativo nativo para enviar apenas token, validade/titular somente se exigidos fora da tokenizacao e endereco de cobranca conforme contrato. PAN e CVV nao podem chegar ao endpoint SaveMed nem aos logs.
5. Cobrir ambos os contratos (apps antigos e cliente tokenizado), falha/expiracao do token, timeout antes/depois da tentativa, repeticao concorrente e ausencia de PAN/CVV no pedido enviado pela SaveMed.
6. Homologar com a chave de teste e dominio autorizado; publicar API aditiva antes do frontend e manter possibilidade de rollback do frontend sem remover suporte legado.

## Evidencia e limite

O frontend tem testes de regressao para impedir persistencia de PAN/CVV, limpeza apos a tentativa de pagamento e limpeza no logout. A integracao com token ainda nao foi implementada: requer confirmacao da conta, configuracao de chave publica e suporte correspondente na API. Nenhum pagamento real ou configuracao de painel foi alterado nesta auditoria.

## Rechecagem oficial - 2026-10-03

A documentacao oficial atual foi reconsultada para validar o bloqueio antes de qualquer implementacao parcial:

- [Criar pedido](https://docs.pagar.me/reference/criar-pedido-2) recomenda nao trafegar dados abertos de cartao pelo servidor sem PCI Compliance; `card_token` e indicado para Gateway, enquanto PSP deve usar `card_id`.
- [Criar token de cartao](https://docs.pagar.me/reference/criar-token-cart%C3%A3o-1) exige a chave publica em `appId`, proibe enviar o header de autorizacao nesse endpoint e exige que o dominio esteja registrado. A documentacao de [tokenizacao](https://docs.pagar.me/reference/tokeniza%C3%A7%C3%A3o-1) informa que o token expira em 60 segundos e so pode ser usado uma vez; dados de cartao abertos nao devem ser enviados ao servidor SaveMed.
- O contrato de [criacao de cartao](https://docs.pagar.me/reference/criar-cart%C3%A3o) inclui `customer_id`, cartao/token e endereco de cobranca conforme o fluxo. Isso reforca que `card_id` PSP precisa de suporte coordenado na API e de um cliente Pagar.me associado.

O frontend atual ainda envia PAN/CVV ao endpoint SaveMed. A limpeza de armazenamento local reduz retencao, mas nao remove esse trafego. Como o modelo da conta, a chave publica, a liberacao do dominio e a disponibilidade de API aditiva continuam sem confirmacao, nao foi alterado o fluxo legado nesta rechecagem. Bloquear cartao ou trocar o payload apenas no frontend quebraria clientes publicados ou enviaria um contrato incompativel. Tratar como pendencia de seguranca para rollout coordenado; ate la, evitar ampliar armazenamento/uso do cartao e nao afirmar que o fluxo esta tokenizado.
