# Projeto de reserva de estoque para PIX

## Problema

O checkout atual cria o pedido e reduz o estoque antes da confirmacao do PIX.
Uma cobranca abandonada pode manter unidades indisponiveis. Alterar essa regra
diretamente quebraria expectativas dos aplicativos publicados, portanto a
evolucao deve ser aditiva.

## Modelo proposto

Criar `INVENTORY_RESERVATION` com pedido, item de estoque, quantidade, estado
(`active`, `consumed`, `released`, `expired`), `EXPIRES_AT`, criacao e
atualizacao. A soma de reservas ativas deve compor a disponibilidade sem alterar
o estoque fisico.

## Fluxo

1. O checkout bloqueia as linhas de estoque em uma transacao.
2. Para PIX, cria reservas com expiracao e nao reduz `STOCK`.
3. A confirmacao do provedor consome a reserva e reduz o estoque atomicamente.
4. Cancelamento, falha ou expiracao libera a reserva de forma idempotente.
5. Cartao aprovado continua consumindo o estoque na confirmacao do pagamento.
6. Um job expira reservas vencidas; leituras tambem podem fazer limpeza
   oportunista.

## Compatibilidade e entrega

Os campos atuais do pedido permanecem. Aplicativos antigos continuam lendo o
mesmo estoque disponivel calculado pela API. A ativacao deve usar feature flag,
metricas de reservas ativas/expiradas e teste concorrente para impedir venda
acima do estoque. Nao implementar a mudanca sem webhook de pagamento idempotente
e rotina de reconciliacao.
