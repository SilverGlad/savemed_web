# Conteúdo editorial do app

O app mantém um fallback local para continuar funcionando sem rede e tenta carregar os blocos publicados em `/api/content`.

## Administração

Somente usuários com papel `app_admin` veem a seção **Conteúdo do app**. Cada bloco possui:

- identificador estável (`SLUG`);
- título, subtítulo e texto de apoio;
- botão opcional e destino;
- ordem e status de publicação;
- imagem opcional em PNG, JPEG ou WebP, limitada pela política de upload da API.

As alterações são aditivas e não mudam as rotas antigas. Se a API estiver indisponível ou ainda não tiver a tabela `CONTENT_BLOCK`, o carrossel usa as imagens editoriais embarcadas no app.

## API

- `GET /api/content`: blocos ativos para clientes;
- `GET /api/content?includeInactive=true`: todos os blocos para o administrador geral autenticado;
- `POST /api/content`, `PUT /api/content/:id`, `DELETE /api/content/:id`: gestão protegida por `app_admin`;
- `POST /api/content/:id/upload`: upload protegido e validado da imagem.
