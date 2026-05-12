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
    final base = ThemeData(brightness: Brightness.dark).textTheme;
    return MaterialApp(
      title: 'SilverLink Gemini Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0E1117),
        textTheme: base.copyWith(
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: SilverLinkTokens.replyFontDefault,
            height: 1.45,
            color: Colors.white,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: SilverLinkTokens.statusFontSize,
            color: Colors.white70,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontSize: SilverLinkTokens.disclaimerFontSize,
            color: Colors.white54,
          ),
        ),
      ),
      home: const LiveScreen(),
    );
  }
}
