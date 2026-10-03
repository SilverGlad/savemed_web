# Correções da revisão visual

Referência: [diagnóstico](revisao-visual-app-2026-09-24.md).

## Entrega local

Atualização de publicação: frontend e API foram publicados após autorização do usuário; ver [publicação de 25/09/2026](publicacao-2026-09-25.md). As referências abaixo a publicação pendente descrevem o estado no momento desta revisão.

Atualização posterior: o usuário autorizou embalagens ilustrativas de demonstração. Seis produtos de teste já tiveram imagens distintas e identificação publicadas pela API existente; ver [registro das embalagens](embalagens-demo-2026-09-24.md). A pendência de fotos reais abaixo passa a se aplicar à conversão desses registros em ofertas comerciais, não à demonstração autorizada.

As alterações estão implementadas no workspace e no build web local. Prévia: http://127.0.0.1:8093/savemed/. Para iniciar novamente: `node scripts/preview-web.cjs` (porta 8093, somente loopback).

**Frontend e API ainda não publicados nesta rodada.** A credencial da conta SaveMed no Google Cloud exige reautenticação. A nova persistência do perfil depende de publicar `PUT /api/users/me` antes do frontend. Não interpretar a prévia contra a API antiga como validação de persistência em produção.

Em produção foram alterados somente dados demonstrativos autorizados: acentuação da farmácia ID 1 e dos produtos 4 a 7; ícones das três categorias, pelo editor local usando as rotas existentes. Estoques, preços, usuários e pedidos não foram alterados nesta rodada.

## O que mudou

Atualização de status em 28/09/2026: o perfil `PUT /api/users/me` foi publicado
na revisão `api-savemed-00058-paj`, conforme o registro de publicação de
25/09/2026. Assim, a referência abaixo a publicação pendente descreve apenas o
estado intermediário desta entrega; não é uma pendência atual. Fotos comerciais,
validação em aparelho e compra em homologação continuam pendentes.

| Referência | Implementação | Limite da validação |
| --- | --- | --- |
| VIS-01 | Removido o rodapé fixo do perfil e do resultado do pagamento. | Perfil capturado; resultado verificado no código. |
| VIS-02 | Login/cadastro centralizados e sem hero anterior ao formulário; requisitos de senha preservados. | Capturas mobile/desktop e testes de autenticação, teclado e fonte ampliada. |
| VIS-03 | Busca em segunda linha abaixo de 1100 px; menu da conta compacto e marca simplificada em 320 px. | Capturas de categoria em 320, 390, 768 e 1440 px. |
| VIS-04 | Estado explícito de imagem ausente no card e melhor inspeção de imagens no gestor. | Fotos corretas das embalagens ainda pendentes; não foram substituídas por imagens inventadas. |
| VIS-05 | Nova rota autenticada de perfil, serviço/controller e salvamento com estado de espera, erro e confirmação real. | Testes de sucesso, falha e restrição de campos. Publicação da API pendente. |
| VIS-06 | Área segura no nível do app e ação de voltar no cabeçalho das rotas internas. | APK, teclado físico/virtual de aparelho e gestos do sistema ainda precisam de ensaio real. |
| VIS-07/08 | Removida apresentação longa da home e textos sobre o design; carrinho, checkout e pagamento com títulos compactos. | Código e capturas da home/login. |
| VIS-09 | Categorias maiores, nomes com até três linhas, ícones do gestor respeitados no app e 18 opções sem texto embutido. | Upload real dos ícones demo validado pelo editor; capturas de lista/modal. |
| VIS-10 | Colunas calculadas pelo espaço disponível; altura de card compartilhada e adaptação à escala do texto. | Capturas de celular/tablet/desktop e teste de acessibilidade do card. |
| VIS-11 | Controles anterior/próximo nas vitrines; rolagem por mouse, toque e trackpad. | Navegação visual e código; não há nova página de catálogo completo. |
| VIS-12 | “Todos os produtos” e “Menores preços” substituem títulos inconsistentes; vitrine de ofertas filtra desconto real no frontend. | Contratos antigos da API de catálogo preservados. |
| VIS-13/14/15 | Vendedor nos cards e detalhe, modalidades da farmácia, colunas desktop proporcionais, ação de compra persistente e metadados de produto cadastrados. | Posologia e informações não fornecidas no cadastro não são inferidas; compra real segue pendente de homologação. |
| VIS-16 | Busca mostra ausência de resultado e lista todos os resultados locais, oferece fechamento e recalcula área do overlay. | Busca remota/paginada e teste com teclado virtual real continuam pendentes. |
| VIS-17/18 | Carrinho sem hero grande; estado vazio com ação de catálogo; revisão/pagamento com cabeçalhos compactos. Barra persistente de subtotal dos produtos no celular/tablet, com acesso ao resumo existente. | Não realizada compra real. Barra não presume frete definido nem cria pedido diretamente. |
| VIS-19 | QR Code respeita a largura disponível. | Expiração/retomada do Pix e cobrança em homologação ainda pendentes. |
| VIS-20 | Resultado pode mostrar número do pedido, abrir pedidos e retornar ao pagamento na falha. | Não houve transação financeira de validação. |
| VIS-21 | Rodapé compacto; removidos textos que aparentavam links mas não navegavam. | Destinos institucionais, políticas e suporte devem ser definidos antes de adicionar links reais. |
| VIS-22 | Modais administrativos dimensionados pela área livre do teclado, sem padding duplicado; ampliar imagem em editor/lista. | Modais de recuperação/endereço/cartão mantêm testes existentes; revisão manual com teclado de aparelho pendente. |
| VIS-23/24 | Retorno no cabeçalho, paleta de fundo unificada nas telas do cliente e raios reduzidos no tema/formulários/compra. O cabeçalho compartilhado permanece fixo na home e nas rotas internas durante a rolagem. | Não foi adicionada barra inferior de navegação; teclado virtual, gestos do sistema e validação em aparelho continuam pendentes. Regressão automatizada da rolagem da home em 390 px. |
| VIS-25 | Testes de fonte ampliada preservados; banners com altura baseada no texto, rotação automática opcional e respeito à redução de animações. Cards não se deslocam no hover. Labels de login/cadastro agora pertencem ao nó editável do campo; o rótulo visual não cria um nó semântico duplicado. A confirmação manual no Edge Web mostrou “Email” e “Senha” como campos editáveis, com o controle de visibilidade separado. Cadastro de farmácia validado semanticamente nas quatro etapas, com CEP simulado. Os formulários do gestor para produto e estoque cobrem campos, dropdowns pesquisáveis, toggle de receita e seleção de imagem; testes locais não substituem leitores de tela reais. | TalkBack/VoiceOver e Safari real não executados. |
| VIS-26 | Acentuação corrigida nos registros demo; ícones de categoria sem legendas incorporadas. | Fotos e revisão editorial integral do catálogo continuam pendentes. |

## Gestor

### Complemento de acessibilidade - 2026-09-27

Corrigida a ativacao semantica das opcoes de endereco/frete, cartao, modalidade
de pagamento e adicao de produto. Os wrappers que excluiam a semantica dos filhos
agora oferecem a mesma acao do toque. Testes executam SemanticsAction.tap para
selecionar Pix e adicionar produto, alem de verificar rotulos e estado selecionado.
Isso nao substitui o ensaio pendente em TalkBack/VoiceOver/NVDA reais.

## Carrinho persistente - 2026-09-27

Subtotal dos produtos e acao Revisar pedido ficam fora da rolagem em larguras
abaixo de 1040 px. A acao leva ao resumo ja existente: nao duplica checkout,
calculo de frete ou criacao de pedido. Barra some no carrinho vazio e com teclado
aberto; fonte ampliada organiza valor e botao verticalmente. Rolagem respeita
preferencia de reducao de animacoes. Desktop preserva o resumo lateral.

Testes em 390 px, 320 px / fonte 200% e 1280 px verificam valor atualizado,
posicao fixa, chegada ao resumo, teclado e carrinho vazio. Capturas com tema e
fontes reais em `test/features/commerce/goldens/cart_review_*.png`, revisadas
localmente. Nao certifica compra real, dispositivos ou navegadores externos.

Validacao desta etapa: 148 testes na suite completa; analise estatica focada de
`cart_page.dart` e `commerce_accessibility_test.dart` sem apontamentos.

### Continuidade ao redimensionar

Regressao reproduziu perda do endereco ao cruzar o breakpoint mobile/desktop.
O resumo agora compartilha a mesma chave de estado nos dois layouts e nao limpa
endereco ao montar. Teste alterna 390/1280 px repetidamente, preservando endereco
e retirada selecionada sem recotar apenas por redimensionar. Outro teste verifica
endereco preexistente na montagem; esvaziar o carrinho continua limpando endereco,
frete e farmacia. Cotacao e controlada em teste, sem chamada a parceiro real.

Validacao: 150 testes aprovados na suite completa; analise estatica dos dois
componentes de carrinho e da suite de acessibilidade sem apontamentos.

### Falha ao carregar a origem do frete

O carregamento de endereco da farmacia trata falhas, libera o estado de espera
e exibe nova tentativa no carrinho. Limpa a origem anterior ao iniciar consulta
e ignora respostas de consultas substituidas ou de controller descartado. O
resumo so usa CEP associado a farmacia atual; callback de cotacao confere que
farmacia e CEP de destino nao mudaram antes de iniciar.

Testes controlados cobrem falha/recuperacao, respostas fora de ordem com sucesso
ou erro, descarte e nova tentativa pelo botao real do carrinho. Nao validam a
resposta comercial da PedMoto nem substituem homologacao de frete.

Validacao desta etapa: suite completa com 155 testes aprovados e analise estatica
focada dos arquivos alterados sem apontamentos. Sem publicacao nesta etapa.

### Cotacoes concorrentes - 2026-09-28

O controller do carrinho identifica a consulta vigente e descarta sucesso/erro
de consultas substituidas. Selecionar/limpar endereco ou esvaziar carrinho
invalida consultas pendentes e limpa selecao, opcoes, erro e espera de frete.
Descarte do controller tambem invalida respostas. Cinco testes controlados
cobrem limpeza, consultas concorrentes e descarte sem acionar parceiros reais.
Essa protecao nao certifica validade comercial ou prazo de expiracao da cotacao.

Validacao: 160 testes aprovados na suite completa e analise estatica focada do
controller/testes de cotacao sem apontamentos. Alteracoes ainda locais.

### Frete acompanha os produtos

Adicionar, aumentar, diminuir ou remover produtos invalida frete de entrega
selecionado e consultas pendentes. O resumo acompanha uma revisao dos dados da
cotacao, nao apenas o CEP: mudancas de quantidade ou endereco diferente no mesmo
CEP disparam nova consulta quando a origem esta disponivel. Retirada continua
selecionada ao mudar quantidades e durante cotacao das alternativas de entrega.

Seis regressoes adicionais cobrem as quatro mutacoes, retirada preservada e o
botao real de aumentar quantidade seguido de troca de endereco com mesmo CEP.
Reconstruir a tela sem alterar os dados nao gera consultas repetidas.

Validacao desta etapa: suite completa com 166 testes aprovados e analise estatica
focada sem apontamentos. Sem chamadas comerciais ou publicacao.

### Limites do carrinho - 2026-09-28

O controller recusa adicionar produto de outra farmacia e unidades acima do
estoque conhecido. Aumento de quantidade valida que o item pertence ao carrinho
e ainda possui saldo. Botao de aumento fica desabilitado no limite, com tooltip
explicativo, e volta a funcionar depois de reduzir. Card e detalhe de produto
nao apresentam sucesso nem avancam quando a inclusao e recusada.

Tres regressoes cobrem controller, botoes reais do carrinho e mensagem do card.
Limite usa o estoque recebido do catalogo, nao e reserva nem garante disponibilidade
em tempo real; validacao/reserva da API permanece obrigatoria no pagamento.

Validacao: 169 testes aprovados na suite completa e analise estatica focada dos
arquivos alterados sem apontamentos. Sem publicacao nesta etapa.

### Consultas de endereco do cliente - 2026-09-28

Carregamento de enderecos agora descarta respostas de consultas anteriores e
apos descarte do controller. Iniciar consulta de outro usuario limpa os dados
anteriores imediatamente. Falha da consulta vigente continua propagando para
os chamadores, preservando o tratamento existente do login.

Quatro regressoes cobrem respostas fora de ordem com sucesso/erro, limpeza na
troca de usuario, propagacao da falha atual e descarte. Isso nao certifica todo
o ciclo de logout nem resolve a apresentacao de falha versus lista vazia nas
telas de endereco; esses pontos continuam para revisao da interface.

Validacao: suite completa com 173 testes aprovados e analise estatica focada
do controller e dos novos testes sem apontamentos.

### Falha de enderecos na interface - 2026-09-28

Perfil e carrinho agora distinguem falha de carregamento de lista vazia e
oferecem nova tentativa. Controller preserva enderecos da mesma conta na falha,
expondo erro para a interface; o carregamento de consulta pela UI trata essa
falha sem excecao nao observada. Metodos de gravacao continuam propagando erro.
Perfil inicia a consulta apos o primeiro frame para evitar notificacao durante
construcao. Testes preenchem ambos os estados reais e acionam o botao de retry.

Esta etapa resolve a apresentacao de falha/lista vazia citada acima; revisao
integral de limpeza no logout permanece pendente.

Validacao: 176 testes aprovados na suite completa e analise estatica focada dos
arquivos alterados sem apontamentos. Recuperacao validada pelo perfil e carrinho.

### Enderecos ao sair da conta - 2026-09-28

Logout e expiracao limpam a lista de enderecos vinculada ao fluxo de autenticacao,
erro e espera, invalidando consultas pendentes. Restauracao sem usuario valido
e entrada administrativa tambem limpam essa lista. Gravacoes concluidas depois
de invalidacao nao iniciam recarga antiga. Testes de logout/expiracao entregam
resposta atrasada e verificam que a lista permanece vazia.

Escopo: cache de AddressController. Carrinho, pedidos, cartoes em memoria e
demais estados privados ainda precisam da auditoria completa de encerramento
de sessao; nao considerar a limpeza global encerrada por estes testes.

Validacao: 181 testes na suite completa, incluindo criacao/edicao/exclusao
concluidas apos limpeza sem recarregar a conta antiga. Build web concluido.

### Cartoes em memoria ao sair - 2026-09-28

A composicao principal vincula CardController ao AuthController. Login, logout
e expiracao limpam lista e selecao em memoria, alem do CardStorage ja existente.
Controller ignora conclusoes de carga anteriores a limpeza/descarte. CardStorage
invalida saves em andamento antes de aguardar a remocao da chave legada, evitando
que um save anterior recoloque cartoes na memoria depois do logout.

Quatro regressoes cobrem logout, expiracao, save concorrente com clear e adicao
pendente; teste existente de ausencia de PAN/CVV persistidos continua aprovado.
Isso nao equivale a tokenizacao PCI. Carrinho e pedidos foram tratados em
continuacao separada; outros estados privados ainda requerem auditoria.

Validacao: suite completa com 185 testes aprovados; analise estatica focada de
controllers, armazenamento, composicao principal e novos testes sem apontamentos.

Continuacao: cabecalho (inicio, login e carrinho) e menu lateral administrativo
tambem compartilham callbacks de toque/ativacao semantica. A acao de compra dos
cards tem limite semantico proprio para nao se misturar com abrir detalhes quando
o produto esta esgotado. Testes verificam navegacao real ao carrinho por acao
semantica e ausencia de acao de compra para produto sem estoque.

### Carrinho e pedidos ao sair - 2026-09-28

Logout e expiracao limpam carrinho, endereco e entrega selecionados, historico,
detalhe e identificador do pedido. Respostas de consultas iniciadas antes da
limpeza sao ignoradas. Se o checkout remoto concluir depois do encerramento,
o controller nao entrega o identificador ao fluxo da sessao encerrada; isso nao
desfaz um pedido que o servidor ja tenha criado.

Regressoes cobrem logout com carga de historico pendente e conclusao tardia do
checkout. Teste direcionado: 2 aprovados. A revisao dos demais estados privados
e a validacao real de compra continuam pendentes.

### Pagamento concorrente com troca de sessao - 2026-09-28

O indicador compartilhado do PaymentController agora invalida pagamentos e
consultas de status iniciados antes de logout/expiracao. Uma resposta atrasada
nao pode zerar o estado de carregamento de um pagamento iniciado pela sessao
seguinte. O tipo PaymentMethod foi movido para o dominio para manter o servico
e controller independentes da pagina de pagamento.

Regressoes cobrem resposta tardia durante uma nova tentativa e status Pix
recebido depois da limpeza. O teste nao cancela a transacao remota nem resolve
tentativas de resultado incerto; conciliacao e recuperacao duravel permanecem
responsabilidade da API.

### Qualidade estatica e regressao administrativa - 2026-09-28

Removidos avisos globais de analise: acesso ao BuildContext apos operacoes
assincronas, helper de dropdown sem uso e condicional sem bloco. O escopo da
sessao administrativa continua comparado pelo mesmo usuario/farmacia apos cada
espera, e o ScaffoldMessenger e capturado antes das operacoes assincronas.

Validacao: `dart analyze` global sem apontamentos; 46 testes direcionados de
cadastro, operacoes/fila administrativa e 189 testes na suite completa. Build
web release com base `/savemed/` concluido localmente; nada foi publicado.

### Ação persistente no detalhe do produto - 2026-09-28

Em viewports de até 900 px, o detalhe mantém preço e ação de compra acessíveis
no rodapé durante a rolagem. A barra adapta-se a 320 px e fonte a 200%, respeita
área segura, some enquanto o teclado está aberto e desabilita produto indisponível.
Desktop preserva o botão no conteúdo. As duas ações usam o mesmo fluxo existente
de adição, confirmação de troca de farmácia, limite de estoque e navegação ao
carrinho.

Quatro regressões validam 390 px, 320 px / escala 200%, indisponibilidade e
teclado aberto. Suíte de comércio: 25 testes; análise global e build web `/savemed/`
reexecutados após a alteração; suíte Flutter completa: 193 testes. Nenhuma
compra real ou publicação foi feita.

### Informações do produto no detalhe - 2026-09-28

O detalhe exibe marca, apresentação/unidade e princípios ativos quando esses
dados estão cadastrados. Quando o sinalizador do produto está ativo, mostra um
aviso de apresentação de receita atribuído à informação da farmácia; não tenta
classificar medicamentos nem promete validar receitas no checkout. Dados ausentes
continuam ocultos em vez de inferidos.

Regressão cobre aviso, marca, unidade e princípio ativo em viewport mobile.
Suíte de comércio: 26 testes. Posologia, contraindicações, fotos comerciais e
compra em homologação não fazem parte dos dados disponíveis e permanecem abertos.

- Cabeçalho das listas empilha título e ações em telas estreitas; o título deixou de ser espremido pelos botões.
- Miniaturas móveis com área própria em produtos, categorias, inventário, promoções e conteúdo; ações separadas do título e com alvos de 48 px.
- Miniaturas padrão maiores, imagem preservada com `contain` e abertura ampliada com zoom.
- Editor de conteúdo oferece prévia de recorte celular/computador. É uma prévia da imagem, não uma simulação exata de todo banner com texto.
- Catálogo de 18 ícones Material; o ícone selecionado é renderizado para PNG e enviado pela API já existente. Clientes antigos continuam recebendo imagem no mesmo contrato.
- Resumo financeiro inicia a consulta quando seu componente é montado, evitando erro assíncrono de uma seção ainda não exibida no mobile.

## Compatibilidade e testes

- `flutter analyze`: sem problemas.
- Suíte Flutter: 82 testes aprovados.
- API: 82 testes aprovados, incluindo atualização limitada a nome/telefone do usuário autenticado e rejeição de conta inativa/dados inválidos.
- Build web release gerado com base `/savemed/` e recursos locais de renderização.
- A API recebeu apenas a rota adicional `PUT /api/users/me`. Não houve mudança de schema, remoção de rota ou alteração de campos obrigatórios dos contratos existentes.
- Não foram feitos pagamentos, redefinições de senha ou alterações de estoque para validar o visual.

## Evidências

Capturas em [visual-fixes-2026-09-24](visual-fixes-2026-09-24/): login mobile/desktop, home, categorias em celular/tablet/desktop, perfil e gestor de categorias/modal. A revisão ocorreu em Edge headless e em modo de visualização administrativa para acessar o catálogo; não é uma certificação do APK nem de todos os dispositivos.

## Próximos passos necessários

1. Reautenticar a conta SaveMed no Google Cloud, publicar a rota aditiva em revisão candidata e testar a persistência antes de promover tráfego.
2. Publicar o build frontend na Hostinger e repetir smoke tests de login, catálogo, imagem e perfil.
3. Obter fotos correspondentes às apresentações dos produtos demonstrativos, sem reutilizar ilustrações de categoria como fotos.
4. Executar a matriz de aparelho físico, teclado, TalkBack/VoiceOver e pagamento em homologação descrita no diagnóstico.

Os pontos condicionados a credenciais, ativos reais ou dispositivo permanecem abertos no roadmap.
