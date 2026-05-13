import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silverlink_gemini_agent/core/prompts/japanese_prompts.dart';
import 'package:silverlink_gemini_agent/features/ambient/ambient_semantic_event.dart';
import 'package:silverlink_gemini_agent/features/guardian/guardian_ai_service.dart';
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
{"reply_jp":"おはようございます","follow_up_jp":"少し寒くありませんか","memory_note_jp":"朝は寒さを気にしていた"}
```
''');

    expect(parsed.replyJp, 'おはようございます');
    expect(parsed.followUpJp, '少し寒くありませんか');
    expect(parsed.memoryNoteJp, '朝は寒さを気にしていた');

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

  test('Google TTS request uses Chirp 3 HD warm Japanese voice controls', () {
    final request = GoogleCloudTtsService.buildWarmJapaneseRequest(
      'おはようございます。今日は少し寒いですね。',
      voiceName: 'ja-JP-Chirp3-HD-Aoede',
    );

    expect(request['voice'], {
      'languageCode': 'ja-JP',
      'name': 'ja-JP-Chirp3-HD-Aoede',
    });
    expect(request['input'], containsPair('prompt', contains('warm')));
    expect(request['input'], containsPair('markup', contains('[pause short]')));
    expect(request['audioConfig'], containsPair('audioEncoding', 'MP3'));
    expect(request['audioConfig'], containsPair('speakingRate', 0.88));
  });
}
