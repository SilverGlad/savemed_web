import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

const double _shellMaxWidth = 1180;

class SaveMedFooter extends StatelessWidget {
  const SaveMedFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 900;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 24,
            0,
            isMobile ? 12 : 24,
            0,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 36,
                vertical: isMobile ? 26 : 34,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(isMobile ? 28 : 32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile) ...[
                    _brandBlock(),
                    const SizedBox(height: 22),
                    _footerColumn(
                      title: 'Institucional',
                      items: const ['Quem somos', 'Missao e visao'],
                      expanded: false,
                    ),
                    const SizedBox(height: 18),
                    _footerColumn(
                      title: 'Suporte',
                      items: const ['Privacidade', 'Trocas e devolucoes'],
                      expanded: false,
                    ),
                    const SizedBox(height: 18),
                    _paymentBlock(),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _brandBlock()),
                        _footerColumn(
                          title: 'Institucional',
                          items: const ['Quem somos', 'Missao e visao'],
                        ),
                        _footerColumn(
                          title: 'Suporte',
                          items: const ['Privacidade', 'Trocas e devolucoes'],
                        ),
                        Expanded(child: _paymentBlock()),
                      ],
                    ),
                  const SizedBox(height: 26),
                  Divider(color: Colors.white.withValues(alpha: 0.18)),
                  const SizedBox(height: 18),
                  Text(
                    'SaveMed | CNPJ: 62.250.078/0001-11 | Todos os direitos reservados.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _brandBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/logo.png', height: 34),
            const SizedBox(width: 10),
            const Text(
              'SaveMed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Saude, beleza e conveniencia com uma experiencia mais clara e mais humana.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.76),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _paymentBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Formas de pagamento',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _paymentIcon('assets/cards/visa.png'),
            _paymentIcon('assets/cards/mastercard.png'),
            _paymentIcon('assets/cards/elo.png'),
            _paymentIcon('assets/cards/amex.png'),
            _paymentIcon('assets/cards/hipercard.png'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'PIX',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentIcon(String asset) {
    return Container(
      width: 48,
      height: 34,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }

  Widget _footerColumn({
    required String title,
    required List<String> items,
    bool expanded = true,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              e,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.74),
              ),
            ),
          ),
        ),
      ],
    );

    if (!expanded) return content;
    return Expanded(child: content);
  }
}
