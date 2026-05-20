import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    expect(find.text('Demo voice preset'), findsOneWidget);
    expect(find.text('TTS voice（推奨: ja-JP-Neural2-B）'), findsOneWidget);
    expect(find.text('温柔音声を試す'), findsOneWidget);
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

  testWidgets('Scenario Injector has local fallback without API key', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));

    if (tester.any(find.text('閉じる'))) {
      await tester.tap(find.text('閉じる'));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.longPress(find.byKey(const ValueKey('ambient-orb')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('服薬サインなし'));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.textContaining('お薬箱'), findsOneWidget);
    expect(find.text('API キーを設定してください'), findsNothing);
  });

  testWidgets('demo image fallback renders medicine card without API key', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));

    if (tester.any(find.text('閉じる'))) {
      await tester.tap(find.text('閉じる'));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.dragFrom(const Offset(400, 560), const Offset(0, -180));
    await tester.pump(const Duration(milliseconds: 300));
    final demoImage = find.textContaining('デモ画像');
    await tester.tap(demoImage);
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(const ValueKey('medicine-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('handoff-card')), findsNothing);
    expect(find.textContaining('ロキソニン'), findsWidgets);
    expect(find.text('確認事項'), findsOneWidget);
    expect(find.byKey(const ValueKey('open-handoff-summary')), findsOneWidget);
  });

  testWidgets('handoff memo copy button writes share text', (
    WidgetTester tester,
  ) async {
    var copiedText = '';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          final args = call.arguments as Map<Object?, Object?>;
          copiedText = args['text'].toString();
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SilverLinkApp());
    await tester.pump(const Duration(milliseconds: 800));

    if (tester.any(find.text('閉じる'))) {
      await tester.tap(find.text('閉じる'));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.dragFrom(const Offset(400, 560), const Offset(0, -180));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.textContaining('デモ画像'));
    await tester.pump(const Duration(milliseconds: 800));

    final openButton = find.byKey(const ValueKey('open-handoff-summary'));
    await tester.ensureVisible(openButton);
    await tester.tap(openButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('handoff-card')), findsOneWidget);
    expect(find.text('家族・薬剤師への交接メモ'), findsOneWidget);

    final copyButton = find.byKey(const ValueKey('copy-handoff-summary'));
    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pump();

    expect(copiedText, contains('【今日確認したこと】'));
    expect(copiedText, contains('【医師・薬剤師に確認すること】'));
    expect(copiedText, contains('ロキソニン'));
    expect(find.text('交接メモをコピーしました'), findsOneWidget);
  });
}
