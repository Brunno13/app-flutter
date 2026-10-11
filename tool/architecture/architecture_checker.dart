import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

class ArchitectureViolation {
  const ArchitectureViolation({
    required this.code,
    required this.path,
    required this.line,
    required this.message,
  });

  final String code;
  final String path;
  final int line;
  final String message;

  @override
  String toString() => '$code: $path:$line — $message';
}

/// Checks project-local import/export boundaries under lib/.
/// No files are modified.
class ArchitectureChecker {
  ArchitectureChecker({
    required Directory projectRoot,
    required this.packageName,
  }) : _libUri = projectRoot.absolute.uri.resolve('lib/');

  final String packageName;
  final Uri _libUri;

  List<ArchitectureViolation> check() {
    final lib = Directory.fromUri(_libUri);
    if (!lib.existsSync()) {
      throw StateError('Missing lib/ directory: ${lib.path}');
    }

    final files =
        lib
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .where((file) => !_isGenerated(file.path))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final violations = <ArchitectureViolation>[];
    for (final file in files) {
      final pathInLib = _pathInLib(file.absolute.uri);
      if (pathInLib == null) continue;

      final scope = pathInLib.split('/').first;
      if (scope != 'features' && scope != 'shared') continue;

      final displayPath = 'lib/$pathInLib';
      final result = parseString(
        content: file.readAsStringSync(),
        path: file.path,
        throwIfDiagnostics: false,
      );

      // Fail closed if an invalid Dart source might hide directives.
      for (final error in result.errors) {
        violations.add(
          ArchitectureViolation(
            code: 'ARCH000',
            path: displayPath,
            line: result.lineInfo.getLocation(error.offset).lineNumber,
            message: 'Invalid Dart syntax: ${error.message}',
          ),
        );
      }

      void inspectUri(String? rawUri, int offset) {
        if (rawUri == null) return;
        final uri = Uri.tryParse(rawUri);
        if (uri == null) return;

        final line = result.lineInfo.getLocation(offset).lineNumber;

        void report(String code, String message) {
          violations.add(
            ArchitectureViolation(
              code: code,
              path: displayPath,
              line: line,
              message: message,
            ),
          );
        }

        if (uri.scheme == 'package' &&
            uri.pathSegments.isNotEmpty &&
            uri.pathSegments.first == 'get_it') {
          report('ARCH003', 'features/shared cannot import or export get_it');
          return;
        }

        Uri? target;
        final isRelative = !uri.hasScheme && !uri.hasAuthority;

        if (uri.scheme == 'package' &&
            uri.pathSegments.isNotEmpty &&
            uri.pathSegments.first == packageName) {
          final suffix = uri.pathSegments.skip(1).join('/');
          target = _libUri.resolve(suffix);
        } else if (isRelative) {
          target = file.absolute.uri.resolveUri(uri);
        } else {
          return; // dart:, third-party packages, etc.
        }

        final targetInLib = _pathInLib(target);
        if (targetInLib == null) {
          if (isRelative) {
            report('ARCH004', 'Relative import/export escapes lib/: $rawUri');
          }
          return;
        }

        final targetScope = targetInLib.split('/').first;
        if (scope == 'features' && targetScope == 'app') {
          report('ARCH001', 'features cannot depend on app/: $rawUri');
        }
        if (scope == 'shared' &&
            (targetScope == 'app' || targetScope == 'features')) {
          report('ARCH002', 'shared cannot depend on $targetScope/: $rawUri');
        }
      }

      for (final directive in result.unit.directives) {
        if (directive is ImportDirective) {
          inspectUri(directive.uri.stringValue, directive.uri.offset);
          for (final conditional in directive.configurations) {
            inspectUri(conditional.uri.stringValue, conditional.uri.offset);
          }
        } else if (directive is ExportDirective) {
          inspectUri(directive.uri.stringValue, directive.uri.offset);
          for (final conditional in directive.configurations) {
            inspectUri(conditional.uri.stringValue, conditional.uri.offset);
          }
        }
      }
    }

    violations.sort((a, b) {
      final byPath = a.path.compareTo(b.path);
      if (byPath != 0) return byPath;
      final byLine = a.line.compareTo(b.line);
      if (byLine != 0) return byLine;
      return a.code.compareTo(b.code);
    });
    return violations;
  }

  String? _pathInLib(Uri uri) {
    if (uri.scheme != _libUri.scheme ||
        uri.authority != _libUri.authority ||
        !uri.path.startsWith(_libUri.path)) {
      return null;
    }
    return uri.path.substring(_libUri.path.length);
  }

  bool _isGenerated(String path) =>
      path.endsWith('.g.dart') ||
      path.endsWith('.config.dart') ||
      path.endsWith('.freezed.dart');
}
