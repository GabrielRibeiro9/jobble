import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Montagem do tema a partir dos tokens do Artemian.
///
/// Regras que atravessam todos os componentes:
/// - todo botão, badge e botão de ícone é **pill**; campos são retângulos de
///   10, cards de 18.
/// - a CTA principal é floresta (`inverse`); a de confirmação/destaque é lima
///   (`primary`). No escuro a CTA vira lima.
/// - bordas são sempre de 1px, em cinza claro. Foco é floresta.
/// - toque não espalha tinta: o feedback é um leve tingimento cinza nas
///   linhas e a escala nos botões.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColorsTheme.light, Brightness.light);
  static ThemeData get dark => _build(AppColorsTheme.dark, Brightness.dark);

  static ThemeData _build(AppColorsTheme colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme(colors);

    OutlineInputBorder fieldBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: AppRadius.fieldAll,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    // Tingimento de toque: o "hover" do sistema (#F6F6F6 sobre branco).
    final pressTint = colors.textPrimary.withValues(alpha: 0.04);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.family,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: pressTint,
      hoverColor: pressTint,
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: textTheme,

      // O `primary` do Material é a cor de tinta de acento dos componentes
      // nativos (seletor de data, indicador, cursor). Tem que ser legível
      // sobre a superfície, então é a CTA — floresta no claro, lima no escuro.
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.inverse,
        onPrimary: colors.onInverse,
        primaryContainer: colors.accentSoft,
        onPrimaryContainer: colors.textPrimary,
        secondary: colors.primary,
        onSecondary: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        surfaceContainerLowest: colors.surface,
        surfaceContainerLow: colors.surface,
        surfaceContainer: colors.surface,
        surfaceContainerHigh: colors.surface,
        surfaceContainerHighest: colors.surfaceLight,
        outline: colors.border,
        outlineVariant: colors.borderLight,
        error: colors.error,
        onError: const Color(0xFFFFFFFF),
        shadow: colors.shadow,
        scrim: colors.overlay,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.screenH,
        titleTextStyle: AppTypography.h3.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary, size: 20),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Campos: branco sobre a página cinza, contorno de 1px, raio 10. Foco
      // é a borda em floresta.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colors.surfaceLight
              : colors.surface,
        ),
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: fieldBorder(colors.border, AppSize.border),
        enabledBorder: fieldBorder(colors.border, AppSize.border),
        disabledBorder: fieldBorder(colors.borderLight, AppSize.border),
        focusedBorder: fieldBorder(colors.focus, AppSize.borderFocused),
        errorBorder: fieldBorder(colors.errorBorder, AppSize.border),
        focusedErrorBorder: fieldBorder(colors.error, AppSize.borderFocused),
        labelStyle: AppTypography.label.copyWith(color: colors.textSecondary),
        floatingLabelStyle: AppTypography.label.copyWith(
          color: colors.textSecondary,
        ),
        hintStyle: AppTypography.body.copyWith(color: colors.textHint),
        helperStyle: AppTypography.bodySmall.copyWith(
          color: colors.textSecondary,
          fontSize: 12,
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: colors.error,
          fontSize: 12,
        ),
        prefixIconColor: colors.textHint,
        suffixIconColor: colors.textHint,
      ),

      // CTA principal: pill floresta. Desabilitado é a mesma pill a 45%.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.inverse,
          foregroundColor: colors.onInverse,
          disabledBackgroundColor: colors.inverse.withValues(alpha: 0.45),
          disabledForegroundColor: colors.onInverse.withValues(alpha: 0.9),
          minimumSize: const Size(double.infinity, AppSize.button),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.button,
        ),
      ),

      // Ação de destaque: pill lima com tinta floresta.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.7),
          minimumSize: const Size(double.infinity, AppSize.button),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.button,
        ),
      ),

      // Ação secundária: pill branca com borda fina.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          backgroundColor: colors.surface,
          disabledForegroundColor: colors.textHint,
          minimumSize: const Size(double.infinity, AppSize.button),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          elevation: 0,
          side: BorderSide(color: colors.border, width: AppSize.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.button,
        ),
      ),

      // Links inline acompanham o corpo do texto, não competem com a CTA.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.link,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // O chip de ícone da casa: círculo branco com borda fina.
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          backgroundColor: colors.surface,
          minimumSize: const Size.square(AppSize.iconButton),
          side: BorderSide(color: colors.borderLight, width: AppSize.border),
          shape: const CircleBorder(),
        ),
      ),

      iconTheme: IconThemeData(color: colors.textPrimary, size: 20),

      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: colors.borderLight, width: AppSize.border),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.primary,
        disabledColor: colors.surfaceLight,
        side: BorderSide(color: colors.border, width: AppSize.border),
        labelStyle: AppTypography.label.copyWith(color: colors.textPrimary),
        secondaryLabelStyle: AppTypography.label.copyWith(
          color: colors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        showCheckmark: false,
      ),

      dividerTheme: DividerThemeData(
        color: colors.borderLight,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        titleTextStyle: AppTypography.title.copyWith(color: colors.textPrimary),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: colors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.textPrimary,
        unselectedItemColor: colors.textHint,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: colors.overlay,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: colors.borderStrong,
        dragHandleSize: const Size(36, 4),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: colors.overlay,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTypography.h3.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: colors.textBody),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: colors.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: colors.borderLight),
        ),
        textStyle: AppTypography.label.copyWith(color: colors.textBody),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverse,
        contentTextStyle: AppTypography.body.copyWith(color: colors.onInverse),
        actionTextColor: isDark ? colors.onInverse : colors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.inverse,
          borderRadius: AppRadius.xsAll,
        ),
        textStyle: AppTypography.caption.copyWith(color: colors.onInverse),
      ),

      // Abas sublinhadas: a única borda de 2px do sistema, em lima.
      tabBarTheme: TabBarThemeData(
        labelColor: colors.textPrimary,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: AppTypography.label.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.label.copyWith(fontSize: 14),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: colors.borderLight,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.inverse,
        linearTrackColor: colors.borderLight,
        circularTrackColor: Colors.transparent,
      ),

      // Switch: trilho lima quando ligado, cinza quando desligado; o polegar
      // é sempre branco.
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.borderStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),

      // Checkbox: caixa floresta com o check em lima.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.inverse
              : colors.surface,
        ),
        checkColor: WidgetStatePropertyAll(
          isDark ? colors.onInverse : colors.primary,
        ),
        side: BorderSide(color: colors.borderStrong, width: AppSize.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accentText
              : colors.borderStrong,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.borderLight,
        thumbColor: colors.inverse,
        overlayColor: colors.primary.withValues(alpha: 0.18),
        trackHeight: 4,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.focus,
        selectionColor: colors.primary.withValues(alpha: 0.45),
        selectionHandleColor: colors.focus,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
