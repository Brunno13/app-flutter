import 'package:app_flutter/app/environment/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment.fromFlavor', () {
    test('resolves production', () {
      expect(
        AppEnvironment.fromFlavor('production'),
        AppEnvironment.production,
      );
    });

    test('resolves staging', () {
      expect(AppEnvironment.fromFlavor('staging'), AppEnvironment.staging);
    });

    test('rejects missing flavor', () {
      expect(() => AppEnvironment.fromFlavor(null), throwsStateError);
    });

    test('rejects unsupported flavor', () {
      expect(() => AppEnvironment.fromFlavor('development'), throwsStateError);
    });
  });
}
