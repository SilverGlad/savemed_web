import 'package:flutter_test/flutter_test.dart';
import '../../scripts/check_pub_advisories.dart';

void main() {
  test(
    'audit selects hosted dependencies and excludes SDK/path/git packages',
    () {
      final packages = hostedPackagesFromGraph({
        'packages': [
          {'name': 'app', 'version': '1.0.0', 'source': 'root'},
          {'name': 'http', 'version': '1.2.2', 'source': 'hosted'},
          {'name': 'flutter', 'version': '0.0.0', 'source': 'sdk'},
          {'name': 'local', 'version': 'any', 'source': 'path'},
          {'name': 'fork', 'version': 'main', 'source': 'git'},
        ],
      });

      expect(packages.map((package) => (package.name, package.version)), [
        ('http', '1.2.2'),
      ]);
    },
  );

  test('audit rejects malformed rows and unknown package sources', () {
    expect(
      () => hostedPackagesFromGraph({
        'packages': [null],
      }),
      throwsFormatException,
    );
    expect(
      () => hostedPackagesFromGraph({
        'packages': [
          {'name': 'unknown_source', 'version': '1.0.0'},
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => hostedPackagesFromGraph({
        'packages': [
          {
            'name': 'future_source',
            'version': '1.0.0',
            'source': 'future-source',
          },
        ],
      }),
      throwsFormatException,
    );
  });

  test('audit sends exact locked versions to the Pub ecosystem', () {
    final queries = osvQueriesFor([
      const HostedPubPackage(name: 'provider', version: '6.1.2'),
    ]);

    expect(queries, [
      {
        'package': {'name': 'provider', 'ecosystem': 'Pub'},
        'version': '6.1.2',
      },
    ]);
  });

  test('audit correlates advisories to the matching package version', () {
    final packages = [
      const HostedPubPackage(name: 'a', version: '1.0.0'),
      const HostedPubPackage(name: 'b', version: '2.0.0'),
    ];

    final findings = findingsFromResults(packages, [
      {},
      {
        'vulns': [
          {'id': 'GHSA-example'},
        ],
      },
    ]);

    expect(
      findings.map(
        (finding) =>
            (finding.package.name, finding.package.version, finding.advisoryId),
      ),
      [('b', '2.0.0', 'GHSA-example')],
    );
  });

  test('audit fails closed on incomplete OSV results', () {
    expect(
      () => findingsFromResults([
        const HostedPubPackage(name: 'a', version: '1.0.0'),
      ], []),
      throwsFormatException,
    );
  });
}
