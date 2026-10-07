import 'dart:io';

const _configPath = 'ci/artifacts.env';
const _androidBuildPath = 'android/app/build.gradle.kts';
const _androidManifestPath = 'android/app/src/main/AndroidManifest.xml';
const _androidKotlinRoot = 'android/app/src/main/kotlin';
const _pubspecPath = 'pubspec.yaml';

void main(List<String> args) {
  if (args.length != 1 || !{'--apply', '--check'}.contains(args.first)) {
    stderr.writeln('Usage: dart run tool/configure_app.dart --apply|--check');
    exitCode = 64;
    return;
  }

  final config = _readEnvFile(File(_configPath));

  final identity = AppIdentity(
    displayName: _required(config, 'APP_DISPLAY_NAME'),
    dartPackageName: _required(config, 'DART_PACKAGE_NAME'),
    androidNamespace: _required(config, 'ANDROID_NAMESPACE'),
    androidApplicationId: _required(config, 'ANDROID_APPLICATION_ID'),
    appScheme: _required(config, 'APP_SCHEME'),
  );

  _validateIdentity(identity);

  if (args.first == '--apply') {
    _apply(identity);
  } else {
    _check(identity);
  }
}

void _apply(AppIdentity identity) {
  stdout.writeln('Applying application identity...');

  _updatePubspec(identity);
  _updateAndroidBuild(identity);
  _updateAndroidManifest(identity);
  _updateAndroidMainActivity(identity);

  stdout.writeln();
  stdout.writeln('APP_IDENTITY_APPLY=PASS');
}

void _check(AppIdentity identity) {
  stdout.writeln('Checking application identity...');

  final failures = <String>[];

  _checkPubspec(identity, failures);
  _checkAndroidBuild(identity, failures);
  _checkAndroidManifest(identity, failures);
  _checkAndroidMainActivity(identity, failures);

  if (failures.isNotEmpty) {
    for (final failure in failures) {
      stderr.writeln('FAIL: $failure');
    }

    stderr.writeln();
    stderr.writeln('APP_IDENTITY_CHECK=FAIL');

    exitCode = 1;
    return;
  }

  stdout.writeln();
  stdout.writeln('APP_IDENTITY_CHECK=PASS');
}

Map<String, String> _readEnvFile(File file) {
  if (!file.existsSync()) {
    throw StateError('Missing ${file.path}');
  }

  final result = <String, String>{};

  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();

    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    final separator = line.indexOf('=');

    if (separator <= 0) {
      throw FormatException('Invalid line in ${file.path}: $rawLine');
    }

    final key = line.substring(0, separator).trim();
    var value = line.substring(separator + 1).trim();

    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }

    result[key] = value;
  }

  return result;
}

String _required(Map<String, String> config, String key) {
  final value = config[key];

  if (value == null || value.trim().isEmpty) {
    throw StateError('Missing required configuration: $key');
  }

  return value.trim();
}

void _validateIdentity(AppIdentity identity) {
  final dartPackagePattern = RegExp(r'^[a-z][a-z0-9_]*$');
  final androidIdPattern = RegExp(
    r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$',
  );
  final schemePattern = RegExp(r'^[a-z][a-z0-9+.-]*$');

  if (!dartPackagePattern.hasMatch(identity.dartPackageName)) {
    throw StateError('Invalid DART_PACKAGE_NAME: ${identity.dartPackageName}');
  }

  if (!androidIdPattern.hasMatch(identity.androidNamespace)) {
    throw StateError('Invalid ANDROID_NAMESPACE: ${identity.androidNamespace}');
  }

  if (!androidIdPattern.hasMatch(identity.androidApplicationId)) {
    throw StateError(
      'Invalid ANDROID_APPLICATION_ID: '
      '${identity.androidApplicationId}',
    );
  }

  if (!schemePattern.hasMatch(identity.appScheme)) {
    throw StateError('Invalid APP_SCHEME: ${identity.appScheme}');
  }
}

void _updatePubspec(AppIdentity identity) {
  final file = File(_pubspecPath);
  var content = file.readAsStringSync();

  final currentPackage = RegExp(
    r'^name:\s*([a-zA-Z0-9_]+)\s*$',
    multiLine: true,
  ).firstMatch(content)?.group(1);

  if (currentPackage == null) {
    throw StateError('Unable to locate package name in $_pubspecPath');
  }

  if (currentPackage != identity.dartPackageName) {
    content = content.replaceFirst(
      RegExp(r'^name:\s*[a-zA-Z0-9_]+\s*$', multiLine: true),
      'name: ${identity.dartPackageName}',
    );

    file.writeAsStringSync(content);

    _replaceDartPackageImports(currentPackage, identity.dartPackageName);
  }
}

void _replaceDartPackageImports(String oldPackage, String newPackage) {
  for (final root in ['lib', 'test']) {
    final directory = Directory(root);

    if (!directory.existsSync()) {
      continue;
    }

    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final original = entity.readAsStringSync();
      final updated = original.replaceAll(
        'package:$oldPackage/',
        'package:$newPackage/',
      );

      if (updated != original) {
        entity.writeAsStringSync(updated);
      }
    }
  }
}

void _updateAndroidBuild(AppIdentity identity) {
  final file = File(_androidBuildPath);
  var content = file.readAsStringSync();

  content = content.replaceFirst(
    RegExp(r'namespace\s*=\s*"[^"]+"'),
    'namespace = "${identity.androidNamespace}"',
  );

  content = content.replaceFirst(
    RegExp(r'applicationId\s*=\s*"[^"]+"'),
    'applicationId = "${identity.androidApplicationId}"',
  );

  file.writeAsStringSync(content);
}

void _updateAndroidManifest(AppIdentity identity) {
  final file = File(_androidManifestPath);
  var content = file.readAsStringSync();

  content = content.replaceFirst(
    RegExp(r'android:label="[^"]*"'),
    'android:label="${identity.displayName}"',
  );

  file.writeAsStringSync(content);
}

void _updateAndroidMainActivity(AppIdentity identity) {
  final kotlinRoot = Directory(_androidKotlinRoot);

  if (!kotlinRoot.existsSync()) {
    throw StateError('Missing Android Kotlin root: $_androidKotlinRoot');
  }

  final candidates = kotlinRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('MainActivity.kt'))
      .toList();

  if (candidates.length != 1) {
    throw StateError(
      'Expected exactly one MainActivity.kt, found ${candidates.length}',
    );
  }

  final source = candidates.single;
  var content = source.readAsStringSync();

  content = content.replaceFirst(
    RegExp(r'^package\s+[^\s]+', multiLine: true),
    'package ${identity.androidNamespace}',
  );

  final relativePackagePath = identity.androidNamespace.replaceAll('.', '/');

  final target = File(
    '$_androidKotlinRoot/$relativePackagePath/MainActivity.kt',
  );

  target.parent.createSync(recursive: true);
  target.writeAsStringSync(content);

  if (source.absolute.path != target.absolute.path) {
    source.deleteSync();
    _removeEmptyParents(source.parent, kotlinRoot);
  }
}

void _removeEmptyParents(Directory directory, Directory stopAt) {
  var current = directory;

  while (current.absolute.path != stopAt.absolute.path) {
    if (!current.existsSync()) {
      break;
    }

    if (current.listSync().isNotEmpty) {
      break;
    }

    final parent = current.parent;
    current.deleteSync();
    current = parent;
  }
}

void _checkPubspec(AppIdentity identity, List<String> failures) {
  final content = File(_pubspecPath).readAsStringSync();

  if (!RegExp(
    '^name:\\s*${RegExp.escape(identity.dartPackageName)}\\s*\$',
    multiLine: true,
  ).hasMatch(content)) {
    failures.add(
      'pubspec.yaml does not use '
      'DART_PACKAGE_NAME=${identity.dartPackageName}',
    );
  }
}

void _checkAndroidBuild(AppIdentity identity, List<String> failures) {
  final content = File(_androidBuildPath).readAsStringSync();

  if (!content.contains('namespace = "${identity.androidNamespace}"')) {
    failures.add(
      'Android namespace differs from '
      'ANDROID_NAMESPACE=${identity.androidNamespace}',
    );
  }

  if (!content.contains('applicationId = "${identity.androidApplicationId}"')) {
    failures.add(
      'Android applicationId differs from '
      'ANDROID_APPLICATION_ID=${identity.androidApplicationId}',
    );
  }
}

void _checkAndroidManifest(AppIdentity identity, List<String> failures) {
  final content = File(_androidManifestPath).readAsStringSync();

  if (!content.contains('android:label="${identity.displayName}"')) {
    failures.add(
      'Android display name differs from '
      'APP_DISPLAY_NAME=${identity.displayName}',
    );
  }
}

void _checkAndroidMainActivity(AppIdentity identity, List<String> failures) {
  final packagePath = identity.androidNamespace.replaceAll('.', '/');

  final file = File('$_androidKotlinRoot/$packagePath/MainActivity.kt');

  if (!file.existsSync()) {
    failures.add(
      'MainActivity.kt is not located under '
      '${identity.androidNamespace}',
    );
    return;
  }

  final content = file.readAsStringSync();

  if (!RegExp(
    '^package\\s+${RegExp.escape(identity.androidNamespace)}\\s*\$',
    multiLine: true,
  ).hasMatch(content)) {
    failures.add(
      'MainActivity.kt package differs from '
      'ANDROID_NAMESPACE=${identity.androidNamespace}',
    );
  }
}

final class AppIdentity {
  const AppIdentity({
    required this.displayName,
    required this.dartPackageName,
    required this.androidNamespace,
    required this.androidApplicationId,
    required this.appScheme,
  });

  final String displayName;
  final String dartPackageName;
  final String androidNamespace;
  final String androidApplicationId;
  final String appScheme;
}
