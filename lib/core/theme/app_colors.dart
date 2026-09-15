import 'package:flutter/material.dart';

/// Paleta do design system Artemian.
///
/// O mundo visual é quieto e estrutural: página cinza chapada, cards brancos
/// com borda fina, e duas cores fazendo todo o trabalho — o lima (`primary`)
/// para estado ativo, confirmação e o card de destaque, e o verde-floresta
/// (`inverse`/`textPrimary`) para tinta, ação principal e a metade pesada de
/// qualquer gráfico. Vermelho e âmbar existem só como status.
///
/// O claro é a referência. O escuro é derivado da escala floresta: fundo
/// verde-escuro, e a CTA vira lima (floresta sobre floresta não teria
/// contraste).
///
/// Regra de uso do lima: ele é **preenchimento**, nunca tinta sobre branco.
/// Texto, ícone ou marcador que precise do tom de acento sobre uma superfície
/// clara usa `accentText`.
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  // Fundos
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color surfaceStrong;

  // Bordas
  final Color border;
  final Color borderLight;
  final Color borderStrong;

  // Texto
  final Color textPrimary;
  final Color textBody;
  final Color textSecondary;
  final Color textHint;

  // Acento (lima)
  final Color primary;
  final Color onPrimary;

  /// Lima pálido: fundo de ícone de categoria, linha selecionada, avatar.
  final Color accentSoft;

  /// Tom de acento legível sobre superfície — o lima vira verde escuro no
  /// claro. Para ícones, marcadores e números positivos.
  final Color accentText;

  // CTA principal
  final Color inverse;
  final Color onInverse;

  // Estados
  final Color disabled;
  final Color onDisabled;
  final Color overlay;
  final Color focus;

  /// Base das sombras. No claro é o floresta, não o preto: é o que deixa as
  /// elevações levemente esverdeadas.
  final Color shadow;

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
    required this.textBody,
    required this.textSecondary,
    required this.textHint,
    required this.primary,
    required this.onPrimary,
    required this.accentSoft,
    required this.accentText,
    required this.inverse,
    required this.onInverse,
    required this.disabled,
    required this.onDisabled,
    required this.overlay,
    required this.focus,
    required this.shadow,
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

  /// Preenchimentos de ícone de categoria. O sistema não tem paleta
  /// categórica colorida — gráficos e categorias usam só a família lima e o
  /// neutro, sempre com o ícone em floresta por cima.
  static const List<Color> categorical = <Color>[
    Color(0xFF9FE870), // green-400
    Color(0xFFCFF2B2), // green-200
    Color(0xFFE4F8D4), // green-100
    Color(0xFFB7EC90), // green-300
    Color(0xFFF0F0F0), // neutral-100
    Color(0xFFFDF1DC), // amber-100
  ];

  /// Degradê do card de destaque (saldo, ganhos). Um por tela, no máximo.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.45, 1],
    colors: [Color(0xFFB7EC90), Color(0xFF9FE870), Color(0xFF7FD44E)],
  );

  /// Lavagem suave de lima para cinza — card de destaque secundário.
  static const LinearGradient brandMistGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4FCEC), Color(0xFFE9E9E9)],
  );

  /// Véu escuro sobre fotos. Não muda com o tema: o texto sobre a foto é
  /// sempre branco, então o véu precisa ser sempre escuro.
  static const Color photoScrim = Color(0xFF071A16);

  @override
  AppColorsTheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? surfaceStrong,
    Color? border,
    Color? borderLight,
    Color? borderStrong,
    Color? textPrimary,
    Color? textBody,
    Color? textSecondary,
    Color? textHint,
    Color? primary,
    Color? onPrimary,
    Color? accentSoft,
    Color? accentText,
    Color? inverse,
    Color? onInverse,
    Color? disabled,
    Color? onDisabled,
    Color? overlay,
    Color? focus,
    Color? shadow,
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
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accentSoft: accentSoft ?? this.accentSoft,
      accentText: accentText ?? this.accentText,
      inverse: inverse ?? this.inverse,
      onInverse: onInverse ?? this.onInverse,
      disabled: disabled ?? this.disabled,
      onDisabled: onDisabled ?? this.onDisabled,
      overlay: overlay ?? this.overlay,
      focus: focus ?? this.focus,
      shadow: shadow ?? this.shadow,
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
  AppColorsTheme lerp(covariant ThemeExtension<AppColorsTheme>? other, double t) {
    if (other is! AppColorsTheme) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorsTheme(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceLight: l(surfaceLight, other.surfaceLight),
      surfaceStrong: l(surfaceStrong, other.surfaceStrong),
      border: l(border, other.border),
      borderLight: l(borderLight, other.borderLight),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textBody: l(textBody, other.textBody),
      textSecondary: l(textSecondary, other.textSecondary),
      textHint: l(textHint, other.textHint),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      accentSoft: l(accentSoft, other.accentSoft),
      accentText: l(accentText, other.accentText),
      inverse: l(inverse, other.inverse),
      onInverse: l(onInverse, other.onInverse),
      disabled: l(disabled, other.disabled),
      onDisabled: l(onDisabled, other.onDisabled),
      overlay: l(overlay, other.overlay),
      focus: l(focus, other.focus),
      shadow: l(shadow, other.shadow),
      link: l(link, other.link),
      error: l(error, other.error),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      info: l(info, other.info),
      ratingStar: l(ratingStar, other.ratingStar),
      errorBackground: l(errorBackground, other.errorBackground),
      errorBorder: l(errorBorder, other.errorBorder),
      themePrimary: l(themePrimary, other.themePrimary),
    );
  }

  /// Referência: os tokens de `tokens/colors.css` do Artemian.
  static const light = AppColorsTheme(
    background: Color(0xFFE8E8E8), // neutral-150 — surface-page
    surface: Color(0xFFFFFFFF), // neutral-0 — surface-card
    surfaceLight: Color(0xFFF0F0F0), // neutral-100 — surface-subtle
    surfaceStrong: Color(0xFFE1E1E1), // neutral-200
    border: Color(0xFFE1E1E1), // neutral-200 — border-default
    borderLight: Color(0xFFE8E8E8), // neutral-150 — border-subtle
    borderStrong: Color(0xFFCFCFCF), // neutral-300 — border-strong
    textPrimary: Color(0xFF0D2F28), // forest-800 — text-strong
    textBody: Color(0xFF404040), // neutral-700 — text-body
    textSecondary: Color(0xFF787878), // neutral-500 — text-muted
    textHint: Color(0xFFA8A8A8), // neutral-400 — text-faint
    primary: Color(0xFF9FE870), // green-400 — brand-primary
    onPrimary: Color(0xFF0D2F28), // forest-800 — text-on-brand
    accentSoft: Color(0xFFE4F8D4), // green-100 — surface-brand-soft
    accentText: Color(0xFF54962C), // green-700 — text-positive
    inverse: Color(0xFF0D2F28), // forest-800 — CTA
    onInverse: Color(0xFFFFFFFF),
    disabled: Color(0xFFE1E1E1),
    onDisabled: Color(0xFFA8A8A8),
    overlay: Color(0x80071A16), // forest-900 a 50%
    focus: Color(0xFF1C574A), // forest-600 — focus-ring
    shadow: Color(0xFF0D2F28),
    link: Color(0xFF1C574A), // forest-600
    error: Color(0xFFD93B36), // red-600
    success: Color(0xFF54962C), // green-700
    warning: Color(0xFFB8862A), // amber-600
    info: Color(0xFF3B7CD9), // blue-500
    ratingStar: Color(0xFF1C574A),
    errorBackground: Color(0xFFFDE7E7), // red-100
    errorBorder: Color(0xFFF0736F), // red-400
    themePrimary: Color(0xFF9FE870),
  );

  /// Derivado da escala floresta — o Artemian não define modo escuro.
  static const dark = AppColorsTheme(
    background: Color(0xFF071A16), // forest-900
    surface: Color(0xFF0D2F28), // forest-800
    surfaceLight: Color(0xFF144238), // forest-700
    surfaceStrong: Color(0xFF1C574A), // forest-600
    border: Color(0xFF1F4D42),
    borderLight: Color(0xFF173F35),
    borderStrong: Color(0xFF2C7364), // forest-500
    textPrimary: Color(0xFFF6F6F6),
    textBody: Color(0xFFD5DEDB),
    textSecondary: Color(0xFFA0B4AE),
    textHint: Color(0xFF6E8A83),
    primary: Color(0xFF9FE870),
    onPrimary: Color(0xFF0D2F28),
    accentSoft: Color(0xFF21492F),
    accentText: Color(0xFF9FE870),
    inverse: Color(0xFF9FE870),
    onInverse: Color(0xFF0D2F28),
    disabled: Color(0xFF144238),
    onDisabled: Color(0xFF4E9384),
    overlay: Color(0xB3030C0A),
    focus: Color(0xFF9FE870),
    shadow: Color(0xFF000000),
    link: Color(0xFFB7EC90), // green-300
    error: Color(0xFFF0736F), // red-400
    success: Color(0xFF8BDC58), // green-500
    warning: Color(0xFFE8B457), // amber-400
    info: Color(0xFF7FA9E8),
    ratingStar: Color(0xFF9FE870),
    errorBackground: Color(0xFF3A1B1A),
    errorBorder: Color(0xFF6B2B28),
    themePrimary: Color(0xFF9FE870),
  );
}

/// Acesso às cores do tema via `context.colors`.
extension AppColorsExt on BuildContext {
  AppColorsTheme get colors =>
      Theme.of(this).extension<AppColorsTheme>() ?? AppColorsTheme.light;
}
