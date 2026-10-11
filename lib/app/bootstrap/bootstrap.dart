import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/app/di/dependency_injection.dart';
import 'package:app_flutter/app/environment/app_environment.dart';
import 'package:app_flutter/app/theme/theme_view_model.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromFlavor(appFlavor);

  await configureDependencies(GetIt.instance, environment: environment);

  final themeViewModel = GetIt.instance<ThemeViewModel>();

  runApp(App(themeViewModel: themeViewModel));
}
