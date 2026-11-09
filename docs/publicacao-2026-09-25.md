# Publicação de cadastros e revisão visual

## Versões ativas

- Frontend: https://savemed.app/savemed/ na Hostinger.
- API: Cloud Run `api-savemed-00058-paj`, projeto `ceremonial-orb-490701-q8`, região `southamerica-east1`, 100% do tráfego.
- Revisão anterior da API: `api-savemed-00056-xur`.
- SHA-256 de `main.dart.js`: `C6B824456D154A777241033190207301E9F83EBD728F64CA85CFFC9097B37EFC`.
- Bootstrap com identificador `20260925-cadastros`; arquivos de entrada com cabeçalhos `no-store, no-cache, must-revalidate, max-age=0`.

## Procedimento e validação

1. 94 testes Flutter e 82 testes da API aprovados. Análise Flutter sem problemas. Build web release gerado com base `/savemed/` e CanvasKit local.
2. API candidata implantada sem tráfego. O banco ficou disponível após a inicialização; saúde confirmada como HTTP 200 antes da promoção.
3. Categorias, medicamentos, inventário, destaques, farmácias e conteúdo comparados entre produção anterior e candidata: HTTP 200, arrays legados e mesmos IDs.
4. Nova rota `PUT /api/users/me`: 401 sem autenticação, 400 para nome vazio e 200 para salvamento dos próprios valores já existentes. Nome, email e papel preservados. Nenhum novo usuário foi criado.
5. API promovida somente após essas verificações. Saúde HTTP 200 também no domínio numérico usado pelos aplicativos.
6. Backup integral do diretório remoto `/savemed` em `.deployment-backups/release-20260925-before/web`.
7. Frontend enviado primeiro a `/savemed-release-20260925`; índice, bootstrap, bundle, manifesto e fonte de ícones comparados byte a byte com o build.
8. Diretório anterior renomeado para `/savemed-backup-20260925`; diretório novo ativado como `/savemed`. Site institucional na raiz e relay de email não foram alterados.
9. Após ativação, índice, bootstrap, bundle e CanvasKit verificados por HTTP e comparação byte a byte.
10. Edge headless no endereço público: login mobile, link superior abrindo cadastro, restauração de sessão administrativa e catálogo desktop com sete imagens. Capturas em [release-2026-09-25](release-2026-09-25/).

## Rollback

- Frontend: preservar a versão problemática com outro nome e restaurar o diretório remoto `/savemed-backup-20260925` como `/savemed`; alternativamente reenviar o backup local. Não excluir backups antes de confirmar a estabilidade.
- API: `gcloud run services update-traffic api-savemed --region southamerica-east1 --project ceremonial-orb-490701-q8 --to-revisions api-savemed-00056-xur=100`.
- Se voltar a API, voltar também o frontend: a função de salvar perfil depende da nova rota.

## Limites

A publicação não criou farmácias, produtos, pedidos, pagamentos ou novos usuários para smoke tests. Os testes completos de criação/edição foram executados com serviços/respostas isolados, conforme [revisão de cadastros](revisao-cadastros-2026-09-25.md). O salvamento de perfil na candidata reenviou os valores existentes da conta de teste administrativa.

Não houve publicação de APK/AAB/IPA na Play Store ou App Store. Teste em aparelhos físicos, teclado virtual e leitores de tela continua pendente. Contratos HTTP legados foram preservados e verificados, mas isso não substitui testar os binários antigos em dispositivos.
