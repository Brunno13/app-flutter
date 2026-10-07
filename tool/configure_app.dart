import 'dart:io';

const _androidIdentityPropertiesPath = 'android/app/AppIdentity.properties';
const _configPath = 'ci/artifacts.env';
const _androidBuildPath = 'android/app/build.gradle.kts';
const _androidManifestPath = 'android/app/src/main/AndroidManifest.xml';
const _androidKotlinRoot = 'android/app/src/main/kotlin';
const _iosIdentityConfigPath = 'ios/Flutter/AppIdentity.xcconfig';
const _iosDebugConfigPath = 'ios/Flutter/Debug.xcconfig';
const _iosReleaseConfigPath = 'ios/Flutter/Release.xcconfig';
const _iosInfoPlistPath = 'ios/Runner/Info.plist';
const _iosProjectPath = 'ios/Runner.xcodeproj/project.pbxproj';
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
    iosBundleIdentifier: _required(config, 'IOS_BUNDLE_IDENTIFIER'),
    iosBundleName: _required(config, 'IOS_BUNDLE_NAME'),
    stagingNameSuffix: _required(config, 'APP_STAGING_NAME_SUFFIX'),
    stagingIdSuffix: _required(config, 'APP_STAGING_ID_SUFFIX'),
    stagingSchemeSuffix: _required(config, 'APP_STAGING_SCHEME_SUFFIX'),
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
  _updateAndroidIdentityProperties(identity);
  _updateAndroidManifest();
  _updateAndroidMainActivity(identity);
  _updateIosIdentityConfig(identity);
  _updateIosConfigIncludes();
  _updateIosInfoPlist();
  _updateIosProjectBundleIdentifiers();

  stdout.writeln();
  stdout.writeln('APP_IDENTITY_APPLY=PASS');
}

void _check(AppIdentity identity) {
  stdout.writeln('Checking application identity...');

  final failures = <String>[];

  _checkPubspec(identity, failures);

  _checkAndroidIdentityProperties(identity, failures);
  _checkAndroidManifest(failures);
  _checkAndroidMainActivity(identity, failures);
  _checkAndroidDeepLinkManifest(failures);
  _checkAndroidFlavors(failures);

  _checkIosIdentityConfig(identity, failures);
  _checkIosConfigIncludes(failures);
  _checkIosInfoPlist(failures);
  _checkIosProjectBundleIdentifiers(failures);
  _checkIosAppScheme(failures);

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

void _checkAndroidDeepLinkManifest(List<String> failures) {
  final content = File(_androidManifestPath).readAsStringSync();

  final requiredFragments = [
    'android.intent.action.VIEW',
    'android.intent.category.DEFAULT',
    'android.intent.category.BROWSABLE',
    r'android:scheme="${appScheme}"',
  ];

  for (final fragment in requiredFragments) {
    if (!content.contains(fragment)) {
      failures.add('Android deep-link manifest is missing: $fragment');
    }
  }
}

void _checkAndroidFlavors(List<String> failures) {
  final file = File(_androidBuildPath);

  if (!file.existsSync()) {
    failures.add('Missing $_androidBuildPath');
    return;
  }

  final content = file.readAsStringSync();

  final requiredFragments = [
    'import java.util.Properties',
    'file("AppIdentity.properties")',
    'appIdentity("androidNamespace")',
    'appIdentity("androidApplicationId")',
    'flavorDimensions += "environment"',
    'create("production")',
    'create("staging")',
    'appIdentity("productionDisplayName")',
    'appIdentity("productionAppScheme")',
    'appIdentity("stagingApplicationId")',
    'appIdentity("stagingDisplayName")',
    'appIdentity("stagingAppScheme")',
  ];

  for (final fragment in requiredFragments) {
    if (!content.contains(fragment)) {
      failures.add('Android flavor configuration is missing: $fragment');
    }
  }
}

void _checkIosAppScheme(List<String> failures) {
  final content = File(_iosInfoPlistPath).readAsStringSync();

  final requiredFragments = [
    '<key>CFBundleURLTypes</key>',
    '<key>CFBundleURLSchemes</key>',
    r'<string>$(APP_URL_SCHEME)</string>',
  ];

  for (final fragment in requiredFragments) {
    if (!content.contains(fragment)) {
      failures.add('iOS URL scheme configuration is missing: $fragment');
    }
  }
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

  // Do not trim the returned value.
  //
  // Quoted values may intentionally contain leading or trailing spaces.
  // Example:
  //
  // APP_STAGING_NAME_SUFFIX=" (staging)"
  //
  // _readEnvFile already trims unquoted values before storing them.
  return value;
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

  if (!androidIdPattern.hasMatch(identity.stagingApplicationId)) {
    throw StateError(
      'Invalid staging Android application ID derived from '
      'ANDROID_APPLICATION_ID + APP_STAGING_ID_SUFFIX: '
      '${identity.stagingApplicationId}',
    );
  }

  final iosBundleIdPattern = RegExp(r'^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$');

  if (!iosBundleIdPattern.hasMatch(identity.iosBundleIdentifier)) {
    throw StateError(
      'Invalid IOS_BUNDLE_IDENTIFIER: '
      '${identity.iosBundleIdentifier}',
    );
  }

  if (!schemePattern.hasMatch(identity.appScheme)) {
    throw StateError('Invalid APP_SCHEME: ${identity.appScheme}');
  }

  if (!schemePattern.hasMatch(identity.stagingAppScheme)) {
    throw StateError(
      'Invalid staging app scheme derived from '
      'APP_SCHEME + APP_STAGING_SCHEME_SUFFIX: '
      '${identity.stagingAppScheme}',
    );
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

void _updateAndroidManifest() {
  final file = File(_androidManifestPath);

  if (!file.existsSync()) {
    throw StateError('Missing $_androidManifestPath');
  }

  var content = file.readAsStringSync();

  final labelPattern = RegExp(r'android:label="[^"]*"');

  if (!labelPattern.hasMatch(content)) {
    throw StateError('Unable to locate android:label in $_androidManifestPath');
  }

  content = content.replaceFirst(labelPattern, r'android:label="${appName}"');

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
      'Expected exactly one MainActivity.kt, '
      'found ${candidates.length}',
    );
  }

  final source = candidates.single;

  var content = source.readAsStringSync();

  content = content.replaceFirst(
    RegExp(r'^package\s+[^\s]+', multiLine: true),
    'package ${identity.androidNamespace}',
  );

  final relativePackagePath = identity.androidNamespace
      .split('.')
      .join(Platform.pathSeparator);

  final target = File(
    [
      _androidKotlinRoot,
      relativePackagePath,
      'MainActivity.kt',
    ].join(Platform.pathSeparator),
  );

  if (_samePath(source.path, target.path)) {
    source.writeAsStringSync(content);
    return;
  }

  target.parent.createSync(recursive: true);
  target.writeAsStringSync(content);

  source.deleteSync();

  _removeEmptyParents(source.parent, kotlinRoot);
}

String _androidIdentityPropertiesContent(AppIdentity identity) {
  return '''
# Generated from ci/artifacts.env by tool/configure_app.dart.
# Do not edit manually.
androidNamespace=${identity.androidNamespace}
androidApplicationId=${identity.androidApplicationId}
productionDisplayName=${identity.displayName}
productionAppScheme=${identity.appScheme}
stagingApplicationId=${identity.stagingApplicationId}
stagingDisplayName=${identity.stagingDisplayName}
stagingAppScheme=${identity.stagingAppScheme}
''';
}

void _updateAndroidIdentityProperties(AppIdentity identity) {
  final file = File(_androidIdentityPropertiesPath);

  file.parent.createSync(recursive: true);

  file.writeAsStringSync(_androidIdentityPropertiesContent(identity));
}

String _iosIdentityConfigContent(AppIdentity identity) {
  return '''
// Generated from ci/artifacts.env by tool/configure_app.dart.
// Do not edit manually.
APP_DISPLAY_NAME = ${identity.displayName}
APP_BUNDLE_IDENTIFIER = ${identity.iosBundleIdentifier}
APP_BUNDLE_NAME = ${identity.iosBundleName}
APP_URL_SCHEME = ${identity.appScheme}
''';
}

void _updateIosIdentityConfig(AppIdentity identity) {
  final file = File(_iosIdentityConfigPath);

  file.parent.createSync(recursive: true);

  file.writeAsStringSync(_iosIdentityConfigContent(identity));
}

void _updateIosConfigIncludes() {
  _ensureXcconfigInclude(File(_iosDebugConfigPath), 'AppIdentity.xcconfig');

  _ensureXcconfigInclude(File(_iosReleaseConfigPath), 'AppIdentity.xcconfig');
}

void _ensureXcconfigInclude(File file, String includeName) {
  if (!file.existsSync()) {
    throw StateError('Missing ${file.path}');
  }

  final directive = '#include "$includeName"';

  final lines = file.readAsLinesSync();

  if (lines.contains(directive)) {
    return;
  }

  lines.insert(0, directive);

  file.writeAsStringSync('${lines.join('\n')}\n');
}

void _updateIosInfoPlist() {
  final file = File(_iosInfoPlistPath);

  if (!file.existsSync()) {
    throw StateError('Missing $_iosInfoPlistPath');
  }

  var content = file.readAsStringSync();

  content = _replacePlistString(
    content,
    'CFBundleDisplayName',
    r'$(APP_DISPLAY_NAME)',
  );

  content = _replacePlistString(content, 'CFBundleName', r'$(APP_BUNDLE_NAME)');

  file.writeAsStringSync(content);
}

String _replacePlistString(String content, String key, String value) {
  final pattern = RegExp(
    '<key>${RegExp.escape(key)}</key>\\s*'
    '<string>[^<]*</string>',
  );

  if (!pattern.hasMatch(content)) {
    throw StateError('Unable to locate $key in $_iosInfoPlistPath');
  }

  return content.replaceFirstMapped(
    pattern,
    (_) => '<key>$key</key>\n\t<string>$value</string>',
  );
}

void _updateIosProjectBundleIdentifiers() {
  final file = File(_iosProjectPath);

  if (!file.existsSync()) {
    throw StateError('Missing $_iosProjectPath');
  }

  var content = file.readAsStringSync();

  final pattern = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);');

  final matches = pattern.allMatches(content).toList();

  if (matches.isEmpty) {
    throw StateError(
      'No PRODUCT_BUNDLE_IDENTIFIER entries found '
      'in $_iosProjectPath',
    );
  }

  content = content.replaceAllMapped(pattern, (match) {
    final current = match.group(1)!;

    if (current.contains('RunnerTests')) {
      return r'PRODUCT_BUNDLE_IDENTIFIER = "$(APP_BUNDLE_IDENTIFIER).RunnerTests";';
    }

    return r'PRODUCT_BUNDLE_IDENTIFIER = "$(APP_BUNDLE_IDENTIFIER)";';
  });

  file.writeAsStringSync(content);
}

void _checkPubspec(AppIdentity identity, List<String> failures) {
  final content = File(_pubspecPath).readAsStringSync();

  if (!RegExp(
    '^name:\\s*'
    '${RegExp.escape(identity.dartPackageName)}'
    '\\s*\$',
    multiLine: true,
  ).hasMatch(content)) {
    failures.add(
      'pubspec.yaml does not use '
      'DART_PACKAGE_NAME=${identity.dartPackageName}',
    );
  }
}

void _checkAndroidManifest(List<String> failures) {
  final file = File(_androidManifestPath);

  if (!file.existsSync()) {
    failures.add('Missing $_androidManifestPath');
    return;
  }

  final content = file.readAsStringSync();

  if (!content.contains(r'android:label="${appName}"')) {
    failures.add(
      'Android display name is not driven by '
      'the appName manifest placeholder',
    );
  }
}

void _checkAndroidMainActivity(AppIdentity identity, List<String> failures) {
  final packagePath = identity.androidNamespace.replaceAll('.', '/');

  final file = File(
    '$_androidKotlinRoot/'
    '$packagePath/'
    'MainActivity.kt',
  );

  if (!file.existsSync()) {
    failures.add(
      'MainActivity.kt is not located under '
      '${identity.androidNamespace}',
    );
    return;
  }

  final content = file.readAsStringSync();

  if (!RegExp(
    '^package\\s+'
    '${RegExp.escape(identity.androidNamespace)}'
    '\\s*\$',
    multiLine: true,
  ).hasMatch(content)) {
    failures.add(
      'MainActivity.kt package differs from '
      'ANDROID_NAMESPACE=${identity.androidNamespace}',
    );
  }
}

void _checkAndroidIdentityProperties(
  AppIdentity identity,
  List<String> failures,
) {
  final file = File(_androidIdentityPropertiesPath);

  if (!file.existsSync()) {
    failures.add('Missing $_androidIdentityPropertiesPath');
    return;
  }

  final actual = _normalizeLineEndings(file.readAsStringSync());

  final expected = _normalizeLineEndings(
    _androidIdentityPropertiesContent(identity),
  );

  if (actual != expected) {
    failures.add(
      '$_androidIdentityPropertiesPath '
      'differs from ci/artifacts.env',
    );
  }
}

void _checkIosIdentityConfig(AppIdentity identity, List<String> failures) {
  final file = File(_iosIdentityConfigPath);

  if (!file.existsSync()) {
    failures.add('Missing $_iosIdentityConfigPath');
    return;
  }

  final actual = _normalizeLineEndings(file.readAsStringSync());

  final expected = _normalizeLineEndings(_iosIdentityConfigContent(identity));

  if (actual != expected) {
    failures.add(
      '$_iosIdentityConfigPath '
      'differs from ci/artifacts.env',
    );
  }
}

void _checkIosConfigIncludes(List<String> failures) {
  for (final path in [_iosDebugConfigPath, _iosReleaseConfigPath]) {
    final file = File(path);

    if (!file.existsSync()) {
      failures.add('Missing $path');
      continue;
    }

    if (!file.readAsLinesSync().contains('#include "AppIdentity.xcconfig"')) {
      failures.add(
        '$path does not include '
        'AppIdentity.xcconfig',
      );
    }
  }
}

void _checkIosInfoPlist(List<String> failures) {
  final file = File(_iosInfoPlistPath);

  if (!file.existsSync()) {
    failures.add('Missing $_iosInfoPlistPath');
    return;
  }

  final content = file.readAsStringSync();

  if (!content.contains(r'<string>$(APP_DISPLAY_NAME)</string>')) {
    failures.add(
      'iOS CFBundleDisplayName is not driven by '
      'APP_DISPLAY_NAME',
    );
  }

  if (!content.contains(r'<string>$(APP_BUNDLE_NAME)</string>')) {
    failures.add(
      'iOS CFBundleName is not driven by '
      'IOS_BUNDLE_NAME',
    );
  }
}

void _checkIosProjectBundleIdentifiers(List<String> failures) {
  final file = File(_iosProjectPath);

  if (!file.existsSync()) {
    failures.add('Missing $_iosProjectPath');
    return;
  }

  final content = file.readAsStringSync();

  final pattern = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);');

  final matches = pattern.allMatches(content).toList();

  if (matches.isEmpty) {
    failures.add('No PRODUCT_BUNDLE_IDENTIFIER entries found');
    return;
  }

  var hasApp = false;
  var hasTests = false;

  for (final match in matches) {
    final value = match.group(1)!.trim();

    if (value == r'"$(APP_BUNDLE_IDENTIFIER)"') {
      hasApp = true;
      continue;
    }

    if (value == r'"$(APP_BUNDLE_IDENTIFIER).RunnerTests"') {
      hasTests = true;
      continue;
    }

    failures.add(
      'Unexpected iOS bundle identifier '
      'setting: $value',
    );
  }

  if (!hasApp) {
    failures.add(
      'Runner does not use '
      'APP_BUNDLE_IDENTIFIER',
    );
  }

  if (!hasTests) {
    failures.add(
      'RunnerTests does not derive from '
      'APP_BUNDLE_IDENTIFIER',
    );
  }
}

String _normalizeLineEndings(String value) {
  return value.replaceAll('\r\n', '\n');
}

void _removeEmptyParents(Directory directory, Directory stopAt) {
  var current = directory;

  while (!_samePath(current.path, stopAt.path)) {
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

bool _samePath(String first, String second) {
  String normalize(String value) {
    var path = File(value).absolute.path.replaceAll('\\', '/');

    if (Platform.isWindows) {
      path = path.toLowerCase();
    }

    return path;
  }

  return normalize(first) == normalize(second);
}

final class AppIdentity {
  const AppIdentity({
    required this.displayName,
    required this.dartPackageName,
    required this.androidNamespace,
    required this.androidApplicationId,
    required this.appScheme,
    required this.iosBundleIdentifier,
    required this.iosBundleName,
    required this.stagingNameSuffix,
    required this.stagingIdSuffix,
    required this.stagingSchemeSuffix,
  });

  final String displayName;
  final String dartPackageName;
  final String androidNamespace;
  final String androidApplicationId;
  final String appScheme;
  final String iosBundleIdentifier;
  final String iosBundleName;
  final String stagingNameSuffix;
  final String stagingIdSuffix;
  final String stagingSchemeSuffix;

  String get stagingDisplayName => '$displayName$stagingNameSuffix';

  String get stagingApplicationId => '$androidApplicationId$stagingIdSuffix';

  String get stagingAppScheme => '$appScheme$stagingSchemeSuffix';
}
