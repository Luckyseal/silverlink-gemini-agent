import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverlink_gemini_agent/core/prompts/japanese_prompts.dart';
import 'package:silverlink_gemini_agent/features/ambient/ambient_semantic_event.dart';
import 'package:silverlink_gemini_agent/features/demo/demo_fixtures.dart';
import 'package:silverlink_gemini_agent/features/guardian/guardian_ai_service.dart';
import 'package:silverlink_gemini_agent/features/handoff/handoff_summary.dart';
import 'package:silverlink_gemini_agent/features/memory/conversation_memory.dart';
import 'package:silverlink_gemini_agent/features/tts/google_cloud_tts_service.dart';
import 'package:silverlink_gemini_agent/features/vision/gemini_multimodal_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ambient event prompt uses semantic token privacy narrative', () {
    final event = AmbientSemanticEvent.demoEvents().first;
    final prompt = JapanesePrompts.ambientEventPrompt(
      event,
      'ベースライン: 朝は薬箱を開ける',
    );

    expect(prompt, contains('Matter互換エッジゲートウェイ'));
    expect(prompt, contains('event: medication_missed'));
    expect(prompt, contains('edge_semantic_token_only'));
    expect(prompt, contains('薬を飲むように直接命令しないでください'));
  });

  test('Gemini JSON parser accepts fenced JSON and falls back to raw text', () {
    final parsed = GeminiMultimodalService.parseReply('''
```json
{"reply_jp":"おはようございます","follow_up_jp":"少し寒くありませんか","memory_note_jp":"朝は寒さを気にしていた","medicine_card":{"medicine_name":"テスト薬","purpose_plain_ja":"痛みをやわらげる可能性があります","timing_plain_ja":"食後と読めます","warnings_plain_ja":"薬剤師に確認してください","confidence":0.75,"needs_human_review":true}}
```
''');

    expect(parsed.replyJp, 'おはようございます');
    expect(parsed.followUpJp, '少し寒くありませんか');
    expect(parsed.memoryNoteJp, '朝は寒さを気にしていた');
    expect(parsed.medicineCard?.medicineName, 'テスト薬');
    expect(parsed.medicineCard?.needsHumanReview, isTrue);

    final fallback = GeminiMultimodalService.parseReply('そのままの返答');
    expect(fallback.replyJp, 'そのままの返答');
    expect(fallback.followUpJp, isEmpty);
  });

  test('memory notes become baseline context', () async {
    SharedPreferences.setMockInitialValues({});
    final memory = await ConversationMemory.open();

    await memory.append(role: 'ambient', text: 'event: medication_missed');
    await memory.append(role: 'baseline', text: '朝は8時台に薬箱を開ける');

    final block = memory.compactBlock();
    expect(block, contains('環境トークン: event: medication_missed'));
    expect(block, contains('ベースライン: 朝は8時台に薬箱を開ける'));
  });

  test('Live adapter reports disabled as fallback path', () async {
    final service = GeminiGuardianAiService(
      apiKey: 'fake-key',
      model: 'gemini-2.0-flash',
      liveModel: 'gemini-3.1-flash-live-preview',
      liveExperimentalEnabled: false,
    );

    final result = await service.probeLive();
    expect(result.ok, isFalse);
    expect(result.message, contains('disabled'));
  });

  test('demo fixtures provide medicine card and ambient fallback replies', () {
    final medicine = DemoFixtures.medicineImageReply();
    expect(medicine.rawText, contains('local_demo_fixture'));
    expect(medicine.medicineCard?.medicineName, contains('ロキソニン'));
    expect(medicine.medicineCard?.needsHumanReview, isTrue);

    final ambient = DemoFixtures.ambientReply(
      AmbientSemanticEvent.demoEvents().first,
    );
    expect(ambient.replyJp, contains('お薬箱'));
    expect(ambient.memoryNoteJp, contains('semantic token'));
  });

  test(
    'handoff summary converts medicine card uncertainty into human handoff',
    () {
      final card = DemoFixtures.medicineImageReply().medicineCard!;
      final summary = HandoffSummary.fromMedicineCard(card);

      expect(summary.todayJp, contains(card.medicineName));
      expect(summary.askProfessionalJp, contains('薬剤師'));
      expect(summary.familyNoteJp, contains('一緒に見てください'));
      expect(summary.toShareText(), contains('【医師・薬剤師に確認すること】'));
    },
  );

  test('Google TTS request uses senior-friendly Neural2 SSML controls', () {
    final request = GoogleCloudTtsService.buildWarmJapaneseRequest(
      'おはようございます。今日は少し寒いですね。',
      voiceName: 'ja-JP-Neural2-B',
    );

    expect(request['voice'], {
      'languageCode': 'ja-JP',
      'name': 'ja-JP-Neural2-B',
    });
    expect(request['input'], containsPair('ssml', contains('<prosody')));
    expect(request['input'], containsPair('ssml', contains('rate="82%"')));
    expect(request['input'], containsPair('ssml', contains('<break')));
    expect(request['audioConfig'], containsPair('audioEncoding', 'MP3'));
    expect(request['audioConfig'], containsPair('speakingRate', 1.0));
    expect(request['audioConfig'], containsPair('pitch', -2.5));
    expect(request['audioConfig'], containsPair('volumeGainDb', 3.5));
    expect(
      request['audioConfig'],
      containsPair('effectsProfileId', [
        'small-bluetooth-speaker-class-device',
      ]),
    );
  });

  test('Google TTS request keeps Chirp3 HD markup pause controls', () {
    final request = GoogleCloudTtsService.buildWarmJapaneseRequest(
      'ゆっくり確認しましょう。',
      voiceName: 'ja-JP-Chirp3-HD-Kore',
    );

    expect(request['input'], containsPair('markup', contains('[pause long]')));
    expect(request['audioConfig'], containsPair('speakingRate', 0.78));
    expect(request['audioConfig'], isNot(contains('effectsProfileId')));
  });
}
