import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/app/theme/theme_view_model.dart';
import 'package:app_flutter/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders the home feature', (tester) async {
    final themeViewModel = ThemeViewModel();

    await tester.pumpWidget(App(themeViewModel: themeViewModel));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('Theme switch updates MaterialApp reactively', (tester) async {
    final themeViewModel = ThemeViewModel();

    await tester.pumpWidget(App(themeViewModel: themeViewModel));

    expect(themeViewModel.themeMode, ThemeMode.light);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(themeViewModel.themeMode, ThemeMode.dark);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    expect(find.text('Dark mode enabled'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(themeViewModel.themeMode, ThemeMode.light);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    expect(find.text('Light mode enabled'), findsOneWidget);
  });
}
