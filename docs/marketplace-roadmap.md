# SaveMed como marketplace de farmacias

## Ordem de execucao

1. Operacao confiavel: central de pedidos, ocorrencias, isolamento de farmacias,
   pagamentos conciliados sem depender do cliente e valores financeiros claros.
2. Modelo comercial: recebedores, comissao, taxas, frete, split, repasse e estorno.
3. Disponibilidade: loja aberta/pausada, horarios, prazo de preparo, area de entrega,
   catalogo/estoque por farmacia e separacao de produtos.
4. Cliente: descoberta por endereco, pagina da farmacia, busca por apresentacao,
   acompanhamento, favoritos, recompra e suporte vinculado ao pedido.
5. Regras farmaceuticas: aprovacao documental, responsavel tecnico, receitas,
   acesso a dados sensiveis, publicidade, substituicao e transporte.
6. Crescimento: avaliacoes verificadas, campanhas, cupons e fidelidade.

## Regras comerciais confirmadas - 2026-09-27

- Comissao SaveMed: 20% somente sobre o valor dos produtos vendidos pelo app.
- O frete nao integra a base da comissao. O cliente paga a opcao escolhida;
  na entrega pela PedMoto, esse valor e destinado a PedMoto.
- Prazo de repasse por farmacia: escolha entre 15 e 30 dias, contados a partir
  da confirmacao da entrega ou retirada, nunca da aprovacao do pagamento.
  Pedidos pagos ainda nao entregues/retirados nao iniciam essa contagem.
- A SaveMed absorve a taxa de processamento da Pagar.me, descontando-a da sua
  comissao, sem repassar esse custo a farmacia.
- Distribuicao dos produtos: 80% para a farmacia e 20% de comissao bruta SaveMed.
  O liquido SaveMed depende da taxa efetivamente cobrada pelo provedor; nao presumir
  percentual de processamento nem confundir essa distribuicao com saldo disponivel.
- Pendente: definir tratamento de descontos/estornos e
  regras do frete para entrega propria. Nao presumir que toda entrega e PedMoto.
- A preferencia de prazo no gestor nao agenda transferencias. Split e repasses
  reais permanecem desativados ate configuracao e homologacao dos recebedores.

## Validacao do lote local

- [x] Central de pedidos por etapas, busca, ocorrencias e atualizacao automatica.
- [x] Separar pendencia de pagamento de novo pedido pago; corrigir pedidos ativos.
- [x] Exibir pagamentos brutos, produtos e frete sem apresentar repasse ficticio.
- [x] Impedir acesso global de administrador de farmacia sem vinculo valido.
- [x] Rotina de conciliacao com reserva persistente, lotes limitados e autenticacao.
- [x] Pausar/reabrir loja e bloquear novas compras tambem na API para apps antigos.
- [x] Na vitrine e no detalhe do produto, identificar loja pausada e desabilitar compra; regressao cobre modelo, card e detalhe.
- [x] Configurar preparo e preferencia de repasse de 15 ou 30 dias por farmacia.
- [x] Mostrar etapas reais do pedido ao cliente, sem estimar GPS ou prazos ficticios.
- [x] Atualizar pedidos do cliente a cada 30 segundos somente com a aba ativa e app em primeiro plano; atualizar ao retornar, sem substituir push.
- [x] Regressao: 159 testes API e 123 Flutter; analise focalizada sem ocorrencias.
- [x] Capturas da central em 390/1280px revisadas e teste 320px com texto 200%.
- [x] Build web release gerado com base /savemed/ em 2026-09-27.
- [ ] Validar migracoes/concorrencia em PostgreSQL de homologacao e aparelhos reais.
- [ ] Publicar API/web e configurar agendamento externo da conciliacao.

### Limites e ativacao

Implementado localmente, nao publicado. O painel consulta pedidos a cada 30 segundos
quando ativo; ainda nao ha push, alerta sonoro ou paginacao do historico na API.
O cliente recebe atualizacao automatica a cada 30 segundos enquanto a aba de pedidos
esta ativa e o app em primeiro plano, e uma consulta ao retornar. A atualizacao manual
continua disponivel. Isso nao substitui push, alerta sonoro ou paginacao do historico.

A API adiciona campos nullable de verificacao de pagamento em Order e os campos
IS_OPEN (true por padrao), PREPARATION_MINUTES, PAYOUT_TERM_DAYS e OPERATION_VERSION
em Pharmacy. O bootstrap usa o mecanismo existente de colunas operacionais e cria
o indice order_payment_sweep. Validar backup, tempo de criacao do indice e rollback
antes de promover uma revisao Cloud Run; os testes locais usam doubles de persistencia.

POST /api/internal/payments/reconcile permanece desativado por padrao. Para ativar,
configurar PAYMENT_RECONCILIATION_ENABLED=true e um segredo exclusivo de pelo menos
32 caracteres em PAYMENT_RECONCILIATION_JOB_SECRET. O agendador externo envia esse
segredo em Authorization: Bearer, nunca a chave Pagar.me ou token de usuario.
Nao colocar o segredo na URL ou nos logs. A rotina reserva ate 20 cobrancas com
FOR UPDATE SKIP LOCKED e intervalo de 5 minutos por cobranca; consulta o reconciliador
existente, sem criar cobrancas. Requer Cloud Scheduler configurado e validado.
Ainda nao substitui webhook, recuperacao de attempt sem charge ID ou chargeback.

## Dependencias e proximos lotes

### Rodada PostgreSQL e seguranca financeira - 2026-09-27

- [x] Executar 8 testes integrados em PostgreSQL local real com duas farmacias,
  checkout, conciliacao simulada, entrega propria, retirada com codigo, concorrencia
  e pausa. Provedores externos nao foram acionados.
- [x] Exigir confirmacao financeira do estorno, preservando ocorrencias incertas.
- [x] Bloquear alteracao manual de pagamento pela rota generica do pedido.
- [x] Executar regressao API: 162 testes passaram.
- [x] Reserva/baixa transacional antes da cobranca, incluindo bloqueio de itens
  legados, disputa por unidades, recusa confirmada e liberacao sem duplicidade.
- [x] Recuperar estornos pendentes por consulta/scheduler sem repetir cancelamento.
- [x] Mostrar situacao do estoque nos detalhes do pedido do gestor.
- [x] Ampliar integracao PostgreSQL para 14 testes aprovados.
- [x] Ampliar para 17 testes PostgreSQL com cadastro atomico, hash de senha,
  rollback de registros dependentes e conflito concorrente de email.
- [x] Ampliar para 21 testes PostgreSQL com aprovacao/rejeicao concorrentes,
  rollback do convite, permissao de plataforma e bloqueio de farmacia inativa.
- [x] Regressao Flutter: 123 testes; analise focalizada sem ocorrencias; build web
  release /savemed/ e capturas do gestor mobile/desktop revisadas.
- [ ] Homologar respostas reais Pix/cartao, expiracao e migracao de base antiga.
- [ ] Recuperar tentativas sem charge ID e disponibilizar conferencia de reservas
  antigas. Timeout nao libera estoque; estorno nao repoe produtos automaticamente.

Relatorio tecnico na API: docs/HOMOLOGACAO-MARKETPLACE-2026-09-27.md.
Esta rodada nao valida migracao de base antiga, APKs ou provedores reais e nao
autoriza publicacao. Split/transferencias seguem desativados.

### Acompanhamento do cliente - 2026-09-28

- [x] Atualizar a lista a cada 30 segundos apenas enquanto a aba de pedidos esta ativa e o app em primeiro plano; consultar ao voltar.
- [x] Distinguir falha de rede de lista vazia, manter nova tentativa manual e mostrar vazio somente apos resposta valida.
- [x] Validar inicio/parada do polling, ciclo do app, falha de rede e recuperacao; suite Flutter completa aprovada com 200 testes.
- [ ] Notificacoes push seguem dependentes de servico e integracao no backend.

### Disponibilidade da loja no catalogo

- [x] O contrato do inventario inclui `IS_OPEN`; itens de loja pausada sao indisponiveis no modelo, no card e no detalhe.
- [x] Cobrir status visivel e acao desabilitada em telas de vitrine e detalhe, sem permitir inclusao no carrinho.
- [x] `flutter test`: 212 testes; `dart analyze`: sem ocorrencias; builds web release em `/savemed/` e APK debug aprovados (2026-09-28).
- A API continua como autoridade no checkout; a indicacao do cliente e uma antecipacao de UX, nao substitui validacao no servidor.
- [x] Abrir o WhatsApp oficial pelo pedido, enviando somente o identificador do pedido; falha ao abrir mostra telefone alternativo.
- [x] Confirmar URL e conteudo da mensagem sem dados pessoais; plugin url_launcher 6.3.2 compativel com iOS 12+, Android 21+ e Web.
- [x] Gerar APK Android debug; fixar url_launcher_android 6.3.25 para manter compatibilidade com o AGP 8.7.3 atual.
- [x] Abrir a pagina da farmacia a partir do detalhe do produto, carregar somente o catalogo do endpoint da farmacia, permitir busca local e mostrar disponibilidade/entrega/retirada sem habilitar compra quando a loja estiver pausada.
- [x] Tratar a resposta do endpoint mesmo quando ela omite o objeto da farmacia, usando os dados da farmacia que originou a navegacao; cobrir servico, busca e navegacao em testes.
- [x] Usar a imagem cadastrada da farmacia com estado de carregamento/erro acessivel, reorganizar nome e status para telas estreitas e cobrir 320px com texto 200%, celular e desktop com fonte ampliada.
- [ ] Confirmar o contrato do endpoint de catalogo por farmacia na revisao atualmente publicada da API e validar a jornada em Android/iOS reais antes da publicacao.

### Pendencias gerais

- [x] Definir comissao sobre produtos, destino do frete PedMoto e opcoes de prazo.
- [x] Definir responsavel pela taxa Pagar.me: SaveMed absorve na sua comissao.
- [ ] Definir detalhes de liquidacao acima e validar taxas efetivas do provedor.
- [ ] Validar recebedores e implementar split/ledger somente apos regras aprovadas.
- [ ] Webhook autenticado, armazenamento de eventos, estorno externo/chargeback e recuperacao por evento.
- [ ] Tokenizar cartao sem alterar contrato dos aplicativos antigos.
- [ ] Homologar PedMoto e integrar cancelamento, retorno e codigo ao app do motoboy.
- [ ] Horarios e cobertura geografica (pausa e preparo implementados localmente).
- [ ] Separacao de itens, falta de estoque e ajuste de valores com consentimento.
- [ ] Descoberta farmacia-proxima-por-endereco e filtros geograficos; a pagina de farmacia e a busca no catalogo da loja foram implementadas localmente, mas a selecao por distancia e disponibilidade depende de contrato/backend.
- [ ] Notificacoes push seguem dependentes de servico e integracao no backend.
- [x] Suporte contextual por pedido via WhatsApp; nao ha sistema de tickets nem promessa de tempo de resposta.
- [ ] Favoritos e recompra sincronizados; nenhum contrato correspondente foi encontrado na API local nesta auditoria.
- [ ] Avaliacoes verificadas: a rota local `POST /api/reviews` valida papel e payload, mas nao vincula a avaliacao a pedido pago e concluido nem impede duplicidade. Nao apresentar a classificacao como verificada antes da correcao e verificacao do contrato publicado.
- [ ] Validacao regulatoria do modelo antes de ampliar oferta de medicamentos.
- [ ] Receita com revisao farmaceutica, acesso restrito e retencao definida.
- [ ] Observabilidade, alertas, indicadores, testes com duas farmacias e aparelhos reais.
- [ ] Publicar candidatos, verificar compatibilidade e promover com rollback.

Regras financeiras, sanitarias e credenciais nao serao presumidas. Implementacao
local nao significa publicacao ou homologacao externa. Novas funcionalidades
devem manter os contratos existentes e falhar sem aprovar pagamentos indevidos.
