import 'package:flutter/material.dart';

/// Escala tipográfica.
///
/// Uma única família (Inter, empacotada em `assets/fonts`). O caráter vem do
/// contraste de peso e do tracking: títulos em peso alto com tracking
/// negativo, corpo em peso regular com tracking neutro. Quanto maior o texto,
/// mais negativo o tracking — é o que dá a densidade dos títulos.
abstract final class AppTypography {
  static const String family = 'Inter';

  /// Título de abertura de tela. Curto, no máximo três linhas.
  static const TextStyle display = TextStyle(
    fontFamily: family,
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.2,
    height: 1.08,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );

  /// Título de item de lista e rótulo de card.
  static const TextStyle title = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Rótulo de botão.
  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
  );

  /// Rótulo de campo e legenda.
  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  /// Etiqueta em caixa alta — datas, status curtos ("EM 5 DIAS").
  static const TextStyle overline = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.2,
  );

  /// Valores monetários e números em destaque.
  static const TextStyle numeric = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.15,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: display.copyWith(color: primary),
      displayMedium: h1.copyWith(color: primary),
      displaySmall: h2.copyWith(color: primary),
      headlineLarge: h1.copyWith(color: primary),
      headlineMedium: h2.copyWith(color: primary),
      headlineSmall: h3.copyWith(color: primary),
      titleLarge: h3.copyWith(color: primary),
      titleMedium: title.copyWith(color: primary),
      titleSmall: label.copyWith(color: primary),
      bodyLarge: body.copyWith(color: primary),
      bodyMedium: body.copyWith(color: secondary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: button.copyWith(color: primary),
      labelMedium: label.copyWith(color: secondary),
      labelSmall: caption.copyWith(color: secondary),
    );
  }
}
