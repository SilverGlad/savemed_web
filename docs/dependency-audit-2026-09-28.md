# Pub Dependency Advisory Audit - 2026-09-28

## Scope and result

- Source graph: `dart pub deps --json` after `flutter pub get --enforce-lockfile`.
- Audited 85 hosted Pub packages at their resolved versions. The graph also had
  four Flutter/Dart SDK packages and the root app; these are not Pub packages
  and were not queried.
- Advisory source: OSV batch query using ecosystem `Pub`, package name, and the
  exact resolved version for every package.
- Result on 2026-09-28: no known OSV advisories matched the 85 queried versions.
- No package versions were changed as part of this audit.

The repeatable gate is `dart run scripts/check_pub_advisories.dart`; CI runs it
after the lockfile-enforced dependency fetch. It exits nonzero on a matching
advisory, malformed/incomplete response, network failure, or non-success HTTP
status. Unit coverage is in `test/security/pub_advisory_audit_test.dart`.

This checks OSV records available at execution time; it is not a guarantee that
packages are vulnerability-free, does not audit Flutter/Dart SDK internals, and
does not replace source review or platform-specific dependency audits. Pushes
and pull requests repeat the lookup.

References: [OSV batch query API](https://google.github.io/osv.dev/post-v1-querybatch/),
[Dart lockfile and `--enforce-lockfile`](https://dart.dev/tools/pub/packages),
[Pub security advisories](https://pub.dev/security).
