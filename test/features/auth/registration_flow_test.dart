import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/services/cep_lookup_service.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/features/auth/auth_page.dart';

http.Client? cepClient;

void main() {
  setUpAll(() async {
    final font = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  tearDown(() {
    CepLookupService.setClientForTesting(null);
    cepClient?.close();
    cepClient = null;
  });

  testWidgets('customer password feedback waits for the confirmation field', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final service = _RegistrationAuthService();
    await _mount(tester, service);

    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();
    await _enter(tester, 'register-password', 'SenhaValida123');

    expect(
      find.bySemanticsLabel('Ter pelo menos 8 caracteres: Atendido'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Ser igual nos dois campos: Pendente'),
      findsOneWidget,
    );
    expect(find.text('A confirmação da senha não confere.'), findsNothing);

    await _enter(tester, 'register-password-confirmation', 'OutraSenha123');
    expect(
      find.bySemanticsLabel('Ser igual nos dois campos: Não atendido'),
      findsOneWidget,
    );

    await _enter(tester, 'register-password-confirmation', 'SenhaValida123');
    expect(
      find.bySemanticsLabel('Ser igual nos dois campos: Atendido'),
      findsOneWidget,
    );
    expect(find.text('A confirmação da senha não confere.'), findsNothing);
    expect(service.customerRegistrations, isEmpty);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('customer registration validates password before submitting', (
    tester,
  ) async {
    final service = _RegistrationAuthService();
    await _mount(tester, service);

    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();
    await _enter(tester, 'register-name', 'Cliente Teste');
    await _enter(tester, 'register-document', '52998224725');
    await _enter(tester, 'register-email', ' Conta.Teste@Example.com ');
    await _enter(tester, 'register-phone', '11999999999');
    await _enter(tester, 'register-password', '1234567');
    await _enter(tester, 'register-password-confirmation', '1234567');
    await _tapVisible(tester, 'Criar conta');

    expect(
      find.text('A senha deve ter pelo menos 8 caracteres.'),
      findsWidgets,
    );
    expect(service.customerRegistrations, isEmpty);

    await _enter(tester, 'register-password', ' senha-test-123 ');
    await _enter(tester, 'register-password-confirmation', '');
    await _tapVisible(tester, 'Criar conta');
    expect(find.text('Confirme sua senha.'), findsOneWidget);
    expect(service.customerRegistrations, isEmpty);

    await _enter(tester, 'register-password-confirmation', ' senha-test-123 ');
    await _tapVisible(tester, 'Criar conta');
    await tester.pumpAndSettle();

    expect(service.customerRegistrations, hasLength(1));
    expect(
      service.customerRegistrations.single.email,
      'conta.teste@example.com',
    );
    expect(service.customerRegistrations.single.password, ' senha-test-123 ');
    expect(service.customerRegistrations.single.cpf, '529.982.247-25');
    expect(service.customerRegistrations.single.phone, '(11) 99999-9999');
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new pharmacy registration submits one complete registration', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    cepClient = MockClient((request) async {
      expect(request.url.host, 'viacep.com.br');
      expect(request.url.path, '/ws/01001000/json/');
      return http.Response(
        jsonEncode({'localidade': 'São Paulo', 'uf': 'SP'}),
        200,
      );
    });
    CepLookupService.setClientForTesting(cepClient!);
    final service = _RegistrationAuthService();
    await _mount(tester, service);

    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farmácia').first);
    await tester.pumpAndSettle();

    _expectSemanticFields(tester, {'register-name': 'Nome do responsável'});
    await _enter(tester, 'register-name', 'Responsável Teste');
    await _tapVisible(tester, 'Continuar');
    await tester.pumpAndSettle();
    expect(find.text('Etapa 2 de 4'), findsOneWidget);

    _expectSemanticFields(tester, {
      'register-document': 'CNPJ',
      'register-pharmacy-name': 'Nome da nova farmácia',
      'register-city': 'Cidade',
      'register-state': 'UF',
      'register-zipcode': 'CEP',
    });
    await _enter(tester, 'register-document', '04252011000110');
    await _enter(tester, 'register-pharmacy-name', 'Farmácia Teste');
    await _enter(tester, 'register-city', 'São Paulo');
    await _enter(tester, 'register-state', 'sp');
    await _enter(tester, 'register-zipcode', '01001000');
    await tester.pumpAndSettle();
    await _tapVisible(tester, 'Continuar');
    await tester.pumpAndSettle();
    expect(find.text('Etapa 3 de 4'), findsOneWidget);

    _expectSemanticFields(tester, {
      'register-email': 'Email',
      'register-phone': 'Telefone',
    });
    await _enter(tester, 'register-email', ' Farmacia.Teste@Example.com ');
    await _enter(tester, 'register-phone', '11999999999');
    await _tapVisible(tester, 'Continuar');
    await tester.pumpAndSettle();
    expect(find.text('Etapa 4 de 4'), findsOneWidget);

    _expectSemanticFields(tester, {
      'register-password': 'Senha',
      'register-password-confirmation': 'Confirmar senha',
    });
    await _enter(tester, 'register-password', 'senha-farmacia-123');
    await _enter(
      tester,
      'register-password-confirmation',
      'senha-farmacia-123',
    );
    await _tapVisible(tester, 'Criar conta e farmácia');
    await tester.pumpAndSettle();

    expect(service.pharmacyRegistrations, hasLength(1));
    final registration = service.pharmacyRegistrations.single;
    expect(registration.name, 'Responsável Teste');
    expect(registration.email, 'farmacia.teste@example.com');
    expect(registration.password, 'senha-farmacia-123');
    expect(registration.cnpj, '04.252.011/0001-10');
    expect(registration.phone, '(11) 99999-9999');
    expect(registration.pharmacyName, 'Farmácia Teste');
    expect(registration.city, 'São Paulo');
    expect(registration.state, 'SP');
    expect(registration.zipcode, '01001-000');
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

void _expectSemanticFields(
  WidgetTester tester,
  Map<String, String> labelsByKey,
) {
  for (final entry in labelsByKey.entries) {
    final field = find.descendant(
      of: find.byKey(ValueKey(entry.key)),
      matching: find.byType(TextFormField),
    );
    expect(field, findsOneWidget, reason: 'Missing field ${entry.key}');
    final data = tester.getSemantics(field).getSemanticsData();
    expect(data.flagsCollection.isTextField, isTrue);
    expect(
      data.label,
      contains(entry.value),
      reason: 'Missing label ${entry.value}',
    );
  }
}

Future<void> _mount(
  WidgetTester tester,
  _RegistrationAuthService service,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthController(service: service),
      child: MaterialApp(
        theme: AppTheme.light,
        home: AuthPage(authService: service),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, String label) async {
  final finder = find.text(label).last;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _RegistrationAuthService extends AuthService {
  final customerRegistrations =
      <
        ({String name, String email, String password, String cpf, String phone})
      >[];
  final pharmacyRegistrations =
      <
        ({
          String name,
          String email,
          String password,
          String cnpj,
          String phone,
          String pharmacyName,
          String city,
          String state,
          String zipcode,
        })
      >[];

  @override
  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    customerRegistrations.add((
      name: name,
      email: email,
      password: password,
      cpf: cpf,
      phone: phone,
    ));
    return {};
  }

  @override
  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String email,
    required String password,
    required String cnpj,
    required String phone,
    required String pharmacyName,
    required String city,
    required String state,
    required String zipcode,
  }) async {
    pharmacyRegistrations.add((
      name: name,
      email: email,
      password: password,
      cnpj: cnpj,
      phone: phone,
      pharmacyName: pharmacyName,
      city: city,
      state: state,
      zipcode: zipcode,
    ));
    return {};
  }
}
