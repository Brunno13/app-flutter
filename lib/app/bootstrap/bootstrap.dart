import 'package:app_flutter/app/di/dependency_injection.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies(GetIt.instance);

  runApp(const App());
}
