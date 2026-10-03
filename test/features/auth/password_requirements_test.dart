import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/widgets/password_requirements.dart';

void main() {
  testWidgets(
    'password requirement states are exposed to assistive technology',
    (tester) async {
      final semantics = tester.ensureSemantics();

      Widget view(String password, String confirmation) => MaterialApp(
        home: Scaffold(
          body: PasswordRequirements(
            password: password,
            confirmation: confirmation,
          ),
        ),
      );

      await tester.pumpWidget(view('', ''));
      expect(
        find.bySemanticsLabel('Ter pelo menos 8 caracteres: Pendente'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Ser igual nos dois campos: Pendente'),
        findsOneWidget,
      );

      await tester.pumpWidget(view('1234567', '12345678'));
      expect(
        find.bySemanticsLabel('Ter pelo menos 8 caracteres: Não atendido'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Ser igual nos dois campos: Não atendido'),
        findsOneWidget,
      );

      await tester.pumpWidget(view('12345678', '12345678'));
      expect(
        find.bySemanticsLabel('Ter pelo menos 8 caracteres: Atendido'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Ser igual nos dois campos: Atendido'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
