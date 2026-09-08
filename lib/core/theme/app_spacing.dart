import 'package:flutter/widgets.dart';

/// Escala de espaçamento, base 4.
///
/// `screenH` é a margem lateral de todas as telas; `gap` é o respiro entre
/// campos de um mesmo formulário; `section` separa blocos de conteúdo.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Margem horizontal padrão das telas.
  static const double screenH = 24;

  /// Respiro vertical entre campos de formulário.
  static const double gap = 16;

  /// Respiro vertical entre seções.
  static const double section = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: screenH);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets listRow = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}

/// Raios de canto.
///
/// A regra que define a linguagem visual: **botões e chips são pills**
/// (totalmente arredondados), **campos e cards são retângulos arredondados**.
/// Não misture — é o contraste entre as duas formas que dá a identidade.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;

  /// Campos de entrada e cards menores.
  static const double md = 16;

  /// Cards e superfícies maiores.
  static const double lg = 20;
  static const double xl = 28;

  /// Pills: botões, chips e badges.
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Alturas fixas dos controles.
abstract final class AppSize {
  /// Altura das CTAs e dos botões de largura total.
  static const double button = 56;

  /// Altura dos campos de entrada.
  static const double field = 56;

  /// Botão de ícone circular (voltar, fechar, menu).
  static const double iconButton = 44;

  /// Ícone de categoria dentro de listas.
  static const double categoryIcon = 40;

  /// Espessura da borda padrão.
  static const double border = 1;

  /// Espessura da borda em foco.
  static const double borderFocused = 1.5;
}

/// Durações de animação.
abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
}
