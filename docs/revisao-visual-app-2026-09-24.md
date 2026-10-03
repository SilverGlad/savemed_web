# Revisão visual e UX do app SaveMed

Data: 24/09/2026. Status: diagnóstico registrado; nenhuma correção aplicada nesta revisão.

## Escopo e método

Foco no cliente padrão: descoberta de produtos, categorias, busca, conta, carrinho e compra, em navegador de celular, navegador de computador e futuro teste do APK. O gestor foi considerado complementarmente, pelo impacto nas imagens e no conteúdo publicado.

Foram inspecionados o código local e o app publicado em https://savemed.app/savemed/, usando Edge headless com viewports de 320 x 568, 390 x 844, 768 x 1024, 1024 x 768 e 1440 x 900. As dimensões foram verificadas em telas específicas, não em todas as combinações. Capturas em [visual-audit-2026-09-24](visual-audit-2026-09-24/).

O catálogo foi acessado pela função administrativa “Visualizar app”, com sessão isolada. A faixa administrativa e o nome do administrador nas capturas não representam o cliente comum; as conclusões sobre o restante do layout estão apoiadas também nos componentes compartilhados. Login, cadastro e recuperação foram observados sem sessão. Não houve cadastro, alteração de produto, pedido, pagamento ou envio de recuperação.

Legenda: **V** = observado no navegador; **C** = identificado no código; **P** = precisa de validação adicional. P1 = prejudica tarefa essencial ou confiança; P2 = melhoria importante de compreensão e consistência; P3 = refinamento. Não foi executado APK, Safari/iOS, teclado virtual, TalkBack ou teste em aparelho físico. Emulação de largura não comprova qualidade nesses ambientes.

## Avaliação geral

A marca é reconhecível, os controles principais usam linguagem familiar e há boas bases de validação de formulários. Entretanto, a experiência ainda se aproxima de uma página institucional longa: grandes apresentações e rodapés competem com o catálogo e as ações. A prioridade deve ser recuperar área útil no celular e estabilizar os tamanhos intermediários antes de acrescentar decoração.

A existência de uma imagem na API não significa que o produto tenha uma foto adequada. As capturas mostram ilustrações de categorias no lugar das embalagens em vários produtos de teste. Isso corrige a ausência técnica de imagem, mas não resolve a apresentação comercial.

## Pontos a preservar

| Área | O que está bom | Evidência e ressalva |
| --- | --- | --- |
| Marca | Logo identificável, verde como cor principal, laranja para destaque e superfícies claras. | V: login, catálogo e detalhe. Há exceções de paleta nas etapas de compra. |
| Formulários | Campos rotulados, ícones conhecidos, mostrar/ocultar senha e requisitos explícitos no cadastro. | V/C: cadastro desktop e `auth_page.dart`, `password_requirements.dart`. Preservar requisitos visíveis. |
| Recuperação | Um campo inicial de e-mail e caminho “Já tenho um código”. | V: modal mobile. Envio e recebimento não testados nesta revisão. |
| Categorias | Filtro acessível no celular e painel lateral no desktop. | V: categorias em 390 e 1024 px. O botão “Filtrar categorias” já aparece. |
| Catálogo | Preço e ação de compra identificáveis; imagem com proporção preservada no detalhe. | V: categorias e detalhe. A qualidade do conteúdo das imagens ainda precisa melhorar. |
| Carrinho | Farmácia, quantidade e subtotal são explicitados; confirmação ao trocar de farmácia existe. | V/C: carrinho vazio e `confirm_clear_cart_dialog.dart`. |
| Organização da conta | Abas de dados, endereços e pedidos são uma divisão compreensível. | V/C: perfil. O rodapé compromete a área útil mobile. |
| Estados | Há tratamento de catálogo vazio, erro e ação de tentar novamente. | C: `home_page.dart` e grades. Estados de rede não foram simulados nesta revisão. |
| Pagamento | Pix copia e cola, estado de espera e seleção identificável do método. | C: `payment_page.dart`. Não foi gerada cobrança. |
| Gestor | Componentes compartilhados de ações e preview de imagem permitem padronização. | C: `admin_widgets.dart`. Não equivale a aprovação visual de todas as abas. |

## Prioridade alta

### VIS-01 — Rodapé consome a área do perfil [P1, V/C]

Em 390 x 844, quase toda a região abaixo das abas é ocupada pelo rodapé. O formulário fica reduzido a uma faixa que mal mostra o rótulo de e-mail. O rodapé está fora da área rolável, depois do `Expanded`. A mesma estrutura aparece na tela de resultado do pagamento, ainda não observada em execução.

- Evidência: [perfil mobile](visual-audit-2026-09-24/perfil-mobile-390.png), [desktop](visual-audit-2026-09-24/perfil-desktop-1440.png).
- Fontes: `lib/features/profile/profile_page.dart`, `lib/features/payment/payment_result_page.dart` e `lib/core/widgets/savemed_footer.dart`.
- Melhoria: colocar conteúdo institucional no fluxo de rolagem ou usar versão compacta no app; priorizar dados e ações.
- Aceite: dados, endereços e pedidos utilizáveis em 320 x 568, inclusive com teclado aberto, sem rodapé comprimindo a tarefa.

### VIS-02 — Login mobile deixa a ação principal abaixo da primeira tela [P1, V/C]

Em 390 x 844, a apresentação anterior ao formulário ocupa cerca de 500 px; a senha e “Entrar” ficam abaixo da dobra. No cadastro desktop, a coluna promocional deixa uma grande região vazia e o botão final exige rolagem.

- Evidência: [login mobile](visual-audit-2026-09-24/login-mobile-390.png), [cadastro desktop](visual-audit-2026-09-24/cadastro-desktop-1440.png).
- Fonte: `lib/features/auth/auth_page.dart`.
- Melhoria: reduzir a apresentação e priorizar formulário; deixar o acesso de farmácia secundário para quem está comprando; trocar “Login obrigatório” por identificação natural da tela.
- Aceite: login acessível com pouca rolagem em celulares pequenos; teclado não esconde o campo focado nem impede envio; cadastro mantém requisitos e erros junto dos campos.

### VIS-03 — Busca fica comprimida na transição para desktop [P1, V/C]

Em 768 px, o cabeçalho assume linha única e o campo de busca fica praticamente do tamanho da lupa. Marca, conta e margens competem com a ação central do catálogo. O problema pode variar com o tamanho do nome do usuário.

- Evidência: [categoria em 768 px](visual-audit-2026-09-24/categoria-tablet-768.png).
- Fonte: `lib/core/widgets/savemed_header.dart`, breakpoint de 760 px e padding desktop.
- Melhoria: escolher a composição pelo espaço disponível; preservar largura útil para digitação, mantendo busca em segunda linha quando necessário.
- Aceite: busca legível e operável em 700, 760, 768, 820, 900 e 1024 px, com nomes curtos e longos.

### VIS-04 — Imagens não representam os produtos [P1, V/C]

Perfume, fraldas, álcool e shampoo usam artes de categoria, inclusive com texto embutido (“Perfumaria”, “Mãe & Bebê”). Em miniatura esse texto é ilegível; no detalhe a imagem parece uma categoria ampliada. Não concluir que “as fotos estão resolvidas” apenas porque os endpoints respondem.

- Evidência: [catálogo mobile](visual-audit-2026-09-24/catalogo-mobile-390.png), [detalhe desktop](visual-audit-2026-09-24/produto-desktop-1440.png).
- Melhoria: fotos correspondentes ao produto e sua apresentação, com fundo e enquadramento consistentes; separar assets de categoria e produto no cadastro.
- Aceite: nome, embalagem, variante e volume coerentes; foto inspecionável em lista e detalhe, sem legendas de categoria incorporadas.

### VIS-05 — Perfil confirma salvamento sem persistir [P1, C]

O botão “Salvar alterações” em `_ProfileForm` apenas mostra o SnackBar “Dados atualizados”; não chama persistência. É um problema de confiança da interface, mesmo não sendo estritamente estético. Nenhum salvamento foi acionado nesta revisão.

- Fonte: `lib/features/profile/profile_page.dart`, callback de “Salvar alterações”.
- Melhoria: associar confirmação ao resultado real, exibir andamento e erro e manter os dados digitados em falha.
- Aceite: alteração confirmada continua disponível após reabrir a sessão.

### VIS-06 — Área segura e retorno no APK precisam ser comprovados [P1, C/P]

As principais telas usam `Scaffold` com conteúdo direto, sem proteção explícita comum por `SafeArea`; a presença de `SafeArea` em uma tela de erro de sessão não protege o restante. Detalhe e carrinho também não exibem uma ação clara de voltar equivalente à navegação do navegador.

- Fontes: `home_page.dart`, `product_list_page.dart`, `product_detail_page.dart`, `cart_page.dart` e `main.dart`.
- Melhoria: tratar status bar, recortes, navegação por gestos, teclado, orientação e retorno consistentemente.
- Aceite: testar APK em aparelho físico, com gestos e botões, fonte ampliada e teclado aberto; nenhuma ação sob barras do sistema. Não classificado como falha visual reproduzida em APK nesta auditoria.

## Melhorias por tela e componente

| ID / prioridade | Tela | Constatação e melhoria | Evidência |
| --- | --- | --- | --- |
| VIS-07 / P2 | Home | Apresentação longa + banner + categorias adiam os produtos. Reduzir texto introdutório e dar prioridade a busca, local de entrega, categorias e itens. A faixa administrativa da captura deve ser desconsiderada ao dimensionar a home do cliente. | V/C: [home mobile](visual-audit-2026-09-24/home-mobile-390.png); `home_page.dart`. |
| VIS-08 / P2 | Textos | Remover frases sobre o próprio design: “navegação mais leve”, “interface pensada primeiro para o celular”, “cuidado rápido e bonito”. Substituir por informações de compra relevantes; não repetir subtítulo genérico em todas as vitrines. | V/C: home, header, carrinho, checkout, `inventory_section.dart`. |
| VIS-09 / P2 | Categorias | “Medicamentos” quebra como “Medicamen/tos”; “Vitaminas e suplementos” é truncado. Ícones são pequenos dentro de grandes áreas e há desenhos repetidos. Usar símbolos sem texto embutido e largura/linhas compatíveis com os nomes. | V: [catálogo mobile](visual-audit-2026-09-24/catalogo-mobile-390.png); `category_section.dart`. |
| VIS-10 / P2 | Grade | Em 768 px, dois cards ficam muito altos, com grande vazio entre descrição e preço. Duas colunas fixas no celular e proporção baseada no viewport não consideram fonte ampliada ou espaço restante após sidebar. Dimensionar pela área real e conteúdo, com uma coluna quando necessário. | V/C: [tablet](visual-audit-2026-09-24/categoria-tablet-768.png), `inventory_grid.dart`, `inventory_grid_box.dart`. |
| VIS-11 / P2 | Vitrines | Rolagem horizontal mobile mostra parte do próximo card, o que ajuda a descobrir mais itens, mas há muita moldura/padding. No desktop faltam controles explícitos ou “Ver todos”. Padronizar acesso ao catálogo completo e melhorar uso por mouse e teclado. | V/C: `inventory_section.dart`; [catálogo mobile](visual-audit-2026-09-24/catalogo-mobile-390.png). |
| VIS-12 / P2 | Organização | “Medicamentos” inclui perfume e fraldas. “Mais vendidos” é carregado com `order: 'price_desc'`, que não representa vendas. “Ofertas em destaque” mostra itens sem desconto na amostra. Alinhar títulos ao critério real; separar recomendação, novidade e promoção. | V/C: `home_page.dart`, `home_inventory_controller.dart`, `inventory_service.dart`. |
| VIS-13 / P2 | Produto | O detalhe tem preço e CTA claros, mas falta evidência visual de quem vende, entrega/retirada, apresentação e dados específicos do produto. A imagem domina a primeira tela; avaliar barra de compra persistente no mobile. | V/C: [detalhe mobile](visual-audit-2026-09-24/produto-mobile-390.png), `product_detail_page.dart`. |
| VIS-14 / P2 | Produto | No desktop, imagem e informações somam 864 px, mas descrição usa até 960 px: bordas direitas não alinham. A composição é rígida e há muito vazio. Uniformizar a grade e permitir colunas proporcionais. | V/C: [detalhe desktop](visual-audit-2026-09-24/produto-desktop-1440.png). |
| VIS-15 / P2 | Identificação da oferta | Cards de catálogo não identificam a farmácia vendedora. Com várias farmácias, produtos iguais podem parecer duplicados e a troca de carrinho vira surpresa. Mostrar vendedor e contexto suficiente para comparar. | C: `inventory_card.dart`, `product_detail_page.dart`. Produção observada tem uma farmácia. |
| VIS-16 / P2 | Busca | Overlay só aparece com resultados; não há estado específico claro de “nenhum resultado” nessa interface. Limite de seis itens sem acesso explícito a todos. Revisar largura após resize, fechamento, loading e área restante com teclado. | C/P: `savemed_header.dart`; não foram simuladas todas as respostas da busca. |
| VIS-17 / P2 | Carrinho | Mesmo vazio, mostra grande hero, métricas zeradas e explicações antes da tarefa. O verde turquesa diverge da paleta principal. Usar estado vazio compacto com acesso direto ao catálogo; no carrinho preenchido priorizar itens, entrega e total. | V/C: [carrinho vazio](visual-audit-2026-09-24/carrinho-vazio-mobile-390.png), `cart_page.dart`. |
| VIS-18 / P2 | Checkout | Grandes resumos e textos introdutórios repetem o carrinho. Reduzir repetição e explicitar etapas, edição do endereço, modalidade de entrega e total antes da ação. Avaliar ação fixa mobile sem encobrir conteúdo. | C: `checkout_page.dart`, `cart_summary_card.dart`. Checkout preenchido não foi executado. |
| VIS-19 / P2 | Pagamento | Pix tem copia e cola, mas o QR Code fixo de 220 px, dentro de sucessivos paddings, é risco em 320 px. Priorizar copiar no celular; apresentar espera, expiração e falha claramente, sem confundir geração com aprovação. | C/P: `_PixPanel`, `payment_page.dart`. Não houve cobrança. |
| VIS-20 / P2 | Resultado | Tela de sucesso não apresenta número do pedido ou atalho direto para acompanhamento. “Tentar novamente” retorna à primeira rota, em vez de retomar claramente a tentativa. Rever ação e rodapé. | C: `payment_result_page.dart`. |
| VIS-21 / P2 | Rodapé | “Quem somos”, “Privacidade” e demais itens são `Text`, não links. Parecem destinos navegáveis, mas não levam a conteúdo. Reduzir rodapé em tarefas e disponibilizar destinos reais. | C: `savemed_footer.dart`; aparência nas capturas. |
| VIS-22 / P2 | Modais | Recuperação se adapta à largura, mas três ações ficam empilhadas à direita com pouco equilíbrio. Padronizar ação principal e secundárias. Endereço e cartão têm rolagem, mas precisam de checagem com teclado, erros e 200% de fonte. | V: [recuperação](visual-audit-2026-09-24/recuperacao-mobile-390.png); C/P: `address_modal.dart`, `add_card_modal.dart`. |
| VIS-23 / P2 | Navegação | Perfil/pedidos ficam dentro do menu da conta; header muda entre rolável na home e fixo nas outras telas. Avaliar navegação mobile persistente e header mais compacto nas etapas internas, com retorno visível. | V/C: header e páginas. Proposta de UX, não requisito de ter barra inferior obrigatoriamente. |
| VIS-24 / P2 | Consistência | Fundos creme e cinza frio, verde oliva e turquesa, raios de 8/16/24/28/30/999 e margens de 12/24/32/64 aparecem em contextos equivalentes. Definir escala comum; reduzir superfícies dentro de superfícies. | V/C: temas, home, categoria, produto e carrinho. |
| VIS-25 / P2 | Acessibilidade | Há semântica e rótulos em vários controles. Ainda revisar targets, foco, nomes longos, 200% de fonte, dropdown de ordenação em `Row`, altura fixa de banners e labels das categorias. Não declarar conformidade só por testes de contraste existentes. | C/P: `order_bar.dart`, `banner_carousel.dart`, `category_section.dart`, `test/features/commerce/commerce_accessibility_test.dart`. |
| VIS-26 / P3 | Acabamento | Nomes e descrições de teste sem acentos (“Alcool”, “Hidratacao”, “protecao”, “Fragrancia”). Há textos embutidos nos assets de categoria que continuam aparecendo mesmo sem label no seletor. Revisar conteúdo real e imagens, além das strings do código. | V: capturas de catálogo e detalhe. |

## Gestor: registro complementar por código

O foco desta rodada foi a experiência do cliente. Não foram percorridas visualmente todas as abas administrativas; os itens abaixo são avaliação estrutural para revisão específica, não aprovação de telas.

- **Bom:** preview de imagem atual/selecionada, miniaturas compartilhadas, filtros e padrões de ações já existem.
- **Melhorar [P2]:** preview genérico de 180 px não representa necessariamente o recorte do banner no app. Mostrar proporção e prévia mobile/desktop do conteúdo antes de publicar (`_AdminImagePicker`).
- **Melhorar [P2]:** miniaturas usam `BoxFit.cover`, que pode cortar embalagens; produto precisa preservar objeto inteiro, banner precisa representar o recorte (`_AdminThumbnail`).
- **Melhorar [P2]:** seletor de categoria tem oito assets; os textos já desenhados dentro das imagens continuam visíveis e pequenos. Ao editar, `selectedIcon` inicia sem indicar o atual. Mostrar estado atual e separar ícone visual de nome acessível (`admin_categories.dart`).
- **Melhorar [P2]:** modal comum usa largura com desconto fixo e corpo limitado a 58% da tela. Conferir formulário curto, formulário longo, erros e teclado aberto; dimensionar pela tarefa (`_AdminFormDialog`).
- **Melhorar [P2]:** verificar ações desktop/mobile, inclusive exceções como “Inativar”, para uniformizar tamanho, posição, tooltip e área de toque sem esconder ações importantes.
- **Melhorar [P2]:** nomes, imagens e títulos comerciais inconsistentes precisam ser identificáveis no gestor; cadastro de imagem tecnicamente válido não basta como validação editorial.

## Matriz de cobertura e validação futura

| Cenário | Nesta rodada | Próxima validação necessária |
| --- | --- | --- |
| 320 x 568 | Categoria capturada. | Todos os fluxos, rodapé, fonte ampliada e teclado. |
| 390 x 844 | Login, recuperação, home, vitrine, categoria, detalhe, carrinho vazio e perfil. | Cliente padrão autenticado, carrinho preenchido, endereço, checkout e pagamento em homologação. |
| 768 x 1024 | Categoria capturada; busca comprimida e cards altos. | Auth, todas as transições de largura e modo paisagem. |
| 1024 x 768 | Categoria com sidebar capturada. | Compra completa, modais e foco de teclado. |
| 1440 x 900 | Login, cadastro, categoria, detalhe e perfil capturados. | Home completa, busca e compra, janela ainda mais larga. |
| APK Android | Não executado. | SafeArea, teclado real, botão/gesto voltar, status bar, TalkBack, fonte do sistema e retomada. |
| Navegador mobile real | Não executado. | Chrome Android e Safari iOS, barras dinâmicas, zoom, autofill e retorno após trocar para app bancário. |
| Rede/estados | Leitura do código. | Carregamento lento, ausência de imagem, catálogo vazio, falha, recuperação e manutenção do espaço no layout. |

## Ordem sugerida para futura implementação

1. Resolver área útil do perfil/resultado, acesso ao login e header intermediário; corrigir o feedback falso de salvar perfil.
2. Uniformizar margens, grids, tipografia e estados responsivos; validar APK e fonte ampliada.
3. Corrigir imagens e organização do catálogo; aproximar produtos e ações da primeira tela.
4. Reduzir repetição no carrinho/checkout e melhorar navegação, confirmação e acompanhamento.
5. Refinar modais, prévias editoriais, acessibilidade e acabamento; repetir capturas nos mesmos tamanhos.

Esta revisão não alterou a interface, API ou dados de produção e não publicou build. A documentação e as capturas são os artefatos desta rodada. Os testes automatizados citados em entregas anteriores não substituem estas evidências e não foram reexecutados para este diagnóstico documental.
