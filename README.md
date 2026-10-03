# SaveMed Web

Frontend Flutter da SaveMed para clientes, farmácias e administração.

## Desenvolvimento

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Build web

O site é publicado no subdiretório `https://savemed.app/savemed/`. O `base href`
precisa apontar para esse caminho; um build com o valor padrão `/` não inicia em
produção.

```powershell
flutter build web --release --base-href /savemed/ --no-web-resources-cdn
powershell -ExecutionPolicy Bypass -File scripts/fingerprint_web_entrypoint.ps1 -WebRoot build/web
```

Antes da publicação, confirme em `build/web/index.html`:

```html
<base href="/savemed/">
```

Depois do pós-processamento, confirme que `flutter_bootstrap.js` aponta para um
arquivo existente `main.<sha256>.dart.js` e que o SHA-256 do arquivo corresponde
ao nome. Publique o conteúdo de `build/web` no diretório remoto `/savemed`,
enviando primeiro o bundle com hash e depois `flutter_bootstrap.js` e
`index.html`. Preserve bundles com hash anteriores para rollback; não espere que
`main.dart.js` exista após o fingerprint. O procedimento de cache e as
verificações pós-publicação estão em
[`docs/cache-web-entrypoint.md`](docs/cache-web-entrypoint.md). Valide também
`version.json` e a saúde da API. O carregador customizado usa o CanvasKit
publicado no próprio domínio para não depender de uma CDN externa durante a
inicialização.

Publicação validada em 04/09/2026: frontend `1.1.0+7`, bundle SHA-256
`084E24A0F42EB0AC9E4A6EA198985C58247FCD2E450CFB546EC41BD213443A0D` e API
Cloud Run `api-savemed-00036-vok`. O backup anterior aos arquivos críticos da
Hostinger está em `.deploy-backup-20260904-030647`.

O build Android de release também foi validado localmente em 04/09/2026. O AAB
assinado está em `build/app/outputs/bundle/release/app-release.aab`; isso não
substitui a validação da faixa interna da Play Store.

## Regras de acesso

Os perfis, permissões e fluxos atuais de cadastro estão documentados em
[`docs/perfis-e-cadastro.md`](docs/perfis-e-cadastro.md).

A política de eventos e dados proibidos em logs está documentada em
[`docs/politica-de-logs.md`](docs/politica-de-logs.md).

Fluxos adicionais:

- [`docs/solicitacoes-de-acesso.md`](docs/solicitacoes-de-acesso.md)
- [`docs/operacao-administrativa.md`](docs/operacao-administrativa.md)
- [`docs/release-2026-09-administracao.md`](docs/release-2026-09-administracao.md)
- [`docs/reserva-estoque-pix.md`](docs/reserva-estoque-pix.md)
- [`docs/web-cookie-session-migration.md`](docs/web-cookie-session-migration.md)

## Referência de desempenho web

Build web publicado em 02/10/2026: o bootstrap aponta para
`main.4a6cf3c1155cd56bbbdba80a7c781a86b426fe9c10812048c6fa45f699d30c75.dart.js`
(3.581.141 bytes; SHA-256
`4A6CF3C1155CD56BBBDBA80A7C781A86B426FE9C10812048C6FA45F699D30C75`). O asset
versionado responde HTTP 200 e a CDN aplica cache de 7 dias; a regra desejada de
um ano imutável continua pendente da atualização segura do `.htaccess`. O antigo
`main.dart.js` (3.575.684 bytes) permanece no servidor para rollback. O WebAssembly
local do CanvasKit Chromium ocupa 5.686.836 bytes. O `index.html` mostra estado de
carregamento e oferece nova tentativa após 20 segundos.
