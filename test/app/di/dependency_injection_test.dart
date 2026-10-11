import 'package:app_flutter/app/di/dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test('initializes an isolated dependency container', () async {
    final container = GetIt.asNewInstance();

    addTearDown(() => container.reset());

    expect(identical(container, GetIt.instance), isFalse);

    await configureDependencies(container);
    await container.allReady();
  });
}
