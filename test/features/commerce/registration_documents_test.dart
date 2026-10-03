import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/features/auth/auth_page.dart';

Finder field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextField),
);

void main() {
  testWidgets('login account creation action is clickable', (tester) async {
    var switched = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoginCard(
              onSwitch: () => switched = true,
              isMobile: true,
              authService: const AuthService(),
            ),
          ),
        ),
      ),
    );
    final createAccount = find.widgetWithText(TextButton, 'Criar conta');
    expect(createAccount, findsOneWidget);
    await tester.tap(createAccount);
    expect(switched, isTrue);
  });

  testWidgets(
    'CPF and CNPJ stay independent when switching registration modes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RegisterCard(
                onSwitch: () {},
                isMobile: true,
                authService: const AuthService(),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(field('register-document'), '52998224725');
      await tester.tap(find.text('Farmácia'));
      await tester.pump();
      await tester.enterText(field('register-name'), 'Responsável Teste');
      final next = find.widgetWithText(FilledButton, 'Continuar');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump();
      expect(
        tester.widget<TextField>(field('register-document')).controller!.text,
        isEmpty,
      );
      await tester.enterText(field('register-document'), '04.252.011/0001-11');
      await tester.enterText(field('register-pharmacy-name'), 'Farmácia Teste');
      await tester.enterText(field('register-city'), 'São Paulo');
      await tester.enterText(field('register-state'), 'SP');
      await tester.enterText(field('register-zipcode'), '01001000');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump();
      expect(find.text('Informe um CNPJ válido.'), findsOneWidget);
      await tester.enterText(field('register-document'), '04252011000110');
      expect(
        tester.widget<TextField>(field('register-document')).controller!.text,
        '04.252.011/0001-10',
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump();
      expect(find.text('Etapa 3 de 4'), findsOneWidget);
      await tester.ensureVisible(find.text('Solicitar acesso'));
      await tester.tap(find.text('Solicitar acesso'));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(field('access-responsible-document'))
            .controller!
            .text,
        '529.982.247-25',
      );
      await tester.ensureVisible(find.text('Cliente'));
      await tester.tap(find.text('Cliente'));
      await tester.pump();
      expect(
        tester.widget<TextField>(field('register-document')).controller!.text,
        '529.982.247-25',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
