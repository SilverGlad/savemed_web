// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' show SemanticsAction;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:savemed/core/api/api_client.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/category_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/services/auth_service.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/services/address_service.dart';
import 'package:savemed/core/services/category_service.dart';
import 'package:savemed/core/services/inventory_service.dart';
import 'package:savemed/core/services/cep_lookup_service.dart';
import 'package:savemed/core/storage/token_storage.dart';
import 'package:savemed/core/widgets/address_modal.dart';
import 'package:savemed/core/widgets/savemed_button.dart';
import 'package:savemed/features/admin/admin_page.dart';
import 'package:savemed/features/auth/auth_page.dart';
import 'package:savemed/features/home/home_page.dart';
import 'package:savemed/main.dart';
import 'package:savemed/models/pharmacy_access_request.dart';
import 'package:savemed/models/pharmacy_access_request_summary.dart';
import 'package:savemed/models/pharmacy_search_result.dart';
import 'package:savemed/models/pharmacy.dart';
import 'package:savemed/models/user.dart';
import 'package:savemed/models/category.dart';
import 'package:savemed/models/active_ingredient.dart';
import 'package:savemed/models/medication.dart';
import 'package:savemed/models/admin_inventory_item.dart';
import 'package:savemed/models/promotion.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/financial_summary.dart';
import 'package:savemed/models/postal_address.dart';
import 'support/in_memory_token_vault.dart';

const _appAdmin = AppUser(
  id: 1,
  name: 'Administrador SaveMed',
  email: 'admin@example.com',
  role: UserRole.appAdmin,
);

void main() {
  setUp(() {
    ApiClient.setClientForTesting(
      MockClient((_) async => http.Response('{}', 503)),
    );
    ApiClient.setUnauthorizedHandler(null);
    CepLookupService.setClientForTesting(
      MockClient((_) async => http.Response('{"erro":true}', 404)),
    );
    TokenStorage.resetForTesting();
    TokenStorage.setVaultForTesting(InMemoryTokenVault());
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    ApiClient.setClientForTesting(null);
    ApiClient.setUnauthorizedHandler(null);
    CepLookupService.setClientForTesting(null);
  });

  testWidgets('shows login page as initial screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('v1.1.0'), findsOneWidget);
    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('version label does not cover registration fields on mobile', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.tap(find.text('Criar conta').first);
    await tester.pumpAndSettle();

    final confirmationField = find.byKey(
      const ValueKey('register-password-confirmation'),
    );
    await tester.ensureVisible(confirmationField);
    await tester.pumpAndSettle();
    final versionLabel = find.text('v1.1.0');
    await tester.ensureVisible(versionLabel);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(confirmationField).overlaps(tester.getRect(versionLabel)),
      isFalse,
    );
  });

  testWidgets('login exposes field semantics and submits from the keyboard', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final authService = _FakeAuthService();
    final auth = AuthController(service: authService)..loading = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<AddressController>(
            create: (_) => AddressController(),
          ),
        ],
        child: MaterialApp(home: AuthPage(authService: authService)),
      ),
    );
    await tester.pump();

    final emailSemantics = find.bySemanticsLabel('Email');
    expect(emailSemantics, findsOneWidget);
    final fields = find.byType(TextFormField);
    final emailData = tester.getSemantics(fields.at(0)).getSemanticsData();
    expect(emailData.flagsCollection.isTextField, isTrue);
    expect(emailData.label, contains('Email'));
    await tester.enterText(fields.at(0), 'cliente@example.com');
    await tester.enterText(fields.at(1), 'senha-segura');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(auth.isLogged, isTrue);
    expect(auth.user?.email, 'admin@example.com');
    semantics.dispose();
  });

  testWidgets('login follows reading order with the physical keyboard', (
    WidgetTester tester,
  ) async {
    final authService = _FakeAuthService();
    final auth = AuthController(service: authService)..loading = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<AddressController>(
            create: (_) => AddressController(),
          ),
        ],
        child: MaterialApp(home: AuthPage(authService: authService)),
      ),
    );
    await tester.pump();

    final editableFields = find.byType(EditableText);
    final emailField = tester.widget<EditableText>(editableFields.at(0));
    final passwordField = tester.widget<EditableText>(editableFields.at(1));

    expect(find.widgetWithText(TextButton, 'Criar conta'), findsOneWidget);
    expect(find.text('Novo por aqui? Criar conta'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(emailField.focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(passwordField.focusNode.hasFocus, isTrue);
  });

  testWidgets('account switch appears once on login and registration', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: AuthPage()));
    await tester.pump();

    expect(find.widgetWithText(TextButton, 'Criar conta'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Fazer login'), findsOneWidget);
    expect(find.text('Já tem conta? Entrar'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer registration fields follow reading order by Tab', (
    WidgetTester tester,
  ) async {
    final authService = _FakeAuthService();
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: AuthPage(authService: authService)),
    );
    await tester.pump();

    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Criar conta'))
        .onPressed!();
    await tester.pumpAndSettle();

    Finder editable(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(EditableText),
    );
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('register-email')),
        matching: find.byType(AutofillGroup),
      ),
      findsOneWidget,
    );
    final fields = [
      'register-document',
      'register-name',
      'register-email',
      'register-phone',
      'register-password',
    ].map(editable).toList();
    final focusNodes = fields
        .map((field) => tester.widget<EditableText>(field).focusNode)
        .toList();

    focusNodes.first.requestFocus();
    await tester.pump();
    expect(focusNodes.first.hasFocus, isTrue);

    for (var index = 1; index < focusNodes.length; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusNodes[index].hasFocus, isTrue);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('pharmacy registration fields follow reading order by Tab', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: AuthPage()));
    await tester.pump();

    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Criar conta'))
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farmácia'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('register-name')),
      'Responsável Teste',
    );
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Etapa 2 de 4'), findsOneWidget);

    EditableText editable(String key) => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(EditableText),
      ),
    );
    final fields = [
      editable('register-document'),
      editable('register-pharmacy-name'),
      editable('register-city'),
      editable('register-state'),
      editable('register-zipcode'),
    ];
    fields.first.focusNode.requestFocus();
    await tester.pump();

    for (final field in fields.skip(1)) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(field.focusNode.hasFocus, isTrue);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration configures autofill and keyboard progression', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final authService = _FakeAuthService();
    await tester.pumpWidget(
      MaterialApp(home: AuthPage(authService: authService)),
    );
    await tester.pump();
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Criar conta'))
        .onPressed!();
    await tester.pumpAndSettle();

    Finder editable(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(EditableText),
    );

    expect(
      tester.widget<EditableText>(editable('register-name')).autofillHints,
      contains(AutofillHints.name),
    );
    expect(
      tester.widget<EditableText>(editable('register-email')).autofillHints,
      contains(AutofillHints.email),
    );
    expect(
      tester.widget<EditableText>(editable('register-phone')).autofillHints,
      contains(AutofillHints.telephoneNumber),
    );
    expect(
      tester.widget<EditableText>(editable('register-password')).autofillHints,
      contains(AutofillHints.newPassword),
    );
    expect(
      tester
          .widget<EditableText>(editable('register-password-confirmation'))
          .textInputAction,
      TextInputAction.done,
    );

    final cpf = tester.widget<EditableText>(editable('register-document'));
    final name = tester.widget<EditableText>(editable('register-name'));
    expect(cpf.textInputAction, TextInputAction.next);
    cpf.focusNode.requestFocus();
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(name.focusNode.hasFocus, isTrue);

    await tester.tap(find.text('Farmácia'));
    await tester.pumpAndSettle();
    await tester.enterText(editable('register-name'), 'Responsável Teste');
    await tester.showKeyboard(editable('register-name'));
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(find.text('Etapa 2 de 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'customer registration exposes labeled fields and password controls',
    (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      final authService = _FakeAuthService();
      await tester.pumpWidget(
        MaterialApp(home: AuthPage(authService: authService)),
      );
      await tester.pump();

      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Criar conta'))
          .onPressed!();
      await tester.pumpAndSettle();

      final labels = [
        'CPF',
        'Nome completo',
        'Email',
        'Telefone',
        'Senha',
        'Confirmar senha',
      ];
      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(labels.length));
      for (var index = 0; index < labels.length; index++) {
        final label = labels[index];
        final data = tester.getSemantics(fields.at(index)).getSemanticsData();
        expect(data.label, contains(label), reason: 'Missing label: $label');
        expect(data.flagsCollection.isTextField, isTrue);
      }

      for (final label in ['Mostrar senha', 'Mostrar confirmação']) {
        final control = find.byTooltip(label);
        expect(control, findsOneWidget);
        final node = tester.getSemantics(control);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      }
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('registration supports enlarged text on a mobile viewport', (
    WidgetTester tester,
  ) async {
    final authService = _FakeAuthService();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: AuthPage(authService: authService),
      ),
    );
    await tester.pump();
    final createAccountButton = find.widgetWithText(TextButton, 'Criar conta');
    tester.widget<TextButton>(createAccountButton).onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.text('Sua senha deve:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer registration fits 320px at 200 percent text scale', (
    WidgetTester tester,
  ) async {
    const viewport = Size(320, 640);
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final authService = _FakeAuthService();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: viewport,
          textScaler: TextScaler.linear(2),
        ),
        child: MaterialApp(home: AuthPage(authService: authService)),
      ),
    );
    await tester.pump();
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Criar conta'))
        .onPressed!();
    await tester.pumpAndSettle();

    for (final key in [
      'register-document',
      'register-name',
      'register-email',
      'register-phone',
      'register-password',
      'register-password-confirmation',
    ]) {
      final field = find.byKey(ValueKey(key));
      await tester.ensureVisible(field);
      final bounds = tester.getRect(field);
      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(viewport.width));
    }

    final submit = find.widgetWithText(SaveMedButton, 'Criar conta');
    await tester.ensureVisible(submit);
    final submitBounds = tester.getRect(submit);
    expect(submitBounds.left, greaterThanOrEqualTo(0));
    expect(submitBounds.right, lessThanOrEqualTo(viewport.width));
    expect(submitBounds.bottom, lessThanOrEqualTo(viewport.height));
    expect(tester.takeException(), isNull);
  });

  testWidgets('login remains usable at 320px with text scaled to 200 percent', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final authService = _FakeAuthService();
    final auth = AuthController(service: authService)..loading = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<AddressController>(
            create: (_) => AddressController(),
          ),
        ],
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2),
          ),
          child: MaterialApp(home: AuthPage(authService: authService)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completes password recovery with visible requirements', (
    WidgetTester tester,
  ) async {
    final service = _FakeAuthService();
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(home: AuthPage(authService: service)));
    await tester.pump();
    await tester.ensureVisible(find.text('Esqueci minha senha'));
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );

    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('forgot-email')),
        matching: find.byType(AutofillGroup),
      ),
      findsOneWidget,
    );

    await tester.enterText(field('forgot-email'), 'cliente@example.com');
    await tester.tap(find.text('Enviar código'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.forgotPasswordEmail, 'cliente@example.com');
    expect(find.text('Sua senha deve:'), findsOneWidget);
    expect(find.byTooltip('Mostrar nova senha'), findsOneWidget);
    expect(find.byTooltip('Mostrar confirmação da nova senha'), findsOneWidget);
    final recoveryPassword = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('forgot-password')),
        matching: find.byType(EditableText),
      ),
    );
    final recoveryCode = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('forgot-code')),
        matching: find.byType(EditableText),
      ),
    );
    expect(recoveryPassword.autofillHints, contains(AutofillHints.newPassword));
    expect(recoveryCode.autofillHints, contains(AutofillHints.oneTimeCode));

    await tester.enterText(field('forgot-code'), '123456');
    await tester.enterText(field('forgot-password'), 'senha123');
    await tester.enterText(field('forgot-password-confirmation'), 'senha123');
    await tester.pump();

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.byIcon(Icons.check_circle)),
      findsNWidgets(2),
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(service.resetPasswordEmail, 'cliente@example.com');
    expect(service.resetPasswordCode, '123456');
    expect(service.newPassword, 'senha123');
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('invited user can use an existing recovery code', (
    WidgetTester tester,
  ) async {
    final service = _FakeAuthService();
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: AuthPage(authService: service)));
    await tester.pump();
    await tester.ensureVisible(find.text('Esqueci minha senha'));
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );

    await tester.enterText(field('forgot-email'), 'convite@example.com');
    await tester.tap(find.text('Já tenho um código'));
    await tester.pump();
    expect(find.byKey(const ValueKey('forgot-code')), findsOneWidget);
    expect(service.forgotPasswordEmail, isNull);

    await tester.enterText(field('forgot-code'), '654321');
    await tester.enterText(field('forgot-password'), 'senha123');
    await tester.enterText(field('forgot-password-confirmation'), 'senha123');
    await tester.tap(find.text('Redefinir senha'));
    await tester.pumpAndSettle();

    expect(service.resetPasswordEmail, 'convite@example.com');
    expect(service.resetPasswordCode, '654321');
  });

  testWidgets('separates new pharmacy and existing pharmacy access flows', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final authService = _FakeAuthService();
    final controller = AuthController(service: authService);
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MyApp(authController: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.text('Criar conta'));
    final createAccountButton = find.widgetWithText(TextButton, 'Criar conta');
    tester.widget<TextButton>(createAccountButton).onPressed!();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Farmácia'));
    await tester.tap(find.text('Farmácia'));
    await tester.pump(const Duration(milliseconds: 200));

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );
    Finder editable(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(EditableText),
    );
    Future<void> enterAndSubmitIme(
      String key,
      String value,
      TextInputAction action,
    ) async {
      await tester.enterText(field(key), value);
      await tester.testTextInput.receiveAction(action);
      await tester.pumpAndSettle();
    }

    expect(find.text('Nova farmácia'), findsWidgets);
    expect(find.text('Solicitar acesso'), findsOneWidget);
    expect(find.text('Etapa 1 de 4'), findsOneWidget);
    await enterAndSubmitIme(
      'register-name',
      'Responsavel Teste',
      TextInputAction.next,
    );

    expect(find.text('Etapa 2 de 4'), findsOneWidget);
    expect(find.text('Nome da nova farmácia'), findsOneWidget);
    expect(find.text('Ja cadastrada'), findsNothing);
    await enterAndSubmitIme(
      'register-document',
      '04252011000110',
      TextInputAction.next,
    );
    expect(
      tester
          .widget<EditableText>(editable('register-pharmacy-name'))
          .focusNode
          .hasFocus,
      isTrue,
    );
    await enterAndSubmitIme(
      'register-pharmacy-name',
      'Farmacia Teste',
      TextInputAction.next,
    );
    expect(
      tester.widget<EditableText>(editable('register-city')).focusNode.hasFocus,
      isTrue,
    );
    await enterAndSubmitIme('register-city', 'Sao Paulo', TextInputAction.next);
    expect(
      tester
          .widget<EditableText>(editable('register-state'))
          .focusNode
          .hasFocus,
      isTrue,
    );
    await enterAndSubmitIme('register-state', 'SP', TextInputAction.next);
    expect(
      tester
          .widget<EditableText>(editable('register-zipcode'))
          .focusNode
          .hasFocus,
      isTrue,
    );
    await enterAndSubmitIme(
      'register-zipcode',
      '01001000',
      TextInputAction.done,
    );

    expect(find.text('Etapa 3 de 4'), findsOneWidget);
    await enterAndSubmitIme(
      'register-email',
      'farmacia@example.com',
      TextInputAction.next,
    );
    expect(
      tester
          .widget<EditableText>(editable('register-phone'))
          .focusNode
          .hasFocus,
      isTrue,
    );
    await enterAndSubmitIme(
      'register-phone',
      '11999999999',
      TextInputAction.done,
    );

    expect(find.text('Etapa 4 de 4'), findsOneWidget);
    expect(find.textContaining('ativados imediatamente'), findsOneWidget);
    expect(find.text('Sua senha deve:'), findsOneWidget);
    expect(find.text('Ter pelo menos 8 caracteres'), findsOneWidget);
    expect(find.text('Ser igual nos dois campos'), findsOneWidget);

    final passwordField = field('register-password');
    final confirmationField = field('register-password-confirmation');
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.enterText(passwordField, '12345678');
    expect(find.text('A confirmação da senha não confere.'), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(editable('register-password-confirmation'))
          .focusNode
          .hasFocus,
      isTrue,
    );
    await tester.enterText(confirmationField, '12345678');
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));

    final showPasswordButton = find.byTooltip('Mostrar senha');
    await tester.ensureVisible(showPasswordButton);
    await tester.tap(showPasswordButton);
    await tester.pump();
    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);

    await tester.showKeyboard(editable('register-password-confirmation'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(authService.registeredSellerEmail, 'farmacia@example.com');
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a customer account and returns to login', (
    WidgetTester tester,
  ) async {
    final authService = _FakeAuthService();
    final controller = AuthController(service: authService)..loading = false;
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: controller,
        child: MaterialApp(home: AuthPage(authService: authService)),
      ),
    );
    final createAccountButton = find.widgetWithText(TextButton, 'Criar conta');
    tester.widget<TextButton>(createAccountButton).onPressed!();
    await tester.pumpAndSettle();

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );
    await tester.enterText(field('register-document'), '52998224725');
    await tester.enterText(field('register-name'), 'Cliente Teste');
    await tester.enterText(field('register-email'), 'cliente@example.com');
    await tester.enterText(field('register-phone'), '11999999999');
    await tester.enterText(field('register-password'), 'senha123');
    await tester.enterText(field('register-password-confirmation'), 'senha123');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(authService.registeredCustomerEmail, 'cliente@example.com');
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pharmacy registration renders on a mobile viewport', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Farmácia'));
    await tester.tap(find.text('Farmácia'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Nova farmácia'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pharmacy responsibility field stays readable at 320 pixels', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Farmácia'));
    await tester.tap(find.text('Farmácia'));
    await tester.pump(const Duration(milliseconds: 200));

    final responsibleField = find.descendant(
      of: find.byKey(const ValueKey('register-name')),
      matching: find.byType(TextField),
    );
    expect(find.text('Etapa 1 de 4'), findsOneWidget);
    final hint =
        tester.widget<TextField>(responsibleField).decoration?.hint! as Text;
    expect(hint.data, 'Nome completo');
    expect(hint.semanticsLabel, 'Nome do responsável');
    expect(tester.takeException(), isNull);
  });

  testWidgets('requests access without collecting a password', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final authService = _FakeAuthService(
      pharmacySearchResults: const [
        PharmacySearchResult(
          id: 9,
          name: 'Farmacia Central',
          maskedCnpj: '**.***.***/****-1234',
          city: 'Sao Paulo',
          state: 'SP',
        ),
      ],
    );
    final auth = AuthController(service: authService);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AuthPage(authService: authService)),
      ),
    );
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farmácia'));
    await tester.pump();
    await tester.tap(find.text('Solicitar acesso'));
    await tester.pump();

    expect(
      find.textContaining('A solicitação não pede senha.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('register-password')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('access-pharmacy-search')),
      'Central',
    );
    await tester.tap(find.byTooltip('Buscar farmácia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farmacia Central'));

    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );
    await tester.enterText(field('access-responsible-name'), 'Maria Silva');
    await tester.enterText(field('access-responsible-document'), '52998224725');
    await tester.enterText(field('access-email'), 'maria@example.com');
    await tester.enterText(field('access-phone'), '11999999999');
    await tester.ensureVisible(find.text('Enviar solicitação'));
    await tester.tap(find.text('Enviar solicitação'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Solicitação enviada'), findsOneWidget);
    expect(authService.accessRequest?.pharmacyId, 9);
    expect(authService.accessRequest?.email, 'maria@example.com');
    expect(tester.takeException(), isNull);
  });

  testWidgets('existing pharmacy search stays concise at 320px and 200% text', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const size = Size(320, 640);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final authService = _FakeAuthService();
    final auth = AuthController(service: authService);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(
          home: AuthPage(authService: authService),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(size: size, textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
        ),
      ),
    );
    final createAccount = find.text('Criar conta').first;
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();
    final pharmacyMode = find.text('Farmácia');
    await tester.ensureVisible(pharmacyMode);
    await tester.tap(pharmacyMode);
    await tester.pump();
    final accessMode = find.text('Solicitar acesso');
    await tester.ensureVisible(accessMode);
    await tester.tap(accessMode);
    await tester.pump();

    final search = find.byKey(const ValueKey('access-pharmacy-search'));
    await tester.ensureVisible(search);
    final searchField = find.descendant(
      of: search,
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(searchField).decoration?.hintText,
      'Nome ou CNPJ',
    );
    expect(
      find.textContaining('Busque por nome, cidade, CNPJ ou ID'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration reports validation errors next to the fields', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pump(const Duration(milliseconds: 400));

    final submit = find.widgetWithText(SaveMedButton, 'Criar conta');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('Informe um CPF válido.'), findsOneWidget);
    expect(find.text('Informe o nome completo.'), findsOneWidget);
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Informe um telefone válido com DDD.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('registration preserves data and guides uncertain outcomes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final failures = <Object>[
      const ApiConnectionException('Sem conexao'),
      const ApiResponseException('Server failure details', 503),
    ];

    for (final failure in failures) {
      SharedPreferences.setMockInitialValues({});
      final service = _FakeAuthService(registerError: failure);
      final controller = AuthController(service: service);

      await tester.pumpWidget(MyApp(authController: controller));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump(const Duration(milliseconds: 400));

      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextField),
      );

      await tester.enterText(field('register-document'), '52998224725');
      await tester.enterText(field('register-name'), 'Cliente Teste');
      await tester.enterText(field('register-email'), 'cliente@example.com');
      await tester.enterText(field('register-phone'), '11999999999');
      await tester.enterText(field('register-password'), 'senha123');
      await tester.enterText(
        field('register-password-confirmation'),
        'senha123',
      );

      final submit = find.widgetWithText(SaveMedButton, 'Criar conta');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        tester.widget<TextField>(field('register-name')).controller?.text,
        'Cliente Teste',
      );
      expect(
        tester.widget<TextField>(field('register-email')).controller?.text,
        'cliente@example.com',
      );
      expect(
        find.textContaining('Não foi possível confirmar se a conta foi criada'),
        findsOneWidget,
      );
      expect(find.text('Ir para login'), findsOneWidget);
      expect(find.textContaining('Server failure details'), findsNothing);

      await tester.enterText(field('register-email'), 'novo@example.com');
      await tester.pump();
      expect(
        find.textContaining('conta foi criada usando cliente@example.com'),
        findsOneWidget,
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Confirmar novo envio'), findsOneWidget);
      expect(
        find.textContaining('A tentativa anterior para cliente@example.com'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Ir para login'), findsOneWidget);

      await tester.ensureVisible(find.text('Ir para login'));
      await tester.tap(find.text('Ir para login'));
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo de volta'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller
            ?.text,
        'cliente@example.com',
      );
    }
  });

  testWidgets('pharmacy registration maps duplicate email and CNPJ errors', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Finder field(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextField),
    );

    for (final (apiMessage, code, fieldName, expectedMessage)
        in <(String, String?, String?, String)>[
          (
            'Ja existe uma farmacia cadastrada com este CNPJ. Solicite acesso a farmacia existente.',
            null,
            null,
            'Este CNPJ já está cadastrado.',
          ),
          (
            'Este email ja esta em uso.',
            null,
            null,
            'Este e-mail já está em uso.',
          ),
          (
            'Conflict',
            'CNPJ_IN_USE',
            'pharmacy.CNPJ',
            'Este CNPJ já está cadastrado.',
          ),
          (
            'Conflict',
            'EMAIL_IN_USE',
            'administrator.EMAIL',
            'Este e-mail já está em uso.',
          ),
        ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      final service = _FakeAuthService(
        registerError: ApiResponseException(
          apiMessage,
          409,
          code: code,
          field: fieldName,
        ),
      );
      await tester.pumpWidget(
        MyApp(authController: AuthController(service: service)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.local_pharmacy_outlined).first);
      await tester.pumpAndSettle();

      await tester.enterText(field('register-name'), 'Responsavel Teste');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.enterText(field('register-document'), '04252011000110');
      await tester.enterText(field('register-pharmacy-name'), 'Farmacia Teste');
      await tester.enterText(field('register-city'), 'Sao Paulo');
      await tester.enterText(field('register-state'), 'SP');
      await tester.enterText(field('register-zipcode'), '01001000');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.enterText(field('register-email'), 'farmacia@example.com');
      await tester.enterText(field('register-phone'), '11999999999');
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.enterText(field('register-password'), 'senha123');
      await tester.enterText(
        field('register-password-confirmation'),
        'senha123',
      );

      final submit = find.byType(SaveMedButton).last;
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text(expectedMessage), findsWidgets);
      if (fieldName != null) {
        final targetField = find.byKey(
          ValueKey(
            fieldName.endsWith('.CNPJ')
                ? 'register-document'
                : fieldName.endsWith('.PHONE_NUMBER')
                ? 'register-phone'
                : 'register-email',
          ),
        );
        expect(targetField, findsOneWidget);
        expect(
          find.descendant(
            of: targetField,
            matching: find.text(expectedMessage),
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            fieldName.endsWith('.CNPJ') ? 'Etapa 2 de 4' : 'Etapa 3 de 4',
          ),
          findsOneWidget,
        );
        final fieldKey = fieldName.endsWith('.CNPJ')
            ? 'register-document'
            : fieldName.endsWith('.PHONE_NUMBER')
            ? 'register-phone'
            : 'register-email';
        await tester.ensureVisible(targetField);
        await tester.enterText(
          field(fieldKey),
          fieldKey == 'register-document'
              ? '00000000000000'
              : fieldKey == 'register-phone'
              ? '11988887777'
              : 'novo@example.com',
        );
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: targetField,
            matching: find.text(expectedMessage),
          ),
          findsNothing,
        );
      }
      expect(find.textContaining(apiMessage), findsNothing);
      expect(tester.takeException(), isNull);
    }

    final invalidPhoneService = _FakeAuthService(
      registerError: const ApiResponseException(
        'Informe um telefone valido com DDD.',
        422,
        code: 'INVALID_PHONE',
        field: 'administrator.PHONE_NUMBER',
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MyApp(authController: AuthController(service: invalidPhoneService)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.local_pharmacy_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(field('register-name'), 'Responsavel Teste');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(field('register-document'), '04252011000110');
    await tester.enterText(field('register-pharmacy-name'), 'Farmacia Teste');
    await tester.enterText(field('register-city'), 'Sao Paulo');
    await tester.enterText(field('register-state'), 'SP');
    await tester.enterText(field('register-zipcode'), '01001000');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(field('register-email'), 'farmacia@example.com');
    await tester.enterText(field('register-phone'), '11999999999');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.enterText(field('register-password'), 'senha123');
    await tester.enterText(field('register-password-confirmation'), 'senha123');

    final submit = find.byType(SaveMedButton).last;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Este telefone já está cadastrado.'), findsNothing);
    expect(find.text('Etapa 4 de 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'uncertain registration retry confirmation fits enlarged mobile',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = _FakeAuthService(
        registerError: const ApiConnectionException('Sem conexao'),
      );
      final auth = AuthController(service: service)..loading = false;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: auth),
            ChangeNotifierProvider<AddressController>(
              create: (_) => AddressController(),
            ),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(2),
            ),
            child: MaterialApp(home: AuthPage(authService: service)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextField),
      );

      for (final (key, value) in [
        ('register-document', '52998224725'),
        ('register-name', 'Cliente Teste'),
        ('register-email', 'cliente@example.com'),
        ('register-phone', '11999999999'),
        ('register-password', 'senha123'),
        ('register-password-confirmation', 'senha123'),
      ]) {
        await tester.ensureVisible(field(key));
        await tester.enterText(field(key), value);
        await tester.pump();
      }

      final submit = find.widgetWithText(SaveMedButton, 'Criar conta');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ir para login'));
      expect(
        find.textContaining('conta foi criada usando cliente@example.com'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Confirmar novo envio'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Ir para login'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pharmacy registration keeps entered data after a connection failure',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(1280, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AuthController(
        service: _FakeAuthService(
          registerError: const ApiConnectionException('Sem conexao'),
        ),
      );

      await tester.pumpWidget(MyApp(authController: controller));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final createAccountButton = find.widgetWithText(
        TextButton,
        'Criar conta',
      );
      tester.widget<TextButton>(createAccountButton).onPressed!();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byIcon(Icons.local_pharmacy_outlined).first);
      await tester.pump();

      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextField),
      );

      await tester.enterText(field('register-name'), 'Responsavel Teste');
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.enterText(field('register-document'), '04252011000110');
      await tester.enterText(field('register-pharmacy-name'), 'Farmacia Teste');
      await tester.enterText(field('register-city'), 'Sao Paulo');
      await tester.enterText(field('register-state'), 'SP');
      await tester.enterText(field('register-zipcode'), '01001000');
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.enterText(field('register-email'), 'farmacia@example.com');
      await tester.enterText(field('register-phone'), '11999999999');
      await tester.tap(find.text('Continuar'));
      await tester.pump();
      await tester.enterText(field('register-password'), 'senha123');
      await tester.enterText(
        field('register-password-confirmation'),
        'senha123',
      );

      final submit = find.byType(SaveMedButton).last;
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('Não foi possível confirmar se a conta foi criada'),
        findsOneWidget,
      );
      expect(find.text('Ir para login'), findsOneWidget);
      expect(find.textContaining('Conta criada com sucesso'), findsNothing);
      expect(
        tester.widget<TextField>(field('register-password')).controller?.text,
        'senha123',
      );

      await tester.ensureVisible(find.text('Voltar'));
      await tester.tap(find.text('Voltar'));
      await tester.pump();
      for (final step in [
        ('register-email', 'farmacia@example.com'),
        ('register-phone', '(11) 99999-9999'),
      ]) {
        expect(
          tester.widget<TextField>(field(step.$1)).controller?.text,
          step.$2,
        );
      }
      await tester.ensureVisible(find.text('Voltar'));
      await tester.tap(find.text('Voltar'));
      await tester.pump();
      for (final step in [
        ('register-document', '04.252.011/0001-10'),
        ('register-pharmacy-name', 'Farmacia Teste'),
        ('register-city', 'Sao Paulo'),
        ('register-state', 'SP'),
        ('register-zipcode', '01001-000'),
      ]) {
        expect(
          tester.widget<TextField>(field(step.$1)).controller?.text,
          step.$2,
        );
      }
      await tester.ensureVisible(find.text('Voltar'));
      await tester.tap(find.text('Voltar'));
      await tester.pump();
      expect(
        tester.widget<TextField>(field('register-name')).controller?.text,
        'Responsavel Teste',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('restores a valid administrative session', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'valid-token'});
    final controller = AuthController(service: _FakeAuthService());

    await tester.pumpWidget(MyApp(authController: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AdminPage), findsOneWidget);
    expect(controller.isLogged, isTrue);
    expect(controller.sessionRestoreError, isNull);
  });

  testWidgets('clears an invalid saved session and returns to login', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'expired-token'});
    final controller = AuthController(
      service: _FakeAuthService(
        error: const ApiResponseException('Token invalido', 401),
      ),
    );

    await tester.pumpWidget(MyApp(authController: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(controller.isLogged, isFalse);
    expect(await TokenStorage.getToken(), isNull);
    expect(
      (await SharedPreferences.getInstance()).getString('auth_token'),
      isNull,
    );
  });

  testWidgets('keeps a saved session when validation is temporarily offline', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'saved-token'});
    final service = _FakeAuthService(
      error: const ApiConnectionException('Sem conexao'),
    );
    final controller = AuthController(service: service);

    await tester.pumpWidget(MyApp(authController: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Não foi possível entrar agora'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(await TokenStorage.getToken(), 'saved-token');
    expect(
      (await SharedPreferences.getInstance()).getString('auth_token'),
      isNull,
    );

    service.error = null;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AdminPage), findsOneWidget);
    expect(controller.isLogged, isTrue);
  });

  testWidgets('opens administrative navigation on a mobile viewport', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'valid-token'});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MyApp(authController: AuthController(service: _FakeAuthService())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byTooltip('Abrir menu'), findsOneWidget);
    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();

    expect(find.text('Sair'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides the drawer button on an administrative desktop', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'valid-token'});
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MyApp(authController: AuthController(service: _FakeAuthService())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byTooltip('Abrir menu'), findsNothing);
    expect(find.text('Sair'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired administrative session offers a new login', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'expired-token'});
    final auth = AuthController(service: _FakeAuthService())
      ..loading = false
      ..user = _appAdmin
      ..token = 'expired-token';

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: const MaterialApp(home: AdminPage()),
      ),
    );
    await tester.pump();

    await auth.expireSession();
    await tester.pump();

    expect(find.text('Sua sessão expirou'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Entrar novamente'),
      findsOneWidget,
    );
  });

  testWidgets('administrative lists distinguish empty and retry states', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final categories = find.widgetWithText(InkWell, 'Categorias');
    await tester.tap(categories);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Nenhum registro cadastrado.'), findsOneWidget);
    expect(find.text('Nova categoria'), findsWidgets);

    adminService.categoryError = const ApiConnectionException('Sem conexao');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Atualizar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sem conexao'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Nenhum registro cadastrado.'), findsNothing);

    adminService.categoryError = null;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Nenhum registro cadastrado.'), findsOneWidget);
  });

  testWidgets('product form allows selecting active ingredients', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: const [
        {'ID': 9, 'NAME': 'Farmacia Central'},
      ],
      categories: const [
        {'ID': 3, 'NAME': 'Medicamentos', 'PHARMACY_ID': 9},
      ],
      activeIngredients: const [
        {'ID': 7, 'NAME': 'Dipirona', 'PHARMACY_ID': 9},
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'Produtos'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Novo produto').first);
    await tester.pumpAndSettle();
    final pharmacyDropdown = find.byType(DropdownMenu<int>).first;
    await tester.tap(pharmacyDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farmacia Central').last);
    await tester.pumpAndSettle();

    expect(find.text('Princípios ativos'), findsWidgets);
    final ingredientChip = find.widgetWithText(FilterChip, 'Dipirona');
    expect(ingredientChip, findsOneWidget);
    await tester.tap(ingredientChip);
    await tester.pump();
    expect(tester.widget<FilterChip>(ingredientChip).selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refund confirmation shows order details before the action', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      orders: [
        {
          'ID': 42,
          'STATUS': 'confirmed',
          'PAYMENT_STATUS': 'paid',
          'TOTAL_AMOUNT': '123.45',
          'DELIVERY_METHOD': 'shipping',
          'DELIVERY_LABEL': 'Entrega própria',
          'pharmacy': {'NAME': 'Farmacia Central'},
        },
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(InkWell, 'Pedidos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Histórico e estornos'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Estornar'));
    await tester.tap(find.text('Estornar'));
    await tester.pumpAndSettle();

    expect(find.text('Estornar pedido #42'), findsOneWidget);
    expect(find.text('Farmacia Central'), findsWidgets);
    expect(find.textContaining('123,45'), findsWidgets);
    expect(find.text('Entrega própria'), findsOneWidget);
    expect(find.textContaining('não pode ser desfeita'), findsOneWidget);
    expect(find.text('Justificativa do estorno'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(adminService.refundedOrderId, isNull);

    await tester.tap(find.text('Estornar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField),
      'Solicitacao confirmada pelo atendimento.',
    );
    await tester.tap(find.text('Confirmar estorno'));
    await tester.pumpAndSettle();
    expect(adminService.refundedOrderId, 42);
    expect(
      adminService.refundReason,
      'Solicitacao confirmada pelo atendimento.',
    );
  });

  testWidgets('pharmacy users show status and confirm deactivation', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: [
        {'ID': 9, 'NAME': 'Farmacia Central', 'IS_ACTIVE': true},
      ],
      users: [
        {
          'ID': 15,
          'NAME': 'Maria Silva',
          'EMAIL': 'maria@example.com',
          'USER_ROLE': 'pharmacy_user',
          'IS_ACTIVE': true,
        },
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Farmácias').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usuários da farmácia'));
    await tester.pumpAndSettle();

    expect(find.text('Ativo'), findsOneWidget);
    expect(find.byTooltip('Inativar usuário'), findsOneWidget);

    await tester.tap(find.byTooltip('Inativar usuário'));
    await tester.pumpAndSettle();
    expect(find.text('Inativar usuário?'), findsOneWidget);
    expect(find.textContaining('perderá o acesso'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Inativar'));
    await tester.pumpAndSettle();
    expect(adminService.updatedUserId, 15);
    expect(adminService.updatedUserActive, false);
  });

  testWidgets('pending pharmacy user can receive invitation again', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: const [
        {'ID': 9, 'NAME': 'Farmacia Central', 'IS_ACTIVE': true},
      ],
      users: const [
        {
          'ID': 16,
          'NAME': 'Novo usuario',
          'EMAIL': 'novo@example.com',
          'USER_ROLE': 'pharmacy_user',
          'IS_ACTIVE': true,
          'MUST_CHANGE_PASSWORD': true,
        },
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Farmácias').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usuários da farmácia'));
    await tester.pumpAndSettle();

    expect(find.text('Convite pendente'), findsOneWidget);
    await tester.tap(find.byTooltip('Reenviar convite'));
    await tester.pumpAndSettle();
    expect(adminService.resentInvitationUserId, 16);
    expect(find.text('Convite reenviado com sucesso.'), findsOneWidget);
  });

  testWidgets('app admin invites a pharmacy user without defining a password', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: const [
        {'ID': 9, 'NAME': 'Farmacia Central', 'IS_ACTIVE': true},
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Farmácias').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usuários da farmácia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convidar usuário'));
    await tester.pumpAndSettle();

    expect(find.text('Senha definida pelo usuário'), findsOneWidget);
    expect(find.text('Senha'), findsNothing);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    Finder editable(String label) => find.descendant(
      of: find.widgetWithText(TextFormField, label),
      matching: find.byType(EditableText),
    );
    final nameFocus = tester.widget<EditableText>(editable('Nome')).focusNode;
    final emailFocus = tester.widget<EditableText>(editable('Email')).focusNode;
    final phoneFocus = tester
        .widget<EditableText>(editable('Telefone (opcional)'))
        .focusNode;
    nameFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(emailFocus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(phoneFocus.hasFocus, isTrue);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Operador Teste',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'operador@example.com',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(adminService.invitedPharmacyId, 9);
    expect(adminService.invitedUserName, 'Operador Teste');
    expect(adminService.invitedUserEmail, 'operador@example.com');
    expect(adminService.invitedUserRole, UserRole.pharmacyUser);
  });

  testWidgets('app admin resets a user password with visible requirements', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: const [
        {'ID': 9, 'NAME': 'Farmacia Central', 'IS_ACTIVE': true},
      ],
      users: const [
        {
          'ID': 18,
          'NAME': 'Administrador da farmacia',
          'EMAIL': 'farmacia@example.com',
          'USER_ROLE': 'pharmacy_admin',
          'IS_ACTIVE': true,
        },
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Farmácias').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usuários da farmácia'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Redefinir senha'));
    await tester.pumpAndSettle();

    expect(find.text('Sua senha deve:'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nova senha'),
      'senha123',
    );
    await tester.pump();
    expect(find.text('A confirmação da senha não confere.'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Confirme sua senha.'), findsOneWidget);
    expect(adminService.resetUserId, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar senha'),
      'senha123',
    );
    await tester.pump();
    expect(find.text('Ter pelo menos 8 caracteres'), findsOneWidget);
    expect(find.text('Ser igual nos dois campos'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(adminService.resetUserId, 18);
    expect(adminService.resetPassword, 'senha123');
  });

  testWidgets('app admin reviews and approves a pharmacy access request', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: const [
        {'ID': 9, 'NAME': 'Farmacia Central'},
      ],
      accessRequests: [
        PharmacyAccessRequestSummary(
          id: 21,
          pharmacyId: 9,
          pharmacyName: 'Farmacia Central',
          responsibleName: 'Maria Silva',
          email: 'maria@example.com',
          phone: '11999999999',
          maskedDocument: '***.***.***-4725',
          status: PharmacyAccessRequestStatus.pending,
          createdAt: DateTime(2026, 9, 4, 10),
          expiresAt: DateTime(2026, 10, 4, 10),
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'Solicitações'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('***.***.***-4725'), findsOneWidget);
    final approveAction = find.byTooltip('Aprovar solicitação');
    await tester.ensureVisible(approveAction);
    await tester.tap(approveAction);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Aprovar'));
    await tester.pumpAndSettle();

    expect(adminService.approvedAccessRequestId, 21);
    expect(
      find.text('Solicitação aprovada e convite enviado.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('app admin rejects access with a required justification', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      accessRequests: [
        PharmacyAccessRequestSummary(
          id: 22,
          pharmacyId: 9,
          pharmacyName: 'Farmácia Central',
          responsibleName: 'João Souza',
          email: 'joao@example.com',
          phone: '11999999999',
          maskedDocument: '***.***.***-0001',
          status: PharmacyAccessRequestStatus.pending,
          createdAt: DateTime(2026, 9, 4, 10),
          expiresAt: DateTime(2026, 10, 4, 10),
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'Solicitações'));
    await tester.pumpAndSettle();

    final rejectAction = find.byTooltip('Rejeitar solicitação');
    final rejectButton = find.ancestor(
      of: rejectAction,
      matching: find.byType(IconButton),
    );
    tester.widget<IconButton>(rejectButton).onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Rejeitar'));
    await tester.pump();
    expect(find.text('Informe a justificativa.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Justificativa'),
      'Documento divergente',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Rejeitar'));
    await tester.pumpAndSettle();

    expect(adminService.rejectedAccessRequestId, 22);
    expect(adminService.accessRejectionReason, 'Documento divergente');
    expect(find.text('Solicitação rejeitada.'), findsOneWidget);
  });

  testWidgets('address form validates required fields on a mobile viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = const AppUser(
        id: 12,
        name: 'Cliente',
        email: 'cliente@example.com',
        role: UserRole.customer,
      );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider(create: (_) => AddressController()),
        ],
        child: const MaterialApp(home: Scaffold(body: AddressModal())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar endereço'));
    await tester.pump();

    expect(find.text('Informe um CEP com 8 dígitos.'), findsOneWidget);
    expect(find.text('Campo obrigatório.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing an address keeps its ID and saves typed fields', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = const AppUser(
        id: 12,
        name: 'Cliente',
        email: 'cliente@example.com',
        role: UserRole.customer,
      );
    final service = _AddressServiceFake();
    final addresses = AddressController(service: service);
    addTearDown(auth.dispose);
    addTearDown(addresses.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<AddressController>.value(value: addresses),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: AddressModal(
              address: PostalAddress.fromJson({
                'ID': '17',
                'CEP': '01001000',
                'STREET': 'Rua Antiga',
                'NUMBER': '20',
                'CITY': 'Sao Paulo',
                'STATE': 'SP',
              }),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final street = find.byWidgetPredicate(
      (widget) =>
          widget is TextFormField && widget.controller?.text == 'Rua Antiga',
    );
    expect(tester.widget<TextFormField>(street).controller?.text, 'Rua Antiga');
    await tester.ensureVisible(street);
    await tester.enterText(street, 'Rua Atualizada');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Salvar endereço'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar endereço'));
    await tester.pumpAndSettle();

    expect(service.updatedId, 17);
    expect(service.updatedAddress?.street, 'Rua Atualizada');
    expect(service.updatedAddress?.cep, '01001000');
    expect(service.updatedAddress?.city, 'Sao Paulo');
    expect(service.updatedAddress?.isDefault, isTrue);
    expect(find.byType(AddressModal), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pharmacy inactivation explains impact and requires a reason', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(service: _FakeAuthService())
      ..token = 'valid-token'
      ..user = _appAdmin;
    final adminService = _FakeAdminService(
      pharmacies: [
        {'ID': 9, 'NAME': 'Farmacia Central', 'IS_ACTIVE': true},
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(home: AdminPage(service: adminService)),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Farmácias').first);
    await tester.pumpAndSettle();
    final deactivateButton = find.widgetWithText(OutlinedButton, 'Inativar');
    tester.widget<OutlinedButton>(deactivateButton).onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.textContaining('sairá da vitrine'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Inativar'));
    await tester.pump();
    expect(find.text('Informe o motivo.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo da inativação'),
      'Loja encerrada',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Inativar'));
    await tester.pumpAndSettle();
    expect(adminService.deactivatedPharmacyId, 9);
    expect(adminService.deactivationReason, 'Loja encerrada');
  });

  test('keeps a successful login when address loading fails', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AuthController(
      service: _FakeAuthService(
        loginUser: {
          'ID': 2,
          'NAME': 'Cliente',
          'EMAIL': 'cliente@example.com',
          'USER_ROLE': 'customer',
          'PHARMACY_ID': null,
        },
      ),
    );

    await controller.login(
      'cliente@example.com',
      'senha-segura',
      _FailingAddressController(),
    );

    expect(controller.isLogged, isTrue);
    expect(controller.user?.role, UserRole.customer);
    expect(await TokenStorage.getToken(), 'login-token');
  });

  for (final role in [
    UserRole.customer,
    UserRole.pharmacyAdmin,
    UserRole.appAdmin,
  ]) {
    testWidgets('login routes ${role.apiValue} to its authorized area', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final pharmacyId = role == UserRole.pharmacyAdmin ? 7 : null;
      final roleUser = {
        'ID': 2,
        'NAME': 'Conta SaveMed',
        'EMAIL': 'conta@example.com',
        'USER_ROLE': role.apiValue,
        'PHARMACY_ID': pharmacyId,
      };
      final size = role == UserRole.customer
          ? const Size(390, 844)
          : const Size(1280, 900);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final service = InventoryService(
        get: (path, {query}) async => http.Response('[]', 200),
      );
      final auth = AuthController(
        service: _FakeAuthService(loginUser: roleUser),
      );
      await tester.pumpWidget(
        MyApp(
          authController: auth,
          addressController: _FailingAddressController(),
          categoryController: CategoryController(
            categoryService: _EmptyCategoryService(),
          ),
          homeInventoryController: HomeInventoryController(service: service),
          adminService: _FakeAdminService(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo de volta'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'conta@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'senha-segura');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(auth.user?.role, role);
      if (role == UserRole.customer) {
        expect(find.byType(HomePage), findsOneWidget);
      } else {
        expect(find.byType(AdminPage), findsOneWidget);
        if (role == UserRole.pharmacyAdmin) {
          expect(find.text('Minha farmácia'), findsOneWidget);
          expect(find.text('Solicitações'), findsNothing);
          expect(find.text('Princípios ativos'), findsNothing);
          expect(find.text('Conteúdo do app'), findsNothing);
        } else {
          expect(find.text('Farmácias'), findsNWidgets(2));
          expect(find.text('Solicitações'), findsOneWidget);
          expect(find.text('Princípios ativos'), findsOneWidget);
          expect(find.text('Conteúdo do app'), findsOneWidget);
        }
      }
      expect(tester.takeException(), isNull);
    });
  }
}

class _FakeAuthService extends AuthService {
  Object? error;
  final Object? registerError;
  final Map<String, dynamic>? loginUser;
  final List<PharmacySearchResult> pharmacySearchResults;
  String? forgotPasswordEmail;
  String? resetPasswordEmail;
  String? resetPasswordCode;
  String? newPassword;
  PharmacyAccessRequest? accessRequest;
  String? registeredCustomerEmail;
  String? registeredSellerEmail;

  _FakeAuthService({
    this.error,
    this.registerError,
    this.loginUser,
    this.pharmacySearchResults = const [],
  });

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession.fromJson({
      'token': 'login-token',
      'user':
          loginUser ??
          {
            'ID': 1,
            'NAME': 'Administrador SaveMed',
            'EMAIL': 'admin@example.com',
            'USER_ROLE': 'app_admin',
            'PHARMACY_ID': null,
          },
    });
  }

  @override
  Future<AppUser> me() async {
    final currentError = error;
    if (currentError != null) throw currentError;

    return AppUser.fromJson({
      'ID': 1,
      'NAME': 'Administrador SaveMed',
      'EMAIL': 'admin@example.com',
      'USER_ROLE': 'app_admin',
      'PHARMACY_ID': null,
    });
  }

  @override
  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    final currentError = registerError;
    if (currentError != null) throw currentError;
    registeredCustomerEmail = email;
    return {'ID': 2};
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
    final currentError = registerError;
    if (currentError != null) throw currentError;
    registeredSellerEmail = email;
    return {'ID': 3};
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    forgotPasswordEmail = email;
    return 'Codigo enviado com sucesso';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    resetPasswordEmail = email;
    resetPasswordCode = code;
    newPassword = password;
    return 'Senha redefinida com sucesso';
  }

  @override
  Future<List<PharmacySearchResult>> searchPharmaciesForAccess(
    String query,
  ) async => pharmacySearchResults;

  @override
  Future<String> requestPharmacyAccess(PharmacyAccessRequest request) async {
    accessRequest = request;
    return 'Solicitacao enviada para analise.';
  }
}

class _FailingAddressController extends AddressController {
  @override
  Future<void> load(int userId) async {
    throw const ApiConnectionException('Sem conexao');
  }
}

class _AddressServiceFake extends AddressService {
  int? updatedId;
  PostalAddress? updatedAddress;

  @override
  Future<List<PostalAddress>> getUserAddresses(int userId) async => [];

  @override
  Future<void> updateAddress(int id, PostalAddress address) async {
    updatedId = id;
    updatedAddress = address;
  }
}

class _EmptyCategoryService extends CategoryService {
  @override
  Future<List<Category>> getCategories() async => [];
}

class _FakeAdminService extends AdminService {
  final List<dynamic> orders;
  final List<dynamic> pharmacies;
  final List<dynamic> users;
  final List<dynamic> categories;
  final List<dynamic> activeIngredients;
  final List<PharmacyAccessRequestSummary> accessRequests;
  Object? categoryError;
  int? refundedOrderId;
  String? refundReason;
  int? updatedUserId;
  bool? updatedUserActive;
  int? deactivatedPharmacyId;
  String? deactivationReason;
  int? resentInvitationUserId;
  int? approvedAccessRequestId;
  int? rejectedAccessRequestId;
  String? accessRejectionReason;
  int? invitedPharmacyId;
  String? invitedUserName;
  String? invitedUserEmail;
  UserRole? invitedUserRole;
  int? resetUserId;
  String? resetPassword;

  _FakeAdminService({
    this.orders = const [],
    this.pharmacies = const [],
    this.users = const [],
    this.categories = const [],
    this.activeIngredients = const [],
    this.accessRequests = const [],
  });

  @override
  Future<List<Pharmacy>> listPharmacies() async => pharmacies
      .whereType<Map<String, dynamic>>()
      .map(Pharmacy.fromJson)
      .toList();

  @override
  Future<List<AppUser>> listPharmacyUsers(int pharmacyId) async =>
      users.whereType<Map<String, dynamic>>().map(AppUser.fromJson).toList();

  @override
  Future<void> updateUserStatus(int userId, {required bool isActive}) async {
    updatedUserId = userId;
    updatedUserActive = isActive;
  }

  @override
  Future<void> deactivatePharmacy(int id, {required String reason}) async {
    deactivatedPharmacyId = id;
    deactivationReason = reason;
  }

  @override
  Future<List<Category>> listCategories({int? pharmacyId}) async {
    final currentError = categoryError;
    if (currentError != null) throw currentError;
    return categories
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  @override
  Future<void> resendUserInvitation(int userId) async {
    resentInvitationUserId = userId;
  }

  @override
  Future<String> invitePharmacyUser({
    required int pharmacyId,
    required String name,
    required String email,
    required UserRole role,
    String? phone,
  }) async {
    invitedPharmacyId = pharmacyId;
    invitedUserName = name;
    invitedUserEmail = email;
    invitedUserRole = role;
    return 'Convite enviado com sucesso.';
  }

  @override
  Future<void> resetUserPassword(int userId, String password) async {
    resetUserId = userId;
    resetPassword = password;
  }

  @override
  Future<List<PharmacyAccessRequestSummary>> listAccessRequests({
    String? query,
    PharmacyAccessRequestStatus? status,
    int? pharmacyId,
    DateTime? from,
    DateTime? to,
  }) async => accessRequests;

  @override
  Future<String> approveAccessRequest(int id, {String? reason}) async {
    approvedAccessRequestId = id;
    return 'Solicitação aprovada e convite enviado.';
  }

  @override
  Future<String> rejectAccessRequest(int id, {required String reason}) async {
    rejectedAccessRequestId = id;
    accessRejectionReason = reason;
    return 'Solicitação rejeitada.';
  }

  @override
  Future<List<Medication>> listMedications({int? pharmacyId}) async => [];

  @override
  Future<List<ActiveIngredient>> listActiveIngredients({
    int? pharmacyId,
  }) async => activeIngredients
      .map(
        (item) => item is ActiveIngredient
            ? item
            : ActiveIngredient.fromJson(item as Map<String, dynamic>),
      )
      .toList();

  @override
  Future<List<AdminInventoryItem>> listInventory({int? pharmacyId}) async => [];

  @override
  Future<List<Promotion>> listHighlights({int? pharmacyId}) async => [];

  @override
  Future<List<CustomerOrder>> listOrders({int? pharmacyId}) async => orders
      .whereType<Map<String, dynamic>>()
      .map(CustomerOrder.fromJson)
      .toList();

  @override
  Future<FinancialSummary> getFinancialSummary({int? pharmacyId}) async =>
      FinancialSummary(
        orders: 0,
        totalAmount: 0,
        paidOrders: 0,
        paidAmount: 0,
        pendingOrders: 0,
        pendingAmount: 0,
        refundedOrders: 0,
        refundedAmount: 0,
        failedOrders: 0,
        failedAmount: 0,
        canceledOrders: 0,
        pharmacyId: pharmacyId,
      );

  @override
  Future<void> refundOrder(int id, {required String reason}) async {
    refundedOrderId = id;
    refundReason = reason;
  }
}
