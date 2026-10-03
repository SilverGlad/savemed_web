# Operacao administrativa

## Permissoes

- `app_admin`: administra todas as farmacias, solicitacoes e configuracoes.
- `pharmacy_admin`: administra catalogo, estoque, promocoes, pedidos e usuarios
  somente da propria farmacia.
- `pharmacy_user`: nao acessa o painel enquanto nao existir uma matriz granular
  de permissoes. Esta decisao evita conceder privilegios por inferencia.

A API sempre aplica papel e `PHARMACY_ID`; ocultar um controle no frontend nao e
considerado autorizacao.

## Exclusao e historico

Farmacias e usuarios sao inativados logicamente. Contas administrativas nao sao
excluidas definitivamente enquanto puderem estar vinculadas a pedidos,
pagamentos, solicitacoes ou auditoria. Produtos, estoque, categorias e promocoes
exigem confirmacao antes da remocao.

## Estorno

Somente pedido pago e ainda ativo pode ser estornado. A interface mostra
farmacia, total, estados e entrega, exige justificativa de 10 a 500 caracteres e
envia a operacao para a rota dedicada. A API registra motivo, administrador,
data e evento de auditoria.

## Repeticao de requisicoes

O cliente nao repete automaticamente mutacoes. Isso evita duplicar cadastros,
pedidos, convites ou estornos em conexoes instaveis. Repeticao automatica fica
restrita a uma futura implementacao com idempotency keys; hoje listas oferecem
uma acao explicita de nova tentativa.
