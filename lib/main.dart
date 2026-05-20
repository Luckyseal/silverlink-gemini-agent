import 'package:flutter/material.dart';

import 'core/layout/silverlink_tokens.dart';
import 'features/live/live_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SilverLinkApp());
}

class SilverLinkApp extends StatelessWidget {
  const SilverLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A73E8),
      brightness: Brightness.dark,
    );
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      useMaterial3: true,
    ).textTheme;
    return MaterialApp(
      title: 'SilverLink Gemini Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surfaceContainerHigh,
          surfaceTintColor: colorScheme.surfaceTint,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SilverLinkTokens.cardRadius),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SilverLinkTokens.cardRadius),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: colorScheme.surfaceContainerHigh,
          surfaceTintColor: colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SilverLinkTokens.cardRadius),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: colorScheme.surfaceContainerHigh,
          surfaceTintColor: colorScheme.surfaceTint,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.inverseSurface,
          contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        ),
        textTheme: base.copyWith(
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: SilverLinkTokens.replyFontDefault,
            height: 1.45,
            color: colorScheme.onSurface,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: SilverLinkTokens.statusFontSize,
            color: colorScheme.onSurfaceVariant,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontSize: SilverLinkTokens.disclaimerFontSize,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      home: const LiveScreen(),
    );
  }
}
