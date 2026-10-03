import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web entrypoint keeps a responsive viewport and browser zoom', () {
    final html = File('web/index.html').readAsStringSync();

    expect(
      html,
      contains(
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
      ),
    );
    expect(html, isNot(contains('user-scalable=no')));
  });

  test(
    'Hostinger headers harden the web app without blocking same-origin use',
    () {
      final htaccess = File('web/.htaccess').readAsStringSync();

      expect(
        htaccess,
        contains('Header always set X-Content-Type-Options "nosniff"'),
      );
      expect(
        htaccess,
        contains('Header always set X-Frame-Options "SAMEORIGIN"'),
      );
      expect(
        htaccess,
        contains(
          'Header always set Referrer-Policy "strict-origin-when-cross-origin"',
        ),
      );
      expect(htaccess, contains('AddType application/wasm .wasm'));
      expect(htaccess, contains('Cache-Control "no-store, no-cache'));
      expect(htaccess, contains(r'^main\.[a-f0-9]{64}\.dart\.js$'));
      expect(
        htaccess,
        contains('Cache-Control "public, max-age=31536000, immutable"'),
      );
      expect(htaccess, contains('Header onsuccess unset Cache-Control'));
      expect(htaccess, contains('Header always unset Cache-Control'));
    },
  );
}
