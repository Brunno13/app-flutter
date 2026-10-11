import 'package:app_flutter/app/di/dependency_injection.dart';
import 'package:app_flutter/app/environment/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:app_flutter/app/theme/theme_view_model.dart';

void main() {
  for (final environment in AppEnvironment.values) {
    test(
      'registers $environment in an isolated dependency container',
      () async {
        final container = GetIt.asNewInstance();

        addTearDown(() => container.reset());

        expect(identical(container, GetIt.instance), isFalse);

        await configureDependencies(container, environment: environment);

        expect(container.isRegistered<ThemeViewModel>(), isTrue);

        final first = container<ThemeViewModel>();
        final second = container<ThemeViewModel>();

        expect(identical(first, second), isTrue);

        expect(container<AppEnvironment>(), environment);

        await container.allReady();
      },
    );
  }
}
