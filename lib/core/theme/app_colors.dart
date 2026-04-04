import 'package:flutter/material.dart';

class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  // Backgrounds
  final Color background;
  final Color surface;
  final Color surfaceLight;

  // Borders
  final Color border;
  final Color borderLight;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Accent
  final Color primary;
  final Color onPrimary;
  final Color link;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color ratingStar;
  final Color errorBackground;
  final Color errorBorder;
  final Color themePrimary;

  const AppColorsTheme({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.border,
    required this.borderLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primary,
    required this.onPrimary,
    required this.link,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.ratingStar,
    required this.errorBackground,
    required this.errorBorder,
    required this.themePrimary,
  });

  @override
  ThemeExtension<AppColorsTheme> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? border,
    Color? borderLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? primary,
    Color? onPrimary,
    Color? link,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? ratingStar,
    Color? errorBackground,
    Color? errorBorder,
    Color? themePrimary,
  }) {
    return AppColorsTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      link: link ?? this.link,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      ratingStar: ratingStar ?? this.ratingStar,
      errorBackground: errorBackground ?? this.errorBackground,
      errorBorder: errorBorder ?? this.errorBorder,
      themePrimary: themePrimary ?? this.themePrimary,
    );
  }

  @override
  ThemeExtension<AppColorsTheme> lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    if (other is! AppColorsTheme) {
      return this;
    }
    return AppColorsTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      link: Color.lerp(link, other.link, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      ratingStar: Color.lerp(ratingStar, other.ratingStar, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      themePrimary: Color.lerp(themePrimary, other.themePrimary, t)!,
    );
  }

  // Definição Dark
  static const dark = AppColorsTheme(
    background: Color(0xFF000000), // Uber Dark Background
    surface: Color(0xFF121212),
    surfaceLight: Color(0xFF262626), // Secondary surface
    border: Color(0xFF333333),
    borderLight: Color(0xFF4A4A4A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
    textHint: Color(0xFF757575),
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF000000),
    link: Color(0xFF276EF1), // Uber Blue
    error: Color(0xFFE11900), // Uber Red
    success: Color(0xFF05A357), // Uber Green
    warning: Color(0xFFFFC043), // Uber Yellow
    info: Color(0xFF276EF1),
    ratingStar: Color(0xFFFFC043),
    errorBackground: Color(0xFF2D0E0E),
    errorBorder: Color(0xFF5C1111),
    themePrimary: Color(0xFF276EF1),
  );

  // Definição Light
  static const light = AppColorsTheme(
    background: Color(0xFFFFFFFF), // Uber Light Background
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFF3F3F3), // Uber Secondary Background
    border: Color(0xFFCBCBCB),
    borderLight: Color(0xFFE2E2E2),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF545454),
    textHint: Color(0xFF9CA3AF),
    primary: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    link: Color(0xFF276EF1),
    error: Color(0xFFE11900),
    success: Color(0xFF05A357),
    warning: Color(0xFFFFC043),
    info: Color(0xFF276EF1),
    ratingStar: Color(0xFFFFC043),
    errorBackground: Color(0xFFFEF2F2),
    errorBorder: Color(0xFFFCA5A5),
    themePrimary: Color(0xFF276EF1),
  );
}

// Extensão útil para acessar as cores diretamente via context
extension AppColorsExt on BuildContext {
  AppColorsTheme get colors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.light;
}
