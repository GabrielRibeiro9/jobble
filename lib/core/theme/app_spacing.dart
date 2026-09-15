import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

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

  /// Margem horizontal padrão das telas (page-pad-mobile).
  static const double screenH = 16;

  /// Respiro vertical entre campos de formulário.
  static const double gap = 16;

  /// Respiro vertical entre seções.
  static const double section = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: screenH);

  /// Padding interno do card (gutter-card).
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets listRow = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}

/// Raios de canto.
///
/// Todo botão, badge, select, avatar e botão de ícone é **pill**. Campos e
/// itens de navegação ficam em 10, cards internos em 14, o card padrão em 18
/// e o card de destaque em 24.
abstract final class AppRadius {
  /// Chips e micro-tiles.
  static const double xs = 6;

  /// Campos de entrada.
  static const double sm = 10;

  /// Cards internos, menus, bolhas.
  static const double md = 14;

  /// O card padrão.
  static const double lg = 18;

  /// Card de destaque e folhas.
  static const double xl = 24;
  static const double xxl = 32;

  /// Pills: botões, chips e badges.
  static const double pill = 999;

  static const double field = sm;
  static const double card = lg;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fieldAll = smAll;
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Alturas fixas dos controles.
abstract final class AppSize {
  /// Altura das CTAs e dos botões de largura total.
  static const double button = 48;

  /// Altura dos campos de entrada.
  static const double field = 48;

  /// Botão de ícone circular (voltar, fechar, menu). O alvo de toque mínimo
  /// no mobile é 44.
  static const double iconButton = 44;

  /// Ícone de categoria dentro de listas — o chip de 34 do sistema.
  static const double categoryIcon = 34;

  /// Altura mínima da barra de abas inferior.
  static const double tabBar = 56;

  /// Espessura da borda padrão.
  static const double border = 1;

  /// Espessura da borda em foco.
  static const double borderFocused = 1.5;
}

/// Sombras, todas tingidas de floresta em vez de preto.
abstract final class AppShadow {
  /// Levantamento de 1px — chips de ícone, stat cards.
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0D0D2F28), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F0D2F28), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x0A0D2F28), offset: Offset(0, 1), blurRadius: 1),
  ];

  /// A sombra padrão de card.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D0D2F28), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x140D2F28), offset: Offset(0, 8), blurRadius: 24),
  ];

  /// Menus, folhas e diálogos.
  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x240D2F28), offset: Offset(0, 20), blurRadius: 48),
  ];
}

/// Durações de animação: 140 para toque e foco, 200 para cards, menus e abas,
/// 320 para preenchimento de gráfico e progresso.
abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
}

/// Uma curva só para quase tudo. Sem bounce, sem mola.
abstract final class AppCurve {
  static const Curve standard = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve out = Cubic(0.16, 1, 0.3, 1);
}

/// Escala do botão pressionado. A escala é o feedback — a cor não muda.
const double kAppPressScale = 0.97;
