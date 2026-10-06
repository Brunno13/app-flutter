# 📱 App-Flutter

Reusable Flutter base project for Android and iOS, designed around **MVVM**, reactive state, feature isolation, offline-first persistence, security, automated testing, and self-hosted CI/CD.

This repository is intentionally a **base app**: it is meant to be cloned or adapted into multiple real production applications. Product identity, package/bundle IDs, URL schemes, environment configuration, artifact naming, and CI secrets are kept explicit and centralized so a derived app can be rebranded without spreading product-specific values through business code.

The project is a sibling of `app-react-native` and `app-kmp`: it keeps the feature boundaries and governance model proven in the React Native project while adopting the layered MVVM structure and constructor-driven dependencies used by the KMP project.

> Initial target: **Flutter 3.47.x / Dart 3.13.x**, with **iOS 15+**.

---

## 🚀 Key Features

- **Reusable App Foundation:** Product identity, environments, artifact naming, and sensitive CI configuration are intentionally separated from business logic.
- **MVVM:** Views focus on rendering and interaction while ViewModels own presentation state and commands.
- **Reactive by Design:** MobX drives ViewModel state, while ObjectBox reactive queries propagate local data changes through repositories to the UI.
- **Feature-First Architecture:** Business domains remain isolated and expose explicit public APIs.
- **Layered Features:** Features may contain Presentation, Domain, and Data layers without unnecessary ceremony.
- **Offline-First Persistence:** ObjectBox is the primary local source of truth for persistent application data.
- **Secure Credentials:** Authentication tokens and secrets stay outside ObjectBox and use native secure storage.
- **Constructor Injection:** GetIt and Injectable compose the dependency graph; business code receives dependencies through constructors.
- **Automated Quality:** Formatting, static analysis, architecture rules, tests, coverage, security scans, Android Lint, and build validation are planned as CI gates.
- **Self-Hosted CI/CD:** Linux/Android workloads run on VM104, while Xcode/iOS workloads remain on the macOS agent.

---

## 🗺️ Initial Roadmap

### Foundation

- [ ] Bootstrap Flutter project and pin Flutter/Dart versions.
- [ ] Set the iOS deployment target to 15+.
- [ ] Validate Android and iOS builds.
- [ ] Add Staging and Production environments.
- [ ] Centralize base-app identity and artifact configuration in `ci/artifacts.env`.
- [ ] Add a bootstrap/validation script for safe app renaming and identity changes.
- [ ] Configure MVVM, feature boundaries, GetIt/Injectable, MobX, and go_router.

### Reactive Offline Foundation

- [ ] Configure ObjectBox and version `objectbox-model.json`.
- [ ] Validate reactive `watch()` behavior with a real repository flow.
- [ ] Add secure credential storage and biometrics.
- [ ] Implement the first complete feature slice.

### Testing and Governance

- [ ] Add unit, ViewModel, repository integration, and widget tests.
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

- [ ] Create a dedicated Flutter Android CI image for VM104.
- [ ] Reproduce local quality gates in Woodpecker CI.
- [ ] Add Patrol E2E for Android and iOS.
- [ ] Add Android/iOS production release flows.
- [ ] Integrate Garage, Gitea Releases, GitHub mirror/releases, and Gotify.

### Future Evaluation

- [ ] Shorebird OTA after the traditional release pipeline is stable.
- [ ] Generic offline mutation/outbox support only when a real feature requires offline writes and synchronization.

---

## 🛠️ Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter 3.47.x |
| Language | Dart 3.13.x |
| Architecture | MVVM + Feature-First + Presentation / Domain / Data |
| Reactive State | MobX + `flutter_mobx` |
| Dependency Injection | GetIt + Injectable |
| Navigation | go_router |
| Offline Database | ObjectBox |
| Networking | Dio |
| Backend | `api-bun` |
| Authentication | Better Auth behind `AuthRepository` (Flutter adapter to be validated) |
| JSON | json_serializable |
| Secure Storage | flutter_secure_storage |
| Biometrics | local_auth |
| Connectivity | connectivity_plus |
| Localization | Flutter `gen_l10n` + ARB |
| UI Catalog | Widgetbook |
| Unit / Widget Tests | flutter_test + mocktail |
| E2E | Patrol |
| Static Analysis | Dart analyzer / `flutter analyze` |
| Architecture Rules | Custom analyzer plugin (`app_arch_lints`) |
| Secrets | Gitleaks |
| SAST | Opengrep |
| Dependencies | Trivy |
| Duplication | jscpd |
| Android Native Analysis | Android Lint |
| CI/CD | Woodpecker CI |

---

## 🏗️ Project Architecture

The project combines **feature isolation** with **layered MVVM**.

```text
lib/
├── app/
│   ├── bootstrap/
│   ├── di/
│   ├── environment/
│   ├── navigation/
│   └── app.dart
│
├── features/
│   ├── auth/
│   │   ├── auth.dart                 # Public API
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
├── shared/
│   ├── domain/
│   ├── data/
│   └── presentation/
│
├── main_staging.dart
└── main_production.dart
```

Directories should be introduced only when they contain real behavior. The architecture must not create empty layers or artificial use cases only to satisfy a diagram.

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

The custom Dart analyzer plugin and CI are intended to enforce these boundaries.

### 3. Constructor Injection

Business code receives dependencies through constructors:

```dart
class ProfileViewModel {
  ProfileViewModel(this._repository);

  final ProfileRepository _repository;
}
```

Direct GetIt access inside repositories, Domain code, or ViewModels is prohibited. GetIt remains restricted to the composition root, route/view composition, and test setup.

### 4. Infrastructure Isolation

- Views and ViewModels do not access Dio or ObjectBox directly.
- ObjectBox entities stay inside Data.
- Data never imports Presentation.
- `BuildContext` does not belong inside ViewModels.
- Credentials stay behind abstractions such as `AuthCredentialStore`.

---

## 🧩 Base App Configuration

The project must remain easy to derive into a real production app.

Versioned non-sensitive identity and artifact configuration will live in:

```text
ci/artifacts.env
```

Initial contract:

```text
GARAGE_REGION
GARAGE_BUCKET
GARAGE_ANDROID_PREFIX
GARAGE_IOS_PREFIX
ARTIFACT_BASENAME

APP_DISPLAY_NAME
APP_STAGING_NAME_SUFFIX
ANDROID_APPLICATION_ID
IOS_BUNDLE_IDENTIFIER
APP_STAGING_ID_SUFFIX
APP_SCHEME
APP_STAGING_SCHEME_SUFFIX
IOS_PRODUCT_NAME
DART_PACKAGE_NAME
```

A bootstrap script is planned to apply these values consistently across Flutter, Android, iOS, deep links, artifact naming, and CI configuration when creating a derived application.

Environment-specific **non-sensitive** runtime configuration belongs in versioned files such as:

```text
config/staging.json
config/production.json
```

and may be passed with `--dart-define-from-file`.

Secrets are never stored in those files. Signing credentials, CI tokens, private keys, Garage credentials, release tokens, and similar values stay in Woodpecker secrets or local secure files.

> Any value shipped inside the mobile binary must be treated as public. Client-side configuration is not a secret store.

---

## 🔄 Reactive Offline-First Model

ObjectBox is the local source of truth for persistent offline-capable data.

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

`objectbox-model.json` is part of the schema history and must be versioned with the source code.

---

## 🧠 MVVM and Reactive State

MobX is restricted to Presentation:

```text
Domain       → no MobX
Data         → no MobX
ViewModel    → MobX Store
View         → Observer
```

ViewModels may expose observable state, computed values, commands/actions, and one-shot UI effects.

Navigation, dialogs, snackbars, and external actions are UI effects rather than durable state. ViewModels must not receive `BuildContext`.

Shared application data should normally be shared through repositories/ObjectBox rather than global ViewModel instances.

---

## 🔐 Security

Sensitive credentials are intentionally kept outside ObjectBox entities and presentation models.

### ObjectBox

May store:

- offline application data;
- cached user/profile data;
- local preferences when appropriate;
- non-sensitive session metadata.

### Secure Storage

Authentication tokens, secrets, and sensitive cryptographic material use `flutter_secure_storage` through an abstraction owned by the Data layer.

Credentials must never be stored in:

- ObjectBox entities;
- UI models;
- logs;
- user-facing error messages.

Biometric access uses `local_auth` and protects local application access; it does not replace remote authentication.

---

## 🌍 Environments

Initial environments:

```text
staging
production
```

Planned entry points:

```text
lib/main_staging.dart
lib/main_production.dart
```

Staging and Production should use separate application identities, with a `.staging` suffix for the non-production package/bundle identifier.

Non-sensitive configuration may use versioned environment files with `--dart-define-from-file`. Product identity and artifact naming are centralized separately in `ci/artifacts.env`.

Secrets remain outside the repository and are injected through local secure configuration or CI secrets. Values compiled into the application must never be treated as secrets.

Production must not inherit development, local-network, or E2E security exceptions.

---

## 🚀 Running Locally

The repository has not been bootstrapped yet. These commands represent the expected Flutter workflow and will be updated after the initial setup is validated.

### Prerequisites

- Flutter stable matching the version pinned by the repository.
- Android Studio + Android SDK for Android development.
- macOS + Xcode for iOS development.
- Access to the backend for authentication/network flows.

### Install Dependencies

```bash
flutter pub get
```

### Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Static Analysis

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
```

### Tests

```bash
flutter test
```

Coverage:

```bash
flutter test --coverage
```

Environment-specific run/build commands will be finalized after Staging and Production are implemented on both platforms.

---

## 🧪 Testing & Quality

Test levels:

```text
Pure Unit Tests
→ Domain rules, errors, mappers

ViewModel Tests
→ commands, MobX state, computed values, UI effects

Repository Integration Tests
→ repository behavior with a real temporary ObjectBox store

Widget Tests
→ Flutter View behavior

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

The project will use self-hosted Woodpecker CI.

```text
Pull Request / Push
        │
        ├── ARM64 / always-on
        │     └── lightweight preflight / VM wake
        │
        └── VM104 / linux-amd64
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
        └── MacBook / darwin-arm64
              ├── Xcode / iOS build
              ├── Patrol iOS
              ├── signing / packaging
              └── release steps
```

Operational rules:

- Gitea is the source of truth.
- GitHub remains the mirror/release target.
- VM104 handles Linux/Android and heavy quality workloads.
- The MacBook remains responsible for Xcode/iOS workloads.
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

- `Brunno13/app-react-native` — feature isolation, architecture boundaries, security gates, E2E, and React Native CI/CD reference.
- `Brunno13/app-kmp` — MVVM, Presentation/Domain/Data, constructor injection, business coverage, and KMP CI/CD reference.
- `Brunno13/api-bun` — backend used by the sibling mobile projects and initial backend target for this project.

---

This repository is intended to remain a reusable Flutter foundation and evolve incrementally as architecture, platform integrations, and quality gates are validated in real code.
