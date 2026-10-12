# 📱 App-Flutter

Reusable Flutter base project for **Android and iOS**, designed for incremental adoption of **MVVM**, reactive UI, feature isolation, offline-first persistence, automated quality, and self-hosted CI/CD.

This is a reusable **base app**, not a finished product. Product identity, native flavors, deep-link schemes, and artifact naming are centralized to keep future derived applications maintainable. The project follows the engineering conventions of [`app-kmp`](https://github.com/Brunno13/app-kmp) and [`app-react-native`](https://github.com/Brunno13/app-react-native) without copying their technology stacks.

> **Validated foundation (October 2026):** Flutter **3.47.6** / Dart **3.13.5**; Android/iOS `production` and `staging` flavors; feature-first bootstrap; GetIt + Injectable; MobX light/dark theming; **ARCH000–ARCH009** architecture checks; **44 passing tests**; and mandatory Woodpecker quality checks for Gitea pull requests. **Not yet implemented:** ObjectBox, production networking/authentication, `go_router`, advanced security gates, E2E, and signed release pipelines.


---

## 🚀 Key Features

- **Reusable App Identity (implemented):** `ci/artifacts.env` is the canonical source for public product identifiers, names, schemes, and future artifact naming. `tool/configure_app.dart` applies and checks the supported Android/iOS configuration.
- **Native Environments (validated):** Independent `production` and `staging` app identities, shared Xcode schemes, Android product flavors, side-by-side installation, and custom deep links on Android and iOS simulators.
- **Application Foundation (implemented):** A single `lib/main.dart`, explicit bootstrap, runtime `AppEnvironment` and composition root with GetIt + Injectable.
- **Reactive Theme (validated):** MobX-backed `ThemeViewModel` switches between light/dark `ThemeData` using `Observer` without restarting the app. The choice is currently in-memory only.
- **Feature-First Boundaries (enforced):** A Dart Analyzer-based checker validates import/export boundaries, feature public APIs, Presentation/Domain/Data constraints, and permitted GetIt/MobX usage (`ARCH000–ARCH009`).
- **Self-Hosted Quality Gate (validated):** PR checks run on a dedicated Flutter 3.47.6 Linux/amd64 image using the VM104 Woodpecker agent. Gitea requires a successful quality status to merge into `main`.
- **Offline-First Direction (planned):** ObjectBox as local source of truth, reactive repository streams and mapping into pure Domain models.
- **Secure Integration (planned):** Dio, authentication adapters, secure credential storage, biometrics, E2E and release workflows will be implemented only when validated independently.

---

## 🗺️ Project Roadmap

### ✅ Foundation and Native Environments

- [x] Bootstrap the Flutter 3.47.6 / Dart 3.13.5 app and validate development on Windows and macOS.
- [x] Establish iOS 15.0+ deployment support and validate Android/iOS debug builds.
- [x] Centralize the supported non-secret application identity in `ci/artifacts.env`.
- [x] Implement and test `tool/configure_app.dart --apply` / `--check`, including negative drift tests.
- [x] Validate `production` / `staging` Android and iOS flavors, default production selection, side-by-side installs and deep-link schemes.
- [x] Replace the sample counter app with a feature-first bootstrap and Home feature.
- [x] Introduce GetIt + Injectable, constructor-driven composition and strict runtime `AppEnvironment` selection.
- [x] Introduce MobX with a working light/dark theme and widget tests on both platforms/flavors.

### ✅ Testing, Governance and CI

- [x] Implement parser-based `ARCH000–ARCH009` architecture boundaries with positive and negative tests.
- [x] Validate **44 tests** on Windows, macOS and the Linux/amd64 CI container.
- [x] Build the dedicated `app-flutter-ci:3.47.6-v1` quality image without Android SDK/NDK.
- [x] Configure Woodpecker wake and quality workflows for PRs and pushes to `main`.
- [x] Require the Gitea quality context `ci/woodpecker/pr/test` for merges into `main`.
- [x] Validate the complete **PASS → FAIL → PASS** cycle using an intentional ARCH001 violation and its removal (PR #5).

### 🔜 Reactive Offline Foundation

- [ ] Introduce ObjectBox and version its schema model once real persistent entities exist.
- [ ] Prove repository-to-ObjectBox `watch()` streams with a complete feature slice.
- [ ] Add Dio, `go_router`, secure credential storage, authentication and biometrics where needed.
- [ ] Add persisted theme preference and optional system theme follow-up.

### 🔜 Quality, Security and Distribution

- [ ] Add reproducible generated-code drift validation to CI.
- [ ] Measure meaningful business coverage before setting thresholds.
- [ ] Add Gitleaks, Opengrep, Trivy, optional jscpd diagnostics and Android Lint in separate validated gates.
- [ ] Add Android build workflows and iOS manual/release workflows; do not treat the quality image as a release image.
- [ ] Introduce Patrol E2E and signing/packaging only after the native build flows are stable.
- [ ] Integrate Garage, Gitea Releases, GitHub mirror/release, and Gotify into authorized artifact/release pipelines.

### Future Evaluation

- [ ] Evaluate Shorebird OTA after standard release validation.
- [ ] Introduce offline mutation/outbox only when a feature requires it.

---

## 🛠️ Tech Stack

The table intentionally separates the **current implementation** from selected future technologies.

| Area | Technology | Status |
|---|---|---|
| Framework / Language | Flutter 3.47.6 / Dart 3.13.5 | Validated |
| Native flavors | Android product flavors / iOS shared schemes | Validated |
| Architecture | Feature-first MVVM foundation; layered feature boundaries | Implemented / enforced |
| Dependency injection | GetIt 9.3.x + Injectable 3.x | Implemented |
| Reactive state | MobX 2.7.x + `flutter_mobx` 2.4.x | Implemented (global theme) |
| Testing | `flutter_test` (unit, DI and widget tests) | 44 PASS |
| Static / architecture checks | `flutter analyze`; Analyzer 14.1.0; `tool/check_architecture.dart` | Blocking in CI |
| Code generation | `build_runner`, `injectable_generator`, `mobx_codegen` | Implemented; generated sources versioned |
| CI | Woodpecker, Gitea required status, Linux/amd64 VM104 | Validated |
| Quality container | `app-flutter-ci:3.47.6-v1` | Validated (quality only) |
| Navigation | `go_router` | Planned |
| Offline database | ObjectBox | Planned |
| Networking / serialization | Dio / `json_serializable` | Planned |
| Authentication | Backend adapter / Better Auth integration | Planned |
| Secure storage / biometrics | `flutter_secure_storage` / `local_auth` | Planned |
| Connectivity / localization | `connectivity_plus` / `gen_l10n` + ARB | Planned |
| UI catalog / E2E | Widgetbook / Patrol | Planned |
| Security / additional analysis | Gitleaks, Opengrep, Trivy, jscpd, Android Lint | Planned |
| Release distribution | Garage, Gitea Releases, signing and macOS iOS builds | Planned for this repository |

---

## 🏗️ Project Architecture

The application uses **one Dart entrypoint** and a composition root; only the implemented Home feature exists today. Domain, Data and other feature directories will be added when they contain real behavior.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── bootstrap/
│   │   └── bootstrap.dart
│   ├── di/
│   │   ├── dependency_injection.dart
│   │   └── dependency_injection.config.dart  # Generated and versioned
│   ├── environment/
│   │   └── app_environment.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── theme_view_model.dart
│       └── theme_view_model.g.dart            # Generated and versioned
└── features/
    └── home/
        ├── home.dart                          # Public API
        └── presentation/
            └── views/
                └── home_view.dart
```

Additional project infrastructure:

```text
ci/artifacts.env
ci/docker/flutter-quality/Dockerfile
scripts/quality_flutter.sh
tool/configure_app.dart
tool/check_architecture.dart
tool/architecture/architecture_checker.dart
test/app/
test/tool/architecture_checker_test.dart
test/widget_test.dart
.woodpecker/security-wake-x86.yml
.woodpecker/test.yml
```

### Dependency Flow

The long-term layered model remains:

```text
Presentation ─────► Domain ◄───── Data
```

The current `HomeView` is intentionally UI-only. The global theme state lives in `app/theme` and is passed to Home through a boolean and callback; Home never resolves GetIt or imports `app/theme`. The bootstrap resolves `ThemeViewModel` through Injectable/GetIt and passes it to `App`. Domain/Data repository implementations are **not** present yet.

---

## 📏 Architecture Guidelines

The committed checker uses the **Dart Analyzer parser** for imports and exports (including relative and conditional directives), excluding recognized generated files. It runs using `dart run tool/check_architecture.dart` and fails with a non-zero exit code.

| Rule | Enforced restriction |
|---|---|
| `ARCH000` | Invalid Dart syntax in checked source files |
| `ARCH001` | `features/**` cannot depend on `app/**` |
| `ARCH002` | `shared/**` cannot depend on `app/**` or `features/**` |
| `ARCH003` | `features/**` and `shared/**` cannot import/export GetIt |
| `ARCH004` | Relative imports/exports cannot escape `lib/` |
| `ARCH005` | Cross-feature imports/exports must use the target feature's public barrel (`features/<name>/<name>.dart`) |
| `ARCH006` | Feature Domain cannot import local Data or Presentation |
| `ARCH007` | Feature Data cannot import local Presentation |
| `ARCH008` | MobX is restricted to feature/shared Presentation, `app/theme` and the approved app-level UI |
| `ARCH009` | Direct GetIt imports are restricted to `app/bootstrap` and `app/di`; re-exporting is forbidden |

Example public API:

```dart
import 'package:app_flutter/features/home/home.dart';
```

A feature must not deep-import another feature's `presentation/`, `domain/` or `data/` implementation. GetIt belongs to application composition; Views and business code receive their dependencies through constructors or explicit parameters.

The `app_arch_lints` analyzer plugin is **not implemented**: the current, blocking architecture gate is the versioned custom command above. The checker validates direct source-level rules, not every possible transitive or runtime dependency.

---

## 🧩 Base App Configuration

The versioned, non-sensitive contract lives in [`ci/artifacts.env`](ci/artifacts.env). Current keys are:

```text
APP_DISPLAY_NAME
DART_PACKAGE_NAME
ANDROID_NAMESPACE
ANDROID_APPLICATION_ID
IOS_BUNDLE_IDENTIFIER
IOS_BUNDLE_NAME
APP_SCHEME
APP_STAGING_NAME_SUFFIX
APP_STAGING_ID_SUFFIX
APP_STAGING_SCHEME_SUFFIX
ARTIFACT_BASENAME
GARAGE_REGION
GARAGE_BUCKET
GARAGE_ANDROID_PREFIX
GARAGE_IOS_PREFIX
```

After deliberate identity edits, apply and validate the supported native configuration:

```bash
dart run tool/configure_app.dart --apply
dart run tool/configure_app.dart --check
```

For normal local development and CI, run **`--check` only**, so unexpected drift fails rather than being silently rewritten. The tool synchronizes the supported Android and iOS identity settings, Xcode shared schemes/build configurations and related paths. Positive, negative and idempotency tests have been performed on Windows and macOS.

The runtime `AppEnvironment` is selected strictly from Flutter's `appFlavor` (`production` or `staging`); unsupported or missing flavors fail instead of silently falling back. The project uses a single `lib/main.dart`, with `flutter.default-flavor: production` configured in `pubspec.yaml`.

Native flavors do not yet configure separate backend endpoints. Future non-sensitive runtime settings may use versioned files and `--dart-define-from-file`; signing keys, storage credentials and CI tokens must **never** be checked into the repository or embedded as secrets in client binaries.

---

## 🔄 Reactive Offline-First Model

*Planned architecture; ObjectBox and the repository flow have not yet been implemented.*

ObjectBox is intended as the local source of truth for persistent offline-capable data.

```text
Remote API
    │
    ▼
Repository
    │ write / synchronize
    ▼
ObjectBox
    │ reactive query / watch()
    ▼
Repository Stream<DomainModel>
    │
    ▼
ViewModel / MobX
    │
    ▼
Observer
    │
    ▼
View
```

A refresh updates the local source of truth. The UI reacts to the resulting database change instead of depending directly on the API response.
ObjectBox entities are intentionally separated from Domain models:

```text
ObjectBox Entity
      │ mapper
      ▼
Domain Model
      │
      ▼
ViewModel / UI State
```

`objectbox-model.json` will be part of the schema history and must be versioned when ObjectBox is introduced.


---

## 🧠 MVVM and Reactive State

The first working example is **global light/dark theming**:

```text
bootstrap (GetIt + Injectable)
      │ ThemeViewModel
      ▼
App (MobX Observer)
      │ themeMode / callback
      ▼
MaterialApp + HomeView
      │ user toggles switch
      └──────────────► ThemeViewModel.setDarkMode()
```

`ThemeViewModel` owns a MobX `@observable` `ThemeMode` and an `@action`. Its generated store and Injectable registration are versioned. `App` observes the mode and provides `AppTheme.light` and `AppTheme.dark` to `MaterialApp`. The Home feature receives only `isDarkMode` and `onDarkModeChanged`, preserving feature boundaries.

Both modes were validated in `production` and `staging` on Android and iOS. The default is currently light mode, and the preference is **not yet persisted**. No ObjectBox/reactive repository flow has been implemented.

For future features, MobX stays in Presentation, Domain remains framework-independent, and shared data should generally be exposed via repositories rather than global feature ViewModels.

---

## 🔐 Security

*The following is the planned security model; secure storage and authentication are not yet integrated.*

Sensitive credentials are intentionally kept outside ObjectBox entities and presentation models.

### ObjectBox

May store:

- offline application data;
- cached user/profile data;
- local preferences when appropriate;
- non-sensitive session metadata.

### Secure Storage

Authentication tokens, secrets, and sensitive cryptographic material will use `flutter_secure_storage` through an abstraction owned by the Data layer.

Credentials must never be stored in:

- ObjectBox entities;
- UI models;
- logs;
- user-facing error messages.

Biometric access will use `local_auth` and protect local application access; it will not replace remote authentication.


---

## 🌍 Environments

Native **production and staging flavors are implemented and validated** on Android and iOS. They share the single Dart entrypoint `lib/main.dart`.

| Environment | Android application ID / iOS bundle ID | Display name | URL scheme |
|---|---|---|---|
| `production` (default) | `com.brunno.app` | `App Flutter` | `app-flutter://` |
| `staging` | `com.brunno.app.staging` | `App Flutter (staging)` | `app-flutter-staging://` |

`flutter: default-flavor: production` in `pubspec.yaml` makes an omitted `--flavor` select production for validated Android/iOS debug builds. Android uses `productFlavors`; iOS uses the shared `production` / `staging` Xcode schemes and the corresponding `Debug-*`, `Profile-*`, and `Release-*` configurations.

Distinct installations and custom URL schemes have been tested side by side on an Android emulator and iOS Simulator. Invalid schemes did not resolve. This does **not** establish signed release readiness or device distribution.

Non-sensitive runtime endpoints/configuration may later use versioned environment files and `--dart-define-from-file`. Native identity flavors do not by themselves configure different API endpoints. Production must not inherit development, local-network, or E2E security exceptions.


---

## 🚀 Running Locally

### Prerequisites

- Flutter **3.47.6**, Dart **3.13.5** (validated baseline).
- Android Studio/SDK for Android development.
- macOS with Xcode for iOS development (the validated Mac baseline used Xcode **26.6**); minimum iOS target **15.0**.
- No backend, ObjectBox or live credentials are necessary for the current Home/theme demo.

### Dependencies and Code Generation

```bash
flutter pub get
dart run build_runner build
```

Generated MobX and Injectable files are committed. Regenerate after annotations change and review generated diffs before committing.

### Identity, Architecture, Formatting and Tests

```bash
dart run tool/configure_app.dart --check
dart run tool/check_architecture.dart
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
```

These are the same validation commands used by [`scripts/quality_flutter.sh`](scripts/quality_flutter.sh) in CI, after dependency resolution.

### Android

```bash
flutter run --flavor production
flutter run --flavor staging

flutter build apk --debug --flavor production
flutter build apk --debug --flavor staging
```

### iOS (macOS only)

```bash
flutter run --flavor production
flutter run --flavor staging

flutter build ios --debug --flavor production --no-codesign
flutter build ios --debug --flavor staging --no-codesign
```

The two flavors were run in Android emulators and an iOS Simulator; both support switching the theme. Debug/unsigned builds do **not** imply release signing or device distribution is ready.

---

## 🧪 Testing & Quality

### Current Validated Baseline

The current suite contains **44 passing tests**: **35 checker tests** for the architecture gate and **9 application tests** (environment, dependency injection, MobX and widgets). These passed on Windows, macOS and the dedicated Linux/amd64 Flutter CI image.

| Check | Command / contract | Current status |
|---|---|---|
| Identity | `dart run tool/configure_app.dart --check` → `APP_IDENTITY_CHECK=PASS` | Blocking |
| Architecture | `dart run tool/check_architecture.dart` → `ARCHITECTURE_CHECK=PASS` | Blocking |
| Formatting | `dart format --output=none --set-exit-if-changed lib test tool` | Blocking |
| Analysis | `flutter analyze` | Blocking; 0 issues |
| Tests | `flutter test` | Blocking; 44 PASS |
| Combined | `bash scripts/quality_flutter.sh` → `FLUTTER_QUALITY_GATE=PASS` | Blocking in Woodpecker |

The architecture gate was validated with deliberate source violations that returned `ARCHITECTURE_CHECK=FAIL` and exit code `1`. The PR-required Woodpecker check was also validated with a real **PASS → FAIL → PASS** cycle: an intentional `ARCH001` violation blocked merge in Gitea, and its removal restored eligibility. The temporary probe is not present in the final `main` tree.

The checker is a **source import/export boundary gate**; it is not a substitute for domain unit tests, integration tests, dependency scanning or end-to-end validation.

### Planned Additional Coverage

```text
Pure domain and ViewModel tests for real features
Repository integration with temporary ObjectBox stores
Offline reactivity / watch() end-to-end across layers
Business and authored coverage baselines (no arbitrary threshold)
Generated-code drift validation
Gitleaks / Opengrep / Trivy
jscpd diagnostics / Android Lint
Patrol Android and iOS E2E
Build/release smoke tests and signing checks
```

Quality gates are added incrementally: measure findings, correct them, prove positive and negative behaviors, and only then make checks mandatory. Avoid artificially aiming for 100% coverage or zero duplication.

---

## ⚙️ CI/CD

**Implemented:** self-hosted Woodpecker quality CI for pull requests targeting `main`, pushes to `main` and qualifying manual quality runs. Gitea is the source of truth; GitHub is the read-only mirror for this workflow.

```text
Gitea PR targeting main / push to main
              │
              ▼
.woodpecker/security-wake-x86.yml
  always-on Linux/ARM64 Woodpecker agent
  Energy Manager wake / readiness for VM104
              │ depends_on
              ▼
.woodpecker/test.yml
  VM104 Woodpecker agent (linux/amd64; role: build-linux)
  local image: app-flutter-ci:3.47.6-v1 (pull: false)
              │
              ▼
scripts/quality_flutter.sh
  pub get → format → identity → architecture → analyze → tests
              │
              ▼
Gitea commit status: ci/woodpecker/pr/test
  mandatory to merge into protected main
```

The quality image is defined in [`ci/docker/flutter-quality/Dockerfile`](ci/docker/flutter-quality/Dockerfile): Ubuntu 24.04 with a pinned Flutter 3.47.6 revision and Dart 3.13.5. It is **quality-only** (no Android SDK/NDK, signing, publishing or release secrets). The prebuilt image was validated on VM104; the workflow uses a locally available image rather than pulling it from a registry.

The Gitea `main` branch has a protection rule with direct/force push disabled and the required status context **`ci/woodpecker/pr/test`**. The check was exercised in PR #5 with valid code, an intentional architecture failure, then a restored clean result; the PR was merged as commit `ced1947`. A separate wake workflow is infrastructure support, **not** a substitute for the required quality status.

The Linux/amd64 executor is used for routine quality checks. The macOS/ARM64 agent is reserved for **future manual iOS builds** and **tag-triggered releases**; those workflows do not exist in this repository yet. Android build pipelines, artifact publishing, Garage, Gotify, security scanning and E2E are also future steps.

CI jobs handling untrusted PRs must not receive signing keys, publication credentials or other release secrets. Configuration and specific wake endpoints are managed privately, not documented as reusable public values here.

---

## 📐 Project Guidelines

- Keep the README honest: distinguish **validated**, **implemented** and **planned** behavior.
- Treat Gitea as the writable source of truth and GitHub as a mirror; develop through protected-branch PRs.
- Preserve the `main` required quality context; do not bypass failed checks to merge changes.
- Use the feature's public API for cross-feature imports. Keep Domain independent of Data, Presentation and infrastructure.
- Keep GetIt confined to the application composition root; use constructor injection and explicit UI parameters.
- Keep MobX in presentation/UI state. Do not introduce MobX, ObjectBox or platform APIs into Domain models.
- Keep generated files versioned and regenerate only when annotations change.
- Create layers and shared abstractions only for real behavior; avoid artificial coverage or duplication targets.
- Put no client-side secrets in Dart defines, source files, binary assets or ObjectBox. Keep signing/publishing secrets outside PR checks.
- Validate quality/security changes incrementally, including negative tests before making gates blocking.
- Keep the Flutter CI image separate from the validated CI environments of sibling projects.
- Reserve the macOS agent for iOS-specific builds/releases, not routine Linux quality checks.

---

## 📚 Related Projects

- [Brunno13/app-react-native](https://github.com/Brunno13/app-react-native) — feature isolation, architecture boundaries, security gates, E2E, and React Native CI/CD reference.
- [Brunno13/app-kmp](https://github.com/Brunno13/app-kmp) — MVVM, Presentation/Domain/Data, constructor injection, business coverage, and KMP CI/CD reference.
- [Brunno13/api-bun](https://github.com/Brunno13/api-bun) — backend used by the sibling mobile projects and initial backend target for this project.

---
This repository is intended to remain a reusable Flutter foundation and evolve incrementally as architecture, platform integrations, and quality gates are validated in real code.
