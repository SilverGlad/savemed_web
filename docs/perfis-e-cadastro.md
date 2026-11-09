# Perfis, cadastro e acesso administrativo

Este documento registra o comportamento vigente do SaveMed. Alteracoes nessas
regras exigem compatibilidade retroativa com os aplicativos publicados e
validacao conjunta do frontend e da API.

## Perfis

| Perfil | Finalidade | Escopo administrativo |
| --- | --- | --- |
| `customer` | Cliente que pesquisa produtos, compra e acompanha pedidos. | Nao acessa o painel administrativo. |
| `pharmacy_user` | Operador vinculado a uma farmacia. | Nao acessa o painel administrativo. O perfil fica reservado para uma futura matriz de permissoes; nao recebe acesso implícito a mutacoes. |
| `pharmacy_admin` | Administrador operacional de uma farmacia. | Acessa somente os dados vinculados ao seu `PHARMACY_ID`. |
| `app_admin` | Administrador geral da SaveMed. | Acessa a operacao de todas as farmacias. |

## Quem pode criar cada conta

- Qualquer pessoa pode criar uma conta `customer` pelo cadastro publico.
- O cadastro publico de farmacia cria uma nova farmacia e seu primeiro
  `pharmacy_admin`. Ele nao deve ser usado para solicitar acesso a uma farmacia
  existente.
- Um `pharmacy_admin` autenticado pode criar `pharmacy_user` ou outro
  `pharmacy_admin` somente para a propria farmacia.
- Um `app_admin` pode criar usuarios administrativos para qualquer farmacia.
- Somente outro `app_admin` autenticado pode criar uma conta `app_admin`.

## Nova farmacia

O comportamento vigente e ativacao imediata. A farmacia e o primeiro acesso
administrativo ficam disponiveis assim que as duas operacoes de cadastro sao
concluidas. Nao existe estado de aprovacao publica na API atual.

O frontend novo prefere o endpoint transacional `POST /pharmacies/register`.
Para continuar funcionando contra uma revisao anterior da API, usa o fluxo
legado de duas chamadas somente quando essa rota responde `404` ou `405`. Nesse
fallback, tenta remover a farmacia se a criacao do administrador falhar.

## Farmacia existente e CNPJ duplicado

A API rejeita CNPJ duplicado com HTTP `409`. O responsavel deve selecionar
"Solicitar acesso", localizar a farmacia por nome, cidade, CNPJ parcial ou ID e
enviar nome, CPF, email e telefone. O fluxo nunca solicita senha.

O CPF completo e usado somente durante a requisicao. A API persiste HMAC e os
quatro ultimos digitos, com validade de 30 dias para solicitacoes pendentes. Um
`app_admin` aprova ou rejeita a solicitacao; a aprovacao cria um convite para o
responsavel definir a propria senha. Os contratos estao detalhados em
[`solicitacoes-de-acesso.md`](solicitacoes-de-acesso.md).

## Troca do administrador responsavel

A troca ainda nao possui fluxo proprio. O procedimento operacional seguro e:

1. Confirmar a solicitacao por um canal administrativo da SaveMed.
2. Criar ou validar um segundo `pharmacy_admin` na mesma farmacia.
3. Confirmar que o novo administrador consegue entrar e acessar o escopo correto.
4. Somente depois inativar o acesso anterior.

O ultimo administrador ativo de uma farmacia nao deve ser removido sem um
substituto validado.
