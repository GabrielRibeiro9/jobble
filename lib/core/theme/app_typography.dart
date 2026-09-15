import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Escala tipográfica do Artemian: três famílias, cada uma com um trabalho.
///
/// - **Space Grotesk** — títulos e todo número. Peso médio no máximo: o
///   sistema nunca põe um título em negrito; ênfase dentro de um título é um
///   degrau de 300 para 500.
/// - **Urbanist** — corpo de texto e parágrafos.
/// - **Plus Jakarta Sans** — cromo de interface: botões, rótulos, navegação,
///   etiquetas em caixa alta.
///
/// As três vêm empacotadas em `assets/fonts`.
abstract final class AppTypography {
  static const String displayFamily = 'SpaceGrotesk';
  static const String bodyFamily = 'Urbanist';
  static const String uiFamily = 'PlusJakartaSans';

  /// Família padrão do `ThemeData` — o que não tiver estilo explícito é corpo.
  static const String family = bodyFamily;

  /// Título de abertura de tela. Curto, no máximo três linhas.
  static const TextStyle display = TextStyle(
    fontFamily: displayFamily,
    fontSize: 34,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.68,
    height: 1.08,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.26,
    height: 1.15,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    height: 1.25,
  );

  /// Título de card e de AppBar.
  static const TextStyle h3 = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.17,
    height: 1.25,
  );

  /// Título de item de lista e rótulo de card.
  static const TextStyle title = TextStyle(
    fontFamily: uiFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.45,
  );

  /// Descritor de tela: a linha em itálico sob o título. É uma assinatura do
  /// sistema — toda tela de topo tem uma.
  static const TextStyle descriptor = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.4,
  );

  /// Rótulo de botão.
  static const TextStyle button = TextStyle(
    fontFamily: uiFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
    height: 1.2,
  );

  /// Rótulo de campo e legenda.
  static const TextStyle label = TextStyle(
    fontFamily: uiFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: uiFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
  );

  /// Micro-rótulo em caixa alta com tracking aberto ("MENU PRINCIPAL", datas,
  /// cabeçalhos de grupo). O chamador faz o `toUpperCase`.
  static const TextStyle overline = TextStyle(
    fontFamily: uiFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.88,
    height: 1.2,
  );

  /// Valores monetários e números em destaque.
  static const TextStyle numeric = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.48,
    height: 1.15,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(AppColorsTheme colors) {
    final strong = colors.textPrimary;
    return TextTheme(
      displayLarge: display.copyWith(color: strong),
      displayMedium: h1.copyWith(color: strong),
      displaySmall: h2.copyWith(color: strong),
      headlineLarge: h1.copyWith(color: strong),
      headlineMedium: h2.copyWith(color: strong),
      headlineSmall: h3.copyWith(color: strong),
      titleLarge: h3.copyWith(color: strong),
      titleMedium: title.copyWith(color: strong),
      titleSmall: label.copyWith(color: strong),
      bodyLarge: body.copyWith(color: strong),
      bodyMedium: body.copyWith(color: colors.textBody),
      bodySmall: bodySmall.copyWith(color: colors.textSecondary),
      labelLarge: button.copyWith(color: strong),
      labelMedium: label.copyWith(color: colors.textSecondary),
      labelSmall: caption.copyWith(color: colors.textSecondary),
    );
  }
}
