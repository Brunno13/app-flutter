import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';

part 'theme_view_model.g.dart';

@lazySingleton
class ThemeViewModel = ThemeViewModelBase with _$ThemeViewModel;

abstract class ThemeViewModelBase with Store {
  @observable
  ThemeMode themeMode = ThemeMode.light;

  @action
  void setDarkMode(bool enabled) {
    themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
