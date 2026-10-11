import 'package:app_flutter/app/theme/app_theme.dart';
import 'package:app_flutter/app/theme/theme_view_model.dart';
import 'package:app_flutter/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class App extends StatelessWidget {
  const App({required this.themeViewModel, super.key});

  final ThemeViewModel themeViewModel;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeViewModel.themeMode,
        home: HomeView(
          isDarkMode: themeViewModel.themeMode == ThemeMode.dark,
          onDarkModeChanged: themeViewModel.setDarkMode,
        ),
      ),
    );
  }
}
