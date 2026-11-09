# Flutter Chrome test runner on Windows

## Environment

- Windows, Flutter 3.41.4, Dart 3.11.1, Chrome 153.0.8010.53.
- `flutter analyze` passed with no issues.
- `flutter test --concurrency=1 --reporter expanded` passed all 233 tests after the API client, 320 px registration retry, and administrative role/isolation regression tests were added.
- `flutter build web --release --base-href /savemed/ --no-web-resources-cdn` succeeded.
- The release bundle rendered its login screen in headless Chrome when served below `/savemed/`.

## Runner failure

`flutter test --platform chrome test/core/utils/money_formatter_test.dart` stalls before the first test. DevTools captured a `SyntaxError: Invalid Unicode escape sequence` in the generated test wrapper: `window.testSelector` contains a Windows path such as `core\utils\money_formatter_test.dart`, where `\u` is parsed as an invalid Unicode escape.

Running `flutter test --platform chrome test/widget_test.dart` avoids the nested-path selector, but then the generated test page fails to load CanvasKit. In the installed Flutter SDK, `packages/flutter_tools/lib/src/test/flutter_web_platform.dart` converts the URI path to a Windows path before testing it against the slash-only prefix `canvaskit/`; the local CanvasKit handler returns 404. The browser then reports a failed CanvasKit module fetch and a WebAssembly HTTP error.

These failures occur in Flutter's Windows test harness before app tests can run. No project source or Flutter SDK files were modified to work around them.

## WASM attempt

On 2026-09-28, `flutter test --platform chrome --wasm test/widget_test.dart` compiled the test bundle and opened the browser host, but remained at `loading` without starting any test. DevTools showed the test iframe requesting `/canvaskit/skwasm.js` and `/canvaskit/skwasm.wasm`; both responses were only a few hundred bytes, not renderer assets. This is consistent with the same Windows separator mismatch in `_localCanvasKitHandler`. The stalled run was stopped after confirming the browser and test processes were idle; no test cases completed.

## Verification that remains

On 2026-09-28, ran `flutter test --platform chrome test/widget_test.dart test/features/admin/pharmacy_operation_test.dart` in a disposable Ubuntu 24.04 container with Flutter 3.41.4 and Chrome 154. All 49 auth, registration, recovery, pharmacy access, administrative, and pharmacy-operation widget tests passed. The source was mounted read-only and copied into the container. The widget test setup injects immediate fake HTTP clients for SaveMed API and ViaCEP calls, preventing tests from reaching production services or leaving timeout timers pending. A larger administrative form test file stalled in `setUpAll` on Chrome without starting cases and was stopped after four minutes; the exact cause is unconfirmed. Its complete suite remains covered by Windows tests, but it is not in the browser gate. The GitHub Actions browser job is pinned to `ubuntu-24.04`, whose [official runner inventory](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md) lists Google Chrome, and runs both passing widget suites. Android, iOS, VoiceOver and TalkBack release checks remain separate and pending as listed in `roadmap.md`.

## Platform-specific golden tests

Ran the full 263-test suite from a read-only source copy in Ubuntu 24.04 with
Flutter 3.41.4, including `lib`, `test`, `assets`, `scripts`, and `web`. 251
tests passed; 12 test cases failed only on exact PNG golden comparisons, with
pixel differences from the checked-in baselines. The full suite had passed on
the Windows development host. To keep both gates meaningful, the workflow runs
the complete suite and web/APK builds on `windows-2025`, while `ubuntu-24.04`
runs the focused real-Chrome password-semantics test. The official
[Windows 2025 runner inventory](https://github.com/actions/runner-images/blob/main/images/windows/Windows2025-Readme.md)
lists Android SDK platform 36 and NDK 28.2.13676358 used by the APK build.

The container used `ghcr.io/cirruslabs/flutter:3.41.4` (`sha256:483b84dde87b1798adbc5e2582b353c9b0e620e9a89464380133d8e30ad9f7c4`) with Google Chrome installed only inside the disposable container. No Flutter SDK, package, or generated file in the SaveMed worktree was changed by this run.

## Reproduction

```powershell
$env:CHROME_EXECUTABLE = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
flutter test --platform chrome test/core/utils/money_formatter_test.dart
flutter test --platform chrome test/widget_test.dart
```
