import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Montagem do tema a partir dos tokens.
///
/// Regras que atravessam todos os componentes:
/// - botões e chips são **pills**; campos e cards são **retângulos
///   arredondados** (`AppRadius.md`/`lg`). O contraste entre as duas formas é
///   a assinatura do sistema.
/// - controles de largura total têm 56 de altura.
/// - a CTA principal é de alto contraste (`inverse`), não do acento. O lima
///   fica reservado para foco, seleção e destaque.
/// - bordas são de 1px e discretas; no foco viram lima com 1.5px.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColorsTheme.light, Brightness.light);
  static ThemeData get dark => _build(AppColorsTheme.dark, Brightness.dark);

  static ThemeData _build(AppColorsTheme colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme(
      colors.textPrimary,
      colors.textSecondary,
    );

    OutlineInputBorder fieldBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.family,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: textTheme,

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.surfaceLight,
        onSecondary: colors.textPrimary,
        surface: colors.background,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceLight,
        outline: colors.border,
        outlineVariant: colors.borderLight,
        error: colors.error,
        onError: isDark ? colors.onPrimary : const Color(0xFFFFFFFF),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h3.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Campos: contorno discreto, sem preenchimento, rótulo flutuante
      // recortado na borda. Foco muda a cor da borda, não a espessura visual.
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md + 2,
        ),
        border: fieldBorder(colors.border, AppSize.border),
        enabledBorder: fieldBorder(colors.border, AppSize.border),
        disabledBorder: fieldBorder(colors.borderLight, AppSize.border),
        focusedBorder: fieldBorder(colors.primary, AppSize.borderFocused),
        errorBorder: fieldBorder(colors.error, AppSize.border),
        focusedErrorBorder: fieldBorder(colors.error, AppSize.borderFocused),
        labelStyle: AppTypography.label.copyWith(color: colors.textSecondary),
        floatingLabelStyle: AppTypography.label.copyWith(
          color: colors.textSecondary,
        ),
        hintStyle: AppTypography.body.copyWith(color: colors.textHint),
        helperStyle: AppTypography.caption.copyWith(color: colors.textHint),
        errorStyle: AppTypography.caption.copyWith(color: colors.error),
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
      ),

      // CTA principal: pill de alto contraste.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.inverse,
          foregroundColor: colors.onInverse,
          disabledBackgroundColor: colors.disabled,
          disabledForegroundColor: colors.onDisabled,
          minimumSize: const Size(double.infinity, AppSize.button),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.button,
        ),
      ),

      // Ação de acento: pill lima.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.disabled,
          disabledForegroundColor: colors.onDisabled,
          minimumSize: const Size(double.infinity, AppSize.button),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.button,
        ),
      ),

      // Ação secundária: pill contornado, fundo transparente.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: colors.textHint,
          minimumSize: const Size(double.infinity, AppSize.button),
          elevation: 0,
          side: BorderSide(color: colors.border, width: AppSize.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: AppTypography.button,
        ),
      ),

      // Links inline são menores que rótulos de botão: eles acompanham o
      // corpo do texto, não competem com a CTA.
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

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          backgroundColor: colors.surfaceLight,
          minimumSize: const Size.square(AppSize.iconButton),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        ),
      ),

      iconTheme: IconThemeData(color: colors.textPrimary, size: 22),

      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceLight,
        selectedColor: colors.primary,
        disabledColor: colors.surfaceLight,
        side: BorderSide.none,
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
        color: colors.border,
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
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: colors.borderStrong,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTypography.h3.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(
          color: colors.textSecondary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceStrong,
        contentTextStyle: AppTypography.body.copyWith(
          color: colors.textPrimary,
        ),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colors.textPrimary,
        unselectedLabelColor: colors.textHint,
        labelStyle: AppTypography.title,
        unselectedLabelStyle: AppTypography.title,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceLight,
        circularTrackColor: colors.surfaceLight,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.textHint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceStrong,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(colors.onPrimary),
        side: BorderSide(color: colors.borderStrong, width: AppSize.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.borderStrong,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.surfaceStrong,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.14),
        trackHeight: 3,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.28),
        selectionHandleColor: colors.primary,
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
