# Roadmap de melhorias do frontend SaveMed

Rechecagem de 03/10/2026 após a limpeza de dados de cartão na restauração de
sessão: `dart format --set-exit-if-changed lib test scripts`, `flutter analyze`,
`flutter test --concurrency=1` (349 testes), teste do fingerprint e auditoria OSV
passaram. O OSV não encontrou advisories conhecidas nas 85 dependências Pub
hospedadas. Builds locais atuais: Web release
`main.040974aff912a4449f7070e9226bfe83a67a46d0e19154b77ab0c81e1df85afc.dart.js`
(3.586.142 bytes; SHA-256 `040974AFF912A4449F7070E9226BFE83A67A46D0E19154B77AB0C81E1DF85AFC`)
e APK debug (SHA-256
`E3609A52E961D7F9FFE1BB8B0EC223C199A5DC0776886B832B72FCFC6A0737C4`). São
artefatos locais, não publicados. Produção continua em `main.06ab...`; nenhum
APK, API ou arquivo Hostinger foi alterado nesta rechecagem. CI hospedado,
distribuição nas lojas e validação em dispositivos reais seguem pendentes.

Rechecagem adicional em 03/10/2026 após reforço de retenção dos dados de cartão:
formatação sem alterações, `flutter analyze` limpo e 348 testes aprovados. Os
testes confirmam que sair de `resumed` limpa a seleção em memória e zera os campos
do modal antes de exibir aviso acessível. Build Web local
`main.9e4883e82ceb2382051a11f7e3fe5eec06d039320076d6ba65c4d9952cf83101.dart.js`
(3.585.893 bytes; SHA-256 `9E4883E82CEB2382051A11F7E3FE5EEC06D039320076D6BA65C4D9952CF83101`)
e APK debug (SHA-256 `82FB10C0F1AC32EDE72A61302383EAEC30EDF59B7CB6739C316C601EB453EDB2`)
compilados. O preview local serviu o bundle com HTTP 200 e os bytes esperados; o
bootstrap de produção continua em `main.06ab...`. Nenhum artefato foi publicado.

Rechecagem adicional em 03/10/2026: `dart format --set-exit-if-changed lib test scripts`,
`flutter analyze` e `flutter test --concurrency=1` aprovados (346 testes). O build
Web release reproduziu o fingerprint local `main.e11192378a58258d7e4a5d053d0626d3fc9df7900500379f619aaf05646a230f.dart.js`
sem diferenca; `flutter build apk --debug` tambem concluiu (SHA-256 local
`4E74BDB6A5077DBD507018FAA4172E8738E46599E0629204D02333125731231E`). A auditoria
OSV nao encontrou avisos conhecidos nas 85 dependencias Pub hospedadas. Nenhum
artefato foi publicado; o bundle ativo na Hostinger continua sendo `main.06ab...`.

Validacao local reexecutada em 03/10/2026: `dart format` sem pendencias, incluindo
`test/widget_test.dart`, `flutter analyze` limpo, 346 testes aprovados e nenhuma
advisory OSV conhecida nas 85 dependencias Pub hospedadas. Builds Web release
`/savemed/` e APK Android debug concluidos. A revisao local de retencao de dados
de cartao, remocao da coleta de CPF redundante e ajuste responsivo da pre-visualizacao
em 320 px/200% gerou
`main.8f4c11c689fbd8348b1b78157484844fb5cbf51782c9e7f91e7bfecf1347a861.dart.js`
(3.581.834 bytes; SHA-256 `8F4C11C689FBD8348B1B78157484844FB5CBF51782C9E7F91E7BFECF1347A861`).
Esse bundle ainda nao foi publicado. A validacao de cadastro e do rodape em
03/10 gerou o candidato local anterior
`main.6fd80cd39642b7f78c8244e55d42f3cff9e7b7be0bbc3ef3e0faae18c990104b.dart.js`
(3.581.770 bytes; SHA-256 `6FD80CD39642B7F78C8244E55D42F3CFF9E7B7BE0BBC3EF3E0FAAE18C990104B`),
que tambem nao foi publicado. O ajuste posterior do CTA do cartao, validado com
345 testes, `flutter analyze`, build Web release e APK debug, gerou o candidato
local anterior
`main.ab6c6abb83a6abfdc3751dba0bc3577a440e0df8024790c763afaf71131b538d.dart.js`
(3.581.768 bytes; SHA-256 `AB6C6ABB83A6ABFDC3751DBA0BC3577A440E0DF8024790C763AFAF71131B538D`).
O APK debug local daquele build tem SHA-256 `05302595E7A3CEE2CEAC1D9B22A0E03B908646D077FBB809F7970F07AAE2AE2C`.
A limpeza de PAN/CVV ao sair da rota de pagamento foi validada posteriormente
com 346 testes e gerou um candidato Web local anterior
`main.e11192378a58258d7e4a5d053d0626d3fc9df7900500379f619aaf05646a230f.dart.js`
(3.581.914 bytes; SHA-256 `E11192378A58258D7E4A5D053D0626D3FC9DF7900500379F619AAF05646A230F`).
O APK debug correspondente tem SHA-256 `2DBFE7ECE537D01850BDC4562C16417A7FF66CD9AEDD1712829178771BF0509E`.
Nenhum desses artefatos foi publicado. O bootstrap de producao aponta para
`main.06ab9aa035d08e0c8d73b99464177071266afdf26af4a58dde2ebce29e32effd.dart.js`.
O teste isolado de
`fingerprint_web_entrypoint.ps1` passou para hash, idempotencia, validacao do
nome, rejeicao de traversal e atomicidade em falha. O candidato permanece
somente local.
O primeiro bundle publicado
em 03/10/2026 foi `main.6ce1c6b7a58cfe3db1cb3c673ccb59ce4b3236aacacca10faf131d4010cf332d.dart.js`
(3.581.009 bytes; SHA-256 `6CE1C6B7A58CFE3DB1CB3C673CCB59CE4B3236AACACCA10FAF131D4010CF332D`),
mantido no servidor para rollback. A atualizacao autorizada em 03/10 ativou
`main.06ab9aa035d08e0c8d73b99464177071266afdf26af4a58dde2ebce29e32effd.dart.js`
(3.581.576 bytes; SHA-256 `06AB9AA035D08E0C8D73B99464177071266AFDF26AF4A58DDE2EBCE29E32EFFD`).
O bootstrap remoto aponta para o `06ab`; ambos os bundles anteriores permanecem
disponiveis para rollback. Validacao publica apos a troca confirmou HTTP 200,
bytes e hash exatos, login renderizado, cache imutavel do bundle e `no-store` da
entrada. Nenhum APK/AAB ou API foi publicado nesta atualizacao.
`flutter build apk --debug` tambem passou nesta validacao. SHA-256 do APK debug:
`D7F80A14C47D635E2A41C2C2C14A037A7F53FB46E14E8D3206CE9D8AF6DB5FD1`. O application ID e a
versao continuam `com.bravelight.save_med` e `1.1.0+7`; esse build debug nao e
artefato de distribuicao. Para atualizar lojas, incrementar o build e validar
assinatura/distribuicao interna primeiro.
Regressao adicional em 03/10: a pre-visualizacao do cartao limitou o nome do
titular com reticencias para impedir overflow horizontal em viewport de 320 px
com texto a 200%. A regressao de cadastro agora verifica explicitamente que a
senha valida com confirmacao vazia deixa o criterio de correspondencia pendente,
que uma confirmacao divergente e sinalizada e que uma confirmacao correspondente
e aceita. A validacao local mais recente da suite serial completa aprovou 345
testes, com formatacao limpa e `flutter analyze` sem issues.
Auditoria de dependencias executada novamente: 85 pacotes Pub hospedados sem
advisories conhecidos no OSV. O workflow CI esta definido localmente, mas ainda
sem execucao hospedada porque nao foi integrado a branch remota.
Rechecagem em 03/10/2026: branch local `codex/merge-d-drive-20260812`,
`origin/main` permanece em `70f7a18bdd661988bad6ef29c9f55b60d1b014ca` e o
workflow continua fora desse commit. A execucao hospedada depende de integrar
o workflow junto dos scripts e testes locais que ele referencia; nenhum commit
ou push foi feito nesta rodada.
O build web final repetiu o comando do CI, incluindo `--no-web-resources-cdn`,
antes de gerar o fingerprint acima. Em 03/10, a recompilacao reproduziu o mesmo
fingerprint; o preview local em `/savemed/` respondeu HTTP 200 para entrada,
bootstrap e bundle, servindo os 3.581.326 bytes esperados. Nenhuma escrita remota.
Smoke visual local em Edge, servindo o artefato no caminho real `/savemed/`:
login e abertura do cadastro carregaram; em viewport de 320x640 CSS px,
`scrollWidth` permaneceu igual a `innerWidth` (sem overflow horizontal). Os
indicadores de senha responderam ao digitar nos dois campos. A automacao rolou
o formulario ao clicar em cadastro; a posicao inicial com toque/clique real
continua pendente de dispositivo, sem evidencias para alterar o layout.
Checkpoint historico de cadastro: teste Flutter por toque realista em viewport
320x640 confirmou que o titulo abre abaixo do cabecalho fixo e dentro da tela;
naquela execucao, 326 testes passaram e `flutter analyze` ficou limpo. O total
atual, validado acima em 03/10/2026, e 330. Nova regressao de
teclado percorre por Tab os campos de CNPJ, nome da farmacia, cidade, UF e CEP
na ordem visual; validacao com teclado fisico e dispositivos reais continua
pendente.
Revisao read-only do contrato financeiro confirmou que o cliente preserva
campos opcionais/ausentes de APIs antigas sem inventar repasse, enquanto a API
atual rejeita valores negativos e frete maior que o total. O comando
`node --test tests/marketplaceOperations.test.js` no repositorio da API passou
(6/6); nenhum arquivo da API foi alterado.
Revisao de cadastro de produto no gestor: corrigida a grafia de “Exige receita
medica” e “prescricao” para “médica” e “prescrição”. O teste confirma que a
opcao marcada envia `REQUIRES_RX: true`, conforme o modelo da API, nos tamanhos
390/1280 px e escala de texto normal/200%. Golden administrativa atualizada;
46 testes do modulo e 326 testes globais passaram naquela execucao, com
`flutter analyze` limpo.

Revisao operacional em 02/10/2026: perfil `Savemed` do Edge acessivel;
snapshot do `.htaccess` ja preservado localmente. Scripts de backup/ativacao
foram endurecidos para exigir dominio e config explicitos, validar host FTP,
rejeitar o endpoint legado `147.93.39.52` e exigir FTPS no helper de backup.
Validacao do parser PowerShell e dos bloqueios negativos passou sem conexao ou
escrita remota nessa etapa. O helper FTP legado permanece bloqueado; a
publicacao aprovada em 03/10 usou upload TUS autenticado somente para os arquivos
especificados, sem sobrescrever a raiz do site.

Revalidação em 02/10/2026 às 23:00 BRT: política de telefone compartilhado
mantida; `dart format` sem alterações, suíte Flutter completa com 324 testes e
`flutter analyze` sem issues. Web release `/savemed/` regenerado com bundle
`main.6ce1c6b7a58cfe3db1cb3c673ccb59ce4b3236aacacca10faf131d4010cf332d.dart.js`
(3.581.009 bytes; SHA-256 `6CE1C6B7A58CFE3DB1CB3C673CCB59CE4B3236AACACCA10FAF131D4010CF332D`);
APK Android debug e release compilados. O release mantém pacote
`com.bravelight.save_med`, versão `1.1.0`/código `7` e certificado SHA-256
`e0354e06ee216b3352525d7683f55a044ae1efea101f8bb4213364e0f15c9936` (assinatura
v2 válida); SHA-256 do arquivo `E6287DD0FDA1A8E59DE63ABE9CDDA03B15D939E412B48397F10470337AA30899`.
Na checagem de 02/10, os builds eram locais, não publicados nem distribuídos. O código `7` já estava nas lojas.
A conta Hostinger correta confirmou `savemed.app` (`u974916224`). O endpoint de
leitura do conector continua bloqueado pelo Cloudflare (HTTP 403), mas o perfil
`Savemed` foi disponibilizado e o File Browser do hPanel permitiu ler
`/public_html/savemed/.htaccess`; snapshot de 370 bytes salvo em
`docs/savemed-app-htaccess-2026-10-02.txt` (SHA-256
`D7E3E0116982BC46621F04223DD188D6DB08859F2A223BCFB9FF33FA80EAFA0D`).
Nenhuma escrita remota havia sido feita naquela etapa.
Checagem pública read-only de 02/10: `/savemed/version.json` respondia `1.1.0`/build `7`;
o bootstrap ativo aponta para `main.4a6cf3c1155cd56bbbdba80a7c781a86b426fe9c10812048c6fa45f699d30c75.dart.js`
(HTTP 200). Aquele estado foi atualizado pela publicação de 03/10 documentada
abaixo: o bundle aprovado está ativo e headers/cache foram confirmados em produção.

Correcao adicional do gestor: ao editar um produto legado cuja subcategoria
pertence a outra categoria, o formulario agora limpa a selecao interna, mostra
um aviso explicito e permite salvar com `SUBCATEGORY_ID` nulo. Regressao validada
em 390/1280 px e escala 100/200%; suite completa atualizada: 330 testes.

Revalidação em 02/10/2026 às 22:35 BRT após a decisão de permitir telefones
compartilhados: `dart format` sem alterações, `flutter analyze` sem issues e
324 testes Flutter aprovados. A regressão confirma que respostas legadas
`PHONE_IN_USE` não são apresentadas como regra de unicidade; telefone inválido
continua com mensagem específica.
Builds locais após a alteração: Web release em `/savemed/` com bundle
`main.3603d10b08ec26504ec32270f4c8a4fdf615192fd53461092041d69d11ae0e46.dart.js`
(3.580.922 bytes; SHA-256 `3603D10B08EC26504EC32270F4C8A4FDF615192FD53461092041D69D11AE0E46`)
e APK Android debug concluídos. O novo bundle ainda não foi publicado; build da
loja permanece `1.1.0+7` e não foi distribuído.

Verificacao em 02/10/2026: `dart format --set-exit-if-changed lib test scripts`,
`flutter analyze`, auditoria OSV de 85 pacotes e 323 testes Flutter seriais
aprovados; build web release em `/savemed/` e APKs Android debug/release concluidos.
Revalidacao em 02/10/2026, 22:27 BRT: formatacao sem alteracoes, `flutter analyze`
sem issues e `flutter test --concurrency=1` com 323 testes aprovados. A conexao
Hostinger `hostinger-savemed` confirmou o site e a presenca de `/savemed/.htaccess`
no document root correto; a leitura do conteudo ainda retorna 403 do Cloudflare.
Nenhum arquivo remoto foi alterado nesta verificacao; nao substituir o `.htaccess`
sem copia confiavel. Rotacionar o token apos concluir a publicacao prevista e
atualizar o alias global sem registrar o novo segredo no repositorio.
O APK mais recente preserva package, versao e certificado de release; SHA-256
`A369C6A95B0D28B0E4F06AB722F5A766492B64F3790B8692B937F53807468C42`.
Rebuild apos os ajustes textuais: web release com base `/savemed/` e APK release
local; `apksigner` confirmou assinatura v2 e certificado de release preservado,
com pacote `com.bravelight.save_med`, versao `1.1.0`/codigo `7` e `targetSdk 36`.
Nenhuma publicacao foi feita nesta rodada. O APK local continua em `1.1.0+7`,
igual ao build publico, e nao deve ser distribuido como atualizacao da loja;
incrementar o numero de build ao aprovar a proxima versao de release. Quatro testes administrativos foram alinhados ao botao de
usuarios atual, identificado por tooltip, e as goldens de login mobile/desktop
foram atualizadas para incluir as bandeiras de pagamento exibidas no rodape.
O parser do gate OSV rejeita linhas de dependencias sem formato/origem validos
ou com origem desconhecida,
com regressao coberta sem rede; a auditoria encontrou zero advisories conhecidos.
Valores monetarios nao finitos (`NaN`/`Infinity`) sao rejeitados no parser
compartilhado e nos parsers de estoque, pedidos, financeiro, farmacia, promocao
e entrega; formularios administrativos e o controller de checkout tambem validam
os valores antes de salvar ou cobrar.
Regressão de autenticação confirma e-mail normalizado em login/cadastro e senha preservada sem `trim`. Hardening HTTP local adicionado ao `.htaccess` e confirmado no build web release;
os headers efetivos no dominio Hostinger ainda aguardam publicação e inspeção HTTP.
Na recuperação de senha, o e-mail fica bloqueado após o envio do código; a ação
"Alterar e-mail" limpa código e senhas para impedir a redefinição com código
vinculado a outro endereço. Reenvio confirmado também limpa os dados anteriores;
se falhar, mantém os dados disponíveis. Regressões cobrem troca de e-mail,
reenvio confirmado e falha ao reenviar.

Smoke test real de cadastro e recuperacao no Cloud Run: farmacia e administrador
QA criados; cadastro `201`, login inicial `200`, recuperacao `200`, codigo recebido
na Inbox Gmail, redefinicao `200`, login apos redefinicao `200` e reutilizacao do
codigo recusada com `400`. O mesmo fluxo de recuperacao e login foi concluido no
APK Android debug em emulador; a captura abriu a visao geral de farmácia sem
estouro visivel. O registro `pharmacy_id=5` permanece ativo e sem
produtos; desativar pelo gestor apos o teste. Nenhuma senha ou codigo foi registrado.
O cabeçalho do e-mail mostrou SPF pass, ausencia de DKIM e DMARC fail para
`savemed.app`; DNS publica SPF com `~all` e DMARC `p=none`. Alinhar DKIM/DMARC
no Hostinger antes de considerar a entregabilidade concluida. Android foi testado
em emulador; iOS e validacao em aparelho fisico continuam pendentes.

Atualizacao do runner web em 28/09/2026: os 49 testes de widgets de auth,
cadastro e administracao passaram no Chrome/Linux; a suíte completa passou no
Windows (263 testes). O runner Chrome local do Windows segue com defeito no
harness do SDK e as 12 divergencias visuais da suíte Linux são apenas snapshots
PNG. O workflow local separa os gates por plataforma; falta sua primeira
execucao hospedada. Evidencia: [diagnostico do runner](docs/flutter-test-chrome-windows-2026-09-28.md).

Auditoria de segredos do frontend em 28/09/2026: refs do `origin` atualizadas
por fetch; nenhum caminho `.env` foi encontrado no historico Git disponivel.
Busca por formatos comuns de tokens e chaves privadas nao encontrou arquivos
no workspace. Repositorio da API, Secret Manager, Hostinger e SMTP nao foram
cobertos; a pendencia de rotacao permanece aberta.

Varredura redigida adicional: refs locais/remotas disponiveis, historico sem
caminhos `.env`, e padroes de chaves AWS (`AKIA`), Google (`AIza`), Pagar.me
(`sk_live`/`sk_test`) e cabecalhos de chaves privadas. Nenhuma correspondencia
no worktree ou refs. Gitleaks/TruffleHog nao estao instalados; a busca por
padroes nao equivale a um scanner completo nem cobre o historico da API.
Hardening local: `.gitignore` exclui `.env` e `.env.*`, permitindo apenas
`.env.example`; `git check-ignore` confirmou os padroes, sem criar arquivos.

Rechecagem redigida em 03/10/2026: Gitleaks 8.29.1 oficial, com checksum do
release verificado e sem instalacao no projeto. `gitleaks git --log-opts=--all`
analisou os seis commits alcancaveis e nao encontrou segredos; os sete blobs
Git inalcançaveis encontrados por `git fsck` tambem foram analisados em stdin,
sem achados. As arvores
`lib`, `web`, `scripts`, `.github`, `android`, `assets` e as demais plataformas
nao tiveram achados; os tres matches em `docs`/`test` foram um identificador
publico de revisao Cloud Run e dois literais de senha de teste, ausentes dos
fontes de producao. O scan amplo do workspace produziu 3.124 matches em sua
maioria nos perfis locais ignorados `.chrome-*`/`.edge-*` e em arquivos binarios
gerados; nem todos esses matches foram individualmente classificados. Entre
eles havia uma URL assinada SigV4 de login AWS salva em dois arquivos Bookmarks,
com data assinada de 31/03/2023, ja obsoleta, alem de padroes GCP/entropia em
metadados do navegador. Os perfis foram preservados sem leitura de cookies nem
alteracao dos dados. A varredura nao cobre segredos externos do Cloud Run,
Hostinger ou SMTP/Pagar.me; rotacao e revisao externa continuam pendentes. O
binario e os downloads do scanner ficaram em `%TEMP%`.
- [ ] Revisar e limpar, com aprovacao do proprietario, as copias ignoradas de perfil
  `.chrome-savemed-check` e `.edge-final-audit`; contem bookmarks com URL de
  autenticacao assinada antiga e podem preservar outros estados locais de sessao.

## Evolucao para marketplace de farmacias

Plano autorizado em 2026-09-27: [execucao e pendencias](docs/marketplace-roadmap.md).
Primeiro lote implementado localmente: central de pedidos, financeiro, pausa da
loja, preparo, acompanhamento e rotina de conciliacao (ativacao externa pendente).
Pedidos do cliente agora atualizam a cada 30 segundos somente enquanto a aba esta
ativa e o app em primeiro plano, com atualizacao ao retornar; push ainda pendente.
O catalogo e o detalhe mostram quando a farmacia esta pausada e impedem adicionar
esses produtos ao carrinho; regressao cobre o contrato `IS_OPEN`.
Comissao confirmada: 20% dos produtos, excluindo frete; repasse de 15 ou 30 dias
apos a confirmacao da entrega ou retirada.
A SaveMed absorve a taxa Pagar.me na sua comissao, sem desconto adicional a farmacia.
Split e transferencias desativados: falta homologar recebedores e regras de liquidacao.

Continuacao local: reserva transacional de estoque antes do pagamento, bloqueio de
edicao legada durante cobranca, liberacao idempotente apos recusa confirmada e
recuperacao de estornos pendentes por consulta. Situacao de estoque visivel no gestor.
Validacao: 162 testes API e 14 testes PostgreSQL. Migracao antiga, APKs e ativacao
externa ainda pendentes; nenhuma publicacao nesta etapa.

## PedMoto - implementada localmente, ativacao pendente em 2026-09-27

- [x] Revisar conversa, PDF de demonstracao e Technical Whitepaper v3 encontrado em Downloads.
- [x] Corrigir envelope da cotacao e payload de criacao conforme whitepaper.
- [x] Integrar cotacao, consentimento de custo, contratacao e consulta no gestor por pedido.
- [x] Proteger duplicacao, timeout, isolamento entre farmacias e estorno durante corrida.
- [x] Exibir motoboy/status/custo e manter confirmacao pelo codigo do cliente.
- [x] Validar 150 testes API e 112 Flutter; revisar capturas mobile/desktop.
- [ ] Validar instancia, chave atual, geocodificador e responsabilidade pelo pagamento.
- [ ] Homologar contrato real; manter PEDMOTO_DISPATCH_ENABLED=false ate essa etapa.
- [ ] Obter API publica de cancelamento, busca por external ID, webhook e codigo no app do motoboy.
- [ ] Publicar API/web e validar dispositivos reais. Nenhuma corrida real solicitada.

Detalhes e limites: [integracao PedMoto](docs/pedmoto-2026-09-27.md).

## Entrega propria - implementada localmente em 2026-09-27

- [x] Detalhes de produtos, cliente e endereco no gestor da farmacia.
- [x] Aceitar, preparar, marcar pronto e identificar entregador proprio.
- [x] Confirmar entrega/retirada e registrar retorno com justificativa.
- [x] Historico operacional e etapa visivel ao cliente atualizado.
- [x] Proteger pedidos pagos, escopo da farmacia e atualizacoes concorrentes.
- [x] Testar layouts mobile/desktop e inspecionar capturas.
- [x] Exibir codigo de 4 digitos ao comprador e exigir validacao na entrega/retirada.
- [x] Bloquear por 15 minutos apos 5 erros, invalidar na conclusao e renovar na nova saida.
- [x] Validar 133 testes da API, 108 testes Flutter e build web com confirmacao por codigo.
- [ ] Configurar segredo estavel de entrega e disponibilizar web atualizada para clientes de apps antigos.
- [ ] Publicar API com migracao aditiva antes do frontend.
- [x] Preparar integracao PedMoto a pedido do usuario; ativacao real segue pendente conforme secao acima.

Detalhes e referencias da conversa: `docs/entrega-propria-2026-09-27.md`.

## Cartoes - correcao local em 2026-09-27

- [x] Corrigir aprovacao captured, pendencia e recusa sem quebrar success dos apps antigos.
- [x] Validar credito aprovado, recusado e pendente no simulador Pagar.me.
- [x] Acompanhar cartao pendente na tela sem limpar carrinho nem permitir novo pagamento.
- [x] Proteger tentativas simultaneas na API com atualizacao condicional persistente.
- [x] Conciliar cartoes antigos gravados como failed mediante confirmacao do provedor.
- [x] Remover persistencia de numero/CVV e apagar o armazenamento legado no cliente atualizado; a serializacao de `PaymentCard` agora permite apenas metadados de exibicao e descarta dados sensiveis ao reconstruir JSON, coberto por teste de regressao. CTA do modal renomeado de "Salvar cartao" para "Usar cartao" para nao sugerir persistencia que o app nao oferece; regressao textual e matriz de 320 px/200% aprovadas.
- [x] Limpar os dados do cartao e o cache da sessao imediatamente apos iniciar cada tentativa, ao descartar o controlador ou ao fechar o modal; exigir nova informacao no retry. Remover CPF redundante que nao chegava a API. Testes cobrem envio do payload corrente, falha, pendencia, resultado incerto e ausencia de restauracao apos limpeza.
- [x] Limpar PAN/CVV da memoria ao abandonar a tela de pagamento sem enviar cobranca; a rota limpa o estado sensivel sincronamente sem notificar listeners durante a desmontagem. Regressao cobre a acao Voltar e confirma selecao/cartoes vazios.
- [x] Ao sair do estado `resumed`, limpar a selecao de cartao em memoria e apagar os campos do formulario aberto; exibir aviso acessivel para reinserir os dados ao retornar. Regressao cobre estado `inactive`, campos vazios, aviso e ausência de excecao (`test/features/commerce/commerce_accessibility_test.dart`).
- [x] Validar localmente tamanho/Luhn do cartao, titular, validade nao vencida e CVV antes de aceitar a entrada; exibir erros junto aos campos e manter a validacao do provedor como autoridade.
- [x] Manter a pre-visualizacao do cartao sem overflow em 320 px com texto a 200%, limitando visualmente o nome do titular e preservando a validade; regressao incluida na suite responsiva.
- [x] Em timeout/falha de conexao, consultar o pedido antes de liberar outra tentativa; pago conclui, falha confirmada libera retry e estado pendente/desconhecido bloqueia nova cobranca. [Comportamento e limites](docs/pagamento-resultado-incerto.md).
- [ ] Habilitar debito na conta de homologacao e validar autenticacao/3DS.
- [ ] Migrar captura de cartao para tokenizacao e validar os requisitos PCI. A auditoria do contrato, as dependencias e os criterios de rollout estao em [diagnostico de tokenizacao](docs/payment-tokenization-discovery-2026-10-02.md). Rechecagem oficial em 03/10/2026 confirmou `card_token` para Gateway, `card_id` para PSP e proibicao de enviar cartao aberto ao servidor sem PCI; modelo da conta, chave publica, dominio liberado e suporte aditivo na API permanecem sem confirmacao. Nao habilitar integracao parcial.
- [ ] Automatizar recuperacao no servidor de tentativas sem ID de cobranca; o frontend mantem a tentativa bloqueada enquanto a API nao confirmar um desfecho.
- [ ] Publicar API/web e distribuir atualizacao mobile apos revisao de release.

Detalhes: `G:/GitHub/api-savemed/docs/CARD-VALIDATION-2026-09-27.md`.

## Objetivo

Estabilizar o frontend publicado da SaveMed, com prioridade para cadastro, autenticação, gerenciamento de farmácias e operação administrativa, evitando regressões nos aplicativos disponíveis na Apple App Store e Google Play Store.

Este roadmap considera o estado atual do projeto Flutter e da API publicada em julho de 2026. Mudanças de contrato entre frontend e backend devem ser validadas em ambiente de homologação antes de qualquer nova versão.

## Princípios de execução

- Não alterar contratos consumidos pelas versões já publicadas sem compatibilidade retroativa.
- Corrigir primeiro problemas de segurança, perda de dados e fluxos impossíveis de concluir.
- Separar mudanças críticas de refatorações visuais ou arquiteturais.
- Entregar alterações em lotes pequenos, testáveis e reversíveis.
- Manter cadastro de clientes e compras funcionando durante a evolução do painel administrativo.
- Publicar primeiro em homologação, depois em distribuição interna e somente então em produção.

## Prioridade 0 - Proteção imediata da produção

Rechecagem em 02/10/2026: o bundle versionado foi publicado e confirmado por SHA-256, HTTP 200 e renderização pública de login/cadastro. O registro de cabeçalhos/cache abaixo foi atualizado nesta mesma data; o `.htaccess` remoto continua sem alteração até leitura/backup confiável.

### Segurança dos dados

- [x] Remover dos logs o header `Authorization` e qualquer token de sessão.
- [x] Não registrar senhas, códigos de recuperação, documentos, telefone ou corpos completos de autenticação.
- [x] Criar uma política central de logs com enumeração de eventos permitidos; impedir interpolação de payloads e preservar chaves estáveis, coberto por teste.
- [x] Desabilitar logs detalhados em builds `release`.
- [x] Revisar mensagens de erro para não expor detalhes internos da API.
- [x] Verificar se builds já publicados registram dados sensíveis em ferramentas externas de monitoramento.
- [x] Adicionar auditoria de advisories OSV às dependências Pub travadas no CI: 85 versões hospedadas consultadas em 28/09/2026, sem correspondências; testes de parser e associação incluídos. Rechecagem em 02/10/2026 às 21:01 BRT com `dart run scripts/check_pub_advisories.dart`: as mesmas 85 dependências sem correspondências, sem alteração de versões. [Escopo e limites](docs/dependency-audit-2026-09-28.md).
  Rechecagem em 02/10/2026 às 21:36 BRT: `dart run scripts/check_pub_advisories.dart` consultou 85 dependências hospedadas, sem advisories; os cinco testes de `test/security/pub_advisory_audit_test.dart` passaram. Nenhuma dependência foi atualizada.
- [x] Configurar `X-Content-Type-Options`, `X-Frame-Options` e `Referrer-Policy` no `.htaccess` local e cobrir as diretivas em teste; a resposta efetiva, pendente na anotação original, foi confirmada em produção em 03/10 abaixo.
- [x] Publicar os cabeçalhos de segurança configurados em `web/.htaccess` e confirmar respostas efetivas em `savemed.app`. Em 03/10/2026, o `.htaccess` previamente copiado foi atualizado no caminho `/public_html/savemed/`, preservando as diretivas de WASM e cache HTML/bootstrap sem armazenamento. `curl -I` confirmou `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Referrer-Policy: strict-origin-when-cross-origin` e `Cache-Control: no-store, no-cache, must-revalidate, max-age=0` para `/savemed/`; nenhuma outra pasta ou arquivo do `public_html` foi substituído.
Rechecagem read-only em 02/10/2026 às 22:55 BRT (estado anterior à publicação de 03/10): `/savemed/version.json` retorna `1.1.0`/build `7`; o bootstrap ativo aponta para `main.4a6cf3c1155cd56bbbdba80a7c781a86b426fe9c10812048c6fa45f699d30c75.dart.js` (HTTP 200). Naquela checagem, `/savemed/` respondia 200 com `no-store`; o JS versionado usava cache de 7 dias e as respostas não tinham `X-Content-Type-Options`, `X-Frame-Options` ou `Referrer-Policy`. O estado foi corrigido e validado nas verificações abaixo.
-   Publicação em 02/10/2026 às 22:08 BRT: o bundle local versionado agora está ativo em `/savemed/`; o bootstrap e o asset foram verificados publicamente, e o login/cadastro renderizou no navegador. O `.htaccess` ainda não foi modificado: a resposta de `/savemed/` segue sem `X-Content-Type-Options`, `X-Frame-Options` e `Referrer-Policy`; leitura remota do arquivo foi bloqueada por desafio Cloudflare.
  Histórico pré-publicação: requisições ao entrypoint estável `main.dart.js` retornavam `no-store` e 3.575.684 bytes. Esse arquivo permanece no servidor para rollback; a versão ativa agora usa o bundle versionado descrito acima.
  Histórico pré-publicação em 02/10/2026 às 22:15 UTC: o bundle ativo ainda era o `main.dart.js` antigo e nenhum arquivo remoto havia sido alterado. O bundle versionado e o bootstrap foram publicados depois; os headers/cache descritos acima foram concluídos em 03/10.
  A FTP previamente configurada foi verificada somente por leitura e não corresponde ao deploy público atual: `/savemed/version.json` nela informa `1.0.1`/build 4/package `SaveMed`, enquanto `savemed.app/savemed/version.json` informa `1.1.0`/build 7/package `savemed`. O `.htaccess` FTP (SHA-256 `F3B71105204D4BBD00129BC016713E2E5CC8568B5B0E82FF96631F13E1AD42F9`) também difere do candidato local. Essa conexão segue fora de uso para publicar no app atual.
  Histórico pré-publicação (02/10/2026 às 21:22 BRT / 03/10 às 00:22 UTC): o bundle ativo ainda era `main.dart.js`; só a CSP estava presente e a conexão então configurada retornou 401. A anotação é anterior ao deploy autorizado de 03/10.
  Confirmação read-only em 02/10/2026: a credencial FTP local ainda autentica e permite listar/baixar `/savemed`. O `version.json` baixado dessa origem informa `1.0.1`/build 4/package `SaveMed`, enquanto o público retorna `1.1.0`/build 7/package `savemed`; são destinos divergentes. Nenhum upload foi feito; não usar essa FTP para alterar o app público.
- [x] Especificar a migração coordenada da sessão Web para cookie `HttpOnly`, CSRF e compatibilidade Bearer mobile em [plano de sessão Web](docs/web-cookie-session-migration.md). Implementação e homologação permanecem pendentes no roadmap da API: não alterar o cliente isoladamente.
- [x] Auditar navegação externa e imagens de conteúdo: suporte usa `https://wa.me` fixo e inclui apenas o número do pedido; CTA promocional executa rolagem interna. O cliente pede conteúdo compacto, confirmado na API pública com seis blocos sem imagem base64 inline e URLs de imagem.

### Fluxo de farmácia existente

- [x] Remover ou desabilitar temporariamente a opção "Farmácia já cadastrada" no cadastro público.
- [x] Exibir uma orientação segura para o responsável entrar em contato com o suporte enquanto a API não estiver disponível.
- [x] Impedir chamadas para rotas inexistentes em produção.
- [x] Remover a tela administrativa de solicitações da navegação ou marcá-la como indisponível sem permitir ações.
- [x] Corrigir o contrato que atualmente envia CNPJ no campo `CPF`.

### Estabilidade mínima

- [x] Atualizar o teste da tela inicial para considerar a restauração de sessão.
- [x] Garantir que uma sessão inválida volte ao login sem loop ou tela vazia.
- [x] Corrigir textos com codificação corrompida.
- [x] Confirmar login e recuperação reais no Web e no APK Android: envio e uso do código, login após redefinição e bloqueio de reutilização foram observados em 02/10/2026.
- [x] Cobrir os contratos de identidade do acesso: login e cadastro normalizam e-mail com `trim + lowercase`, preservando a senha exatamente como digitada; validar recuperação na interface (e-mail, falha de envio, código, confirmação e redefinição) e rotas/payloads atuais sem fallback.
- [ ] Confirmar login, logout e recuperação de senha no iOS via TestFlight/dispositivo; indisponível neste ambiente Windows.

### Critérios de aceite da prioridade 0

- Nenhum token, senha ou documento aparece nos logs.
- Nenhuma opção visível chama rota `404` conhecida.
- `flutter analyze` não apresenta erros.
- Todos os testes existentes passam.
- Cadastro de cliente, login e recuperação de senha passam por teste manual em homologação.

## Prioridade 1 - Cadastro de usuários e farmácias

### Definição dos fluxos

- [x] Documentar claramente os perfis `customer`, `pharmacy_admin` e `app_admin`.
- [x] Definir quem pode criar uma farmácia e quem pode criar usuários administrativos.
- [x] Definir se a criação pública de uma nova farmácia exige aprovação da SaveMed.
- [x] Definir o estado inicial da farmácia: pendente, ativa, rejeitada, suspensa ou inativa.
- [x] Definir o comportamento para CNPJ já cadastrado.
- [x] Definir o processo para troca do administrador responsável.

### Cadastro público de nova farmácia

- [x] Transformar o formulário em etapas curtas: responsável, farmácia, contato e segurança.
- [x] Explicar antes do envio se a conta será ativada imediatamente ou ficará pendente.
- [x] Validar nome, e-mail, CNPJ, telefone, CEP, cidade e UF antes da chamada de API.
- [x] Aplicar máscaras consistentes e enviar valores normalizados.
- [x] Validar e-mail e força mínima da senha.
- [x] Exibir requisitos da senha antes do envio.
- [x] Permitir mostrar ou ocultar senha e confirmação.
- [x] Bloquear envios duplicados enquanto a requisição estiver em andamento.
- [x] Preservar os dados preenchidos em erros recuperáveis.
- [x] Exibir confirmação com próximo passo objetivo após sucesso.
- [x] Exibir mensagens específicas para duplicidade de e-mail e CNPJ, conforme os contratos atuais da API.
- [x] Cobrir no teste de interface o cadastro de cliente e o cadastro de farmácia nas quatro etapas, validando senha, e-mail normalizado, máscaras e submissão única; a consulta de CEP usa resposta controlada.
- [x] Definir a política de telefone compartilhado, conforme decisão do produto em 02/10/2026 BRT. O frontend não verifica duplicidade e respostas legadas `PHONE_IN_USE` não são mais apresentadas como conflito inline; regressões preservam a mensagem específica para telefone inválido. O serviço de cadastro da API valida o formato e o modelo `User` não declara `PHONE_NUMBER` como único.
- [ ] Confirmar dois cadastros com o mesmo telefone em banco de homologação. Rechecagem read-only em 02/10/2026 às 23:00 BRT: `User.PHONE_NUMBER` não declara `unique`, o serviço valida formato/comprimento e `server.js` chama `sequelize.sync()` sem `alter`. `node --test tests/pharmacyRegistration.test.js` passou 4/4; os testes usam dependências falsas e não exercitam índice preexistente no banco. A validação ponta a ponta segue pendente.
- [x] Substituir a criação em duas chamadas por uma operação atômica no backend.
- [x] Usar exclusivamente o cadastro transacional no frontend novo; o fallback em duas escritas foi removido porque a compensação de exclusão exige token administrativo e poderia deixar uma farmácia órfã. Os apps publicados mantêm seus próprios endpoints.

### Associação a farmácia existente

- [x] Criar endpoint de solicitação de acesso no backend.
- [x] Definir payload oficial com documento do responsável e `PHARMACY_ID`.
- [x] Definir se a lista pública pode expor nome, cidade e UF das farmácias.
- [x] Criar busca por nome, CNPJ parcial, cidade ou identificador seguro.
- [x] Evitar uma lista extensa em `DropdownButtonFormField`.
- [x] Exibir dados suficientes para diferenciar filiais com nomes iguais.
- [x] Criar status da solicitação: pendente, aprovada, rejeitada, cancelada ou expirada.
- [x] Impedir solicitações duplicadas para o mesmo e-mail e farmácia.
- [x] Definir validade e armazenamento seguro da senha antes da aprovação.
- [x] Preferir convite ou criação de senha após aprovação, evitando guardar senha de solicitação pendente.
- [x] Notificar solicitante e administradores nas mudanças de status.

### Gerenciamento administrativo de usuários

- [x] Separar visualmente "Nova farmácia" de "Novo usuário de farmácia".
- [x] Permitir criar usuário dentro do contexto da farmácia selecionada.
- [x] Ocultar campos de senha em criação e redefinição.
- [x] Preferir convite por e-mail em vez de senha temporária definida pelo administrador.
- [x] Exigir troca de senha no primeiro acesso quando senha temporária for mantida.
- [x] Exibir e diferenciar usuários ativos e inativos.
- [x] Exibir estados pendente e bloqueado após definir o contrato oficial desses estados.
- [x] Permitir ativar e inativar usuários com confirmação.
- [x] Reenviar convite após implementar o fluxo de convite no backend.
- [x] Impedir que o último administrador ativo de uma farmácia seja removido sem substituto.
- [x] Exigir confirmação para ações destrutivas ou irreversíveis.
- [x] Registrar auditoria de criação, aprovação, bloqueio e redefinição de senha.

### Fila de solicitações

- [x] Implementar rotas de listar, detalhar, aprovar e rejeitar solicitações.
- [x] Adicionar filtros por status, farmácia, data, nome e e-mail.
- [x] Mostrar documento mascarado e dados essenciais para conferência.
- [x] Exigir justificativa opcional ou obrigatória conforme a decisão.
- [x] Atualizar a lista sem perder filtros e posição.
- [x] Evitar aprovação duplicada por concorrência.
- [x] Exibir histórico da decisão e administrador responsável.

### Critérios de aceite da prioridade 1

- Cada tipo de cadastro tem uma finalidade clara e um único caminho principal.
- Nenhum formulário perde dados após erro de validação ou API.
- CNPJ e `PHARMACY_ID` chegam ao backend nos campos corretos.
- Criação de farmácia e primeiro administrador não deixa registros incompletos.
- Solicitações podem ser acompanhadas do envio até a decisão.
- Todos os fluxos possuem testes de sucesso, validação, duplicidade e falha de rede.

## Prioridade 2 - Painel administrativo e operação da farmácia

### Formulários e feedback

- [x] Manter diálogos abertos enquanto validação e salvamento são executados.
- [x] Mostrar carregamento no botão que iniciou a ação.
- [x] Desabilitar ações concorrentes durante o salvamento.
- [x] Exibir erros junto ao campo correspondente.
- [x] Exibir mensagem geral somente para erros não associados a um campo.
- [x] Aplicar `Form`, `FormField` e validadores reutilizáveis.
- [x] Identificar no rótulo o telefone opcional ao convidar um usuário de farmácia; regressão cobre ordem de Tab Nome -> E-mail -> Telefone e reduz o modal aberto a 390 px sem overflow.
- [x] Corrigir acentuação nos rótulos de promoção, inativação de farmácia e validação de UF; regressões cobrem o texto da UF e os rótulos de formulário existentes.
- [x] Revisar rótulos administrativos adicionais: conteúdo do app, entrega própria, início da promoção e limite de tamanho de imagem; testes de navegação administrativa e de pedido cobrem os textos atualizados.
- [x] Corrigir acentuação de mensagens de erro, validação de endereço/categoria/subcategoria, respostas da API e promoções, inventário e campos de entrega própria; formulário de farmácia verifica o texto nos quatro tamanhos/escala cobertos.
- [x] Alinhar o título da seção de inventário ao rótulo de navegação já acentuado e cobrir o título na matriz de viewport do formulário.
- [x] Descartar `TextEditingController` após o fechamento dos formulários.
- [x] Confirmar exclusão de farmácia, produto, categoria e item de estoque.
- [x] Informar consequências antes de inativar uma farmácia.
- [x] Diferenciar sucesso, aviso, validação e falha de conexão.

### Gerenciamento de farmácias

- [x] Validar CNPJ e impedir duplicidade.
- [x] Validar telefone, CEP, UF e campos obrigatórios.
- [x] Normalizar valores antes de montar o payload.
- [x] Buscar endereço por CEP com opção de correção manual.
- [x] Separar dados cadastrais, operação, entrega e usuários em seções ou abas.
- [x] Exibir claramente o status da farmácia e o motivo de inativação.
- [x] Definir permissões de edição para `app_admin` e `pharmacy_admin`.
- [x] Impedir que administrador de farmácia altere dados fora de seu escopo.
- [x] Substituir exclusão destrutiva por inativação lógica, preservando pedidos e vínculos históricos.

### Categorias, produtos e estoque

- [x] Substituir campos de ID numérico por seletores com nome e busca.
- [x] Filtrar categorias, produtos, estoque, pedidos e farmácias pela farmácia do usuário administrativo.
- [x] Garantir isolamento das operações administrativas no backend, não apenas na interface.
- [x] Validar preço, preço original, estoque e distância de entrega.
- [x] Usar formatação monetária brasileira.
- [x] Evitar preços negativos, estoque negativo e relações inexistentes.
- [x] Mostrar unidade, disponibilidade e última atualização.
- [x] Permitir estados vazios com ação apropriada.
- [x] Adicionar paginação local para listas grandes.

### Produtos, usuários e promoções - revisão de 10/07/2026

- [x] Incluir marca, unidade, EAN e exigência de receita no cadastro de produto.
- [x] Validar EAN opcional entre 8 e 14 dígitos.
- [x] Permitir criar operador ou administrador vinculado à farmácia.
- [x] Criar módulo administrativo de promoções com produto, farmácia, percentual e período.
- [x] Validar percentual, datas e vínculo do produto com a farmácia.
- [x] Exibir estados agendada, ativa e encerrada e confirmar exclusão.
- [x] Implementar upload de imagem do produto e da promoção com `multipart/form-data`.
- [x] Em falha de upload, manter o formulário e reutilizar o ID já salvo em retries de categoria, produto e conteúdo; testes de widget verificam que o retry não duplica os registros.
- [x] Permitir vincular princípios ativos ao produto.
- [x] Implementar ativação e inativação lógica de usuários no backend e no painel.
- [x] Avaliar remoção definitiva somente para contas sem vínculos históricos.
- [x] Proteger no backend as mutações administrativas de farmácias, usuários, categorias, subcategorias, produtos, estoque, promoções e pedidos.
- [x] Unificar promoções da vitrine: `/inventory/highlights` prioriza promoções ativas com estoque e preço promocional, mantendo itens recentes como fallback compatível com o aplicativo antigo.
- [x] Impedir promoções sobrepostas para o mesmo produto e validar o vínculo com o estoque da farmácia no backend.
- [x] Exigir autenticação e escopo de farmácia para criar, editar, excluir e enviar imagens de promoções.
- [x] Proteger a listagem de usuários por farmácia e a criação de usuários administrativos adicionais.
- [x] Definir no backend se `pharmacy_user` pode acessar o painel e quais operações esse perfil pode executar.

### Pedidos

- [x] Substituir campos livres de status por opções permitidas pelo backend.
- [x] Definir transições válidas de pedido e pagamento.
- [x] Exigir confirmação e justificativa para estorno.
- [x] Exibir detalhes do pedido antes de ações financeiras.
- [x] Impedir ações incompatíveis com o status atual.
- [x] Atualizar o pedido após alteração sem recarregar toda a aplicação.

### Navegação e responsividade

- [x] Garantir acesso ao menu lateral em larguras móveis.
- [x] Ocultar o botão de menu quando não houver `Drawer` disponível.
- [x] Testar tabelas e ações em telas pequenas sem corte ou sobreposição.
- [x] Manter filtros e seção selecionada ao voltar de um formulário.
- [x] Oferecer estados de carregamento, vazio, erro e tentativa novamente em todas as páginas administrativas.
- [x] Revisar foco, teclado e ordem de tabulação nos fluxos críticos automatizados.
- [ ] Validar os fluxos completos com leitores de tela reais: VoiceOver, TalkBack e NVDA.
- [x] Adicionar rótulos semânticos a todos os botões apenas com ícone e ao indicador de endereço padrão.

## Prioridade 3 - Arquitetura e manutenção

### Modularização

- [x] Dividir `admin_page.dart` por funcionalidade.
- [x] Criar módulos separados para visão geral, farmácias, usuários, categorias, produtos, estoque e pedidos; solicitações permanecem removidas até existir backend.
- [x] Separar componentes visuais, estado, validação e acesso a serviços.
- [x] Criar modelos tipados para usuário, farmácia, solicitação, produto, estoque e pedido.
- [x] Remover o uso disseminado de `Map<String, dynamic>` nas fronteiras principais.
- [x] Centralizar decodificação, validação de status e erros das respostas da API.
- [x] Criar uma representação tipada para papéis e status.
- [x] Evitar comparações de papéis e status por strings espalhadas.

### Cliente HTTP e erros

- [x] Criar um resultado padronizado para sucesso e erro da API.
- [x] Tratar respostas que não sejam JSON sem lançar erro de decodificação secundário.
- [x] Adicionar timeout às requisições.
- [x] Mapear ausência de conexão, timeout, autenticação expirada e erro de servidor.
- [x] Centralizar tratamento de `401` e encerramento de sessão.
- [x] Evitar mensagens técnicas como `PHARMACY_ID` para usuários finais.
- [x] Adicionar identificador de correlação seguro para suporte.
- [x] Avaliar retry somente para operações idempotentes.

### Estado e ciclo de vida

- [x] Garantir que `loading` seja finalizado mesmo quando a restauração de sessão falhar inesperadamente.
- [x] Evitar uso de `BuildContext` após operações assíncronas sem verificar `mounted`.
- [x] Impedir múltiplos carregamentos simultâneos da mesma lista.
- [x] Preservar filtros e paginação em atualizações.
- [x] Cancelar ou ignorar respostas obsoletas de buscas.

### Qualidade do código

- [x] Corrigir todos os avisos relevantes do `flutter analyze`.
- [x] Preservar os tipos dos modelos nos indicadores assíncronos da visão geral administrativa, removendo listas e casts `dynamic`.
- [x] Modelar endereços como `PostalAddress` no serviço, controlador, perfil, carrinho, checkout e pagamento; serializar na borda HTTP mantendo a cotação e o payload legado.
- [x] Rejeitar linhas malformadas na resposta de endereços com erro seguro e `requestId`, sem ocultar registros como lista vazia.
- [x] Migrar controles `Radio` depreciados para a API atual.
- [x] Remover declarações e imports não utilizados.
- [x] Padronizar nomes, textos e terminologia: farmácia, loja, responsável e administrador.
- [x] Corrigir o nome do pacote para o padrão Dart em uma versão planejada, avaliando impacto.
- [x] Configurar formatação e análise estática no CI.
- [x] Configurar workflow de formatação, análise, testes e builds web release/APK debug em pushes e pull requests; fixar `actions/checkout` por SHA verificado (atualizado para `v7.0.1` em 03/10/2026).
- [x] Incluir compilação de APK debug no workflow, sem keystore nem publicação, para cobrir regressões de build Android junto aos gates web.
- [x] Fixar as actions diretas por SHA e o Flutter em 3.41.4; manter o cache do `subosito/flutter-action` desativado. A composite action ainda declara passos condicionais com `actions/cache@v5`, mas a configuração default do workflow não os executa. O job tem 30 minutos para suportar o download sem cache e executa `flutter pub get --enforce-lockfile`.
- [x] Validar localmente os mesmos gates: formatação sem alterações, auditoria OSV sem correspondências, `flutter analyze` sem ocorrências, 257 testes e build web release `/savemed/` aprovados em 28/09/2026.
- [x] Reexecutar os gates locais em 28/09/2026 após a correção do foco IME na senha da farmácia: 257 testes aprovados, `flutter analyze` limpo, formatação de 176 arquivos sem alterações, auditoria OSV sem advisory nas 85 dependências Pub hospedadas e build web release `/savemed/` concluído.
- [x] Remover ações duplicadas de troca entre login/cadastro; o subtítulo agora orienta e cada tela tem um único comando de navegação. O Tab do login passa diretamente ao e-mail; cobertura de regressão acrescentada. Verificação posterior: 263 testes, `flutter analyze`, formatação e builds web release `/savemed/` e APK debug aprovados em 28/09/2026.
- [x] Adicionar goldens Flutter de login (390/1440 px) e cadastro de cliente/farmácia (390 px), incluindo senha/requisitos/envio após rolagem; a revisão visual identificou e corrigiu o hint de confirmação de senha truncado. As capturas são baselines de widgets, não substituem a recaptura browser/produção.
- [x] Expor os requisitos e status dinâmicos de senha como nós semânticos distintos para tecnologias assistivas; cobrir pendente, não atendido e atendido em teste de widget. Leitores de tela reais permanecem pendentes.
- [x] Separar a suíte completa (runner `windows-2025`) da suíte browser (runner `ubuntu-24.04`); os 49 testes de widgets de auth/cadastro/admin/operação de farmácia passaram no Chrome Linux com Flutter 3.41.4/Chrome 154. O teste usa clientes HTTP falsos por padrão para não atingir SaveMed/ViaCEP reais. Na comparação da suíte completa Linux, 251/263 passaram e os 12 restantes são somente goldens com divergência de pixels; a suíte completa passa no host Windows. O runner Chrome do Windows continua com falha do harness. A suíte maior de formulários administrativos fica no job Windows; no Chrome ela trava em `setUpAll` sem iniciar casos (causa não confirmada) e não foi incluída no gate browser.
- [x] Revalidar em 28/09/2026 a compilação Android debug adicionada ao CI: `flutter build apk --debug` concluiu localmente.
- [ ] Rastrear o workflow no repositório e confirmar a primeira execução hospedada do GitHub Actions. Rechecagem read-only em 03/10/2026: `origin/main` continua no SHA `70f7a18bdd661988bad6ef29c9f55b60d1b014ca` e não contém `.github/workflows/frontend-ci.yml`; o workflow permanece local e não rastreado nesta branch. O YAML foi parseado localmente. O gate browser inclui as suítes isoladas de recuperação de senha e header, mas ainda não teve execução hospedada. Ambos os jobs usam `actions/checkout@v7.0.1`, SHA fixo `3d3c42e5aac5ba805825da76410c181273ba90b1` (runtime Node 24). O SDK segue pinado em Flutter 3.41.4, igual ao ambiente validado. A auditoria OSV passou em 03/10 sem advisory conhecida nas 85 dependências hospedadas. A execução hospedada requer integrar o arquivo ao repositório.
  Diagnóstico adicional do runner Chrome Windows em 02/10/2026: tanto os testes de auth/cadastro quanto o teste puro `number_parser_test.dart` param no evento `testStart` `loading <arquivo>` mesmo com o host Flutter em HTTP 200 e Chrome respondendo; não chegam a iniciar casos após 30 s. As execuções foram interrompidas e não contam como falha da aplicação nem como aprovação browser. O job Ubuntu e a primeira execução hospedada continuam necessários.
  Reexecução local do comando browser do workflow em 02/10/2026 com Chrome 154: carregou `widget_test.dart`, mas não iniciou o primeiro caso em 45 s; processo interrompido. O CI browser continua restrito ao runner Ubuntu, aguardando integração/publicação do workflow.
  Nova tentativa local em 03/10/2026: o comando browser completo e, depois, apenas `password_recovery_test.dart` abriram Chrome headless e permaneceram em `loading <arquivo>` sem iniciar casos. Ambos foram interrompidos após mais de 60 s; portanto o teste browser desta máquina segue inconclusivo. A suíte Flutter completa passou com 334 testes; a checagem global de formatação também passou após formatar `test/widget_test.dart`. `dart run scripts/check_pub_advisories.dart` passou sem advisory nas 85 dependências hospedadas. `flutter build web --release --base-href /savemed/ --no-web-resources-cdn` e fingerprint local concluídos em 03/10/2026; após a correção do header local, o bundle resultante foi `main.db1f583a79acb90f00f2bf6788ea212715cca74350dcb5cf3647e008e9bcb22c.dart.js`, não publicado. A produção continua em `06ab`. `flutter build apk --debug` também passou; sem instalação em dispositivo nem publicação mobile.
  Para cobrir o header fixo em Web, o job browser local agora também inclui `test/features/home/home_header_test.dart`. O caso verifica em browser que houve rolagem real e que o header manteve sua posição; o golden continua exclusivo do runner VM. A regressão passou isolada em VM; a execução hospedada do workflow ainda está pendente.
  O job browser também executa `test/features/auth/registration_flow_test.dart`, cobrindo as quatro etapas do cadastro de farmácia com CEP mockado. Esse comando ainda aguarda uma execução no runner Ubuntu hospedado; no Windows, o harness Chrome continua travando antes do primeiro caso.
  Continuação da investigação em 03/10/2026: o comando do job com cinco arquivos ficou em `loading widget_test.dart` por cerca de três minutos; a suíte individual `registration_flow_test.dart` e o teste unitário de controle `document_validator_test.dart` também abriram Chrome headless, mas não iniciaram casos após cerca de 90 segundos. As tentativas foram encerradas; `flutter test --concurrency=1` segue aprovado. Isso confirma uma limitação/inconclusão do runner local Windows, não uma falha nem aprovação dos testes browser. A primeira execução hospedada em `ubuntu-24.04` permanece necessária.
  Rechecagem Git/read-only em 03/10/2026: `origin/codex/merge-d-drive-20260812` e a branch local estão no mesmo commit `3ede31d5695f6fc2adbf159e11acaa3f9685abfe`; o workflow continua não rastreado no worktree, portanto ainda não pode ser executado pelo GitHub. WSL2 Ubuntu não pôde iniciar porque o arquivo `ext4.vhdx` da distro não foi encontrado. `scripts/test_fingerprint_web_entrypoint.ps1` passou localmente; os padrões conhecidos de segredo não corresponderam em `lib`, `web`, `android` ou `scripts`, e o bootstrap público permaneceu em `06ab`.

Revalidação em 02/10/2026: três regressões adicionais percorrem por Tab os
campos de cadastro de farmácia, inventário e promoção; a suíte completa passou
com 312 testes, `flutter analyze` e formatação aprovados.
Auditoria local do CI em 02/10/2026: YAML válido com dois jobs e quatro actions
fixadas por SHA; os comandos do job Windows passaram, incluindo lockfile,
auditoria OSV (85 pacotes), 312 testes, build Web sem CDN externa e APK debug.
O job Chrome ainda requer runner Linux/hospedagem; o workflow não está integrado
ao remoto e não foi executado pelo GitHub Actions.
Reteste do job browser no Windows em 02/10/2026: tanto o comando com os três
arquivos do workflow quanto o teste isolado de recuperação abriram Chrome, mas
permaneceram em `loading` sem iniciar casos; as execuções foram interrompidas.
O gate browser precisa ser confirmado em runner Linux hospedado.

## Prioridade 4 - Testes e validação

Reexecução local em 03/10/2026 do comando browser completo do workflow: permaneceu em `loading test/widget_test.dart` por aproximadamente 120 segundos sem iniciar casos e foi interrompida; não classificada como falha dos testes do app. A limitação do harness Windows permanece e não substitui a execução Ubuntu hospedada. O teste isolado do fingerprint PowerShell passou em Windows PowerShell, incluindo hash, idempotência, nomes Flutter aceitos, rejeição de traversal e atomicidade diante de falhas.

### Testes unitários

- [x] Validadores de CPF, CNPJ, telefone, e-mail e senha.
- [x] Cobrir o parser do gate OSV: pacotes Pub hospedados, ordenação determinística, queries por versão, achados e origens inválidas/desconhecidas sem rede.
- [x] Validar linhas e preços das cotações de frete; respostas malformadas, negativas ou não finitas geram erro e não são convertidas em frete grátis. Coberto com HTTP falso e regressão integrada serviço→carrinho.
- [x] Validar o preço novamente no `OrderController` antes de chamar `/orders/checkout`; preço ausente, inválido ou não finito não cria pedido nem vira frete zero. Checkout informa que é necessário recalcular o frete.
- [x] Normalização dos payloads enviados à API.
- [x] Mapeamento de erros HTTP para mensagens de interface.
- [x] Cliente HTTP: metadados da versão/plataforma, ausência de token, `401`, upload multipart e falhas de conexão.
- [x] Regras de papéis, permissões e escopo de farmácia.
- [x] Transições de status de solicitação e pedido.

### Testes de widgets

- [x] Tela inicial sem sessão.
- [x] Login automatizado encaminha `customer` para a vitrine e `pharmacy_admin`/`app_admin` para a área administrativa com menus autorizados.
- [x] Restauração de sessão válida e inválida.
- [x] Cadastro de cliente.
- [x] Edicao de endereco do cliente com modelo tipado, ID preservado e campos carregados pelo servico.
- [x] Cadastro de nova farmácia, incluindo regressão do campo de responsável em viewport de 320 px.
- [x] Solicitação de acesso a farmácia existente com busca clara, sem pedir senha antes da aprovação; hint e fluxo responsivos verificados em 320 px / 200%.
- [x] Validação e preservação dos campos após erro.
- [x] Criação, convite, bloqueio e redefinição de usuário administrativo.
- [x] Responsividade da navegação do painel em celular e desktop; tabelas continuam responsivas por lista móvel e rolagem horizontal.
- [x] Estados de carregamento, vazio e erro das listas.
- [x] Fluxo de subcategorias no gestor: criar e editar preservam o vínculo da categoria; excluir só ocorre após confirmação, coberto com serviço isolado.

### Testes de integração em ambiente isolado com dados descartáveis

- [x] Contratos frontend/backend executados contra revisão candidata sem tráfego.
- [x] Criação atômica de farmácia e primeiro administrador: validada em PostgreSQL
  isolado, incluindo rollback por falha e disputa concorrente pelo mesmo e-mail.
- [x] Aprovação e rejeição de solicitação: PostgreSQL isolado valida concorrencia,
  motivo obrigatorio, permissao de plataforma, farmacia inativa e rollback do convite.
  Entrega real do e-mail permanece na matriz de homologacao externa.
- [x] Expiração de sessão durante ação administrativa: teste do formulario
  compartilhado com HTTP 401 preserva rascunho e mostra sessao expirada sem sucesso falso.
- [x] Frontend: falha de rede e repetição segura por ação explícita; 72 testes focalizados passaram em 28/09/2026.
  Protecoes locais verificadas: envio simultaneo bloqueado, rascunho mantido apos
  falha e Voltar do sistema bloqueado durante gravacao. Idempotencia apos resposta
  perdida ainda pendente; nao repetir automaticamente criacoes incertas. Em cadastro
  de cliente ou farmacia, timeout e HTTP 5xx agora mostram aviso persistente no
  formulario de que a conta pode ter sido criada, mantem os dados e oferecem o
  caminho para login com o e-mail original pre-preenchido. Alterar o e-mail nao
  limpa o aviso; uma nova tentativa exige confirmacao explicita. Continua
  pendente a idempotencia no servidor e a conciliacao de uma criacao cuja resposta
  foi perdida. Regressao adicional valida aviso, confirmacao de reenvio e
  cancelamento em viewport de 320 px com texto em 200%.
  Teste frontend adicional cobre cadastro novo de farmacia: erro de conexao
  permanece visivel e nome, CNPJ, endereco, contato e senha persistem ao voltar
  pelas etapas. Isso nao comprova idempotencia no servidor.
- [x] Frontend: isolamento de formulários e respostas ao trocar entre duas farmácias; coberto por testes de widget.
  Interface: testes validam troca de sessao entre duas farmacias, listas isoladas,
  formulario anterior bloqueado e ausencia de upload se a sessao mudar antes dessa
  etapa. Matriz HTTP completa de autorizacao e isolamento ainda pendente.
  Respostas tardias de listas/opcoes e mensagens de gravacao tambem validadas
  contra mudanca de sessao, inclusive antes da reconstrucao da tela. Regressao
  de salvamento com icone selecionado confirma que trocar a farmacia antes da
  etapa de upload nao dispara a imagem para a sessao anterior.
- [x] Frontend: permissões visuais para administrador geral e administrador de farmácia; coberto por testes de widget.
  Interface: menus da plataforma aparecem somente para administrador geral; a
  farmacia ve sua propria area, e contas inativas/sem farmacia sao bloqueadas
  antes de carregar dados. Testes de widget cobrem os papeis. A autorizacao em
  requisicoes diretas continua dependendo da API.

### Testes manuais antes da publicação

- [ ] Android em distribuição interna.
  Smoke local do APK debug em 03/10/2026 no AVD Android 15/API 35 (1080x2400): login e cadastro de cliente abriram, sem login nem envio de cadastro. A revisão encontrou o selo de versão cobrindo a confirmação de senha em telas roláveis; a versão foi movida para o fluxo do `SaveMedFooter`, fora do shell global. Regressão em 390x844, suíte completa (344 testes), `flutter analyze`, build Web/fingerprint e APK debug passaram. O Gboard não foi visualmente validado no AVD: o serviço reportou a janela visível, mas a captura mostrou a região em branco. [Captura Android](docs/android-qa-2026-10-03.md); [validação Web](docs/web-qa-2026-10-03.md). Não substitui distribuição interna, aparelho físico, API de homologação ou leitor de tela.
- [x] Gerar o AAB Android de release local apos o ultimo codigo de autenticacao;
  assinatura valida e impressao digital igual a do APK release verificado.
- [x] Gerar APK de release local e validar assinatura v2, `applicationId`
  `com.bravelight.save_med`, versão `1.1.0`/código `7` e SDK alvo 36.
  Em 28/09/2026, APK e AAB foram reconstruídos após os ajustes de autenticação
  e acessibilidade da senha. `apksigner` confirmou a assinatura v2 do APK;
  `jarsigner` confirmou a assinatura do AAB e ambos têm certificado SHA-256
  `e0354e06ee216b3352525d7683f55a044ae1efea101f8bb4213364e0f15c9936`.
  A versão continua `1.1.0`/código `7`; nenhum artefato foi distribuído.
  Em 02/10/2026, `flutter build apk --release` também concluiu com o código
  atual: APK de 57.1 MB, `applicationId` e SDK alvo inalterados, assinatura v2
  válida pelo mesmo certificado SHA-256. SHA-256 do artefato local:
  `1eb42bdbc4ff7140d93d6c6da6ed568fa6bca07f35a9d35df335f661446e0060`.
  Build e assinatura não substituem instalação/testes em dispositivo ou
  distribuição interna; não houve publicação.
  Este APK substitui o build validado visualmente abaixo: após validar preços de
  frete, o bundle web e este APK release foram recompilados; a instalação em AVD
  pertence à compilação anterior ao ajuste de frete.
  O AVD `Default` encontrado já tinha o mesmo `applicationId` instalado com
  certificado Android Debug. A instalação por atualização seria incompatível;
  o app/dados desse AVD foram preservados. O APK release atual foi instalado
  separadamente em AVD Android 15 novo; a tela de login abriu sem erro fatal.
  Nenhum login ou escrita de dados foi executado; [captura e limites](docs/android-qa-2026-09-28.md).
  Não há aparelho físico conectado. O smoke test local do APK debug passou no
  AVD `Default` (API 35): login, cadastro de cliente, modos de cadastro da
  farmácia, solicitação de acesso e teclado nativo; fonte em 200% também foi
  verificada.
  Após reconstrução, o APK release assinado foi instalado e aberto no mesmo AVD;
  `MainActivity` permaneceu em primeiro plano sem exceção fatal. Login real e
  distribuição interna permanecem pendentes; [capturas e limites](docs/android-qa-2026-09-28.md).
  Smoke IME adicional no AVD: Próximo avançou do responsável para a etapa 2 e
  do CEP para Contato; o CNPJ transferiu foco para o nome da farmácia. A entrada
  automatizada de telefone via `adb input` foi pouco confiável e interrompeu a
  etapa 3 por validação, então senha não foi percorrida manualmente no AVD.
  O fluxo completo das quatro etapas e o foco senha-confirmação seguem cobertos
  pelo teste widget com serviço fake; [capturas e limites](docs/android-qa-2026-09-28.md).
- [ ] iOS via TestFlight.
  Update from the 03/10/2026 production smoke test and AVD QA: the pharmacy form reached the password step using synthetic data; no account was submitted. A valid password showed a mismatch error before confirmation was entered. Fixed locally by separating password-length and confirmation validation; submission still requires confirmation. Android 15 AVD QA also found the global version label overlapping the password confirmation field; the label now sits inside the normal `SaveMedFooter` flow, and the app shell no longer reserves global space. `flutter analyze`, 344 tests, web release build, fingerprint test, and debug APK build passed. Current local web candidate is `main.6fd80cd39642b7f78c8244e55d42f3cff9e7b7be0bbc3ef3e0faae18c990104b.dart.js`; production remains on `main.06ab`. No account was submitted, and the authenticated tab was left untouched.
- 03/10/2026: Edge no preview local confirmou os três estados de senha no cadastro: senha válida com confirmação vazia fica pendente sem erro, senha diferente mostra erro e senha igual limpa o erro. Foram usados apenas valores sintéticos e o cadastro não foi enviado. [QA Web](docs/web-qa-2026-10-03.md).
- [x] Revalidar visualmente o bundle web atual em Chrome headless: 1440 x 900, 390 x 844 e 320 x 640; login e cadastro sem overflow horizontal, com `innerWidth` igual a `documentWidth`. [Capturas e limites](docs/browser-qa-2026-09-28.md).
- [ ] Testar autenticacao/persistencia reais, outros navegadores e build publicado; as capturas locais nao substituem essas verificacoes.
  Edge desktop no preview local em 28/09/2026: confirmou carregamento do build,
  ordem de foco por Tab no login, controle de mostrar senha, alternância de
  cadastro cliente/farmácia e solicitação de acesso sem coleta prévia de senha.
  A sessão Edge não cobre login real, largura estreita, outros navegadores ou publicação.
  Revisão adicional: o indicador de carregamento removia-se ao detectar apenas
  o elemento inicial do Flutter; agora aguarda `runApp` e dois quadros, e exibe
  tentativa de recuperação se a inicialização falhar ou exceder o limite.
  Recaptura do bundle atual as 05:21: login desktop 1440 px e login/cadastro mobile
  390/320 px. Emulacao por CDP confirma `innerWidth` e `documentWidth` iguais e
  rolagem vertical esperada; [capturas](docs/browser-qa-2026-09-28.md).
  Chrome headless em emulação mobile 390 x 844 também conferiu login, senha do
  cadastro de cliente, primeira etapa de nova farmácia e pedido de acesso a
  farmácia existente, inclusive as áreas de envio após rolagem; sem overflow
  horizontal. Em 320 x 640, a revisão encontrou e corrigiu um placeholder de
  responsável truncado; a captura do bundle reconstruído confirma leitura completa.
  Captura adicional do bundle atual com metricas CDP explicitas: login e cadastro
  inicial em 390 x 844 reportam `innerWidth=390` e largura do documento 390.
  Nova verificacao do bundle atual em 320 x 640: login e cadastro inicial sem
  overflow horizontal (largura do documento 320); cadastro segue por rolagem
  vertical esperada. Capturas atuais adicionadas ao relatorio de QA.
  [Capturas e limites](docs/browser-qa-2026-09-28.md).
  Login real, envio/persistência, outros navegadores e publicação permanecem pendentes.
  `flutter test --platform chrome` segue sem executar casos neste Windows: o wrapper
  gera seletor inválido com `\u` em caminhos aninhados; no teste de raiz, o handler
  do SDK retorna 404 para CanvasKit após converter `/` em `\`. Diagnóstico e
  reprodução: [runner Chrome no Windows](docs/flutter-test-chrome-windows-2026-09-28.md).
  Isto é falha do harness local, não resultado dos testes de widget. `flutter analyze`
  e `flutter test --concurrency=1` passaram; após incluir a matriz administrativa
  de 320 px / 200%, o domínio tipado de endereços, as validações adicionais,
  o gate de advisories Pub e a recuperação parcial do catálogo, a suíte concluiu
  257 testes.
- [x] Login web: navegação por Tab observada no Chrome local; árvore semântica
  expõe nomes para campos, mostrar senha, recuperar senha e ações principais.
  Cadastro de cliente tem teste semântico: CPF, nome, e-mail, telefone, senhas
  e controles de visibilidade expõem campo e ação acessíveis.
- [ ] Teclado físico nos fluxos completos de cadastro e gestor; confirmar ordem,
  foco visível, Enter/Espaço e leitor de tela em navegadores/dispositivos reais.
  Cobertura automatizada adicional: Tab percorre CPF, nome, e-mail, telefone e
  senha no cadastro de cliente; no gestor, valida Nome -> CNPJ -> Telefone ->
  Cidade -> UF -> CEP no cadastro de farmácia, alcança o seletor de farmácia no
  formulário de categoria, percorre Nome -> Descrição -> Marca no produto,
  Produto -> Preço -> Preço original -> Estoque no inventário e Produto ->
  Desconto na promoção. O foco também percorre o controle de abrir o seletor.
  O convite administrativo valida Nome -> E-mail -> Telefone. Essas regressões
  usam plataforma desktop e não substituem a validação manual dos fluxos
  completos, do foco visível/Enter/Espaço ou o teste com leitores de tela reais.
  Verificação não destrutiva em 02/10/2026 no Edge publicado: foco por teclado
  ficou visível ao avançar de e-mail para telefone; o botão de mostrar senha é
  uma parada de foco e Tab seguinte alcança confirmar senha. Nenhum dado foi
  digitado/enviado. Cadastro completo, teclado no gestor e leitores de tela
  reais continuam pendentes.
  Autenticação usa dicas de autofill para credenciais, endereço e contato; o
  cadastro só pede ao sistema para salvar a senha após sucesso confirmado. Ações
  Next/Done foram configuradas nos campos, com teste de progressão por IME no
  cadastro de cliente, nas quatro etapas da farmácia (incluindo senha, confirmação
  e envio) e na recuperação de senha. A ação Next da senha da farmácia foca a
  confirmação explicitamente para não parar no controle de visibilidade.
- [x] Respeitar o aumento de fonte do sistema ate 200% nos fluxos cobertos, sem corte horizontal nos viewports estreitos; manter validacao manual global em dispositivos como pendencia separada.
  Regressao automatizada do gestor em 390 px / 200% cobre os cadastros principais,
  painel e seletor de imagens. Matriz adicional aprovada em 320 px / 200% para
  cadastros de farmacias, produtos, inventario, promocoes, principios ativos e
  conteudo do app. Login Android tambem verificado em AVD com escala nativa 200%,
  incluindo rolagem ate o rodape; a busca de farmacias existente tambem foi
  verificada em 200%, com hint completo, e no teclado nativo em escala normal.
  Cadastro de cliente também verificado em 320 x 640 com texto a 200%, rolagem
  até o botão de envio e sem overflow ou corte horizontal nos campos.
  [Capturas e limites](docs/android-qa-2026-09-28.md).
  Cortes corrigidos; validacao manual global pendente.
- [x] Catálogo inicial mantém os resultados das seções que responderam quando
  uma consulta falha; mostra aviso de carga parcial e permite tentar novamente.
  Também preserva o último catálogo durante atualização offline na mesma sessão.
  Testes verificam recuperação após reconexão simulada e layout/retry em 320 px
  com texto a 200%; o estado é anunciado como região dinâmica na árvore semântica.
- [ ] Validar latência real, perda/restauração da rede e persistência offline nos
  fluxos completos em dispositivos e contra a API de homologação.
  Enderecos do cliente: consulta antiga nao substitui dados de outro usuario;
  perfil/carrinho mostram erro distinto de vazio e oferecem retry validado pela
  interface. Cache de enderecos limpo no logout/expiracao com invalidacao de
  consultas.
  Cartoes: controller e armazenamento de sessao limpos na composicao principal,
  incluindo save concorrente. Logout/expiração agora limpam carrinho e pedidos;
  respostas antigas de histórico são ignoradas e checkout tardio não retorna ID
  à sessão encerrada. Os controllers autenticados descritos acima agora ignoram
  respostas obsoletas quando a sessão termina ou muda.
  Carrinho: falha ao carregar origem do frete mostra nova tentativa; consultas
  de outra farmacia sao descartadas. Regressao de recuperacao pela UI aprovada.
  Cotações pendentes sao invalidadas ao trocar/limpar endereco ou esvaziar
  carrinho; respostas antigas nao substituem a consulta atual.
  Quantidades/produtos e endereco diferente no mesmo CEP invalidam/recalculam
  frete; retirada escolhida permanece ao alterar quantidades.
  Carrinho limita quantidade ao estoque recebido e recusa outra farmacia no
  controller; UI desabilita aumento no limite e nao mostra inclusao falsa.
  PaymentController invalida respostas de pagamento/status ao sair, impedindo
  que uma tentativa antiga altere o loading da sessao seguinte. Checkout remoto
  ou pagamento que ja chegou ao provedor nao sao cancelados pelo cliente.
  Respostas tardias de login, restauração de sessão e atualização de perfil não
  recriam usuário após logout/expiração; leituras, gravações e remoções do token
  usam geração de sessão para invalidar operações obsoletas.
- [ ] Leitores de tela VoiceOver, TalkBack e NVDA.
- [x] Atualização a partir da versão atualmente publicada, preservando a sessão quando válida e oferecendo nova tentativa em falhas temporárias.
- [ ] Login manual com contas reais de cliente, administrador geral e administrador de farmácia em homologação.

## Prioridade 5 - Experiência geral do frontend

Rechecagem em 02/10/2026: o bundle versionado já está publicado e ativo, mas a CDN ainda serve esse arquivo com `Cache-Control: public, max-age=604800` (7 dias), em vez de `max-age=31536000, immutable`. A regra local está pronta e testada; aplicar somente após backup/leitura confiável do `.htaccess` remoto.

- [x] Revisar home, busca, listagem e detalhe de produtos.
- [x] Revisar criação de pedido, endereços e validação do valor de pagamento.
- [x] Revisar responsividade, foco, semântica e estados do carrinho e dos meios de pagamento com testes automatizados.
- [ ] Concluir testes manuais do carrinho e dos meios de pagamento com dados reais.
- [x] Corrigir o uso assíncrono de contexto no detalhe de produto.
- [x] Validar documentos exibidos no perfil e checkout.
- [x] Não assumir que todo usuário possui `CPF` quando há perfis de farmácia.
- [x] Revisar mensagens de erro e sucesso em linguagem consistente.
- [x] Revisar contraste e tamanho mínimo dos controles interativos.
- [x] Garantir `width=device-width` no entrypoint web sem desabilitar zoom; validar login/cadastro em 320 px e 390 px com CDP.
- [x] Garantir que textos não sejam cortados em telas pequenas, incluindo autenticação a 320 px com texto em 200%.
- [x] Revisar comportamento do cabeçalho e rodapé no Web.
- [x] Medir tempo de inicialização, carregamento de imagens e listas.
- [x] Confirmar em produção o cache imutável do bundle versionado sem servir versão desatualizada. Na primeira publicação de 03/10/2026, `flutter_bootstrap.js` apontava para `main.6ce1c6b7a58cfe3db1cb3c673ccb59ce4b3236aacacca10faf131d4010cf332d.dart.js`; na atualização autorizada posterior do mesmo dia, passou a apontar para `main.06ab9aa035d08e0c8d73b99464177071266afdf26af4a58dde2ebce29e32effd.dart.js`. O asset ativo responde HTTP 200, 3.581.576 bytes, SHA-256 `06AB9AA035D08E0C8D73B99464177071266AFDF26AF4A58DDE2EBCE29E32EFFD`, igual ao artefato local; header efetivo `public, max-age=31536000, immutable`. `/savemed/` continua `no-store`; bundles `6ce` e `4a6` permanecem disponíveis para rollback.
  Rebuild local verificado em 02/10/2026: `flutter build web --release --base-href /savemed/ --no-web-resources-cdn` concluiu; o fingerprint produziu o asset `main.4a6cf3c1155cd56bbbdba80a7c781a86b426fe9c10812048c6fa45f699d30c75.dart.js` (3.581.141 bytes, SHA-256 conferido), com `base href` e `mainJsPath` corretos. Os dois testes de `test/web_entrypoint_test.dart` passaram. Naquele momento, a regra de cache imutável e os headers ainda estavam pendentes; ambos foram publicados e validados em 03/10.
- [x] Otimizar somente após medir gargalos reais.

## Dependências obrigatórias do backend

- [x] Endpoint transacional para criar farmácia e primeiro administrador.
- [x] Endpoint para solicitar acesso a farmácia existente.
- [x] Endpoints para listar, detalhar, aprovar e rejeitar solicitações.
- [x] Contrato oficial de documentos para cliente e responsável de farmácia.
- [x] Estados oficiais de farmácia, usuário e solicitação.
- [x] Autorização por papel e farmácia em todas as rotas administrativas.
- [x] Paginação e filtros nas listagens administrativas, mantendo o array legado quando os parâmetros não são enviados.
- [x] Auditoria de ações sensíveis.
- [x] Convite e definição segura de senha.
- [x] Respostas de erro padronizadas com código estável e campos inválidos.
- [ ] Validar os vínculos de catálogo no servidor publicado, em banco de homologação e com os clientes móveis antigos. A implementação local no repositório `G:\GitHub\api-savemed` valida a categoria do produto contra a farmácia (incluindo categoria global), a subcategoria contra a categoria e o produto contra a farmácia ao criar estoque; ao trocar a categoria de um produto legado, remove uma subcategoria incompatível e converte `SUBCATEGORY_ID: 0` legado em nulo. Também bloqueia mover categoria/subcategoria com produtos dependentes ou transferir produto com estoque ou princípios ativos incompatíveis. Uma edição legada apenas de nome preserva os vínculos existentes sem reescrevê-los. Treze regressões novas e a suíte API completa passaram em 03/10/2026 (184/184); são testes de rota com modelos simulados, não substituem concorrência/banco PostgreSQL real. O frontend preserva e exibe as quatro mensagens `409` de forma acionável; suíte Flutter com 334 testes e `flutter analyze` passaram. Ainda requer commit/revisão, homologação e validação/publicação compatível da API; a revisão Cloud Run ativa não foi alterada.

## Estratégia de entrega

### Versão corretiva

- Segurança dos logs.
- Remoção temporária do fluxo sem API.
- Correção dos testes e textos corrompidos.
- Correção do fechamento prematuro dos formulários.
- Proteção dos campos de senha.

### Versão de estabilização administrativa

- Formulários validados.
- Confirmações de ações destrutivas.
- Seletores no lugar de IDs manuais.
- Gerenciamento consistente de farmácias e usuários.
- Testes de widgets dos fluxos administrativos.

### Versão do fluxo de aprovação

- Contratos de backend concluídos.
- Solicitação de acesso a farmácia existente.
- Fila administrativa de aprovação.
- Convites, notificações e auditoria.

### Versão de manutenção estrutural

- Modularização do painel.
- Modelos e contratos tipados.
- Padronização do cliente HTTP e erros.
- Ampliação da automação de testes e CI.

## Checklist de publicação

### Compatibilidade com aplicativos publicados

- [x] Manter caminhos e métodos dos endpoints consumidos pelos aplicativos antigos.
- [x] Manter o formato de inventário retornado por `/inventory/highlights`.
- [x] Manter fallback de itens recentes quando não houver promoção ativa.
- [x] Permitir o primeiro administrador no cadastro público de uma nova farmácia.
- [ ] Executar testes de fumaça com builds publicados de Android e iOS antes de publicar a API.
- [x] Publicar mudanças de API com rollback imediato para a revisão anterior.
- [x] Monitorar respostas `400`, `401`, `403` e `500` por versão do aplicativo após a publicação.

- [x] Contratos validados na revisão candidata sem tráfego.
- [x] Migrações de backend compatíveis com versões antigas do aplicativo.
- [x] `flutter analyze` aprovado.
- [x] Testes automatizados aprovados.
- [ ] Testes manuais Android, iOS e Web aprovados.
- [x] Nenhum dado sensível nos logs.
- [x] Número de versão e build atualizados.
- [x] Notas da versão preparadas.
- [x] Plano de rollback definido: Cloud Run `api-savemed-00034-pul` e backup Hostinger `.deploy-backup-20260904-030647`.
- [x] Monitoramento de login, cadastro e erros HTTP preparado.
- [x] Acompanhamento reforçado após a publicação, com smoke de todas as listagens e consulta de erros da revisão ativa.

## Indicadores de sucesso

- Redução de erros no cadastro de farmácias.
- Redução de contatos de suporte sobre "farmácia já cadastrada".
- Percentual de cadastros concluídos por etapa.
- Tempo médio para criar ou aprovar um usuário de farmácia.
- Quantidade de farmácias órfãs ou sem administrador ativo igual a zero.
- Taxa de erro de login, cadastro e recuperação de senha.
- Ausência de dados sensíveis em logs e relatórios.
- Cobertura automatizada dos fluxos críticos.

## Estado atual conhecido

### Incidentes corrigidos

- [x] Preservar login válido quando o carregamento de endereços falhar, sem apresentar a autenticação como inválida.
- [x] Diferenciar token inválido de indisponibilidade temporária durante a restauração e oferecer nova tentativa sem apagar a sessão salva.
- [x] Centralizar mensagens de conexão, timeout, autorização, validação e servidor, ocultando detalhes técnicos no login e no painel.
- [x] Descartar controladores temporários de todos os formulários administrativos ao fechar os diálogos.
- [x] Validar navegação administrativa móvel e desktop e publicar o lote na Hostinger em 03/09/2026.
- [x] Corrigir indisponibilidade do web app em 03/09/2026 causada por build com `<base href="/">` publicado no subdiretório `/savemed/`.
- [x] Republicar o Flutter Web com `--base-href /savemed/` e validar HTML, bootstrap, bundle principal e API em produção.
- [x] Configurar a Hostinger para servir arquivos `.wasm` como `application/wasm`.
- [x] Documentar o comando de build obrigatório para evitar recorrência do incidente de rota-base.
- [x] Corrigir tela branca em 04/09/2026 removendo a dependência de inicialização do CanvasKit no `gstatic.com`; o motor WebAssembly agora é servido pelo próprio `savemed.app` e o service worker legado não é mais registrado pelo bootstrap.
- [x] Publicar em 04/09/2026 um carregamento resiliente no `index.html`, preservando o bundle anterior e oferecendo nova tentativa quando a inicializacao exceder 20 segundos.
- [x] Dividir o cadastro público de farmácia em quatro etapas, exibir ativação imediata e orientar farmácias já cadastradas ao suporte.
- [x] Manter dados preenchidos após falha recuperável e exibir validações junto aos campos no cadastro e no painel.
- [x] Separar carregamento, lista vazia e falha nas páginas administrativas, com ação contextual e nova tentativa.
- [x] Preservar o tipo da falha de carregamento administrativo para apresentar a mensagem correta de conexão.
- [x] Exibir requisitos e controles de visibilidade também na definição de nova senha.
- [x] Implementar e testar localmente `POST /pharmacies/register` com criação transacional da farmácia, endereço e primeiro administrador.
- [x] Migrar o frontend novo para usar exclusivamente a rota transacional; em `404/405`, interromper sem iniciar escritas legadas. Os endpoints dos aplicativos publicados não foram alterados. Testes cobrem ambos os status.
- [x] Publicar e validar a rota transacional no Cloud Run após reautenticar a conta Google do projeto SaveMed.
- [x] Centralizar a autorização administrativa da API por papel e escopo de farmácia.
- [x] Exigir token nas mutações de categorias, subcategorias, produtos, estoque, pedidos e farmácias, preservando os cadastros públicos usados pelos aplicativos antigos.
- [x] Restringir princípios ativos, exclusão de farmácia e cadastro em lote ao administrador geral.
- [x] Cobrir autenticação, autorização, escopo, checkout, pagamento e presença dos middlewares nas rotas com testes automatizados; suíte da API aprovada com 70 testes.
- [x] Integrar busca de CEP editável ao cadastro administrativo e centralizar o tratamento do ViaCEP.
- [x] Padronizar leitura e exibição de valores monetários no formato brasileiro.
- [x] Exibir o contexto completo antes do estorno e ocultar a ação em estados incompatíveis.
- [x] Publicar em 03/09/2026 o lote de cadastro, recuperação, CEP, valores monetários e pedidos; validar `/savemed/`, API, banco, MIME WebAssembly e bundle remoto `E51F048F3BAC24DF6ECCF7316FCFAE910D1823978F4FE23F8ABE22AE2E79F637`.
- [x] Adicionar estado ativo/inativo aos usuários, bloquear login e sessão inativa, impedir auto-inativação e preservar o último administrador da farmácia.
- [x] Exibir status e ações de ativação/inativação no contexto da farmácia, inclusive para `pharmacy_admin` da própria farmácia.
- [x] Forçar escopo de farmácia nas listagens administrativas da API e impedir exposição pública de farmácias inativas por `includeInactive`.
- [x] Implementar `POST /orders/checkout` transacional com pedido e itens atômicos, preços obtidos do estoque, validação de endereço, farmácia e disponibilidade. O frontend novo interrompe em `404/405` sem gravar pedido parcial; os endpoints legados dos apps antigos permanecem inalterados, coberto por testes.
- [x] Exigir autenticação e propriedade para pedidos, itens e pagamento; validar o valor de pagamento contra pedido e itens persistidos e sanitizar falhas do provedor.
- [x] Implementar edição e exclusão de endereços esperadas pelo frontend, proteger endereços do cliente por proprietário e manter apenas o endereço público da farmácia acessível à vitrine.
- [x] Refazer o modal de endereço com `Form`, validações por campo, busca centralizada de CEP, estado de salvamento, erro recuperável e layout móvel.
- [x] Substituir exclusão em cascata de farmácia por inativação lógica com motivo obrigatório, confirmação de impacto e histórico preservado.
- [x] Projetar reserva de estoque com expiração para PIX antes de descontar unidades durante o checkout.
- [x] Corrigir lista de produtos vazia quando medicamentos não possuem subcategoria. O modelo agora aceita `SUBCATEGORY_ID` nulo, conforme o contrato da API.
- [x] Ler `REQUIRES_RX` sem remover a compatibilidade com o campo legado `REQUIRES_PRESCRIPTION`.
- [x] Aceitar preço, estoque e identificadores serializados como número ou texto.
- [x] Cobrir o parsing do inventário publicado com testes de regressão.
- [x] Manter aplicativos antigos compatíveis pela API: inventários sem subcategoria são serializados como `SUBCATEGORY_ID: 0`, sem alterar o valor nulo armazenado no banco.
- [x] Publicar e validar a compatibilidade na revisão Cloud Run `api-savemed-00026-kp6` em 22/07/2026.
- [x] Publicar em 04/09/2026 a revisão administrativa `api-savemed-00031-zuk`, validada primeiro sem tráfego e com rollback para `api-savemed-00029-78q`.
- [x] Publicar o frontend `1.1.0+7` na Hostinger e validar o bundle remoto `084E24A0F42EB0AC9E4A6EA198985C58247FCD2E450CFB546EC41BD213443A0D`.
- [x] Corrigir imagens de produtos armazenadas no banco para usar a URL pública `/api/medications/:id/image`, removendo a resolução incorreta para o domínio legado.
- [x] Exigir dados persistidos do cliente e do endereço no pagamento, ignorando identidade enviada pelo navegador.
- [x] Exigir justificativa, responsável e data em estornos e registrar a ação na auditoria.
- [x] Publicar paginação e filtros opcionais, telemetria sanitizada por versão e contratos administrativos tipados na revisão Cloud Run `api-savemed-00036-vok`, com rollback para `api-savemed-00034-pul`.
- [x] Corrigir a inicialização da auditoria com nomes de índices estáveis e menores que o limite do PostgreSQL antes de promover a revisão candidata.
- [x] Corrigir a atualização de endereço do resumo do carrinho para ocorrer após o frame, evitando notificação de estado durante o `build`.
- [x] Adaptar carrinho, pagamento e cartões de produto para 320 px com texto em 200%, sem estouros de layout.
- [x] Tornar seletores de perfil, entrega, cartão e meio de pagamento navegáveis por teclado e identificáveis por leitores de tela.
- [x] Diferenciar sessão administrativa expirada de falta de permissão e oferecer reautenticação segura.
- [x] Cobrir aprovação e rejeição justificada de acesso no painel e rejeição de JWT expirado na API.

### Incidente de autenticação e recuperação - 21/08/2026

- [x] Identificar que login, recuperação e catálogo falhavam porque o container não iniciava.
- [x] Confirmar erro PostgreSQL `28P01`: a credencial Railway configurada no Cloud Run foi invalidada.
- [x] Confirmar que o projeto Google Cloud SaveMed ainda não possui Cloud SQL nem backup de banco.
- [x] Confirmar falha independente do SMTP Hostinger com resposta `535 authentication failed`.
- [x] Publicar modo degradado e reconexão automática na revisão Cloud Run `api-savemed-00027-497`.
- [x] Registrar a decisão operacional de iniciar uma base vazia, sem importar os dados inacessíveis da Railway.
- [x] Criar Cloud SQL PostgreSQL 16 no projeto SaveMed, em `southamerica-east1`, com backup, recuperação pontual e proteção contra exclusão.
- [x] Criar banco e usuário técnico exclusivos, rotacionar `DB_PASSWORD` no Secret Manager e conceder ao Cloud Run somente `roles/cloudsql.client`.
- [x] Publicar a conexão via socket do Cloud SQL, remover a referência de ambiente à Railway na revisão `api-savemed-00029-78q` e validar `/health` com banco disponível.
- [x] Criar a conta inicial de plataforma como o único usuário da base e validar o login real com papel `app_admin`.
- [x] Remover do serviço de banners do frontend a URL residual da Railway e reutilizar a URL central do Cloud Run.
- [x] Publicar o build web corrigido em `/savemed` na Hostinger e validar o bundle remoto por SHA-256.
- [x] Aplicar a identidade visual do protótipo (fundo `#FCFCF7`, verdes musgo, laranja de destaque, superfícies claras, controles arredondados e marca cápsula nativa), recompilar e republicar; bundle remoto `084E24A0F42EB0AC9E4A6EA198985C58247FCD2E450CFB546EC41BD213443A0D`.
- [x] Salvar a versão anterior do site público em `G:\GitHub\SaveMed Site\deploy-backups\20260914-visual-before-prototype` e aplicar a identidade do protótipo também em `https://savemed.app/`, preservando o aplicativo em `/savemed/` e os endpoints PHP da raiz.
- [x] Adicionar fallback Apache na raiz para que `/privacy-policy` funcione por acesso direto, sem interceptar `/savemed/` nem os endpoints PHP.
- [x] Substituir o PNG antigo pelo logo cápsula também no site React e publicar links sociais funcionais: Instagram `savemed.app` e WhatsApp `+55 19 99170-7830`.
- [x] Atualizar o favicon do domínio para o mesmo símbolo cápsula e confirmar o site, a privacidade e o app publicados com resposta HTTP 200.
- [x] Revisar os ícones do site público com `lucide-react`: traço unificado, menu com estados, ícones de saúde/entrega mais específicos e verificação dos 19 SVGs renderizados sem erros de console.
- [x] Substituir os ícones genéricos dos badges por marcas preenchidas oficiais (`FaApple` e `FaGooglePlay`), gerar novo bundle para invalidar cache e validar visualmente em produção sem erros de console.
- [x] Corrigir a centralização vertical dos badges de App Store e Google Play, isolando o ícone do layout do texto e validando os estilos computados em produção.
- [x] Aplicar a temática visual do protótipo no app: fundo creme, verde SaveMed, banners editoriais com fotos reais e mensagens de entrega, economia e cuidado.
- [x] Adicionar conteúdo editorial configurável: API protegida para blocos de conteúdo, upload validado de imagens, ativação/ordenação e seção "Conteúdo do app" para o administrador geral, com fallback local offline.
- [x] Publicar a API com o gestor editorial na revisão Cloud Run `api-savemed-00042-wim`, promover 100% do tráfego e validar `/health`, `/api/content` e `/api/highlights` com banco disponível.
- [x] Gerar e publicar o build Flutter web com base `/savemed/` na Hostinger e validar `https://savemed.app/savemed/` com HTTP 200 e base href correta.
- [x] Cadastrar conteúdo editorial inicial com as sete imagens de referência e textos editáveis no gestor do app.
- [x] Criar a farmácia de demonstração `Farmácia SaveMed Demo`, com endereço em Americana, três categorias e três produtos com estoque, permitindo desativação pelo gestor.
- [x] Adicionar o comando "Visualizar app" ao painel do administrador para abrir a vitrine autenticada sem encerrar a sessão administrativa.
- [x] Republicar o build web com a pré-visualização administrativa e validar o domínio com HTTP 200 após o upload.
- [x] Adicionar texto superior editorial, CTAs funcionais com rolagem para catálogo/categorias, pausa do carrossel ao foco/hover e faixa de modo prévia com retorno ao painel.
- [x] Corrigir a experiência de senha no login com mostrar/ocultar e manter a suíte de autenticação aprovada.
- [x] Publicar a coluna editorial `EYEBROW` de forma aditiva na API e reduzir a dependência de slugs técnicos na apresentação dos banners.
- [x] Otimizar imagens editoriais com resposta compacta e endpoint público cacheável, mantendo a resposta legada compatível; publicar API `api-savemed-00046-qit` e validar produção.
- [x] Exibir miniaturas no gestor editorial, normalizar URLs compactas no app e republicar o bundle final na Hostinger.
- [x] Adicionar resumo financeiro administrativo por farmácia, com totais brutos de pagos, pendentes, estornados e falhos, respeitando o escopo de `pharmacy_admin`.
- [x] Ajustar a grade de produtos para duas colunas em telas estreitas e corrigir mensagens visíveis com caracteres corrompidos.
- [x] Publicar API Cloud Run `api-savemed-00052-yib` e frontend web atualizado em `/savemed/`; validar saúde da API, resumo financeiro e HTTP 200 do app.
- [x] Corrigir o endpoint de imagens de produtos para entregar bytes com MIME correto; preencher as três imagens do catálogo demo e validar JPEG/PNG em produção na revisão `api-savemed-00054-zor`.
- [x] Mostrar miniaturas no inventário/produtos do gestor, preview no modal de edição e filtro de categorias em bottom sheet no celular.
- [x] Adicionar ícones selecionáveis para categorias, endpoint público de imagem de categoria e publicar API `api-savemed-00056-xur` com o gestor visual atualizado na Hostinger.
- [x] Refinar proporções dos modais, ampliar miniaturas, padronizar ações das listas e substituir os chips nomeados de categoria por uma grade visual de ícones com tooltip.
- [x] Promover a revisão final Cloud Run `api-savemed-00048-jan` com proteção de imagens ocultas e validar API e frontend públicos.
- [x] Atualizar `react-router-dom` do site para `7.18.3` e confirmar `npm audit --omit=dev --audit-level=high` sem vulnerabilidades.
- [x] Publicar fallback de envio nativo no relay da Hostinger; a solicitação de recuperação voltou a responder HTTP 200.
- [ ] Rotacionar a senha da caixa SMTP `@savemed.app` e atualizar Secret Manager e Hostinger.
- [ ] Confirmar o recebimento do código na caixa administrativa SaveMed e validar a redefinição completa da senha.
- [x] Em 02/10/2026, confirmar dois e-mails de recuperação enviados à caixa de suporte e recebidos na conta QA conectada; a conexão Gmail permitiu validar destinatário e horário, mas não expor os códigos nem comprovar a conclusão da redefinição. A confirmação da caixa administrativa permanece aberta.
- [ ] Rotacionar credenciais que tenham sido expostas e concluir a revisão dos segredos fora dos formatos conhecidos. Busca em 02/10/2026 cobriu o worktree e todos os 7 commits alcançáveis em um clone não raso; `git ls-remote origin` anunciou somente `HEAD`, `main` (`70f7a18bdd661988bad6ef29c9f55b60d1b014ca`) e `codex/merge-d-drive-20260812` (`3ede31d5695f6fc2adbf159e11acaa3f9685abfe`), todos incluídos nas refs locais. O `git fsck` encontrou 10 trees e 7 blobs inalcançáveis, sem commits órfãos; não há caminhos `.env*` nas trees, marcadores conhecidos nos blobs nem atribuições a literais longos nos padrões pesquisados no código atual. A heurística de nomes sensíveis encontrou somente identificadores de campos/estado no antigo `auth_page.dart`. Objetos foram preservados. Formatos desconhecidos e rotação no Secret Manager/Hostinger ainda não foram cobertos.

- [ ] Rotacionar a credencial da API Hostinger usada na publicação web de 02/10/2026 e atualizar o alias global `hostinger-savemed` com o novo token, sem gravá-lo no repositório.

- [x] Revarrer em 03/10/2026 os fontes/configuracoes do frontend por formatos conhecidos de chaves Pagar.me, chaves privadas e atribuicoes literais de senha: nenhum segredo correspondente foi encontrado; strings de senha localizadas estao restritas a fixtures de teste. Escopo limitado a este frontend, sem leitura de valores `.env` ignorados e sem cobertura do historico/remoto da API, Secret Manager, Hostinger ou credenciais de servicos. [Auditoria e limites](docs/dependency-audit-2026-09-28.md).

### Marketplace e repasse entre farmácias

- [x] Definir as regras comerciais confirmadas: comissão de 20% sobre produtos, SaveMed absorve a taxa Pagar.me na comissão e prazo de 15 ou 30 dias após entrega/retirada; o frete não integra a comissão.
- [ ] Definir responsabilidade por chargeback, descontos/estornos e frete em entrega própria antes de calcular saldo final por farmácia.
- [ ] Cadastrar e validar os `recipient_id` do Pagar.me para cada farmácia antes de habilitar vendas reais.
- [ ] Implementar split de pagamento por pedido, com valores calculados no servidor e registro de cada repasse.
- [x] Decidir que cada carrinho representa uma única farmácia; produtos de outra farmácia exigem confirmação para limpar o carrinho e iniciar um novo pedido.
- [x] Disponibilizar contato de suporte pelo detalhe de cada pedido, abrindo o WhatsApp oficial apenas com o número do pedido.
- [ ] Criar testes de pagamento para múltiplas farmácias, falha parcial, estorno, cancelamento, comissão e conciliação financeira.
- [x] Testar o resumo financeiro da farmácia em 360 px e escala de texto 200%, verificando escopo por farmácia, bruto pago/pendente, produtos, frete e ausência de repasse fictício.
- [x] Diferenciar falha do financeiro de saldo zero e testar recuperação; corrigir o botão de atualização que retornava uma `Future` dentro de `setState`.

- A API pública de farmácias responde normalmente.
- As rotas de solicitação de acesso a farmácia existente, consulta administrativa, aprovação e rejeição estão publicadas e protegidas por papel.
- O cadastro diferencia nova farmácia de solicitação de acesso a uma farmácia já existente e não coleta senha antes da aprovação.
- Logs de headers, tokens, senhas e corpos sensíveis foram removidos do cliente HTTP.
- A suíte automatizada cobre respostas HTTP, papéis, validações, status de pedidos, endereços, checkout, pagamento, solicitações, convites, upload, catálogo, contraste, teclado e cadastro responsivo; frontend aprovado com 79 testes e API com 79 testes.
- `flutter analyze`, 79 testes e o build web de produção estão aprovados em 04/09/2026.
- A área administrativa foi dividida por domínio, incluindo promoções.
- As mutações administrativas críticas estão protegidas e publicadas no Cloud Run `api-savemed-00036-vok`.
- Promoções ativas com estoque alimentam `/inventory/highlights`, mantendo itens recentes como fallback compatível.

### Validações locais adicionais em 02/10/2026

- [x] Validar o limite de 5 MB do gestor antes da leitura quando o seletor informa o tamanho e durante a leitura em fluxo quando ele diverge; cancelar assim que os bytes excedem o limite, sem carregar o arquivo inteiro ou iniciar upload (`test/features/admin/registration_ui_test.dart`).
- [x] Mostrar fallback quando bytes selecionados não forem uma imagem decodificável, tanto no formulário quanto na ampliação; teste de widget confirma ausência de exceção visível.
- [x] Priorizar os códigos estáveis `CNPJ_IN_USE`/`EMAIL_IN_USE` e manter fallback para mensagens textuais antigas; corrigida a forma feminina `cadastrada`, que antes escapava para a mensagem técnica. Regressão cobre os códigos e os textos reais da API.
- [x] Preservar o campo validado (`field`) das respostas de erro da API com validação de formato; conflitos de CNPJ/e-mail levam de volta à etapa correta do cadastro e exibem erro junto ao campo, removido ao editar. Testes cobrem campos válidos/inválidos e os dois caminhos de formulário.
- [x] Recriar o Web release com entrypoint versionado: `flutter build web --release --base-href /savemed/ --no-web-resources-cdn` seguido de `powershell -ExecutionPolicy Bypass -File scripts/fingerprint_web_entrypoint.ps1 -WebRoot build/web`; o bootstrap referencia `main.4a6cf3c1155cd56bbbdba80a7c781a86b426fe9c10812048c6fa45f699d30c75.dart.js` (3.581.141 bytes; SHA-256 `4A6CF3C1155CD56BBBDBA80A7C781A86B426FE9C10812048C6FA45F699D30C75`). Base-href `/savemed/` correta. O bundle e o bootstrap foram publicados depois desta validação local; o registro da publicação está na Prioridade 0.
- [x] Confirmar compilação Android após a validação adicional do seletor compartilhado: `flutter build apk --debug` concluiu localmente; nenhum APK foi distribuído.
- [x] Regerar o APK release do código atual: pacote `com.bravelight.save_med`, versão `1.1.0`/build `7`, `targetSdk 36`, assinatura v2 verificada com SHA-256 de certificado preservado `e0354e06ee216b3352525d7683f55a044ae1efea101f8bb4213364e0f15c9936`; APK local (60.043.094 bytes) SHA-256 `A369C6A95B0D28B0E4F06AB722F5A766492B64F3790B8692B937F53807468C42`. Não distribuir como atualização, pois o build 7 já está publicado.
- [x] Validar campos estruturados de erro no cadastro: preservar `field` apenas quando seu formato é seguro; duplicidade de CNPJ/e-mail reabre a etapa correspondente e exibe mensagem inline até o usuário editar. Naquela rodada, `PHONE_IN_USE` era tratado preventivamente; essa parte foi substituída em 02/10/2026 BRT após a decisão de permitir telefones compartilhados, mantendo `INVALID_PHONE` separado. Suíte daquela rodada: 323 testes; builds Web/APK locais e bundle Web publicado; nenhum APK distribuído.
- [x] Extrair o mapeamento de erros de cadastro de `RegisterCard` para `RegistrationErrorMapper`, mantendo navegação e mensagens inline no widget; adicionar cinco testes unitários para códigos atuais, fallback legado, validação de telefone e resultado incerto. Suíte serial: 323 testes; `flutter analyze` sem issues.
- [x] Preparar cache imutável do bundle web por conteúdo: renomeação SHA-256 e validação do `mainJsPath` gerado antes de remover o entrypoint estável; `.htaccess` local limita cache longo ao nome versionado. Em 03/10, o bundle publicado `06ab` e os headers efetivos foram validados no CDN; o candidato local atual `8f4` não foi publicado. Build limpo, execução repetida e smoke test em servidor local aprovados.
- [x] Adicionar teste isolado de `fingerprint_web_entrypoint.ps1` para hash, idempotência, rejeição de path traversal e ausência de mutação em caso de falha; o teste usa e remove apenas uma pasta temporária exclusiva. Validado com Windows PowerShell local e incluído no workflow ainda não integrado ao remoto.
- [x] Restringir o fingerprint a `main.dart.js` e `main.<sha256>.dart.js`; teste isolado rejeita `index.html` sem alterar o bootstrap nem o arquivo sentinela.

## Pendências externas e evidência necessária

### Segurança da sessão móvel

- [x] Armazenar o token de autenticação em Keychain/Keystore nos apps nativos, migrando a cópia legada de forma transparente; manter o armazenamento web compatível.
- [x] Desativar backup Android do app para não restaurar preferências incompatíveis com chaves do Keystore.
- [x] Concluir a suíte serial completa: 219 testes aprovados; validar login/logout em APK instalado antes de publicar.

### Confirmação Pix em 27/09/2026

- [x] Identificar ausência de conciliação após geração do Pix; confirmar cobrança do pedido 2 diretamente na Pagar.me.
- [x] Publicar conciliação autenticada na API `api-savemed-00061-tug`, mantendo rotas do app antigo. Pedido 2 confirmado como pago, R$ 8,90, e refletido no financeiro; 96 testes da API aprovados.
- [ ] Configurar fluxo durável de webhook e recuperação de eventos para atualizar pagamentos mesmo sem consultas ao aplicativo; a correção atual reconcilia ao consultar status, histórico e financeiro.

### Cadastros pela interface em 25/09/2026

- [x] Publicar frontend na Hostinger e API `api-savemed-00058-paj` no Cloud Run, com backup, revisão candidata, verificações de compatibilidade e smoke tests no endereço público. [Registro e rollback](docs/publicacao-2026-09-25.md).

- [x] Corrigir acesso ao cadastro no topo, separar CPF/CNPJ, filtrar vínculos entre farmácia/categoria/produto e impedir duplicação de categoria após falha de imagem.
- [x] Exibir falha de salvamento dentro do modal, preservando os dados.
- [x] Testar formulários de farmácia, categoria, produto, inventário, promoção, princípios ativos e conteúdo em celular/desktop; suíte com 93 testes aprovada.
- [x] Conferir cadastro público e produto no build web com endpoints isolados; [relatório e limites](docs/revisao-cadastros-2026-09-25.md).
- [x] Confirmar que o CNPJ inválido informado na reclamação foi rejeitado pelos dígitos verificadores; registrar a rejeição em teste e solicitar conferência do documento oficial, sem alterar automaticamente o número.
- [x] Em 02/10/2026, instalar `app-debug.apk` em AVD Android 15 (API 35) e inspecionar login e as etapas 1-2 do cadastro de farmácia; nome de teste digitado, CNPJ fictício formatado e fluxo avançou sem enviar conta. A automação inicial foi interrompida por erro do IME `putmethod.latin`, sem crash do SaveMed; não substitui teste em aparelho físico.
- [ ] Ampliar testes de gravação em homologação e validar APK/dispositivos reais; publicação e smoke tests não destrutivos em produção concluídos.

### Revisão visual registrada em 24/09/2026

- [x] Registrar pontos positivos, problemas e prioridades da experiência do cliente em celular e computador, com capturas do app publicado: [revisão visual do app](docs/revisao-visual-app-2026-09-24.md).
- [x] Implementar VIS-01 a VIS-05 no app web: área útil do perfil, login compacto, busca em tablet, estado explícito para imagem ausente e salvamento persistente de perfil; API `PUT /api/users/me` publicada na revisão `api-savemed-00058-paj`.
- [x] Implementar VIS-07 a VIS-26 localmente: organização do catálogo, proporções responsivas, busca, navegação, carrinho/checkout, modais, consistência visual e acessibilidade automatizada; [registro de alterações e limites](docs/correcoes-visuais-2026-09-24.md).
- [x] Manter o cabeçalho compartilhado visível ao rolar a home, consistente com as telas internas; teste responsivo em 390 px confirma que o catálogo rola sem deslocar o header.
- [x] Manter preço e ação de compra acessíveis no detalhe mobile/tablet, respeitando estoque, farmácia, teclado e área segura; quatro regressões no fluxo de comércio.
- [x] Mostrar estado de carregamento em miniaturas, seletor de imagem atual e recorte editorial do gestor, preservando as dimensões dos previews e mantendo os fallbacks de erro.
- [x] Exibir marca, apresentação, princípios ativos e sinalização de receita informados no cadastro de produto, sem inventar posologia ou validação de receita.
- [x] Preencher imagens dos seis produtos de demonstração com embalagens ilustrativas distintas, identificadas como demonstração e autorizadas pelo usuário; [registro](docs/embalagens-demo-2026-09-24.md).
- [ ] Obter e validar fotos comerciais correspondentes antes de transformar os produtos de demonstração em ofertas reais.
- [ ] Validar SafeArea, teclado, retorno por gestos/botões, leitores de tela e barras do sistema no APK e em dispositivos/navegadores reais (VIS-06 e validação externa de VIS-25).
- [ ] Executar compra integral em homologação, incluindo expiração/retomada do Pix; os testes visuais e automatizados não substituem uma transação real.
- [x] Corrigir regressão ao redimensionar o carrinho; endereço e modalidade de entrega são preservados entre layouts mobile e desktop, cobertos por testes.
- [x] Manter placeholders de produto/categoria visíveis durante o carregamento de imagens no catálogo, categorias, carrinho e busca; exibir fallback em erro. Os fallbacks do carrinho e da busca são cobertos com URL inválida e sem exceção visível.
- Esta rodada foi apenas de identificação e registro; os itens novos permanecem pendentes, sem alteração ou publicação de interface.

### Execução das correções visuais em 24/09/2026

- [x] Implementar login compacto, perfil sem rodapé fixo, busca responsiva, grade proporcional, vendedor nos cards e títulos coerentes de catálogo.
- [x] Simplificar carrinho/checkout/pagamento, adaptar QR Code, identificar pedido no resultado e incluir retorno nas telas internas.
- [x] Refinar gestor mobile, miniaturas, ampliação de imagens, recorte editorial e seletor de 18 ícones de categoria.
- [x] Implementar salvamento de perfil com confirmação após resposta da API e rota aditiva de edição da própria conta.
- [x] Validar análise, 82 testes Flutter, 82 testes da API e gerar build web; registrar capturas e [status por item](docs/correcoes-visuais-2026-09-24.md).
- [x] Reautenticar Google Cloud e publicar API/frontend em conjunto; a nova rota de perfil está em produção na revisão `api-savemed-00058-paj`.
- [x] Substituir ilustrações genéricas dos seis produtos de teste por embalagens demonstrativas distintas, conforme autorização do usuário; imagens e descrições publicadas na API. [Registro](docs/embalagens-demo-2026-09-24.md).
- [ ] Antes de usar esses registros para ofertas reais, substituir as embalagens fictícias pelas fotos dos produtos comerciais correspondentes.
- [ ] Validar APK/aparelho, teclado real, leitores de tela, Safari mobile e compra em homologação; manter refinamentos explicitados no relatório abertos.

- Android em distribuição interna: requer acesso ao Google Play Console e teste em dispositivo com a versão atualmente publicada e a candidata.
- iOS e VoiceOver: requer macOS, TestFlight e dispositivo iOS; este ambiente Windows não compila nem executa o aplicativo iOS.
- TalkBack, NVDA e navegadores suportados: requer sessão manual observada em dispositivos e navegadores reais, incluindo teclado e fonte ampliada.
- Integração administrativa completa: requer ambiente isolado com banco descartável e ao menos duas farmácias, clientes e administradores; a produção permanece vazia por decisão operacional.
- Carrinho e pagamento reais: requer produtos, estoque, endereço, frete e credenciais de homologação do provedor de pagamento.
- Recuperação de senha: requer acesso à caixa administrativa SaveMed para confirmar recebimento e concluir a redefinição; HTTP 200 isoladamente não comprova entrega.
- Segurança de credenciais: o `.env` não está mais rastreado, mas aparece em cinco commits do histórico da API; a remoção exige reescrita coordenada do repositório remoto e rotação das credenciais afetadas.
- Histórico pré-publicação em 02/10/2026 às 22:28 UTC: `/savemed/` respondia HTTP 200, `Last-Modified` de 29/09 e somente CSP; a conexão disponível ainda retornava 401 e nenhum arquivo havia sido alterado. A checagem posterior confirmou o bundle versionado; naquele momento os headers extras continuavam pendentes. Foram publicados e validados em 03/10.
