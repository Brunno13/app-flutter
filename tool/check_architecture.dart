import 'dart:io';

import 'architecture/architecture_checker.dart';

void main() {
  stdout.writeln('Checking architecture boundaries...');

  try {
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      throw StateError('Run this command from the project root.');
    }

    final match = RegExp(
      r'^name:\s*([A-Za-z_][A-Za-z0-9_]*)\s*$',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());
    if (match == null) {
      throw StateError('Missing package name in pubspec.yaml');
    }

    final violations = ArchitectureChecker(
      projectRoot: Directory.current,
      packageName: match.group(1)!,
    ).check();

    if (violations.isNotEmpty) {
      for (final violation in violations) {
        stderr.writeln(violation);
      }
      stderr.writeln('\nARCHITECTURE_CHECK=FAIL');
      exitCode = 1;
      return;
    }

    stdout.writeln('ARCHITECTURE_CHECK=PASS');
  } on Exception catch (error) {
    stderr.writeln('ARCHITECTURE_CHECK=FAIL: $error');
    exitCode = 1;
  }
}
