# Revisão dos cadastros pela interface

## Status

Correções implementadas e build local validado. **Atualização: frontend e API publicados após autorização do usuário**, conforme [registro da publicação](publicacao-2026-09-25.md). Prévia local: http://127.0.0.1:8093/savemed/.

Nenhum registro real foi criado, editado ou removido nesta revisão. Não houve alteração de API, schema ou contrato de clientes antigos. O build contém também as mudanças da revisão anterior, cuja publicação coordenada continua pendente; a persistência de perfil requer a rota aditiva registrada naquele relatório.

## Problemas corrigidos

1. O texto superior "Novo por aqui?" não era uma ação. Agora "Novo por aqui? Criar conta" abre o cadastro; "Já tem conta? Entrar" também funciona no topo do cadastro. Navegação por Tab atualizada e testada.
2. CPF do cliente/responsável e CNPJ da farmácia compartilhavam um controller. Agora o CNPJ tem controller e máscara próprios, preservando o CPF ao alternar entre cliente, nova farmácia e solicitação de acesso. Máscaras de documentos pertencem à instância do formulário.
3. CNPJ composto apenas por zeros passava pelo cálculo de dígitos. Sequências repetidas agora são recusadas.
4. Produto oferecia categorias de outras farmácias e subcategorias de outras categorias. Seletores agora dependem da farmácia/categoria atual; trocar o vínculo limpa as seleções dependentes.
5. Estoque e promoções ofereciam produtos de outras farmácias, recusados apenas ao salvar. Agora a seleção é filtrada e reiniciada ao trocar a farmácia.
6. Campos de seleção mantinham estado visual/validação antigo depois de mudar suas opções. A identidade do campo agora acompanha valor e opções disponíveis.
7. Repetir o salvamento de uma categoria após falha no upload do ícone podia criar outro registro. A tentativa seguinte reutiliza o ID já salvo.
8. Falha ao salvar só aparecia no snackbar atrás do modal. O modal agora mostra um aviso persistente e acessível, mantém os dados e permite tentar novamente; exceções inesperadas também liberam o botão.

## Validação realizada

### Testes de widgets com serviços isolados

Os testes preenchem e submetem os formulários reais, verificando payload, validação, fechamento do modal e atualização da lista. Não são apenas chamadas diretas à API.

- Farmácia: campos obrigatórios, CNPJ com máscara, normalização de UF, criação e edição em 390 e 1280 px.
- Produto: seleção de farmácia/categoria/subcategoria, limpeza após troca, bloqueio de seleção incompleta e criação em 390 e 1280 px.
- Inventário: produto da farmácia correta, preço com vírgula, original menor que atual rejeitado e envio válido em ambos os tamanhos.
- Promoção: produto filtrado, desconto acima de 100 rejeitado e envio válido em ambos os tamanhos.
- Categoria: criação com ícone, falha simulada no upload, dados preservados, aviso no modal e nova tentativa sem duplicar o registro.
- Princípios ativos e conteúdo: criação pelo formulário e atualização da lista em ambos os tamanhos; título obrigatório de conteúdo.
- Cadastro público: acesso pelo link superior, CPF preservado entre perfis, CNPJ inválido recusado e válido aceito.
- Suíte anterior mantida: cadastro completo de farmácia/cliente, solicitação de acesso, recuperação, convite de usuário, inativação, sessão e demais fluxos.

### Navegador

Build release executado no Edge headless, com endpoints interceptados e respostas isoladas, sem gravação em produção:

- Cadastro público: link superior, quatro etapas, CNPJ correto, senha/confirmacão, envio HTTP para `/api/pharmacies/register` com CNPJ normalizado e retorno ao login após sucesso simulado.
- Gestor: duas farmácias isoladas; categoria A não aparece para farmácia B; produto enviado para `/api/medications` com os IDs corretos, modal fechado e lista atualizada.
- Capturas em [registration-qa-2026-09-25](registration-qa-2026-09-25/), incluindo celular e lista desktop.

### Resultado

- `flutter analyze`: sem problemas.
- `flutter test`: **93 testes aprovados**, incluindo 11 novos testes de interface.
- `flutter build web --release --base-href /savemed/ --no-web-resources-cdn`: aprovado.

## Limites e pendências

- O documento de teste informado falha na validação dos dígitos verificadores. A rejeição foi adicionada como teste de regressão; isso não confirma existência ou situação cadastral de outro número. Conferir o documento oficial antes de cadastrar.
- As respostas isoladas comprovam comportamento do programa e contrato enviado, mas não comprovam persistência, entrega de convite/email ou autorização do backend publicado. Repetir smoke tests coordenados em homologação antes da promoção.
- Publicar as correções do frontend e verificar a versão carregada no navegador. O APK já distribuído não recebe alterações de Flutter automaticamente; exige build e distribuição próprios.
- Aparelho físico, teclado virtual Android/iOS, picker nativo de arquivos, TalkBack/VoiceOver e upload real em cada formulário ainda requerem validação de homologação. O teste de ícone cobre a geração PNG e repetição, não o picker nativo.
- Esta revisão não certifica todas as combinações de dados, todas as permissões, todas as exclusões ou todos os dispositivos.

## Complemento de regressao - 2026-09-27

O formulario administrativo compartilhado agora bloqueia reentrada do metodo
Salvar enquanto ha requisicao em andamento. Teste dispara o mesmo callback duas
vezes antes do rebuild e verifica somente uma chamada ao servico.

Teste de sessao expirada (HTTP 401 ao salvar categoria) confirma mensagem de
autenticacao, modal aberto, nome preservado e ausencia de confirmacao de sucesso.
Nao equivale a renovacao automatica de sessao nem a idempotencia de criacao apos
timeout com resposta perdida; esses fluxos nao foram presumidos como resolvidos.

O botao Voltar do sistema tambem fica bloqueado durante a gravacao pelo
`PopScope` do formulario compartilhado. Testes de widget confirmam que o modal
permanece aberto durante a requisicao, fecha quando o salvamento termina com
sucesso e libera a navegacao apos falha, mantendo o rascunho ate o usuario sair.
Isso nao impede fechar a aba do navegador nem encerrar o aplicativo pelo sistema.

### Fonte ampliada no gestor

A matriz de widgets agora executa criacao/edicao de farmacia, produto com
categorias dependentes, estoque, promocao, principio ativo e conteudo editorial
em 390 px com fonte a 200%, alem de 390/1280 px com fonte padrao. Usa tema e
fontes do aplicativo, servicos isolados e rolagem real para alcancar os itens.

Os testes expuseram e corrigiram cortes nos indicadores de altura fixa,
mensagens de lista vazia e seletor de imagens. Indicadores passam a crescer com
o conteudo; estados vazio/erro permitem rolagem; selecao de imagem ocupa linha
propria, com nome/status quebrando linha. Nao foi limitada a escala de fonte.
Capturas de regressao do painel e formulario de produto ficam em
`test/features/admin/goldens/*large_text_390.png`.

Esta evidencia nao substitui a matriz manual de dispositivos nem certifica
todas as telas em todas as escalas. O titulo compacto do header ainda pode
abreviar o nome da secao com reticencias em fonte ampliada.

Validacao local desta etapa: 18 testes de cadastro e captura passaram; a suite
completa `flutter test` passou com 134 testes. Analise estatica focada do teste
e do painel sem apontamentos. Nenhuma alteracao de API ou publicacao nesta etapa.

### Troca de sessao e isolamento visual

Teste reproduziu categorias da farmacia anterior permanecendo na tela apos
mudanca da conta vinculada. O conteudo administrativo agora tem identidade por
usuario, papel, farmacia e status ativo, descartando estados anteriores quando
esse escopo muda. Contas inativas ou gestores sem farmacia nao carregam o painel.

O formulario compartilhado oculta seus campos e bloqueia o callback Salvar se
a sessao mudar. Requisicao ja iniciada pode concluir na conta original, mas nao
gera confirmacao de sucesso na nova conta. Acoes de lista validam o escopo antes
de iniciar e antes de recarregar; uploads posteriores a criacao de categoria,
produto, promocao ou conteudo nao iniciam se o escopo mudou nesse intervalo.

Regressoes verificam troca entre duas farmacias, seletor de farmacia bloqueado,
payload vinculado, ausencia de menus exclusivos SaveMed, callback antigo,
troca durante gravacao sem upload posterior e negacao de contas inativas/sem
vinculo antes de consultar dados. Servicos isolados: nao certifica autorizacao
HTTP de todas as rotas nem cancela requisicoes que ja chegaram ao servidor.

Validacao da etapa de isolamento: `flutter test` com 140 testes aprovados e
analise estatica focada de `admin_page.dart` e `registration_ui_test.dart` sem
apontamentos. Alteracoes somente locais, sem migracao ou alteracao de contrato API.

Complemento: consultas de lista, carga de opcoes e mensagens de sucesso/erro
agora conferem o escopo tambem ao concluir seus `await`, inclusive no intervalo
entre a notificacao da troca de conta e o proximo frame. Cinco regressoes cobrem
respostas tardias com sucesso/falha, falha de gravacao nesse intervalo e opcoes
de produto que nao devem abrir um formulario da sessao anterior. Nenhuma
requisicao de escrita e repetida automaticamente por essas protecoes.

Validacao desse complemento: 145 testes na suite completa e analise estatica
focada sem apontamentos. As cinco novas regressoes usam servicos controlados.
