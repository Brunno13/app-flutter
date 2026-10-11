import 'package:app_flutter/app/environment/app_environment.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection.config.dart';

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(
  GetIt container, {
  required AppEnvironment environment,
}) async {
  container.registerSingleton<AppEnvironment>(environment);

  container.init();
  await container.allReady();
}
