import 'package:app_flutter/app/theme/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('switches between light and dark theme', () {
    final viewModel = ThemeViewModel();

    expect(viewModel.themeMode, ThemeMode.light);

    viewModel.setDarkMode(true);
    expect(viewModel.themeMode, ThemeMode.dark);

    viewModel.setDarkMode(false);
    expect(viewModel.themeMode, ThemeMode.light);
  });
}
