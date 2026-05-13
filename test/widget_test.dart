import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silverlink_gemini_agent/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SilverLink shell renders settings entrypoint', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byTooltip('設定'), findsOneWidget);
  });

  testWidgets('settings expose Google Chirp 3 HD voice controls', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'gemini_api_key': 'fake-key',
      'gemini_model': 'gemini-2.0-flash',
    });
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.byTooltip('設定'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Google Chirp 3 HD 音声'), findsOneWidget);
    expect(find.text('GOOGLE_TTS_API_KEY / OAuth token'), findsOneWidget);
    expect(find.text('TTS voice（例: ja-JP-Chirp3-HD-Aoede）'), findsOneWidget);
  });

  testWidgets('long-press orb opens Scenario Injector', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'gemini_api_key': 'fake-key',
      'gemini_model': 'gemini-2.0-flash',
    });
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));

    await tester.longPress(find.byKey(const ValueKey('ambient-orb')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Scenario Injector'), findsOneWidget);
    expect(find.text('服薬サインなし'), findsOneWidget);
    expect(find.textContaining('medication_missed'), findsOneWidget);
  });
}
