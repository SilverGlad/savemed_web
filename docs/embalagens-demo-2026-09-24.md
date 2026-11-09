# Embalagens ilustrativas de demonstração

Autorização: usuário aprovou embalagens ilustrativas para os produtos de teste em 24/09/2026.

## Escopo publicado

- Farmácia SaveMed Demo, ID 1: produtos 2 a 7 receberam imagens distintas e aviso na descrição: "Produto de teste. Embalagem ilustrativa de demonstração; não representa uma marca ou apresentação comercial real."
- Paracetamol (ID 1) preservado. Preços, estoque, categorias e pedidos não foram alterados.
- Imagens publicadas pelas rotas existentes `POST /medications/:id/upload` e descrições por `PUT /medications/:id`. Não houve alteração de código, schema ou contrato para clientes antigos.
- As seis imagens retornaram HTTP 200 e tiveram seus bytes comparados com os arquivos enviados.
- As seis descrições foram relidas e confirmadas com o aviso. Capturas no build local consumindo a API de produção confirmam miniaturas, editor e catálogo mobile: `visual-fixes-2026-09-24/embalagens-gestor-390.png`, `embalagens-editor-390.png` e `embalagens-app-390.png`.
- Originais anteriores preservados localmente em `.deployment-backups/demo-images-2026-09-24/` (fora do versionamento).
- Arquivos finais em `assets/images/demo-products/`. São ativos de catálogo enviados à API, não novos fallbacks embutidos no aplicativo.
- As embalagens são fictícias e não devem ser usadas para representar produtos comerciais reais. Substituir por fotos corretas antes de converter os registros em ofertas reais.
- Esta publicação de conteúdo não publica as alterações de interface ou a nova rota de perfil, que continuam com o status do relatório anterior.

## Geração

Ferramenta integrada `image_gen`, uma geração por produto, sem CLI/API externa. Prompts finais:

### Produto 2: vitamina-c-demo.png

Use case: product-mockup. Create one square raster product catalog illustration for a demo pharmacy app: a white cylindrical effervescent vitamin tube with a bright yellow cap; label 'VITAMINA C', '1 g'. Clean polished 3D illustrative packaging, entirely fictional, no real brand, no manufacturer or regulatory seals, no medical claims. Pure white background, soft minimal contact shadow, entire single package visible, centered occupying 75% of image height, no props. Large clean readable Portuguese typography. Prominent dark green text 'DEMONSTRAÇÃO' on the packaging and separate readable small caption 'EMBALAGEM ILUSTRATIVA' below the package. Distinct actual packaging shape, not a category icon. Output one image for this single product.

### Produto 3: protetor-solar-demo.png

Use case: product-mockup. Create one square raster product catalog illustration for a demo pharmacy app: an upright white sunscreen squeeze tube with yellow details and cap; label 'PROTETOR SOLAR', 'FPS 60'. Clean polished 3D illustrative packaging, entirely fictional, no real brand, no manufacturer or regulatory seals, no medical claims. Pure white background, soft minimal contact shadow, entire single package visible, centered occupying 75% of image height, no props. Large clean readable Portuguese typography. Prominent dark green text 'DEMONSTRAÇÃO' on the packaging and separate readable small caption 'EMBALAGEM ILUSTRATIVA' below the package. Distinct actual packaging shape, not a category icon. Output one image for this single product.

### Produto 4: shampoo-demo.png

Use case: product-mockup. Create one square raster product catalog illustration for a demo pharmacy app: a teal shampoo bottle with flip cap; label 'SHAMPOO', 'HIDRATAÇÃO', '200 ml'. Clean polished 3D illustrative packaging, entirely fictional, no real brand, no manufacturer or regulatory seals, no medical claims. Pure white background, soft minimal contact shadow, entire single package visible, centered occupying 75% of image height, no props. Large clean readable Portuguese typography. Prominent dark green text 'DEMONSTRAÇÃO' on the packaging and separate readable small caption 'EMBALAGEM ILUSTRATIVA' below the package. Distinct actual packaging shape, not a category icon. Output one image for this single product.

### Produto 5: alcool-gel-demo.png

Use case: product-mockup. Create one square raster product catalog illustration for a demo pharmacy app: a clear pump bottle of hand gel, pale blue details; label 'ÁLCOOL EM GEL', '70%', '500 ml'. Clean polished 3D illustrative packaging, entirely fictional, no real brand, no manufacturer or regulatory seals, no medical claims. Pure white background, soft minimal contact shadow, entire single package visible, centered occupying 75% of image height, no props. Large clean readable Portuguese typography. Prominent dark green text 'DEMONSTRAÇÃO' on the packaging and separate readable small caption 'EMBALAGEM ILUSTRATIVA' below the package. Distinct actual packaging shape, not a category icon. Output one image for this single product.

### Produto 6: fralda-demo.png

Use case: product-mockup. Create one square raster product catalog illustration for a demo pharmacy app: a soft rectangular pack of baby diapers, white with green and lavender details, no baby photograph; label 'FRALDA INFANTIL', 'M'. Clean polished 3D illustrative packaging, entirely fictional, no real brand, no manufacturer or regulatory seals, no medical claims. Pure white background, soft minimal contact shadow, entire single package visible, centered occupying 75% of image height, no props. Large clean readable Portuguese typography. Prominent dark green text 'DEMONSTRAÇÃO' on the packaging and separate readable small caption 'EMBALAGEM ILUSTRATIVA' below the package. Distinct actual packaging shape, not a category icon. Output one image for this single product.

### Produto 7: perfume-demo.png

Use case: product-mockup. Create one square raster product catalog illustration for a demo pharmacy app: a transparent rectangular perfume bottle with pale pink liquid and simple frosted cap; label 'PERFUME FLORAL', '100 ml'. Clean polished 3D illustrative packaging, entirely fictional, no real brand, no manufacturer or regulatory seals, no medical claims. Pure white background, soft minimal contact shadow, entire single package visible, centered occupying 75% of image height, no props. Large clean readable Portuguese typography. Prominent dark green text 'DEMONSTRAÇÃO' on the packaging and separate readable small caption 'EMBALAGEM ILUSTRATIVA' below the package. Distinct actual packaging shape, not a category icon. Output one image for this single product.
