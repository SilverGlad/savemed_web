# Migração da sessão Web para cookie HttpOnly

## Estado atual confirmado

- O Flutter Web e os aplicativos móveis usam `Authorization: Bearer <JWT>`.
- `TokenStorage` persiste o token em `SharedPreferences` na Web e no armazenamento
  seguro da plataforma nos aplicativos nativos.
- A API valida exclusivamente o header Bearer nos middlewares de autenticação.
- O CORS da API permite `origin: '*'` e não habilita credenciais.
- O frontend está em `https://savemed.app/savemed/`; a API usa o domínio
  `api-savemed-146487220267.southamerica-east1.run.app`.

Assim, mudar apenas o cliente quebraria a autenticação. Também não se deve enviar
cookies com CORS curinga. O domínio atual do Cloud Run é cross-site em relação ao
site SaveMed; cookies `SameSite=None` nessa topologia dependeriam de cookies de
terceiros, que podem ser bloqueados pelo navegador.

## Arquitetura proposta

1. Disponibilizar um hostname HTTPS próprio para a API, como `api.savemed.app`,
   validando DNS, certificado TLS, roteamento e monitoramento antes de usá-lo.
   Não presumir que esse domínio já exista.
2. Adicionar autenticação por cookie na API sem remover o Bearer. O middleware
   deve preferir explicitamente uma credencial válida e rejeitar credenciais
   conflitantes, em vez de alternar silenciosamente entre identidades.
3. No login Web, definir cookie host-only `__Host-savemed_session`, com
   `Secure`, `HttpOnly`, `SameSite=Lax`, `Path=/`, sem atributo `Domain` e com
   expiração compatível com a validade da sessão. Não expor o JWT no JSON de
   login Web. Os clientes móveis continuam recebendo e usando Bearer.
4. Configurar CORS para a origem exata `https://savemed.app`, com credenciais
   habilitadas, `Vary: Origin` e preflight coerente. Credenciais nunca devem ser
   combinadas com `Access-Control-Allow-Origin: *`.
5. Proteger operações autenticadas que alteram estado com token CSRF associado à
   sessão, enviado em header dedicado, e validação de `Origin`/`Referer` contra
   a allowlist. `SameSite` é defesa adicional, não substitui essa validação.
   Rotas de login, logout e recuperação também precisam de política explícita
   contra CSRF e abuso.
6. Implementar logout Web que invalide/revogue a sessão no servidor quando
   suportado e sempre expire o cookie com os mesmos atributos. Se o JWT atual
   não puder ser revogado antes do `exp`, documentar o intervalo residual e
   considerar sessão opaca/rotativa antes de prometer logout imediato.
7. Manter clientes móveis no Bearer. A API continuará aceitando o header durante
   toda a transição e não alterará formato, duração ou semântica dos tokens
   mobile sem uma migração independente.

## Rollout e remoção do armazenamento Web

1. Alterar e testar primeiro a API em homologação: cookie, CORS por allowlist,
   CSRF, expiração, logout, rejeição de origem inválida e coexistência Bearer.
2. Publicar a API aditiva e verificar telemetria sem registrar tokens, cookies,
   códigos CSRF ou dados pessoais.
3. Atualizar o Flutter Web com credenciais incluídas nas requisições, obtenção e
   envio do token CSRF, tratamento de `401` e remoção do token Web salvo em
   `SharedPreferences`. Não mudar as implementações nativas de `TokenStorage`.
4. Validar login, refresh/expiração (se implementado), logout, recuperação de
   senha, recarga de página, múltiplas abas e operações protegidas nos navegadores
   suportados, além dos aplicativos Android/iOS existentes com Bearer.
5. Observar métricas e erros por versão. Só depois remover compatibilidade com
   Bearer para sessões de navegador, mantendo-a para mobile e integrações
   existentes. A remoção requer identificação confiável do cliente; não confiar
   somente em `X-App-Platform`, que é controlado pelo cliente.

## Critérios de aceite

- Nenhum JWT Web fica acessível a JavaScript, localStorage ou SharedPreferences.
- Cookies só são enviados ao host da API e não são aceitos de origem arbitrária.
- Requisições mutáveis sem CSRF válido ou com origem externa falham sem alterar
  dados.
- Login/logout e expiração funcionam em recarga e abas distintas sem loops de
  autenticação.
- Aplicativos Android/iOS publicados continuam autenticando via Bearer sem
  atualização obrigatória.
- Testes de integração cobrem cookie, CORS, CSRF, identidade conflitante,
  revogação/expiração e compatibilidade Bearer.
- O rollout e rollback estão documentados para API e Web; sessão não é
  compartilhada em logs ou ferramentas de analytics.

## Dependências e limites

Esta é uma especificação, não uma alteração de autenticação. A implementação
depende de coordenar mudanças no repositório `api-savemed`, habilitar um hostname
próprio para a API, definir política de sessão/refresh e executar testes em
homologação. Até isso ocorrer, o comportamento atual Bearer deve permanecer.

## Referências

- [OWASP: Cross-Site Request Forgery Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [MDN: Set-Cookie](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Set-Cookie)
- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)
