import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/architecture/architecture_checker.dart';

void main() {
  late Directory project;

  setUp(() {
    project = Directory.systemTemp.createTempSync('app_arch_test_');
  });

  tearDown(() {
    project.deleteSync(recursive: true);
  });

  void write(String path, String source) {
    final file = File.fromUri(project.uri.resolve(path));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
  }

  List<ArchitectureViolation> check() => ArchitectureChecker(
    projectRoot: project,
    packageName: 'app_flutter',
  ).check();

  test('accepts allowed boundaries and ignores comments/generated files', () {
    write('lib/shared/value.dart', 'class Value {}');
    write('lib/features/home/home.dart', '''
// import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/shared/value.dart';
export 'presentation/home_view.dart';
''');
    write('lib/features/home/presentation/home_view.dart', 'class HomeView {}');
    write(
      'lib/features/home/ignored.g.dart',
      "import 'package:app_flutter/app/app.dart';",
    );

    expect(check(), isEmpty);
  });

  test('ARCH001 catches package imports and exports', () {
    write('lib/features/home/home.dart', '''
import 'package:app_flutter/app/app.dart';
export 'package:app_flutter/app/theme/app_theme.dart';
''');

    expect(check().map((v) => v.code), ['ARCH001', 'ARCH001']);
  });

  test('ARCH001 also catches relative imports across the boundary', () {
    write(
      'lib/features/home/presentation/home_view.dart',
      "import '../../../app/app.dart';",
    );

    expect(check().single.code, 'ARCH001');
  });

  test('ARCH002 catches shared depending on app or features', () {
    write('lib/shared/example.dart', '''
import 'package:app_flutter/app/app.dart';
export 'package:app_flutter/features/home/home.dart';
''');

    expect(check().map((v) => v.code), ['ARCH002', 'ARCH002']);
  });

  test('ARCH003 catches direct GetIt dependency', () {
    write(
      'lib/features/home/home.dart',
      "import 'package:get_it/get_it.dart';",
    );

    expect(check().single.code, 'ARCH003');
  });

  test('ARCH004 catches a relative path leaving lib/', () {
    write('lib/features/home/home.dart', "import '../../../outside.dart';");

    expect(check().single.code, 'ARCH004');
  });

  test('checks conditional imports even when the condition is inactive', () {
    write('lib/features/home/home.dart', '''
import 'package:app_flutter/shared/value.dart'
    if (dart.library.io) 'package:app_flutter/app/app.dart';
''');

    expect(check().single.code, 'ARCH001');
  });
}
