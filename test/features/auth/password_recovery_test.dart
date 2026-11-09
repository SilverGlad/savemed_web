import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savemed/core/services/auth_service.dart';
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

  testWidgets('password recovery sends code and submits validated reset data', (
    tester,
  ) async {
    final service = _RecoveryAuthService();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthPage(authService: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    expect(find.text('Recuperar conta'), findsOneWidget);

    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(service.forgotEmails, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey('forgot-email')),
      'qa@example.com',
    );
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    expect(service.forgotEmails, ['qa@example.com']);
    expect(find.byKey(const ValueKey('forgot-code')), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('forgot-email')),
              matching: find.byType(TextFormField),
            ),
          )
          .enabled,
      isFalse,
    );

    await tester.enterText(find.byKey(const ValueKey('forgot-code')), '123456');
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password')),
      'teste-seguro-2026',
    );
    expect(find.text('A confirmação da senha não confere.'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirmation')),
      'senha-divergente',
    );
    await tester.ensureVisible(find.text('Redefinir senha'));
    await tester.tap(find.text('Redefinir senha'));
    await tester.pumpAndSettle();
    expect(find.text('A confirmação da senha não confere.'), findsWidgets);
    expect(service.resetRequests, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirmation')),
      'teste-seguro-2026',
    );
    await tester.ensureVisible(find.text('Redefinir senha'));
    await tester.tap(find.text('Redefinir senha'));
    await tester.pumpAndSettle();

    expect(service.resetRequests, [
      (email: 'qa@example.com', code: '123456', password: 'teste-seguro-2026'),
    ]);
    expect(find.text('Recuperar conta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing recovery email clears the old code and password', (
    tester,
  ) async {
    final service = _RecoveryAuthService();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthPage(authService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('forgot-email')),
      'primeiro@example.com',
    );
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alterar e-mail'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('forgot-code')), findsNothing);
    expect(find.byKey(const ValueKey('forgot-password')), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('forgot-email')),
      'segundo@example.com',
    );
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    expect(service.forgotEmails, [
      'primeiro@example.com',
      'segundo@example.com',
    ]);
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('forgot-code')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller
          ?.text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('forgot-password')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller
          ?.text,
      isEmpty,
    );

    await tester.enterText(find.byKey(const ValueKey('forgot-code')), '111111');
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password')),
      'senha-antiga',
    );
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirmation')),
      'senha-antiga',
    );
    await tester.ensureVisible(find.text('Reenviar código'));
    await tester.tap(find.text('Reenviar código'));
    await tester.pumpAndSettle();
    expect(service.forgotEmails, [
      'primeiro@example.com',
      'segundo@example.com',
      'segundo@example.com',
    ]);
    for (final key in [
      'forgot-code',
      'forgot-password',
      'forgot-password-confirmation',
    ]) {
      expect(
        tester
            .widget<TextFormField>(
              find.descendant(
                of: find.byKey(ValueKey(key)),
                matching: find.byType(TextFormField),
              ),
            )
            .controller
            ?.text,
        isEmpty,
      );
    }

    await tester.enterText(find.byKey(const ValueKey('forgot-code')), '654321');
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password')),
      'nova-senha-segura',
    );
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirmation')),
      'nova-senha-segura',
    );
    await tester.ensureVisible(find.text('Redefinir senha'));
    await tester.tap(find.text('Redefinir senha'));
    await tester.pumpAndSettle();

    expect(service.resetRequests.single.email, 'segundo@example.com');
    expect(service.resetRequests.single.code, '654321');
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed code request keeps recovery on the email step', (
    tester,
  ) async {
    final service = _RecoveryAuthService(failCodeRequest: true);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthPage(authService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('forgot-email')),
      'qa@example.com',
    );
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('forgot-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('forgot-code')), findsNothing);
    expect(
      find.text(
        'Não foi possível concluir a recuperação. Tente novamente em instantes.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed resend preserves the current recovery data', (
    tester,
  ) async {
    final service = _RecoveryAuthService(failCodeRequestOnAttempt: 2);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthPage(authService: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('forgot-email')),
      'qa@example.com',
    );
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('forgot-code')), '123456');
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password')),
      'senha-segura-2026',
    );
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirmation')),
      'senha-segura-2026',
    );

    await tester.ensureVisible(find.text('Reenviar código'));
    await tester.tap(find.text('Reenviar código'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('forgot-code')), findsOneWidget);
    expect(service.forgotEmails, ['qa@example.com', 'qa@example.com']);
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('forgot-code')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller
          ?.text,
      '123456',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.descendant(
              of: find.byKey(const ValueKey('forgot-password')),
              matching: find.byType(TextFormField),
            ),
          )
          .controller
          ?.text,
      'senha-segura-2026',
    );
    expect(tester.takeException(), isNull);
  });
}

class _RecoveryAuthService extends AuthService {
  _RecoveryAuthService({
    this.failCodeRequest = false,
    this.failCodeRequestOnAttempt,
  });

  final bool failCodeRequest;
  final int? failCodeRequestOnAttempt;
  final List<String> forgotEmails = [];
  final List<({String email, String code, String password})> resetRequests = [];

  @override
  Future<String> forgotPassword({required String email}) async {
    forgotEmails.add(email);
    if (failCodeRequest || failCodeRequestOnAttempt == forgotEmails.length) {
      throw Exception('smtp indisponível');
    }
    return 'Código enviado';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    resetRequests.add((email: email, code: code, password: password));
    return 'Senha redefinida';
  }
}
