# Resultado incerto de pagamento

## Comportamento do frontend

Quando `POST /pay` falha por timeout, erro de rede ou erro HTTP 5xx, o cliente nao
trata a resposta como recusa. O pedido pode ter chegado ao provedor mesmo que a
resposta nao tenha chegado ao aplicativo.

Antes de permitir uma nova tentativa, o cliente consulta `GET /orders/:id/status`:

- `paid`: limpa o carrinho e abre a confirmacao do pedido.
- `failed`: mostra a falha e permite escolher outra forma/tentar novamente.
- `pending`, status desconhecido ou falha na consulta: mantem a tentativa bloqueada
  e consulta novamente a cada cinco segundos enquanto a tela estiver aberta.

Erros de validacao/clientes sem cobranca enviada nao sao classificados como
resultado incerto e continuam exibindo a mensagem de erro para correcao.

## Limites

O bloqueio no cliente evita que o usuario dispare uma segunda tentativa enquanto
nao ha conclusao, mas nao substitui a reserva/idempotencia da API. A API atual
responde `PAYMENT_PENDING` para submissoes ambiguas e o endpoint de status tenta
conciliar cobranças Pagar.me conhecidas. Uma tentativa interna `attempt_*` sem
`charge_id` ainda depende de recuperacao no servidor; ate la, o cliente nao deve
liberar pagamento por conta propria.

O teste usa servicos simulados e nao envia cobrancas. Validar timeout real,
retomada da sessao, conciliacao sem identificador e baixa financeira em
homologacao antes da publicacao.
