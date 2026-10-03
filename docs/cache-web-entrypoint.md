# Cache do entrypoint Web

O build de produção do Flutter grava o bundle em `main.dart.js`, um nome estável
que não pode receber cache de longa duração com segurança. Após o build, o script
`scripts/fingerprint_web_entrypoint.ps1` aceita somente `main.dart.js` ou o
nome já versionado `main.<sha256>.dart.js`, calcula o SHA-256 do conteúdo, grava
`main.<sha256>.dart.js` e atualiza `mainJsPath` no `flutter_bootstrap.js` gerado.
O script pode ser executado novamente sem alterar o hash ou criar cópias extras.

## Build local

```powershell
flutter build web --release --base-href /savemed/ --no-web-resources-cdn
powershell -ExecutionPolicy Bypass -File scripts/test_fingerprint_web_entrypoint.ps1
powershell -ExecutionPolicy Bypass -File scripts/fingerprint_web_entrypoint.ps1 -WebRoot build/web
```

O workflow `Frontend CI` executa o teste isolado do script e o mesmo pós-processamento depois do build Web.
Antes de publicar, confirme que existe exatamente o nome referenciado em
`build/web/flutter_bootstrap.js` e que seu SHA-256 corresponde ao sufixo.

## Headers e publicação

`web/.htaccess` mantém `index.html`, `flutter_bootstrap.js`, `version.json` e o
entrypoint legado com `no-store`. Somente `main.<64 caracteres hexadecimais>.dart.js`
recebe `Cache-Control: public, max-age=31536000, immutable`. O HTML e bootstrap
precisam ser carregados novamente para descobrir o novo hash; o bundle já
carregado pelo navegador pode ser reutilizado sem nova transferência.

Ao publicar, envie o bundle com hash antes de `flutter_bootstrap.js` e
`index.html`. Não remova imediatamente bundles versionados anteriores: preserve
os artefatos necessários para rollback e para qualquer bootstrap que ainda possa
estar em uso. A decisão de retenção/deleção deve ser feita após confirmar como o
sincronizador Hostinger trata arquivos remotos não presentes no build local.

Após a publicação, confira no domínio real, através do CDN:

- O bootstrap público aponta para o mesmo nome que foi enviado.
- O arquivo versionado responde HTTP 200, tem tamanho e SHA-256 esperados e
  `Cache-Control: public, max-age=31536000, immutable` sem um `no-store` duplicado.
- `index.html` e `flutter_bootstrap.js` continuam sem cache de longa duração.
- Uma segunda abertura do app reutiliza o bundle versionado e o app inicia sem
  erros no console.

Em 03/10/2026, a produção `https://savemed.app/savemed/` foi validada após a
publicação autorizada do bundle `main.06ab9aa035d08e0c8d73b99464177071266afdf26af4a58dde2ebce29e32effd.dart.js`:
bootstrap e bundle responderam HTTP 200, o bundle tinha cache imutável e a
entrada não tinha cache de longa duração. O bundle local posterior
`main.8f4c11c689fbd8348b1b78157484844fb5cbf51782c9e7f91e7bfecf1347a861.dart.js`
foi substituído por builds locais posteriores e não foi publicado. Em 03/10/2026,
a limpeza de dados de cartão ao sair do primeiro plano gerou
`main.9e4883e82ceb2382051a11f7e3fe5eec06d039320076d6ba65c4d9952cf83101.dart.js`
(3.585.893 bytes; SHA-256
`9E4883E82CEB2382051A11F7E3FE5EEC06D039320076D6BA65C4D9952CF83101`). Este bundle
também permanece local, não publicado; a produção continua apontando para `06ab`.
As versões publicadas anteriores foram preservadas para rollback.

Rebuild local de 03/10/2026 após a limpeza de dados de cartão na restauração de
sessão produziu `main.040974aff912a4449f7070e9226bfe83a67a46d0e19154b77ab0c81e1df85afc.dart.js`
(3.586.142 bytes; SHA-256
`040974AFF912A4449F7070E9226BFE83A67A46D0E19154B77AB0C81E1DF85AFC`). O build
Web foi compilado com `/savemed/` e passou pelo fingerprint; permanece apenas
local. O bundle servido em produção continua sendo `main.06ab...`.
