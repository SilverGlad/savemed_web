import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/api/api_response.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/features/admin/admin_page.dart';
import 'package:savemed/models/active_ingredient.dart';
import 'package:savemed/models/admin_inventory_item.dart';
import 'package:savemed/models/category.dart';
import 'package:savemed/models/customer_order.dart';
import 'package:savemed/models/content_block.dart';
import 'package:savemed/models/financial_summary.dart';
import 'package:savemed/models/medication.dart';
import 'package:savemed/models/pharmacy.dart';
import 'package:savemed/models/promotion.dart';
import 'package:savemed/models/subcategory.dart';
import 'package:savemed/models/user.dart';

Finder input(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Finder dropdown(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is DropdownMenu<int> &&
      widget.label is Text &&
      (widget.label as Text).data == label,
);

void expectSemanticTextField(WidgetTester tester, Finder finder, String label) {
  expect(finder, findsOneWidget, reason: 'Missing field widget: $label');
  final data = tester.getSemantics(finder).getSemanticsData();
  expect(
    data.flagsCollection.isTextField,
    isTrue,
    reason: '$label is not a field',
  );
  expect(data.label, contains(label), reason: 'Missing semantic label: $label');
}

Future<void> fill(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(input(label));
  await tester.enterText(input(label), value);
  await tester.pump();
}

Future<void> fillLast(WidgetTester tester, String label, String value) async {
  final field = input(label).last;
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> select(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(dropdown(label));
  await tester.tap(dropdown(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> openSection(WidgetTester tester, String section) async {
  final menu = find.byTooltip('Abrir menu');
  if (menu.evaluate().isNotEmpty) {
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(InkWell, section),
      150,
      scrollable: find
          .descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }
  await tester.tap(find.widgetWithText(InkWell, section));
  await tester.pumpAndSettle();
}

Future<void> command(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label).first;
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> mount(
  WidgetTester tester,
  AdminService service,
  double width, {
  double textScale = 1,
  AuthController? session,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final auth =
      session ??
      (AuthController()
        ..user = const AppUser(
          id: 1,
          name: 'Admin',
          email: 'qa@example.com',
          role: UserRole.appAdmin,
        )
        ..token = 'isolated-test');
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: AdminPage(service: service),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    if (!kIsWeb) {
      await (FontLoader('Montserrat')
            ..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf')))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  for (final (role, pharmacyId, active) in [
    (UserRole.pharmacyAdmin, null, true),
    (UserRole.pharmacyAdmin, 1, false),
    (UserRole.appAdmin, null, false),
  ]) {
    testWidgets(
      'denies invalid admin scope $role/$pharmacyId/$active before loading data',
      (tester) async {
        final auth = AuthController()
          ..user = AppUser(
            id: 1,
            name: 'Conta sem acesso',
            email: 'blocked@example.invalid',
            role: role,
            pharmacyId: pharmacyId,
            isActive: active,
          )
          ..token = 'isolated-test';
        final service = _ScopedFormService();
        await mount(tester, service, 390, session: auth);
        expect(find.text('Acesso administrativo indisponível'), findsOneWidget);
        expect(service.pharmacyReads, 0);
        expect(service.categoryReads, 0);
        expect(find.byTooltip('Abrir menu'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('app administrator sees platform management sections', (
    tester,
  ) async {
    await mount(tester, _FormService(), 1280);

    for (final label in [
      'Farm\u00e1cias',
      'Solicita\u00e7\u00f5es',
      'Princ\u00edpios ativos',
      'Conteúdo do app',
    ]) {
      expect(find.widgetWithText(InkWell, label), findsOneWidget);
    }
    expect(find.widgetWithText(InkWell, 'Minha farm\u00e1cia'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final fails in [false, true]) {
    testWidgets(
      'late product options do not open a form in another session (fails: $fails)',
      (tester) async {
        final auth = _MutableSession()..switchPharmacy(1);
        final service = _ScopedFormService();
        await mount(tester, service, 1280, session: auth);
        await openSection(tester, 'Produtos');
        final gate = Completer<void>();
        service.oldCatalogGate = gate.future;
        await tester.tap(
          find.widgetWithText(FilledButton, 'Novo produto').first,
        );
        await tester.pump();
        auth.switchPharmacy(2);
        if (fails) {
          gate.completeError(const ApiResponseException('Unavailable', 503));
        } else {
          gate.complete();
        }
        await tester.idle();
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
        expect(service.productPayload, isNull);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'late catalog response cannot replace the new pharmacy (fails: $fails)',
      (tester) async {
        final auth = _MutableSession()..switchPharmacy(1);
        final service = _ScopedFormService();
        await mount(tester, service, 1280, session: auth);
        final gate = Completer<void>();
        service.oldCatalogGate = gate.future;
        await tester.tap(find.widgetWithText(InkWell, 'Categorias'));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        auth.switchPharmacy(2);
        await tester.pumpAndSettle();
        expect(find.text('Categoria B'), findsOneWidget);
        if (fails) {
          gate.completeError(const ApiResponseException('Unavailable', 503));
        } else {
          gate.complete();
        }
        await tester.pumpAndSettle();
        expect(find.text('Categoria B'), findsOneWidget);
        expect(find.text('Categoria A'), findsNothing);
        expect(find.text('Tentar novamente'), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'save failure between session change and rebuild stays in the old session',
    (tester) async {
      final auth = _MutableSession()..switchPharmacy(1);
      final gate = Completer<void>();
      final service = _ScopedFormService()
        ..saveGate = gate.future
        ..saveError = const ApiResponseException('Unavailable', 503);
      await mount(tester, service, 1280, session: auth);
      await openSection(tester, 'Categorias');
      await command(tester, 'Nova categoria');
      await fill(tester, 'Nome', 'Cadastro da conta anterior');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pump();
      auth.switchPharmacy(2);
      gate.complete();
      // Let the old request finish before the next frame replaces its page.
      await tester.idle();
      await tester.pumpAndSettle();
      expect(find.text('Sessão alterada'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(service.categoryPayload, isNull);
      await tester.tap(find.widgetWithText(TextButton, 'Fechar'));
      await tester.pumpAndSettle();
      expect(find.text('Categoria B'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('changing pharmacy session replaces previously loaded catalog', (
    tester,
  ) async {
    final auth = _MutableSession()..switchPharmacy(1);
    final service = _ScopedFormService();
    await mount(tester, service, 1280, session: auth);
    await openSection(tester, 'Categorias');
    expect(find.text('Categoria A'), findsOneWidget);
    expect(find.text('Categoria B'), findsNothing);
    expect(find.widgetWithText(InkWell, 'Minha farm\u00e1cia'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Farm\u00e1cias'), findsNothing);
    for (final label in [
      'Solicitações',
      'Princípios ativos',
      'Conteúdo do app',
    ]) {
      expect(find.widgetWithText(InkWell, label), findsNothing);
    }
    auth.switchPharmacy(2);
    await tester.pumpAndSettle();
    expect(find.text('Categoria A'), findsNothing);
    expect(find.text('Categoria B'), findsOneWidget);
    await command(tester, 'Nova categoria');
    expect(
      tester.widget<DropdownMenu<int>>(dropdown('Farmácia')).enabled,
      isFalse,
    );
    await fill(tester, 'Nome', 'Categoria vinculada');
    await command(tester, 'Salvar');
    expect(service.categoryPayload?['PHARMACY_ID'], 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'category form tabs from name to pharmacy selector',
    (tester) async {
      await mount(tester, _FormService(), 1280);
      await openSection(tester, 'Categorias');
      await command(tester, 'Nova categoria');

      final nameField = tester.widget<EditableText>(
        find.descendant(of: input('Nome'), matching: find.byType(EditableText)),
      );
      final pharmacyField = tester.widget<EditableText>(
        find.descendant(
          of: dropdown('Farmácia'),
          matching: find.byType(EditableText),
        ),
      );

      nameField.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(pharmacyField.focusNode.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'product form tabs through its first fields in reading order',
    (tester) async {
      await mount(tester, _FormService(), 1280);
      await openSection(tester, 'Produtos');
      await command(tester, 'Novo produto');

      EditableText editable(String label) => tester.widget<EditableText>(
        find.descendant(of: input(label), matching: find.byType(EditableText)),
      );
      final name = editable('Nome');
      final description = editable('Descrição');
      final brand = editable('Marca');
      name.focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(description.focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(brand.focusNode.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'pharmacy form tabs through identity and address fields in reading order',
    (tester) async {
      await mount(tester, _FormService(), 1280);
      await openSection(tester, 'Farmácias');
      await command(tester, 'Nova farmácia');

      EditableText editable(String label) => tester.widget<EditableText>(
        find.descendant(of: input(label), matching: find.byType(EditableText)),
      );
      final fields = [
        editable('Nome'),
        editable('CNPJ'),
        editable('Telefone'),
        editable('Cidade'),
        editable('UF'),
        editable('CEP'),
      ];
      fields.first.focusNode.requestFocus();
      await tester.pump();

      for (final field in fields.skip(1)) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(field.focusNode.hasFocus, isTrue);
      }
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('product and inventory forms expose searchable field labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await mount(tester, _FormService(), 1280);
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');

    for (final label in [
      'Nome',
      'Descrição',
      'Marca',
      'Unidade (ex.: caixa, frasco)',
      'Código de barras (EAN)',
    ]) {
      expectSemanticTextField(tester, input(label), label);
    }
    for (final label in ['Farmácia', 'Categoria', 'Subcategoria']) {
      final editable = find.descendant(
        of: dropdown(label),
        matching: find.byType(EditableText),
      );
      expectSemanticTextField(tester, editable, label);
    }
    final prescription = find.widgetWithText(
      SwitchListTile,
      'Exige receita médica',
    );
    final prescriptionData = tester
        .getSemantics(prescription)
        .getSemanticsData();
    expect(prescriptionData.label, contains('Exige receita médica'));
    expect(prescriptionData.hasAction(SemanticsAction.tap), isTrue);
    final imagePicker = find.widgetWithText(FilledButton, 'Selecionar');
    expect(imagePicker, findsOneWidget);
    expect(
      tester
          .getSemantics(imagePicker)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(find.text('Cancelar').last);
    await tester.pumpAndSettle();
    await openSection(tester, 'Inventário');
    await command(tester, 'Novo item');
    for (final label in [
      'Farmácia',
      'Produto',
      'Preço',
      'Preço original',
      'Estoque',
    ]) {
      final field = label == 'Farmácia' || label == 'Produto'
          ? find.descendant(
              of: dropdown(label),
              matching: find.byType(EditableText),
            )
          : input(label);
      expectSemanticTextField(tester, field, label);
    }

    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inventory form tabs from product to price and stock fields',
    (tester) async {
      await mount(tester, _FormService(), 1280);
      await openSection(tester, 'Inventário');
      await command(tester, 'Novo item');
      await select(tester, 'Farmácia', 'Farmácia A');

      EditableText editable(String label) => tester.widget<EditableText>(
        find.descendant(of: input(label), matching: find.byType(EditableText)),
      );
      final product = tester.widget<EditableText>(
        find.descendant(
          of: dropdown('Produto'),
          matching: find.byType(EditableText),
        ),
      );
      final fields = [
        editable('Preço'),
        editable('Preço original'),
        editable('Estoque'),
      ];
      product.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      for (final field in fields) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(field.focusNode.hasFocus, isTrue);
      }
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'promotion form tabs from product to discount field',
    (tester) async {
      await mount(tester, _FormService(), 1280);
      await openSection(tester, 'Promoções');
      await command(tester, 'Nova promoção');
      await select(tester, 'Farmácia', 'Farmácia A');

      final product = tester.widget<EditableText>(
        find.descendant(
          of: dropdown('Produto'),
          matching: find.byType(EditableText),
        ),
      );
      final discount = tester.widget<EditableText>(
        find.descendant(
          of: input('Desconto (%)'),
          matching: find.byType(EditableText),
        ),
      );
      product.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(discount.focusNode.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('a form from another session cannot submit or reveal its draft', (
    tester,
  ) async {
    final auth = _MutableSession()..switchPharmacy(1);
    final service = _ScopedFormService();
    await mount(tester, service, 1280, session: auth);
    await openSection(tester, 'Categorias');
    await command(tester, 'Nova categoria');
    await fill(tester, 'Nome', 'Rascunho da farmacia anterior');
    final oldSave = tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'))
        .onPressed!;
    auth.switchPharmacy(2);
    oldSave();
    await tester.pumpAndSettle();
    expect(find.text('Sessão alterada'), findsOneWidget);
    expect(input('Nome'), findsNothing);
    expect(service.categorySaveIds, isEmpty);
    await tester.tap(find.widgetWithText(TextButton, 'Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Categoria B'), findsOneWidget);
    expect(find.text('Categoria A'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('session change during save never confirms in the new account', (
    tester,
  ) async {
    final gate = Completer<void>();
    final auth = _MutableSession()..switchPharmacy(1);
    final service = _ScopedFormService()..saveGate = gate.future;
    await mount(tester, service, 1280, session: auth);
    await openSection(tester, 'Categorias');
    await command(tester, 'Nova categoria');
    await fill(tester, 'Nome', 'Cadastro em andamento');
    await tester.ensureVisible(find.byTooltip('Medicamentos'));
    await tester.tap(find.byTooltip('Medicamentos'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pump();
    auth.switchPharmacy(2);
    await tester.pump();
    expect(find.text('Sessão alterada'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Fechar'))
          .onPressed,
      isNull,
    );
    gate.complete();
    await tester.pumpAndSettle();
    expect(service.categoryPayload?['PHARMACY_ID'], 1);
    expect(service.categorySaveIds, [null]);
    expect(service.uploads, 0);
    expect(find.text('Alteracao salva com sucesso.'), findsNothing);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Fechar'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Categoria B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text overview and image form remain readable', (
    tester,
  ) async {
    await mount(tester, _FormService(), 390, textScale: 2);
    await expectLater(
      find.byType(AdminPage),
      matchesGoldenFile('goldens/overview_large_text_390.png'),
    );
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');
    await tester.ensureVisible(find.text('Selecionar'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AlertDialog),
      matchesGoldenFile('goldens/product_image_large_text_390.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'expired session keeps category draft and does not confirm a save',
    (tester) async {
      final service = _FormService()
        ..saveError = const ApiResponseException('Unauthorized', 401);
      await mount(tester, service, 390);
      await openSection(tester, 'Categorias');
      await command(tester, 'Nova categoria');
      await fill(tester, 'Nome', 'Rascunho preservado');
      await select(tester, 'Farmácia', 'Farmácia A');
      await command(tester, 'Salvar');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        tester.widget<TextField>(input('Nome')).controller!.text,
        'Rascunho preservado',
      );
      expect(find.textContaining('Sua sessão expirou'), findsOneWidget);
      expect(find.textContaining('Seus dados foram mantidos'), findsOneWidget);
      expect(find.text('Alteracao salva com sucesso.'), findsNothing);
      expect(service.categoryPayload, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'repeated save callback submits only one in-flight category request',
    (tester) async {
      final gate = Completer<void>();
      final service = _FormService()..saveGate = gate.future;
      await mount(tester, service, 390);
      await openSection(tester, 'Categorias');
      await command(tester, 'Nova categoria');
      await fill(tester, 'Nome', 'Categoria unica');
      await select(tester, 'Farmácia', 'Farmácia A');
      final save = tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Salvar'))
          .onPressed!;
      save();
      save();
      await tester.pump();
      expect(service.categorySaveIds, [null]);
      expect(service.uploads, 0);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(service.categorySaveIds, [null]);
      expect(tester.takeException(), isNull);
    },
  );

  for (final fails in [false, true]) {
    testWidgets('system back waits for category save (fails: $fails)', (
      tester,
    ) async {
      final gate = Completer<void>();
      final service = _FormService()
        ..saveGate = gate.future
        ..saveError = fails
            ? const ApiResponseException('Unavailable', 503)
            : null;
      await mount(tester, service, 390);
      await openSection(tester, 'Categorias');
      await command(tester, 'Nova categoria');
      await fill(tester, 'Nome', 'Categoria em andamento');
      await select(tester, 'Farmácia', 'Farmácia A');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(service.categorySaveIds, [null]);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Cancelar'))
            .onPressed,
        isNull,
      );
      gate.complete();
      await tester.pumpAndSettle();
      if (fails) {
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          tester.widget<TextField>(input('Nome')).controller!.text,
          'Categoria em andamento',
        );
        expect(service.categoryPayload, isNull);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      } else {
        expect(service.categoryPayload?['NAME'], 'Categoria em andamento');
      }
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('category retry keeps persisted ID when image upload fails', (
    tester,
  ) async {
    final service = _FormService()..failUpload = true;
    await mount(tester, service, 390);
    await openSection(tester, 'Categorias');
    await command(tester, 'Nova categoria');
    await fill(tester, 'Nome', 'Categoria UI');
    await select(tester, 'Farmácia', 'Farmácia A');
    final icon = find.byTooltip('Medicamentos');
    await tester.ensureVisible(icon);
    await tester.tap(icon);
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();
    expect(service.categorySaveIds, [null]);
    expect(find.textContaining('Seus dados foram mantidos'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      tester.widget<TextField>(input('Nome')).controller!.text,
      'Categoria UI',
    );
    service.failUpload = false;
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();
    expect(service.categorySaveIds, [null, 30]);
    expect(service.uploads, 2);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Categoria UI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product image retry updates the same persisted product', (
    tester,
  ) async {
    final image = await rootBundle.load('assets/images/editorial/family.jpeg');
    final bytes = image.buffer.asUint8List(
      image.offsetInBytes,
      image.lengthInBytes,
    );
    FilePicker.platform = _TestFilePicker(bytes);
    final service = _FormService()..failMedicationUpload = true;
    await mount(tester, service, 390);
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');
    await fill(tester, 'Nome', 'Produto com imagem');
    await select(tester, 'Farmácia', 'Farmácia A');
    await select(tester, 'Categoria', 'Categoria A');
    await command(tester, 'Selecionar');
    expect(find.text('family.jpeg'), findsOneWidget);

    await command(tester, 'Salvar');
    expect(service.productSaveIds, [null]);
    expect(service.medicationUploads, 1);
    expect(find.textContaining('Seus dados foram mantidos'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);

    service.failMedicationUpload = false;
    await command(tester, 'Salvar');
    expect(service.productSaveIds, [null, 300]);
    expect(service.medicationUploads, 2);
    expect(
      service.products.where((product) => product['ID'] == 300),
      hasLength(1),
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Produto com imagem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app content image retry updates the same persisted block', (
    tester,
  ) async {
    final image = await rootBundle.load('assets/images/editorial/family.jpeg');
    final bytes = image.buffer.asUint8List(
      image.offsetInBytes,
      image.lengthInBytes,
    );
    FilePicker.platform = _TestFilePicker(bytes);
    final service = _FormService()..failContentUpload = true;
    await mount(tester, service, 390);
    await openSection(tester, 'Conteúdo do app');
    await command(tester, 'Novo conteúdo');
    await fill(tester, 'Identificador', 'conteudo-com-imagem');
    await fill(tester, 'Título', 'Conteúdo com imagem');
    await command(tester, 'Selecionar');
    expect(find.text('family.jpeg'), findsOneWidget);

    await command(tester, 'Salvar');
    expect(service.contentSaveIds, [null]);
    expect(service.contentUploads, 1);
    expect(find.textContaining('Seus dados foram mantidos'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);

    service.failContentUpload = false;
    await command(tester, 'Salvar');
    expect(service.contentSaveIds, [null, 1]);
    expect(service.contentUploads, 2);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Conteúdo com imagem'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('oversized product image is rejected before upload', (
    tester,
  ) async {
    FilePicker.platform = _TestFilePicker(Uint8List(5 * 1024 * 1024 + 1));
    final service = _FormService();
    await mount(tester, service, 390);
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');
    await command(tester, 'Selecionar');

    expect(find.textContaining('5 MB'), findsOneWidget);
    expect(find.text('family.jpeg'), findsNothing);
    expect(service.medicationUploads, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('image byte limit is enforced despite a smaller reported size', (
    tester,
  ) async {
    final picker = _TestFilePicker(
      Uint8List(10 * 1024 * 1024 + 1),
      reportedSize: 1,
    );
    FilePicker.platform = picker;
    final service = _FormService();
    await mount(tester, service, 390);
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');
    await command(tester, 'Selecionar');

    expect(find.textContaining('5 MB'), findsOneWidget);
    expect(find.text('family.jpeg'), findsNothing);
    expect(service.medicationUploads, 0);
    expect(picker.chunksRead, 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid selected image shows a preview fallback', (
    tester,
  ) async {
    FilePicker.platform = _TestFilePicker(Uint8List.fromList([0, 1, 2, 3]));
    await mount(tester, _FormService(), 390);
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');
    await command(tester, 'Selecionar');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    final enlargeButton = find.widgetWithText(TextButton, 'Ampliar imagem');
    await tester.ensureVisible(enlargeButton);
    await tester.tap(enlargeButton);
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar a imagem.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pharmacy can create and assign an active ingredient', (
    tester,
  ) async {
    final service = _FormService();
    final pharmacyAdmin = AuthController()
      ..user = const AppUser(
        id: 3,
        name: 'Responsável',
        email: 'farmacia@example.com',
        role: UserRole.pharmacyAdmin,
        pharmacyId: 1,
      )
      ..token = 'pharmacy-session';
    await mount(tester, service, 390, session: pharmacyAdmin);
    await openSection(tester, 'Produtos');
    await command(tester, 'Novo produto');
    await fill(tester, 'Nome', 'Produto com princípio ativo');
    await select(tester, 'Categoria', 'Categoria A');
    final addIngredient = find.byTooltip('Cadastrar princípio ativo');
    await tester.ensureVisible(addIngredient);
    await tester.tap(addIngredient);
    await tester.pumpAndSettle();
    await fillLast(tester, 'Nome', 'Ibuprofeno');
    await command(tester, 'Adicionar');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilterChip, 'Ibuprofeno'), findsOneWidget);
    expect(service.ingredientPayload?['NAME'], 'Ibuprofeno');
    final ingredientChip = find.widgetWithText(FilterChip, 'Ibuprofeno');
    await tester.ensureVisible(ingredientChip);
    expect(tester.widget<FilterChip>(ingredientChip).selected, isTrue);
    await command(tester, 'Salvar');
    expect(service.productPayload?['activeIngredientIds'], [1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category list exposes subcategory management', (tester) async {
    final service = _FormService();
    await mount(tester, service, 1280);
    await openSection(tester, 'Categorias');
    await tester.tap(find.byTooltip('Gerenciar subcategorias').first);
    await tester.pumpAndSettle();

    expect(find.text('Subcategorias de Categoria A'), findsOneWidget);
    await command(tester, 'Adicionar subcategoria');
    await fill(tester, 'Nome', 'Dermocosméticos');
    await command(tester, 'Salvar');
    await tester.pumpAndSettle();

    expect(service.subcategoryPayload?['CATEGORY_ID'], 10);
    expect(service.subcategoryPayload?['NAME'], 'Dermocosméticos');
    expect(find.text('Dermocosméticos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('subcategory editing and deletion require the intended actions', (
    tester,
  ) async {
    final service = _FormService();
    await mount(tester, service, 1280);
    await openSection(tester, 'Categorias');
    await tester.tap(find.byTooltip('Gerenciar subcategorias').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar subcategoria'));
    await tester.pumpAndSettle();
    await fill(tester, 'Nome', 'Dermocosméticos');
    await command(tester, 'Salvar');
    await tester.pumpAndSettle();

    expect(service.subcategoryPayload?['CATEGORY_ID'], 10);
    expect(service.subcategoryPayload?['NAME'], 'Dermocosméticos');
    expect(
      service.subcategories.singleWhere((item) => item['ID'] == 11)['NAME'],
      'Dermocosméticos',
    );

    await tester.tap(find.byTooltip('Excluir subcategoria'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();
    expect(service.subcategories, hasLength(1));

    await tester.tap(find.byTooltip('Excluir subcategoria'));
    await tester.pumpAndSettle();
    await command(tester, 'Excluir');
    await tester.pumpAndSettle();
    expect(service.subcategories, isEmpty);
    expect(find.text('Dermocosméticos'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (width, textScale) in [
    (390.0, 1.0),
    (1280.0, 1.0),
    (390.0, 2.0),
    (320.0, 2.0),
  ]) {
    testWidgets(
      'creates active ingredient and editorial content at $width px scale $textScale',
      (tester) async {
        final service = _FormService();
        await mount(tester, service, width, textScale: textScale);
        await openSection(tester, 'Princípios ativos');
        await command(tester, 'Novo princípio ativo');
        await fill(tester, 'Nome', 'Princípio Teste UI');
        await select(tester, 'Farmácia', 'Farmácia A');
        await command(tester, 'Salvar');
        expect(service.ingredientPayload?['NAME'], 'Princípio Teste UI');
        expect(find.text('Princípio Teste UI'), findsOneWidget);
        await openSection(tester, 'Conteúdo do app');
        await command(tester, 'Novo conteúdo');
        await command(tester, 'Salvar');
        expect(service.contentPayload, isNull);
        await fill(tester, 'Identificador', 'banner-teste-ui');
        await fill(tester, 'Título', 'Conteúdo Teste UI');
        await command(tester, 'Salvar');
        expect(service.contentPayload?['SLUG'], 'banner-teste-ui');
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Conteúdo Teste UI'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'creates and edits pharmacy through UI at $width px scale $textScale',
      (tester) async {
        final service = _FormService();
        await mount(tester, service, width, textScale: textScale);
        await openSection(tester, 'Farmácias');
        await command(tester, 'Nova farmácia');
        await command(tester, 'Salvar');
        expect(service.pharmacyPayload, isNull);
        expect(find.text('Informe uma UF válida.'), findsOneWidget);
        await fill(tester, 'Nome', 'Farmácia Teste UI');
        await fill(tester, 'CNPJ', '04252011000110');
        await fill(tester, 'Telefone', '11999999999');
        await fill(tester, 'Cidade', 'São Paulo');
        await fill(tester, 'UF', 'sp');
        await fill(tester, 'CEP', '01001000');
        await command(tester, 'Salvar');
        expect(service.pharmacyPayload?['CNPJ'], '04252011000110');
        expect(service.pharmacyPayload?['STATE'], 'SP');
        expect(find.byType(AlertDialog), findsNothing);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        if (width < 760) {
          await tester.scrollUntilVisible(
            find.text('Farmácia Teste UI'),
            150,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
        }
        expect(find.text('Farmácia Teste UI'), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Editar').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Editar').last);
        await tester.pumpAndSettle();
        expect(
          find.text('Imagem da farmácia (PNG, JPEG ou WebP)'),
          findsOneWidget,
        );
        expect(find.text('Entrega própria'), findsOneWidget);
        final ownDeliverySwitch = find.ancestor(
          of: find.text('Entrega própria'),
          matching: find.byType(SwitchListTile),
        );
        await tester.ensureVisible(ownDeliverySwitch);
        await tester.tap(ownDeliverySwitch);
        await tester.pumpAndSettle();
        expect(find.text('Raio máximo km'), findsOneWidget);
        await tester.tap(ownDeliverySwitch);
        await tester.pumpAndSettle();
        await fill(tester, 'Nome', 'Farmácia Editada UI');
        await command(tester, 'Salvar');
        expect(service.pharmacyId, 3);
        expect(find.text('Farmácia Editada UI'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'creates product with dependent category selectors at $width px scale $textScale',
      (tester) async {
        final service = _FormService();
        await mount(tester, service, width, textScale: textScale);
        await openSection(tester, 'Produtos');
        await command(tester, 'Novo produto');
        await fill(tester, 'Nome', 'Produto UI');
        await select(tester, 'Farmácia', 'Farmácia A');
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Categoria'))
              .dropdownMenuEntries
              .map((e) => e.label),
          ['Categoria A'],
        );
        await select(tester, 'Categoria', 'Categoria A');
        await select(tester, 'Subcategoria', 'Subcategoria A');
        await select(tester, 'Farmácia', 'Farmácia B');
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Categoria'))
              .initialSelection,
          isNull,
        );
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Subcategoria'))
              .initialSelection,
          isNull,
        );
        await command(tester, 'Salvar');
        expect(service.productPayload, isNull);
        await select(tester, 'Categoria', 'Categoria B');
        await tester.ensureVisible(find.text('Exige receita médica'));
        await tester.tap(find.text('Exige receita médica'));
        await command(tester, 'Salvar');
        expect(service.productPayload?['PHARMACY_ID'], 2);
        expect(service.productPayload?['CATEGORY_ID'], 20);
        expect(service.productPayload?['SUBCATEGORY_ID'], isNull);
        expect(service.productPayload?['REQUIRES_RX'], isTrue);
        expect(find.byType(AlertDialog), findsNothing);
        if (width < 760) {
          await tester.scrollUntilVisible(
            find.text('Produto UI'),
            150,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
        }
        expect(find.text('Produto UI'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'repairs a legacy cross-category subcategory at $width px scale $textScale',
      (tester) async {
        final service = _FormService();
        service.products[1]['SUBCATEGORY_ID'] = 11;
        await mount(tester, service, width, textScale: textScale);
        await openSection(tester, 'Produtos');
        final editProduct = find.byTooltip('Editar').last;
        await tester.ensureVisible(editProduct);
        await tester.pumpAndSettle();
        await tester.tap(editProduct);
        await tester.pumpAndSettle();

        expect(find.text('Subcategoria incompatível'), findsOneWidget);
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Subcategoria'))
              .initialSelection,
          isNull,
        );

        await command(tester, 'Salvar');
        expect(service.productPayload?['SUBCATEGORY_ID'], isNull);
        expect(service.productSaveIds, [200]);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'inventory and promotion select only pharmacy products at $width px scale $textScale',
      (tester) async {
        final service = _FormService();
        await mount(tester, service, width, textScale: textScale);
        await openSection(tester, 'Inventário');
        expect(find.text('Inventário'), findsWidgets);
        await command(tester, 'Novo item');
        await select(tester, 'Farmácia', 'Farmácia A');
        await select(tester, 'Produto', 'Produto A');
        await select(tester, 'Farmácia', 'Farmácia B');
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Produto'))
              .initialSelection,
          isNull,
        );
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Produto'))
              .dropdownMenuEntries
              .map((e) => e.label),
          ['Produto B'],
        );
        await select(tester, 'Produto', 'Produto B');
        await fill(tester, 'Preço', '12,50');
        await fill(tester, 'Preço original', '10');
        await fill(tester, 'Estoque', '5');
        await command(tester, 'Salvar');
        expect(service.inventoryPayload, isNull);
        await fill(tester, 'Preço original', '15');
        await command(tester, 'Salvar');
        expect(service.inventoryPayload?['PRICE'], 12.5);
        expect(service.inventoryPayload?['PHARMACY_ID'], 2);
        expect(service.inventoryPayload?['MEDICATION_ID'], 200);
        expect(find.byType(AlertDialog), findsNothing);
        await openSection(tester, 'Promoções');
        await command(tester, 'Nova promoção');
        await select(tester, 'Farmácia', 'Farmácia B');
        expect(
          tester
              .widget<DropdownMenu<int>>(dropdown('Produto'))
              .dropdownMenuEntries
              .map((e) => e.label),
          ['Produto B'],
        );
        await select(tester, 'Produto', 'Produto B');
        await fill(tester, 'Desconto (%)', '101');
        await command(tester, 'Salvar');
        expect(service.promotionPayload, isNull);
        await fill(tester, 'Desconto (%)', '10');
        await command(tester, 'Salvar');
        expect(service.promotionPayload?['MEDICATION_ID'], 200);
        expect(service.promotionPayload?['DISCOUNT_PERCENTAGE'], 10);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _MutableSession extends AuthController {
  void switchPharmacy(int pharmacyId) {
    user = AppUser(
      id: pharmacyId,
      name: 'Gestor $pharmacyId',
      email: 'gestor$pharmacyId@example.invalid',
      role: UserRole.pharmacyAdmin,
      pharmacyId: pharmacyId,
    );
    token = 'isolated-test';
    notifyListeners();
  }
}

class _ScopedFormService extends _FormService {
  Future<void>? oldCatalogGate;
  int pharmacyReads = 0;
  int categoryReads = 0;
  @override
  Future<List<Pharmacy>> listPharmacies() {
    pharmacyReads++;
    return super.listPharmacies();
  }

  @override
  Future<List<Category>> listCategories({int? pharmacyId}) async {
    categoryReads++;
    if (pharmacyId == 1 && oldCatalogGate != null) await oldCatalogGate;
    return (await super.listCategories(
      pharmacyId: pharmacyId,
    )).where((item) => item.pharmacyId == pharmacyId).toList();
  }
}

class _FormService extends AdminService {
  Object? saveError;
  Future<void>? saveGate;
  bool failUpload = false;
  bool failMedicationUpload = false;
  bool failContentUpload = false;
  int uploads = 0;
  int medicationUploads = 0;
  int contentUploads = 0;
  final categorySaveIds = <int?>[];
  final productSaveIds = <int?>[];
  final contentSaveIds = <int?>[];
  Map<String, dynamic>? categoryPayload;
  Map<String, dynamic>? ingredientPayload, contentPayload;
  final pharmacies = <Map<String, dynamic>>[
    {'ID': 1, 'NAME': 'Farmácia A'},
    {'ID': 2, 'NAME': 'Farmácia B'},
  ];
  final products = <Map<String, dynamic>>[
    {'ID': 100, 'NAME': 'Produto A', 'PHARMACY_ID': 1, 'CATEGORY_ID': 10},
    {'ID': 200, 'NAME': 'Produto B', 'PHARMACY_ID': 2, 'CATEGORY_ID': 20},
  ];
  Map<String, dynamic>? pharmacyPayload,
      productPayload,
      inventoryPayload,
      promotionPayload,
      subcategoryPayload;
  int? pharmacyId;
  final subcategories = <Map<String, dynamic>>[
    {'ID': 11, 'NAME': 'Subcategoria A', 'CATEGORY_ID': 10},
  ];
  @override
  Future<List<Pharmacy>> listPharmacies() async =>
      pharmacies.map(Pharmacy.fromJson).toList();
  @override
  Future<int> savePharmacy(Map<String, dynamic> data, {int? id}) async {
    pharmacyPayload = data;
    pharmacyId = id;
    pharmacies.removeWhere((p) => p['ID'] == (id ?? 3));
    pharmacies.add({...data, 'ID': id ?? 3});
    return id ?? 3;
  }

  @override
  Future<void> uploadPharmacyImage(
    int id, {
    required Uint8List bytes,
    required String filename,
  }) async {
    expect(id, 3);
    expect(bytes, isNotEmpty);
    uploads++;
  }

  @override
  Future<List<Subcategory>> listSubcategories(int categoryId) async =>
      subcategories
          .where((item) => item['CATEGORY_ID'] == categoryId)
          .map(Subcategory.fromJson)
          .toList();

  @override
  Future<int> saveSubcategory(Map<String, dynamic> data, {int? id}) async {
    subcategoryPayload = data;
    final savedId = id ?? 40;
    subcategories.removeWhere((item) => item['ID'] == savedId);
    subcategories.add({...data, 'ID': savedId});
    return savedId;
  }

  @override
  Future<void> deleteSubcategory(int id) async {
    subcategories.removeWhere((item) => item['ID'] == id);
  }

  @override
  Future<List<Category>> listCategories({int? pharmacyId}) async => [
    if (categoryPayload != null)
      Category.fromJson({...categoryPayload!, 'ID': 30}),
    Category.fromJson({
      'ID': 10,
      'NAME': 'Categoria A',
      'PHARMACY_ID': 1,
      'subcategories': [
        {'ID': 11, 'NAME': 'Subcategoria A', 'CATEGORY_ID': 10},
      ],
    }),
    Category.fromJson({'ID': 20, 'NAME': 'Categoria B', 'PHARMACY_ID': 2}),
  ];
  @override
  Future<List<Medication>> listMedications({int? pharmacyId}) async =>
      products.map(Medication.fromJson).toList();
  @override
  Future<int> saveMedication(Map<String, dynamic> data, {int? id}) async {
    productPayload = data;
    productSaveIds.add(id);
    final savedId = id ?? 300;
    products.removeWhere((product) => product['ID'] == savedId);
    products.add({...data, 'ID': savedId});
    return savedId;
  }

  @override
  Future<void> uploadMedicationImage(
    int medicationId, {
    required Uint8List bytes,
    required String filename,
  }) async {
    expect(medicationId, 300);
    expect(bytes, isNotEmpty);
    medicationUploads++;
    if (failMedicationUpload) throw Exception('Upload indisponível');
  }

  @override
  Future<List<AdminInventoryItem>> listInventory({int? pharmacyId}) async => [];
  @override
  Future<void> saveInventory(Map<String, dynamic> data, {int? id}) async {
    inventoryPayload = data;
  }

  @override
  Future<List<Promotion>> listHighlights({int? pharmacyId}) async => [];
  @override
  Future<int> saveHighlight(Map<String, dynamic> data, {int? id}) async {
    promotionPayload = data;
    return id ?? 1;
  }

  @override
  Future<List<ActiveIngredient>> listActiveIngredients({
    int? pharmacyId,
  }) async => [
    if (ingredientPayload != null &&
        (pharmacyId == null || ingredientPayload!['PHARMACY_ID'] == pharmacyId))
      ActiveIngredient.fromJson({...ingredientPayload!, 'ID': 1}),
  ];
  @override
  Future<int> saveActiveIngredient(Map<String, dynamic> data, {int? id}) async {
    ingredientPayload = {...data, 'ID': id ?? 1};
    return id ?? 1;
  }

  @override
  Future<List<ContentBlock>> listContentBlocks() async => [
    if (contentPayload != null)
      ContentBlock.fromJson({...contentPayload!, 'ID': 1}),
  ];
  @override
  Future<int> saveContentBlock(Map<String, dynamic> data, {int? id}) async {
    contentPayload = data;
    contentSaveIds.add(id);
    return id ?? 1;
  }

  @override
  Future<void> uploadContentImage(
    int contentId, {
    required Uint8List bytes,
    required String filename,
  }) async {
    expect(contentId, 1);
    expect(bytes, isNotEmpty);
    contentUploads++;
    if (failContentUpload) throw Exception('Upload indisponível');
  }

  @override
  Future<List<CustomerOrder>> listOrders({int? pharmacyId}) async => [];
  @override
  Future<FinancialSummary> getFinancialSummary({int? pharmacyId}) async =>
      FinancialSummary.fromJson({});
  @override
  Future<void> uploadCategoryImage(
    int categoryId, {
    required Uint8List bytes,
    required String filename,
  }) async {
    expect(categoryId, 30);
    expect(bytes, isNotEmpty);
    uploads++;
    if (failUpload) throw Exception('Upload indisponível');
  }

  @override
  Future<int> saveCategory(Map<String, dynamic> data, {int? id}) async {
    categorySaveIds.add(id);
    if (saveGate != null) await saveGate;
    if (saveError != null) throw saveError!;
    categoryPayload = data;
    return id ?? 30;
  }
}

class _TestFilePicker extends FilePicker {
  final Uint8List bytes;
  final int? reportedSize;
  int chunksRead = 0;

  _TestFilePicker(this.bytes, {this.reportedSize});

  Stream<List<int>> _readBytes() async* {
    const chunkSize = 1024 * 1024;
    for (var offset = 0; offset < bytes.length; offset += chunkSize) {
      final end = offset + chunkSize > bytes.length
          ? bytes.length
          : offset + chunkSize;
      chunksRead++;
      yield bytes.sublist(offset, end);
    }
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    expect(withData, isFalse);
    expect(withReadStream, isTrue);
    return FilePickerResult([
      PlatformFile(
        name: 'family.jpeg',
        size: reportedSize ?? bytes.length,
        readStream: _readBytes(),
      ),
    ]);
  }
}
