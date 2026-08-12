// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:savemed/main.dart';

void main() {
  testWidgets('shows login page as initial screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('shows only new pharmacy registration flow', (
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
    await tester.ensureVisible(find.text('Farmacia'));
    await tester.tap(find.text('Farmacia'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Cadastro de farmacia'), findsOneWidget);
    expect(find.text('Nome da nova farmacia'), findsOneWidget);
    expect(find.text('Ja cadastrada'), findsNothing);
    expect(find.text('Sua senha deve:'), findsOneWidget);
    expect(find.text('Ter pelo menos 8 caracteres'), findsOneWidget);
    expect(find.text('Ser igual nos dois campos'), findsOneWidget);

    final passwordField = find.descendant(
      of: find.byKey(const ValueKey('register-password')),
      matching: find.byType(TextField),
    );
    final confirmationField = find.descendant(
      of: find.byKey(const ValueKey('register-password-confirmation')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.enterText(passwordField, '12345678');
    await tester.enterText(confirmationField, '12345678');
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));

    final showPasswordButton = find.byTooltip('Mostrar senha');
    await tester.ensureVisible(showPasswordButton);
    await tester.tap(showPasswordButton);
    await tester.pump();
    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
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
    await tester.ensureVisible(find.text('Farmacia'));
    await tester.tap(find.text('Farmacia'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Cadastro de farmacia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
