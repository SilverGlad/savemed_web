import 'package:flutter/material.dart';
import '../../core/widgets/savemed_header.dart';
import '../profile/profile_page.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/savemed_button.dart';

class PaymentResultPage extends StatelessWidget {
  final bool success;
  final int? orderId;

  const PaymentResultPage({super.key, required this.success, this.orderId});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SaveMedHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
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
                          Semantics(
                            header: true,
                            liveRegion: true,
                            child: Text(
                              success
                                  ? 'Pagamento aprovado!'
                                  : 'Erro no pagamento',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                          if (orderId != null) Text('Pedido #$orderId'),
                          if (success) ...[
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ProfilePage(initialTab: 2),
                                ),
                              ),
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('Acompanhar pedido'),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: SaveMedButton(
                              label: success
                                  ? 'Continuar comprando'
                                  : 'Voltar ao pagamento',
                              onPressed: () {
                                if (success) {
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                } else {
                                  Navigator.of(context).maybePop();
                                }
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
        ],
      ),
    );
  }
}
