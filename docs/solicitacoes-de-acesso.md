# Solicitacoes de acesso a farmacia

## Contrato publico

- `GET /api/access-requests/pharmacies?q=` pesquisa somente farmacias ativas.
- A resposta publica contem ID, nome, cidade, UF e CNPJ mascarado.
- `POST /api/access-requests` recebe `PHARMACY_ID`, `NAME`, `EMAIL`,
  `PHONE_NUMBER` e `RESPONSIBLE_DOCUMENT`.
- Senha nao faz parte do payload e nunca e armazenada na solicitacao.

Consultas exigem ao menos dois caracteres, sao limitadas a 80 caracteres e
retornam no maximo 20 resultados. Curingas de SQL sao escapados.

## Dados e estados

O documento deve ser um CPF valido. A API armazena somente HMAC-SHA-256 e os
quatro ultimos digitos. A chave vem de `ACCESS_REQUEST_HASH_SECRET`, com fallback
temporario para `JWT_SECRET` durante a migracao.

Estados oficiais: `pending`, `approved`, `rejected`, `cancelled` e `expired`.
Solicitacoes pendentes expiram em 30 dias. Um indice unico parcial impede duas
solicitacoes pendentes para o mesmo email e farmacia.

## Operacao administrativa

As rotas de listagem, detalhe, aprovacao e rejeicao exigem `app_admin`. A
aprovacao usa bloqueio de linha para impedir decisao concorrente, cria um
`pharmacy_admin` pendente e envia convite para definicao de senha. A rejeicao
exige justificativa. Decisao, responsavel e horario permanecem no historico e
geram auditoria sem documento, senha ou payload livre.

Falha no email nao desfaz uma aprovacao ja confirmada. A interface informa o
aviso e permite reenviar o convite.
