import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/theme/app_theme.dart';
import 'package:savemed/features/auth/auth_page.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final (width, height) in [(390.0, 844.0), (1440.0, 900.0)]) {
    testWidgets('login visual baseline at ${width.toInt()} px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, height));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AuthPage()),
      );
      final context = tester.element(find.byType(AuthPage));
      await tester.runAsync(() async {
        await Future.wait([
          for (final brand in [
            'visa',
            'mastercard',
            'elo',
            'amex',
            'hipercard',
          ])
            precacheImage(AssetImage('assets/cards/$brand.png'), context),
        ]);
      });
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Criar conta'), findsOneWidget);
      await expectLater(
        find.byType(AuthPage),
        matchesGoldenFile('goldens/login_${width.toInt()}.png'),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('registration opens below the fixed header on a short screen', (
    tester,
  ) async {
    const viewport = Size(320, 640);
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AuthPage()),
    );
    await tester.pumpAndSettle();

    final createAccount = find.widgetWithText(TextButton, 'Criar conta');
    expect(tester.getRect(createAccount).bottom, lessThan(viewport.height));
    await tester.tap(createAccount);
    await tester.pumpAndSettle();

    final headerBottom = tester.getRect(find.text('Sua conta')).bottom;
    final registrationTitle = tester.getRect(find.text('Crie sua conta'));
    expect(registrationTitle.top, greaterThanOrEqualTo(headerBottom));
    expect(registrationTitle.bottom, lessThan(viewport.height));
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer and new pharmacy registration visual baselines', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AuthPage()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hint is Text &&
            (widget.decoration!.hint! as Text).data == 'Repita a senha',
      ),
      findsOneWidget,
    );
    await expectLater(
      find.byType(AuthPage),
      matchesGoldenFile('goldens/register_customer_390.png'),
    );

    final signupScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Sua senha deve:'),
      200,
      scrollable: signupScroll,
    );
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.pumpAndSettle();
    final requirements = tester.getRect(find.text('Sua senha deve:'));
    final submit = tester.getRect(find.text('Criar conta'));
    expect(requirements.top, greaterThanOrEqualTo(0));
    expect(requirements.bottom, lessThan(844));
    expect(submit.top, greaterThan(requirements.bottom));
    expect(submit.bottom, lessThan(844));
    await expectLater(
      find.byType(AuthPage),
      matchesGoldenFile('goldens/register_password_submit_390.png'),
    );

    await tester.ensureVisible(find.text('Farmácia').first);
    await tester.tap(find.text('Farmácia').first);
    await tester.pumpAndSettle();
    expect(find.text('Etapa 1 de 4'), findsOneWidget);
    await expectLater(
      find.byType(AuthPage),
      matchesGoldenFile('goldens/register_pharmacy_390.png'),
    );
    expect(tester.takeException(), isNull);
  });
}
