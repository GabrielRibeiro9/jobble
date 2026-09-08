import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  /// O design system é dark-first: o escuro é o modo de referência.
  ThemeCubit() : super(ThemeMode.dark);

  void toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
  }
}
