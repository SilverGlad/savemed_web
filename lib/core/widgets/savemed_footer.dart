import 'package:flutter/material.dart';

class SaveMedFooter extends StatelessWidget {
  const SaveMedFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 900;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 48,
            vertical: 32,
          ),
          color: const Color(0xFFF7F7F7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================
              // CONTEÚDO PRINCIPAL
              // =====================
              if (isMobile) ...[
                _brandBlock(),
                const SizedBox(height: 24),
                _footerColumn(
                  title: 'Institucional',
                  items: ['Quem Somos', 'Missão e Visão'],
                  expanded: false,
                ),
                const SizedBox(height: 20),
                _footerColumn(
                  title: 'Segurança e Privacidade',
                  items: ['Política de Privacidade', 'Trocas e Devoluções'],
                  expanded: false,
                ),
                const SizedBox(height: 20),
                _paymentBlock(),
                const SizedBox(height: 20),
                _footerColumn(
                  title: 'Central de Atendimento',
                  items: ['Fale Conosco'],
                  expanded: false,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _brandBlock()),
                    _footerColumn(
                      title: 'Institucional',
                      items: ['Quem Somos', 'Missão e Visão'],
                    ),
                    _footerColumn(
                      title: 'Segurança e Privacidade',
                      items: ['Política de Privacidade', 'Trocas e Devoluções'],
                    ),
                    Expanded(child: _paymentBlock()),
                    _footerColumn(
                      title: 'Central de Atendimento',
                      items: ['Fale Conosco'],
                    ),
                  ],
                ),

              const SizedBox(height: 32),
              const Divider(),

              // =====================
              // COPYRIGHT
              // =====================
              Center(
                child: Text(
                  'SaveMed | CNPJ: 62.250.078/0001-11 | Todos os direitos reservados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
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
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              'SaveMed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.facebook, size: 18),
            SizedBox(width: 12),
            Icon(Icons.camera_alt, size: 18),
            SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  Widget _paymentBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Formas de Pagamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _paymentIcon('assets/cards/visa.png'),
            _paymentIcon('assets/cards/mastercard.png'),
            _paymentIcon('assets/cards/elo.png'),
            _paymentIcon('assets/cards/amex.png'),
            _paymentIcon('assets/cards/hipercard.png'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Text(
                'PIX',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
      width: 44,
      height: 32,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              e,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );

    if (!expanded) {
      return content;
    }

    return Expanded(child: content);
  }
}
