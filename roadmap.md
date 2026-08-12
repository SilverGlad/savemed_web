# Roadmap de melhorias do frontend SaveMed

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

### Segurança dos dados

- [x] Remover dos logs o header `Authorization` e qualquer token de sessão.
- [x] Não registrar senhas, códigos de recuperação, documentos, telefone ou corpos completos de autenticação.
- [ ] Criar uma política central de logs sanitizados para requisições HTTP.
- [x] Desabilitar logs detalhados em builds `release`.
- [ ] Revisar mensagens de erro para não expor detalhes internos da API.
- [ ] Verificar se builds já publicados registram dados sensíveis em ferramentas externas de monitoramento.

### Fluxo de farmácia existente

- [x] Remover ou desabilitar temporariamente a opção "Farmácia já cadastrada" no cadastro público.
- [ ] Exibir uma orientação segura para o responsável entrar em contato com o suporte enquanto a API não estiver disponível.
- [x] Impedir chamadas para rotas inexistentes em produção.
- [x] Remover a tela administrativa de solicitações da navegação ou marcá-la como indisponível sem permitir ações.
- [x] Corrigir o contrato que atualmente envia CNPJ no campo `CPF`.

### Estabilidade mínima

- [x] Atualizar o teste da tela inicial para considerar a restauração de sessão.
- [ ] Garantir que uma sessão inválida volte ao login sem loop ou tela vazia.
- [ ] Corrigir textos com codificação corrompida.
- [ ] Confirmar que login, logout e recuperação de senha funcionam em Android, iOS e Web.

### Critérios de aceite da prioridade 0

- Nenhum token, senha ou documento aparece nos logs.
- Nenhuma opção visível chama rota `404` conhecida.
- `flutter analyze` não apresenta erros.
- Todos os testes existentes passam.
- Cadastro de cliente, login e recuperação de senha passam por teste manual em homologação.

## Prioridade 1 - Cadastro de usuários e farmácias

### Definição dos fluxos

- [ ] Documentar claramente os perfis `customer`, `pharmacy_admin` e `app_admin`.
- [ ] Definir quem pode criar uma farmácia e quem pode criar usuários administrativos.
- [ ] Definir se a criação pública de uma nova farmácia exige aprovação da SaveMed.
- [ ] Definir o estado inicial da farmácia: pendente, ativa, rejeitada, suspensa ou inativa.
- [ ] Definir o comportamento para CNPJ já cadastrado.
- [ ] Definir o processo para troca do administrador responsável.

### Cadastro público de nova farmácia

- [ ] Transformar o formulário em etapas curtas: responsável, farmácia, contato e segurança.
- [ ] Explicar antes do envio se a conta será ativada imediatamente ou ficará pendente.
- [x] Validar nome, e-mail, CNPJ, telefone, CEP, cidade e UF antes da chamada de API.
- [x] Aplicar máscaras consistentes e enviar valores normalizados.
- [x] Validar e-mail e força mínima da senha.
- [x] Exibir requisitos da senha antes do envio.
- [x] Permitir mostrar ou ocultar senha e confirmação.
- [x] Bloquear envios duplicados enquanto a requisição estiver em andamento.
- [ ] Preservar os dados preenchidos em erros recuperáveis.
- [ ] Exibir confirmação com próximo passo objetivo após sucesso.
- [ ] Tratar e-mail, CNPJ e telefone duplicados com mensagens específicas.
- [ ] Substituir a criação em duas chamadas por uma operação atômica no backend.
- [ ] Enquanto não houver operação atômica, registrar e tratar explicitamente farmácias órfãs.

### Associação a farmácia existente

- [ ] Criar endpoint de solicitação de acesso no backend.
- [ ] Definir payload oficial com documento do responsável e `PHARMACY_ID`.
- [ ] Definir se a lista pública pode expor nome, cidade e UF das farmácias.
- [ ] Criar busca por nome, CNPJ parcial, cidade ou identificador seguro.
- [ ] Evitar uma lista extensa em `DropdownButtonFormField`.
- [ ] Exibir dados suficientes para diferenciar filiais com nomes iguais.
- [ ] Criar status da solicitação: pendente, aprovada, rejeitada, cancelada ou expirada.
- [ ] Impedir solicitações duplicadas para o mesmo e-mail e farmácia.
- [ ] Definir validade e armazenamento seguro da senha antes da aprovação.
- [ ] Preferir convite ou criação de senha após aprovação, evitando guardar senha de solicitação pendente.
- [ ] Notificar solicitante e administradores nas mudanças de status.

### Gerenciamento administrativo de usuários

- [ ] Separar visualmente "Nova farmácia" de "Novo usuário de farmácia".
- [ ] Permitir criar usuário dentro do contexto da farmácia selecionada.
- [x] Ocultar campos de senha em criação e redefinição.
- [ ] Preferir convite por e-mail em vez de senha temporária definida pelo administrador.
- [ ] Exigir troca de senha no primeiro acesso quando senha temporária for mantida.
- [ ] Exibir status do usuário: ativo, pendente, bloqueado ou inativo.
- [ ] Permitir ativar, desativar e reenviar convite.
- [ ] Impedir que o último administrador ativo de uma farmácia seja removido sem substituto.
- [x] Exigir confirmação para ações destrutivas ou irreversíveis.
- [ ] Registrar auditoria de criação, aprovação, bloqueio e redefinição de senha.

### Fila de solicitações

- [ ] Implementar rotas de listar, detalhar, aprovar e rejeitar solicitações.
- [ ] Adicionar filtros por status, farmácia, data, nome e e-mail.
- [ ] Mostrar documento mascarado e dados essenciais para conferência.
- [ ] Exigir justificativa opcional ou obrigatória conforme a decisão.
- [ ] Atualizar a lista sem perder filtros e posição.
- [ ] Evitar aprovação duplicada por concorrência.
- [ ] Exibir histórico da decisão e administrador responsável.

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
- [ ] Exibir erros junto ao campo correspondente.
- [ ] Exibir mensagem geral somente para erros não associados a um campo.
- [ ] Aplicar `Form`, `FormField` e validadores reutilizáveis.
- [ ] Descartar `TextEditingController` após o fechamento dos formulários.
- [x] Confirmar exclusão de farmácia, produto, categoria e item de estoque.
- [ ] Informar consequências antes de inativar uma farmácia.
- [ ] Diferenciar sucesso, aviso, validação e falha de conexão.

### Gerenciamento de farmácias

- [ ] Validar CNPJ e impedir duplicidade.
- [x] Validar telefone, CEP, UF e campos obrigatórios.
- [x] Normalizar valores antes de montar o payload.
- [ ] Buscar endereço por CEP com opção de correção manual.
- [ ] Separar dados cadastrais, operação, entrega e usuários em seções ou abas.
- [ ] Exibir claramente o status da farmácia e o motivo de inativação.
- [ ] Definir permissões de edição para `app_admin` e `pharmacy_admin`.
- [ ] Impedir que administrador de farmácia altere dados fora de seu escopo.
- [ ] Usar inativação lógica quando houver pedidos ou vínculos históricos.

### Categorias, produtos e estoque

- [x] Substituir campos de ID numérico por seletores com nome e busca.
- [ ] Filtrar categorias, produtos e estoque pela farmácia do usuário.
- [ ] Garantir isolamento de dados no backend, não apenas na interface.
- [x] Validar preço, preço original, estoque e distância de entrega.
- [ ] Usar formatação monetária brasileira.
- [x] Evitar preços negativos, estoque negativo e relações inexistentes.
- [ ] Mostrar unidade, disponibilidade e última atualização.
- [ ] Permitir estados vazios com ação apropriada.
- [x] Adicionar paginação local para listas grandes.

### Produtos, usuários e promoções - revisão de 10/07/2026

- [x] Incluir marca, unidade, EAN e exigência de receita no cadastro de produto.
- [x] Validar EAN opcional entre 8 e 14 dígitos.
- [x] Permitir criar operador ou administrador vinculado à farmácia.
- [x] Criar módulo administrativo de promoções com produto, farmácia, percentual e período.
- [x] Validar percentual, datas e vínculo do produto com a farmácia.
- [x] Exibir estados agendada, ativa e encerrada e confirmar exclusão.
- [ ] Implementar upload de imagem do produto e da promoção com `multipart/form-data`.
- [ ] Permitir vincular princípios ativos ao produto.
- [ ] Implementar ativação, inativação e remoção de usuários após o backend oferecer essas rotas.
- [ ] Proteger no backend as rotas administrativas de farmácias, usuários, categorias, produtos, estoque e promoções.
- [x] Unificar promoções da vitrine: `/inventory/highlights` prioriza promoções ativas com estoque e preço promocional, mantendo itens recentes como fallback compatível com o aplicativo antigo.
- [x] Impedir promoções sobrepostas para o mesmo produto e validar o vínculo com o estoque da farmácia no backend.
- [x] Exigir autenticação e escopo de farmácia para criar, editar, excluir e enviar imagens de promoções.
- [x] Proteger a listagem de usuários por farmácia e a criação de usuários administrativos adicionais.
- [ ] Definir no backend se `pharmacy_user` pode acessar o painel e quais operações esse perfil pode executar.

### Pedidos

- [x] Substituir campos livres de status por opções permitidas pelo backend.
- [x] Definir transições válidas de pedido e pagamento.
- [ ] Exigir confirmação e justificativa para estorno.
- [ ] Exibir detalhes do pedido antes de ações financeiras.
- [ ] Impedir ações incompatíveis com o status atual.
- [ ] Atualizar o pedido após alteração sem recarregar toda a aplicação.

### Navegação e responsividade

- [ ] Garantir acesso ao menu lateral em larguras móveis.
- [ ] Ocultar o botão de menu quando não houver `Drawer` disponível.
- [ ] Testar tabelas e ações em telas pequenas sem corte ou sobreposição.
- [ ] Manter filtros e seção selecionada ao voltar de um formulário.
- [ ] Oferecer estados de carregamento, vazio, erro e tentativa novamente em todas as páginas.
- [ ] Revisar foco, teclado, ordem de tabulação e leitores de tela.
- [ ] Adicionar rótulos semânticos a botões apenas com ícone.

## Prioridade 3 - Arquitetura e manutenção

### Modularização

- [x] Dividir `admin_page.dart` por funcionalidade.
- [x] Criar módulos separados para visão geral, farmácias, usuários, categorias, produtos, estoque e pedidos; solicitações permanecem removidas até existir backend.
- [x] Separar componentes visuais, estado, validação e acesso a serviços.
- [ ] Criar modelos tipados para usuário, farmácia, solicitação, produto, estoque e pedido.
- [ ] Remover o uso disseminado de `Map<String, dynamic>` nas fronteiras principais.
- [x] Centralizar decodificação, validação de status e erros das respostas da API.
- [x] Criar uma representação tipada para papéis e status.
- [x] Evitar comparações de papéis e status por strings espalhadas.

### Cliente HTTP e erros

- [x] Criar um resultado padronizado para sucesso e erro da API.
- [x] Tratar respostas que não sejam JSON sem lançar erro de decodificação secundário.
- [x] Adicionar timeout às requisições.
- [ ] Mapear ausência de conexão, timeout, autenticação expirada e erro de servidor.
- [x] Centralizar tratamento de `401` e encerramento de sessão.
- [ ] Evitar mensagens técnicas como `PHARMACY_ID` para usuários finais.
- [ ] Adicionar identificador de correlação seguro para suporte.
- [ ] Avaliar retry somente para operações idempotentes.

### Estado e ciclo de vida

- [ ] Garantir que `loading` seja finalizado mesmo quando a restauração de sessão falhar inesperadamente.
- [ ] Evitar uso de `BuildContext` após operações assíncronas sem verificar `mounted`.
- [x] Impedir múltiplos carregamentos simultâneos da mesma lista.
- [x] Preservar filtros e paginação em atualizações.
- [x] Cancelar ou ignorar respostas obsoletas de buscas.

### Qualidade do código

- [x] Corrigir todos os avisos relevantes do `flutter analyze`.
- [x] Migrar controles `Radio` depreciados para a API atual.
- [x] Remover declarações e imports não utilizados.
- [ ] Padronizar nomes, textos e terminologia: farmácia, loja, responsável e administrador.
- [x] Corrigir o nome do pacote para o padrão Dart em uma versão planejada, avaliando impacto.
- [ ] Configurar formatação e análise estática no CI.

## Prioridade 4 - Testes e validação

### Testes unitários

- [x] Validadores de CPF, CNPJ, telefone, e-mail e senha.
- [ ] Normalização dos payloads enviados à API.
- [x] Mapeamento de erros HTTP para mensagens de interface.
- [ ] Regras de papéis, permissões e escopo de farmácia.
- [ ] Transições de status de solicitação e pedido.

### Testes de widgets

- [x] Tela inicial sem sessão.
- [ ] Restauração de sessão válida e inválida.
- [ ] Cadastro de cliente.
- [ ] Cadastro de nova farmácia.
- [ ] Solicitação de acesso a farmácia existente quando a API estiver pronta.
- [ ] Validação e preservação dos campos após erro.
- [ ] Criação, convite, bloqueio e redefinição de usuário administrativo.
- [ ] Responsividade do painel em celular, tablet e desktop.
- [ ] Estados de carregamento, vazio e erro das listas.

### Testes de integração

- [ ] Contratos frontend/backend executados contra homologação.
- [ ] Criação atômica de farmácia e primeiro administrador.
- [ ] Aprovação e rejeição de solicitação.
- [ ] Expiração de sessão durante ação administrativa.
- [ ] Falha de rede e repetição segura.
- [ ] Isolamento entre duas farmácias distintas.
- [ ] Permissões do administrador geral e administrador de farmácia.

### Testes manuais antes da publicação

- [ ] Android em distribuição interna.
- [ ] iOS via TestFlight.
- [ ] Web nos navegadores suportados.
- [ ] Teclado físico e navegação por foco.
- [ ] Tamanhos de fonte aumentados.
- [ ] Conexão lenta e modo offline.
- [ ] Atualização a partir da versão atualmente publicada, preservando a sessão quando válida.
- [ ] Login com conta de cliente, administrador geral e administrador de farmácia.

## Prioridade 5 - Experiência geral do frontend

- [ ] Revisar home, busca, listagem e detalhe de produtos.
- [ ] Revisar carrinho, checkout, endereços e pagamento.
- [ ] Corrigir o uso assíncrono de contexto no detalhe de produto.
- [ ] Validar documentos exibidos no perfil e checkout.
- [ ] Não assumir que todo usuário possui `CPF` quando há perfis de farmácia.
- [ ] Revisar mensagens de erro e sucesso em linguagem consistente.
- [ ] Revisar contraste, tamanho de toque e estados de foco.
- [ ] Garantir que textos não sejam cortados em telas pequenas.
- [ ] Revisar comportamento do cabeçalho e rodapé no Web.
- [ ] Medir tempo de inicialização, carregamento de imagens e listas.
- [ ] Otimizar somente após medir gargalos reais.

## Dependências obrigatórias do backend

- [ ] Endpoint transacional para criar farmácia e primeiro administrador.
- [ ] Endpoint para solicitar acesso a farmácia existente.
- [ ] Endpoints para listar, detalhar, aprovar e rejeitar solicitações.
- [ ] Contrato oficial de documentos para cliente e responsável de farmácia.
- [ ] Estados oficiais de farmácia, usuário e solicitação.
- [ ] Autorização por papel e farmácia em todas as rotas administrativas.
- [ ] Paginação e filtros nas listagens administrativas.
- [ ] Auditoria de ações sensíveis.
- [ ] Convite e definição segura de senha.
- [ ] Respostas de erro padronizadas com código estável e campos inválidos.

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
- [ ] Publicar mudanças de API com rollback imediato para a revisão anterior.
- [ ] Monitorar respostas `400`, `401`, `403` e `500` por versão do aplicativo após a publicação.

- [ ] Contratos validados em homologação.
- [ ] Migrações de backend compatíveis com versões antigas do aplicativo.
- [x] `flutter analyze` aprovado.
- [x] Testes automatizados aprovados.
- [ ] Testes manuais Android, iOS e Web aprovados.
- [ ] Nenhum dado sensível nos logs.
- [ ] Número de versão e build atualizados.
- [ ] Notas da versão preparadas.
- [x] Plano de rollback definido: Cloud Run `api-savemed-00024-s4f` e backup Hostinger de 11/07/2026.
- [ ] Monitoramento de login, cadastro e erros HTTP preparado.
- [ ] Acompanhamento reforçado após a publicação.

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

- [x] Corrigir lista de produtos vazia quando medicamentos não possuem subcategoria. O modelo agora aceita `SUBCATEGORY_ID` nulo, conforme o contrato da API.
- [x] Ler `REQUIRES_RX` sem remover a compatibilidade com o campo legado `REQUIRES_PRESCRIPTION`.
- [x] Aceitar preço, estoque e identificadores serializados como número ou texto.
- [x] Cobrir o parsing do inventário publicado com testes de regressão.
- [x] Manter aplicativos antigos compatíveis pela API: inventários sem subcategoria são serializados como `SUBCATEGORY_ID: 0`, sem alterar o valor nulo armazenado no banco.
- [x] Publicar e validar a compatibilidade na revisão Cloud Run `api-savemed-00026-kp6` em 22/07/2026.

- A API pública de farmácias responde normalmente.
- A rota de solicitação de acesso a farmácia existente não existe na API publicada.
- A rota de listagem de solicitações administrativas não existe na API publicada.
- O fluxo confuso de farmácia existente foi removido enquanto não houver contrato de API publicado.
- Logs de headers, tokens, senhas e corpos sensíveis foram removidos do cliente HTTP.
- A suíte automatizada cobre respostas HTTP, papéis, validações, status de pedidos e cadastro responsivo.
- `flutter analyze` e o build web de produção estão aprovados em 10/07/2026.
- A área administrativa foi dividida por domínio, incluindo promoções.
- Rotas administrativas críticas ainda precisam de autenticação e autorização obrigatórias no backend.
- Promoções cadastradas ainda não alimentam a vitrine até a unificação entre `/highlights` e `/inventory/highlights`.
