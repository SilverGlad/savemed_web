# Política de logs da SaveMed

## Frontend

- Eventos do aplicativo devem passar por `AppLogger`.
- Logs são emitidos somente em builds de desenvolvimento.
- Eventos usam identificadores estáveis e não incluem valores informados pelo usuário.
- Nunca registrar tokens, senhas, códigos de recuperação, documentos, telefone, endereço, dados de cartão, termos de busca ou corpos HTTP.
- Erros apresentados ao usuário devem passar por `ApiErrorMessage`.

## API

- Nunca registrar headers ou corpos completos de requisições.
- Erros devem registrar somente nome do evento, tipo, código técnico não secreto e identificador de correlação.
- Não retornar mensagens do banco, stack traces ou respostas brutas de provedores.
- Credenciais e segredos devem permanecer em variáveis protegidas ou no Secret Manager.

## Suporte

Cada resposta da API recebe um UUID novo no header `X-Request-ID`. Respostas de
erro também retornam esse valor em `requestId`, e o frontend o apresenta apenas
como referência de suporte. O cliente rejeita identificadores fora do formato
UUID para evitar exibir conteúdo arbitrário devolvido por intermediários.

O identificador localiza o evento técnico, mas não autoriza registrar payload,
credenciais ou dados pessoais. Eventos de auditoria guardam somente ator, ação,
tipo e identificador da entidade, farmácia, data e `requestId`.
