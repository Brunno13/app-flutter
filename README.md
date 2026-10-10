# 📱 App-Flutter

Reusable Flutter base project for Android and iOS, designed around **MVVM**, reactive state, feature isolation, offline-first persistence, security, automated testing, and self-hosted CI/CD.
This repository is intentionally a **base app**: it is meant to be cloned or adapted into multiple real production applications. Product identity, package/bundle IDs, URL schemes, environment configuration, artifact naming, and CI secrets are kept explicit and centralized so a derived app can be rebranded without spreading product-specific values through business code.
The project is a sibling of `app-react-native` and `app-kmp`: it keeps the feature boundaries and governance model proven in the React Native project while adopting the layered MVVM structure and constructor-driven dependencies used by the KMP project.

> **Current foundation:** Flutter 3.47.6 / Dart 3.13.5, iOS 15+, and validated Android/iOS `production` and `staging` flavors. MVVM, ObjectBox, MobX, authentication, advanced quality gates, and application-specific CI/CD are planned, not yet implemented.

---
## 🚀 Key Features

- **Reusable App Foundation (implemented):** Non-sensitive product identity and native environments are derived from `ci/artifacts.env`, with repeatable `--apply` and drift-detecting `--check` commands.
- **Native Flavors (validated):** Android product flavors and iOS shared schemes provide distinct production/staging app IDs, display names, and custom URL schemes, with side-by-side installation and deep-link testing on emulators/simulators.
- **MVVM (planned):** Views focus on rendering and interaction while ViewModels own presentation state and commands.
- **Reactive by Design (planned):** MobX drives ViewModel state, while ObjectBox reactive queries propagate local data changes through repositories to the UI.
- **Feature-First Architecture (planned):** Business domains remain isolated and expose explicit public APIs.
- **Layered Features (planned):** Features may contain Presentation, Domain, and Data layers without unnecessary ceremony.
- **Offline-First Persistence (planned):** ObjectBox will be the primary local source of truth for persistent application data.
- **Secure Credentials (planned):** Authentication tokens and secrets will stay outside ObjectBox and use native secure storage.
- **Constructor Injection (planned):** GetIt and Injectable will compose the dependency graph; business code will receive dependencies through constructors.
- **Automated Quality:** Dart format, static analysis, starter tests, identity validation, and native debug builds have been validated locally. Architecture rules, business coverage, security scans, Android Lint, and E2E remain future gates.
- **Self-Hosted CI/CD (planned for this repository):** Linux/Android workloads will run on a self-hosted amd64 agent, while Xcode/iOS workloads remain on macOS.

---
## 🗺️ Initial Roadmap

### Foundation

- [x] Bootstrap Flutter project and validate Flutter 3.47.6 / Dart 3.13.5 on Windows and macOS ARM64.
- [x] Verify the iOS deployment target is 15.0.
- [x] Validate Android APK and iOS `.app` debug builds.
- [x] Implement and validate Android/iOS Staging and Production flavors, including default production selection.
- [x] Centralize base-app identity and artifact configuration in `ci/artifacts.env`.
- [x] Add `tool/configure_app.dart` for app identity application and validation, with idempotency and negative tests.
- [x] Validate distinct app IDs, labels, URL schemes, side-by-side installation, and deep links on Android and iOS simulators/emulators.
- [ ] Configure MVVM, feature boundaries, GetIt/Injectable, MobX, and go_router.

### Reactive Offline Foundation

- [ ] Configure ObjectBox and version `objectbox-model.json`.
- [ ] Validate reactive `watch()` behavior with a real repository flow.
- [ ] Add secure credential storage and biometrics.
- [ ] Implement the first complete feature slice.

### Testing and Governance

- [x] Validate existing Flutter starter test and static analysis locally.
- [x] Validate the app identity gate with positive and negative checks, including iOS flavor project structure.
- [ ] Add domain/unit, ViewModel, repository integration, and feature widget tests.
- [ ] Create the `app_arch_lints` analyzer plugin.
- [ ] Enforce feature/layer boundaries.
- [ ] Measure business and authored coverage before defining thresholds.

### Security and Native Quality

- [ ] Gitleaks.
- [ ] Opengrep.
- [ ] Trivy.
- [ ] jscpd diagnostic baseline.
- [ ] Android Lint baseline and classification.

### CI/CD and E2E

- [ ] Create a dedicated Flutter Android CI image for the self-hosted amd64 executor.
- [ ] Reproduce local quality gates in Woodpecker CI.
- [ ] Add Patrol E2E for Android and iOS.
- [ ] Add Android/iOS signed production release flows.
- [ ] Integrate Garage, Gitea Releases, GitHub mirror/releases, and Gotify into the Flutter release pipeline.

### Future Evaluation

- [ ] Shorebird OTA after the traditional release pipeline is stable.
- [ ] Generic offline mutation/outbox support only when a real feature requires offline writes and synchronization.

---
## 🛠️ Tech Stack

The framework/toolchain and native flavor support are already validated. The remaining architecture, state-management, persistence, security, and delivery entries describe the **selected or planned stack**, not installed dependencies.

| Area | Technology |
|---|---|
| Framework | Flutter 3.47.6 (validated baseline) |
| Language | Dart 3.13.5 (validated baseline) |
| Native Environments | Android productFlavors / Xcode schemes and configurations (validated) |
| Architecture | MVVM + Feature-First + Presentation / Domain / Data (planned) |
| Reactive State | MobX + `flutter_mobx` (planned) |
| Dependency Injection | GetIt + Injectable (planned) |
| Navigation | go_router (planned) |
| Offline Database | ObjectBox (planned) |
| Networking | Dio (planned) |
| Backend | `api-bun` (integration planned) |
| Authentication | Better Auth behind `AuthRepository` (Flutter adapter to be validated) |
| JSON | json_serializable (planned) |
| Secure Storage | flutter_secure_storage (planned) |
| Biometrics | local_auth (planned) |
| Connectivity | connectivity_plus (planned) |
| Localization | Flutter `gen_l10n` + ARB (planned) |
| UI Catalog | Widgetbook (planned) |
| Unit / Widget Tests | flutter_test (starter test validated); mocktail planned |
| E2E | Patrol (planned) |
| Static Analysis | Dart analyzer / `flutter analyze` (validated locally) |
| Architecture Rules | Custom analyzer plugin (`app_arch_lints`) (planned) |
| Secrets | Gitleaks (planned) |
| SAST | Opengrep (planned) |
| Dependencies | Trivy (planned) |
| Duplication | jscpd (planned) |
| Android Native Analysis | Android Lint (planned) |
| CI/CD | Woodpecker CI for this app (planned) |

---
## 🏗️ Project Architecture

The **target architecture** combines feature isolation with layered MVVM. These directories describe the intended evolution, not the current bootstrap filesystem; they should be introduced only when they contain real behavior.

```text
lib/
├── main.dart                        # Current shared entrypoint
├── app/                             # Planned
│   ├── bootstrap/
│   ├── di/
│   ├── environment/
│   ├── navigation/
│   └── app.dart
│
├── features/                        # Planned
│   ├── auth/
│   │   ├── auth.dart                # Public API
│   │   ├── presentation/
│   │   │   ├── views/
│   │   │   ├── widgets/
│   │   │   ├── viewmodels/
│   │   │   └── effects/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   ├── errors/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── data/
│   │       ├── repositories/
│   │       ├── remote/
│   │       └── local/
│   │
│   └── profile/
│       └── ...
│
└── shared/                          # Planned
    ├── domain/
    ├── data/
    └── presentation/
```

Directories should be introduced only when they contain real behavior. The architecture must not create empty layers or artificial use cases only to satisfy a diagram. Native flavors currently share `lib/main.dart`; separate `main_staging.dart` and `main_production.dart` entrypoints are not required.

### Dependency Flow

```text
Presentation ─────► Domain ◄───── Data
```

- **Presentation:** Views, Widgets, ViewModels, MobX state, and UI effects.
- **Domain:** Business models, errors, repository contracts, and pure business rules.
- **Data:** Repository implementations, networking, persistence, DTOs, entities, mappers, and secure-storage implementations.

The Domain layer must not depend on Flutter, MobX, ObjectBox, Dio, GetIt, or platform APIs.

---

## 📏 Architecture Guidelines

### 1. Top-Level Boundaries

```text
app
 ↓
features
 ↓
shared
```

- `app` composes features and shared infrastructure.
- `features` may depend on `shared`.
- `shared` must never depend on `features` or `app`.

### 2. Feature Encapsulation

Each feature exposes a public entry point:

```dart
import 'package:app_flutter/features/auth/auth.dart';
```

Deep imports from another feature are prohibited:

```dart
// ❌ Wrong
import 'package:app_flutter/features/auth/data/repositories/auth_repository_impl.dart';
```

The custom Dart analyzer plugin and CI are intended to enforce these boundaries once implemented.

### 3. Constructor Injection

Business code will receive dependencies through constructors:

```dart
class ProfileViewModel {
  ProfileViewModel(this._repository);

  final ProfileRepository _repository;
}
```

Direct GetIt access inside repositories, Domain code, or ViewModels will be prohibited. GetIt remains restricted to the composition root, route/view composition, and test setup.

### 4. Infrastructure Isolation

- Views and ViewModels do not access Dio or ObjectBox directly.
- ObjectBox entities stay inside Data.
- Data never imports Presentation.
- `BuildContext` does not belong inside ViewModels.
- Credentials stay behind abstractions such as `AuthCredentialStore`.

---
## 🧩 Base App Configuration

The project must remain easy to derive into a real production app.

The **versioned, non-sensitive** identity and artifact configuration is implemented in:

```text
ci/artifacts.env
```

Current identity contract:

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

The following tool is implemented and validated on Windows and macOS ARM64:

```bash
dart run tool/configure_app.dart --apply
dart run tool/configure_app.dart --check
```

`--apply` generates/applies the supported native identity files; `--check` detects drift against the canonical configuration. The latter also checks iOS flavor schemes, Xcode configurations, and `.xcconfig` references. Negative tests have verified that incorrect staging paths and a missing shared scheme fail the gate; changes are restored afterward. Running `--apply` repeatedly has been validated for idempotency.

```text
ci/artifacts.env
    ├── android/app/AppIdentity.properties
    │     └── Android productFlavors / manifest placeholders
    └── ios/Flutter/AppIdentity.xcconfig
          ios/Flutter/AppIdentity-staging.xcconfig
              └── Xcode configurations / schemes / Info.plist
```

`DART_PACKAGE_NAME` is primarily a bootstrap/rebranding setting. The current identity tool does **not** provision signing credentials, CI pipelines, runtime endpoints, or release publishing. `ARTIFACT_BASENAME` and Garage configuration are defined for future CI use, not yet enforced end-to-end as an artifact/release gate.

Environment-specific **non-sensitive** runtime configuration is planned in files such as:

```text
config/staging.json
config/production.json
```

It may later be passed using `--dart-define-from-file`. These files do not currently form an implemented runtime environment layer. Secrets must never be stored in them. Signing credentials, CI tokens, private keys, storage credentials, and release tokens stay in CI secrets or local secure files.

> Any value shipped inside the mobile binary must be treated as public. Client-side configuration is not a secret store.

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

*Planned implementation.*

MobX will be restricted to Presentation:

```text
Domain       → no MobX
Data         → no MobX
ViewModel    → MobX Store
View        → Observer
```

ViewModels may expose observable state, computed values, commands/actions, and one-shot UI effects.

Navigation, dialogs, snackbars, and external actions are UI effects rather than durable state. ViewModels must not receive `BuildContext`.
Shared application data should normally be shared through repositories/ObjectBox rather than global ViewModel instances.

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

- Flutter **3.47.6** / Dart **3.13.5** (validated local baseline).
- Android Studio, Android SDK and compatible NDK for Android development.
- macOS with Xcode **26.6** and iOS tooling for iOS development (validated Mac baseline).
- iOS minimum deployment target: **15.0**.

### Install Dependencies

```bash
flutter pub get
```

### Apply and Check App Identity

After changing any supported values in `ci/artifacts.env`:

```bash
dart run tool/configure_app.dart --apply
dart run tool/configure_app.dart --check
```

For regular development/CI validation, use `--check`; do not automatically rewrite identity files to hide drift.

### Static Analysis

```bash
dart format --output=none --set-exit-if-changed tool
flutter analyze
```

### Tests

```bash
flutter test
```

The initial Flutter template widget test passes. Feature-level unit, repository, ViewModel and E2E suites are still planned. Code generation via `build_runner` is also planned and is not a bootstrap prerequisite yet.

### Android

```bash
flutter run --flavor production
flutter run --flavor staging

flutter build apk --debug --flavor production
flutter build apk --debug --flavor staging
flutter build apk --debug                  # default: production
```

The debug APKs are produced as `app-production-debug.apk` and `app-staging-debug.apk` in `build/app/outputs/flutter-apk/`.

### iOS (macOS only)

```bash
flutter run --flavor production
flutter run --flavor staging

flutter build ios --debug --flavor production --no-codesign
flutter build ios --debug --flavor staging --no-codesign
flutter build ios --debug --no-codesign   # default: production
```

These iOS build commands produce an **unsigned device-targeted `.app`** for build validation; running the flavors has been validated separately on Simulator. `build/ios/iphoneos/Runner.app` is overwritten by the subsequent flavor build. Neither proves signed distribution to physical devices.

---
## 🧪 Testing & Quality

### Validated Local Baseline

- `dart format --output=none --set-exit-if-changed tool`: PASS.
- `dart run tool/configure_app.dart --check`: `APP_IDENTITY_CHECK=PASS` on Windows/macOS.
- `flutter analyze`: no issues.
- `flutter test`: starter widget test (1 passing test).
- Android: explicit production/staging and implicit production debug APK builds; package, label, and URL scheme inspected in packaged manifests; both apps launched via deep links on emulator.
- iOS: explicit production/staging and implicit production unsigned debug builds; final `Info.plist` inspected; both apps installed and launched via deep links on Simulator.
- Identity configurator: repeated `--apply` plus `--check`; negative tests for an invalid iOS `.xcconfig` reference and a missing `staging.xcscheme` returned FAIL, then PASS after restoration.

**Scope:** these are local validations, not a Flutter Woodpecker pipeline, release-signing gate, Patrol test suite, or production-device certification.

### Planned Test Levels

```text
Pure Unit Tests
→ Domain rules, errors, mappers

ViewModel Tests
→ commands, MobX state, computed values, UI effects

Repository Integration Tests
→ repository behavior with a real temporary ObjectBox store

Widget Tests
→ feature View behavior

Patrol E2E
→ Android and iOS user flows
```

Repository tests should validate the real reactive persistence path when relevant:

```text
write
→ ObjectBox
→ watch()
→ Repository stream
→ updated state
```

### Planned Quality Gate

```text
Code generation
ObjectBox schema consistency
Dart format
Flutter analyze
Architecture boundaries
Unit tests
Widget tests
Business coverage
Authored coverage diagnostics
Gitleaks
Opengrep
Trivy
jscpd
Android Lint
Production build smoke test
```

The project follows an incremental gate policy:

```text
measure
→ understand findings
→ fix real issues
→ define a baseline
→ validate positive and negative paths
→ make the gate blocking
```

Coverage thresholds are intentionally **not defined yet**. The project will first measure real business coverage after the initial features are implemented.

jscpd starts as a diagnostic tool; the project does not target artificial `0%` duplication.

---
## ⚙️ CI/CD

The project **plans** to use self-hosted Woodpecker CI. Flutter-specific pipelines and release signing are not yet implemented or validated in this repository.

```text
Pull Request / Push
        │
        ├── ARM64 / always-on
        │     └── lightweight preflight / VM wake
        │
        └── Linux amd64 agent
              ├── dependency restore
              ├── code generation
              ├── format / analyzer
              ├── architecture rules
              ├── tests / coverage
              ├── security scans
              ├── Android Lint
              └── Android build validation
Manual iOS / Release
        │
        └── macOS arm64 agent
              ├── Xcode / iOS build
              ├── Patrol iOS
              ├── signing / packaging
              └── release steps
```

Operational rules:

- Gitea is the source of truth for this repository.
- GitHub is the external mirror; mirroring is separate from Flutter CI/release validation.
- Self-hosted amd64 infrastructure will handle Linux/Android heavy quality workloads.
- macOS will handle Xcode/iOS workloads.
- Garage may store internal artifacts.
- Gotify may report pipeline results.
- E2E/instrumented builds must not be published as final Production artifacts; Production is rebuilt clean after E2E gates pass.

---
## 📐 Project Guidelines

- Prefer constructor injection over Service Locator access inside business code.
- Keep Domain independent from Flutter and infrastructure libraries.
- Keep ObjectBox entities inside Data.
- Keep credentials outside ObjectBox.
- Do not share global ViewModels when shared repository state solves the problem.
- Do not add architectural layers without real behavior.
- Do not suppress analyzer/security findings only to make CI green.
- Do not create artificial abstractions only to reduce duplication metrics.
- Do not create tests only to increase coverage.
- Measure baselines before defining thresholds.
- Add and validate one major quality gate at a time.
- Keep E2E configuration out of final Production artifacts.
- Keep product identity and environment values centralized; do not scatter app names, IDs, schemes, endpoints, or artifact names through business code.
- Treat any value embedded in the client binary as public; real secrets stay outside source and release artifacts.

---
## 📚 Related Projects

- [Brunno13/app-react-native](https://github.com/Brunno13/app-react-native) — feature isolation, architecture boundaries, security gates, E2E, and React Native CI/CD reference.
- [Brunno13/app-kmp](https://github.com/Brunno13/app-kmp) — MVVM, Presentation/Domain/Data, constructor injection, business coverage, and KMP CI/CD reference.
- [Brunno13/api-bun](https://github.com/Brunno13/api-bun) — backend used by the sibling mobile projects and initial backend target for this project.

---
This repository is intended to remain a reusable Flutter foundation and evolve incrementally as architecture, platform integrations, and quality gates are validated in real code.
