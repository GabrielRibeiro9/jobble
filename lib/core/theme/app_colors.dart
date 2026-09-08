import 'package:flutter/material.dart';

/// Paleta do design system.
///
/// O sistema é dark-first: o tema escuro é a referência e o claro é a
/// contraparte com os mesmos papéis. O acento é um lima de alta saturação,
/// usado com moderação — estado ativo, foco, seleção e destaques pontuais.
/// A CTA principal não usa o acento: ela é um pill de alto contraste
/// (`inverse`/`onInverse`), branco no escuro e preto no claro.
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  // Backgrounds
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color surfaceStrong;

  // Borders
  final Color border;
  final Color borderLight;
  final Color borderStrong;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Acento
  final Color primary;
  final Color onPrimary;

  // CTA de alto contraste
  final Color inverse;
  final Color onInverse;

  // Estados
  final Color disabled;
  final Color onDisabled;
  final Color overlay;

  // Semânticas
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
    required this.surfaceStrong,
    required this.border,
    required this.borderLight,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primary,
    required this.onPrimary,
    required this.inverse,
    required this.onInverse,
    required this.disabled,
    required this.onDisabled,
    required this.overlay,
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

  /// Cores categóricas para gráficos e ícones de categoria.
  /// Não mudam entre os temas: são pensadas para ler sobre superfície escura
  /// e mantêm contraste suficiente sobre a clara.
  static const List<Color> categorical = <Color>[
    Color(0xFFE8434F), // vermelho
    Color(0xFFC63BD9), // magenta
    Color(0xFFF0803C), // laranja
    Color(0xFFA78BFA), // violeta
    Color(0xFFC7F53F), // lima
    Color(0xFF4FC3F7), // azul
  ];

  @override
  ThemeExtension<AppColorsTheme> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? surfaceStrong,
    Color? border,
    Color? borderLight,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? primary,
    Color? onPrimary,
    Color? inverse,
    Color? onInverse,
    Color? disabled,
    Color? onDisabled,
    Color? overlay,
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
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      inverse: inverse ?? this.inverse,
      onInverse: onInverse ?? this.onInverse,
      disabled: disabled ?? this.disabled,
      onDisabled: onDisabled ?? this.onDisabled,
      overlay: overlay ?? this.overlay,
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
    if (other is! AppColorsTheme) return this;
    return AppColorsTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      inverse: Color.lerp(inverse, other.inverse, t)!,
      onInverse: Color.lerp(onInverse, other.onInverse, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      onDisabled: Color.lerp(onDisabled, other.onDisabled, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
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

  static const dark = AppColorsTheme(
    background: Color(0xFF0A0A0B),
    surface: Color(0xFF121214),
    surfaceLight: Color(0xFF1C1C1F),
    surfaceStrong: Color(0xFF26262A),
    border: Color(0xFF2A2A2E),
    borderLight: Color(0xFF212125),
    borderStrong: Color(0xFF3A3A40),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFF9B9BA3),
    textHint: Color(0xFF6B6B73),
    primary: Color(0xFFC7F53F),
    onPrimary: Color(0xFF0A0A0B),
    inverse: Color(0xFFFAFAFA),
    onInverse: Color(0xFF0A0A0B),
    disabled: Color(0xFFA8A8AD),
    onDisabled: Color(0xFF3A3A40),
    overlay: Color(0xB30A0A0B),
    link: Color(0xFFC7F53F),
    error: Color(0xFFFF453A),
    success: Color(0xFF32D74B),
    warning: Color(0xFFFF9F0A),
    info: Color(0xFF64D2FF),
    ratingStar: Color(0xFFC7F53F),
    errorBackground: Color(0xFF2A1211),
    errorBorder: Color(0xFF5C1F1B),
    themePrimary: Color(0xFFC7F53F),
  );

  static const light = AppColorsTheme(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F7F8),
    surfaceLight: Color(0xFFEFEFF1),
    surfaceStrong: Color(0xFFE4E4E8),
    border: Color(0xFFE2E2E6),
    borderLight: Color(0xFFEDEDF0),
    borderStrong: Color(0xFFC9C9D0),
    textPrimary: Color(0xFF0A0A0B),
    textSecondary: Color(0xFF6B6B73),
    textHint: Color(0xFF9B9BA3),
    primary: Color(0xFFC7F53F),
    onPrimary: Color(0xFF0A0A0B),
    inverse: Color(0xFF0A0A0B),
    onInverse: Color(0xFFFAFAFA),
    disabled: Color(0xFFC9C9D0),
    onDisabled: Color(0xFF8E8E96),
    overlay: Color(0x800A0A0B),
    link: Color(0xFF0A0A0B),
    error: Color(0xFFD70015),
    success: Color(0xFF1E9E3A),
    warning: Color(0xFFB56A00),
    info: Color(0xFF0071A4),
    ratingStar: Color(0xFF7BA800),
    errorBackground: Color(0xFFFDF0EF),
    errorBorder: Color(0xFFF3B9B4),
    themePrimary: Color(0xFFC7F53F),
  );
}

/// Acesso às cores do tema via `context.colors`.
extension AppColorsExt on BuildContext {
  AppColorsTheme get colors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.dark;
}
