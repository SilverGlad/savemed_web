import 'package:flutter/material.dart';
import '../../core/widgets/savemed_header.dart';
import '../../core/widgets/savemed_footer.dart';
import '../../core/widgets/savemed_button.dart';

class PaymentResultPage extends StatelessWidget {
  final bool success;

  const PaymentResultPage({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(
        children: [
          SaveMedHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile ? double.infinity : 420,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 24 : 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            success ? Icons.check_circle : Icons.error,
                            color: success ? Colors.green : Colors.red,
                            size: isMobile ? 64 : 72,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            success
                                ? 'Pagamento aprovado!'
                                : 'Erro no pagamento',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            success
                                ? 'Seu pedido foi confirmado com sucesso.'
                                : 'Não foi possível processar o pagamento.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: SaveMedButton(
                              label: success
                                  ? 'Voltar para a loja'
                                  : 'Tentar novamente',
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SaveMedFooter(),
        ],
      ),
    );
  }
}
