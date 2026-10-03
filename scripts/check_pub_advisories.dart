import 'dart:convert';
import 'dart:io';

const _osvQueryBatchUrl = 'https://api.osv.dev/v1/querybatch';
const _knownNonHostedSources = {'root', 'sdk', 'git', 'path'};

class HostedPubPackage {
  const HostedPubPackage({required this.name, required this.version});

  final String name;
  final String version;
}

class PubAdvisoryFinding {
  const PubAdvisoryFinding({required this.package, required this.advisoryId});

  final HostedPubPackage package;
  final String advisoryId;
}

List<HostedPubPackage> hostedPackagesFromGraph(Object? decodedGraph) {
  if (decodedGraph is! Map<Object?, Object?> ||
      decodedGraph['packages'] is! List) {
    throw const FormatException('Invalid `dart pub deps --json` graph.');
  }

  final packages = <HostedPubPackage>[];
  for (final row in decodedGraph['packages'] as List) {
    if (row is! Map<Object?, Object?>) {
      throw const FormatException('Invalid Pub package row.');
    }

    final source = row['source'];
    if (source is! String || source.isEmpty) {
      throw const FormatException('Pub package is missing its source.');
    }
    if (source != 'hosted') {
      if (_knownNonHostedSources.contains(source)) continue;
      throw const FormatException('Pub package has an unsupported source.');
    }

    final name = row['name'];
    final version = row['version'];
    if (name is! String ||
        name.isEmpty ||
        version is! String ||
        version.isEmpty) {
      throw const FormatException(
        'Hosted Pub package is missing name/version.',
      );
    }
    packages.add(HostedPubPackage(name: name, version: version));
  }

  packages.sort((a, b) {
    final byName = a.name.compareTo(b.name);
    return byName == 0 ? a.version.compareTo(b.version) : byName;
  });
  return packages;
}

List<Map<String, Object>> osvQueriesFor(List<HostedPubPackage> packages) =>
    packages
        .map(
          (package) => {
            'package': {'name': package.name, 'ecosystem': 'Pub'},
            'version': package.version,
          },
        )
        .toList(growable: false);

List<PubAdvisoryFinding> findingsFromResults(
  List<HostedPubPackage> packages,
  Object? decodedResults,
) {
  if (decodedResults is! List || decodedResults.length != packages.length) {
    throw const FormatException('OSV response does not match query count.');
  }

  final findings = <PubAdvisoryFinding>[];
  for (var index = 0; index < packages.length; index++) {
    final result = decodedResults[index];
    if (result is! Map<Object?, Object?>) {
      throw const FormatException('Invalid OSV result row.');
    }
    final vulnerabilities = result['vulns'];
    if (vulnerabilities == null) continue;
    if (vulnerabilities is! List) {
      throw const FormatException('Invalid OSV vulnerability list.');
    }

    for (final vulnerability in vulnerabilities) {
      if (vulnerability is! Map<Object?, Object?> ||
          vulnerability['id'] is! String ||
          (vulnerability['id'] as String).isEmpty) {
        throw const FormatException('OSV vulnerability is missing an ID.');
      }
      findings.add(
        PubAdvisoryFinding(
          package: packages[index],
          advisoryId: vulnerability['id'] as String,
        ),
      );
    }
  }
  return findings;
}

Future<void> main() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final graph = await Process.run(Platform.resolvedExecutable, [
      'pub',
      'deps',
      '--json',
    ]);
    if (graph.exitCode != 0) {
      throw ProcessException(
        Platform.resolvedExecutable,
        const ['pub', 'deps', '--json'],
        graph.stderr.toString(),
        graph.exitCode,
      );
    }

    final packages = hostedPackagesFromGraph(
      jsonDecode(graph.stdout as String),
    );
    if (packages.isEmpty) {
      throw const FormatException('No hosted Pub packages found to audit.');
    }

    final request = await client.postUrl(Uri.parse(_osvQueryBatchUrl));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'queries': osvQueriesFor(packages)}));
    final response = await request.close().timeout(const Duration(seconds: 30));
    final responseBody = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('OSV returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<Object?, Object?>) {
      throw const FormatException('Invalid OSV batch response.');
    }
    final findings = findingsFromResults(packages, decoded['results']);
    if (findings.isNotEmpty) {
      for (final finding in findings) {
        stderr.writeln(
          '${finding.package.name} ${finding.package.version}: '
          '${finding.advisoryId}',
        );
      }
      exitCode = 1;
      return;
    }

    stdout.writeln(
      'No known OSV advisories matched ${packages.length} hosted Pub packages.',
    );
  } on Object catch (error) {
    stderr.writeln('Pub advisory audit could not complete: $error');
    exitCode = 2;
  } finally {
    client.close(force: true);
  }
}
