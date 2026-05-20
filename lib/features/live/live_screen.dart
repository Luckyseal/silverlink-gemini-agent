import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/config/app_config.dart';
import '../../core/layout/silverlink_tokens.dart';
import '../../features/ambient/ambient_semantic_event.dart';
import '../../features/demo/demo_fixtures.dart';
import '../../features/guardian/guardian_ai_service.dart';
import '../../features/handoff/handoff_summary.dart';
import '../../features/medicine/medicine_card.dart';
import '../../features/memory/conversation_memory.dart';
import '../../features/tts/google_cloud_tts_service.dart';
import '../../features/vision/gemini_multimodal_service.dart';

enum LivePhase { idle, listening, processing, speaking }

/// Single-screen ambient orb experience for SilverLink (demo).
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _demoVoicePresets = [
    'ja-JP-Neural2-B',
    'ja-JP-Neural2-A',
    'ja-JP-Neural2-D',
    'ja-JP-Chirp3-HD-Kore',
    'ja-JP-Chirp3-HD-Leda',
    'ja-JP-Chirp3-HD-Autonoe',
    'ja-JP-Chirp3-HD-Laomedeia',
    'ja-JP-Chirp3-HD-Zephyr',
    'ja-JP-Chirp3-HD-Aoede',
  ];

  late final AnimationController _orbPulse;
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  GoogleCloudTtsService? _googleTts;
  OverlayEntry? _notificationOverlay;
  Timer? _handoffNotificationTimer;

  ConversationMemory? _memory;
  AppConfig _config = AppConfig.fromEnvironmentAndPrefs();
  LivePhase _phase = LivePhase.idle;
  String _status = '準備できました';
  String _lastReply = '';
  MedicineCard? _lastMedicineCard;
  bool _speechReady = false;
  double _replyFontPt = SilverLinkTokens.replyFontDefault;

  @override
  void initState() {
    super.initState();
    _orbPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(AppConfig.prefsApiKeyKey);
    final model = prefs.getString(AppConfig.prefsModelKey);
    final liveModel = prefs.getString(AppConfig.prefsLiveModelKey);
    final liveEnabled = prefs.getBool(AppConfig.prefsLiveEnabledKey);
    final googleTtsCredential = prefs.getString(
      AppConfig.prefsGoogleTtsCredentialKey,
    );
    final googleTtsVoice = prefs.getString(AppConfig.prefsGoogleTtsVoiceKey);
    final googleTtsEnabled = prefs.getBool(AppConfig.prefsGoogleTtsEnabledKey);
    _memory = await ConversationMemory.open();
    final storedFont = prefs.getDouble(AppConfig.prefsReplyFontPtKey);
    setState(() {
      _config = AppConfig.fromEnvironmentAndPrefs(
        prefsApiKey: apiKey,
        prefsModel: model,
        prefsLiveModel: liveModel,
        prefsLiveExperimentalEnabled: liveEnabled,
        prefsGoogleTtsCredential: googleTtsCredential,
        prefsGoogleTtsVoice: googleTtsVoice,
        prefsGoogleTtsEnabled: googleTtsEnabled,
      );
      _replyFontPt = (storedFont ?? SilverLinkTokens.replyFontDefault).clamp(
        SilverLinkTokens.replyFontMin,
        SilverLinkTokens.replyFontMax,
      );
    });
    await _initSpeech();
    await _initTts();
    if (!_config.hasApiKey && mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openSettings(auto: true),
      );
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.42);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> _initSpeech() async {
    if (kIsWeb) {
      setState(() => _speechReady = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (s) {
        if (!mounted) return;
        if (s == 'done' || s == 'notListening') {
          setState(() {
            if (_phase == LivePhase.listening) _phase = LivePhase.idle;
          });
        }
      },
      onError: (_) {},
    );
    setState(() => _speechReady = available);
  }

  @override
  void dispose() {
    _orbPulse.dispose();
    _googleTts?.dispose();
    _handoffNotificationTimer?.cancel();
    _notificationOverlay?.remove();
    _notificationOverlay = null;
    super.dispose();
  }

  GuardianAiService? get _guardianAi {
    if (!_config.hasApiKey) return null;
    return GeminiGuardianAiService(
      apiKey: _config.apiKey,
      model: _config.model,
      liveModel: _config.liveModel,
      liveExperimentalEnabled: _config.liveExperimentalEnabled,
    );
  }

  Future<void> _openSettings({bool auto = false}) async {
    final keyCtrl = TextEditingController(text: _config.apiKey);
    final modelCtrl = TextEditingController(text: _config.model);
    final liveModelCtrl = TextEditingController(text: _config.liveModel);
    final ttsCredentialCtrl = TextEditingController(
      text: _config.googleTtsCredential,
    );
    final ttsVoiceCtrl = TextEditingController(text: _config.googleTtsVoice);
    var draftFont = _replyFontPt;
    var draftLiveEnabled = _config.liveExperimentalEnabled;
    var draftGoogleTtsEnabled = _config.googleTtsEnabled;
    var previewingVoice = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(auto ? 'API キーを設定してください' : '接続設定'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: keyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'GEMINI_API_KEY',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'モデル ID（例: gemini-2.0-flash）',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Gemini Live 実験トラック'),
                  subtitle: const Text('失敗時は安定トラックへ戻します'),
                  value: draftLiveEnabled,
                  onChanged: (v) => setModalState(() => draftLiveEnabled = v),
                ),
                TextField(
                  controller: liveModelCtrl,
                  enabled: draftLiveEnabled,
                  decoration: const InputDecoration(labelText: 'Live モデル ID'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Google Chirp 3 HD 音声'),
                  subtitle: const Text('自然で温かいCloud TTS。失敗時は本体TTSへ戻します'),
                  value: draftGoogleTtsEnabled,
                  onChanged: (v) =>
                      setModalState(() => draftGoogleTtsEnabled = v),
                ),
                TextField(
                  controller: ttsCredentialCtrl,
                  enabled: draftGoogleTtsEnabled,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'GOOGLE_TTS_API_KEY / OAuth token',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue:
                      _demoVoicePresets.contains(ttsVoiceCtrl.text.trim())
                      ? ttsVoiceCtrl.text.trim()
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Demo voice preset',
                  ),
                  items: [
                    for (final voice in _demoVoicePresets)
                      DropdownMenuItem<String>(
                        value: voice,
                        child: Text(voice),
                      ),
                  ],
                  onChanged: draftGoogleTtsEnabled
                      ? (voice) {
                          if (voice == null) return;
                          setModalState(() {
                            ttsVoiceCtrl.text = voice;
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ttsVoiceCtrl,
                  enabled: draftGoogleTtsEnabled,
                  decoration: const InputDecoration(
                    labelText: 'TTS voice（推奨: ja-JP-Neural2-B）',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: previewingVoice
                        ? null
                        : () async {
                            setModalState(() => previewingVoice = true);
                            final messenger = ScaffoldMessenger.of(context);
                            final usesCloud =
                                draftGoogleTtsEnabled &&
                                ttsCredentialCtrl.text.trim().isNotEmpty;
                            try {
                              await _previewWarmVoice(
                                enabled: draftGoogleTtsEnabled,
                                credential: ttsCredentialCtrl.text.trim(),
                                voiceName: ttsVoiceCtrl.text.trim(),
                              );
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    usesCloud
                                        ? 'Google Cloud TTSで再生しました'
                                        : '本体TTSで再生しました',
                                  ),
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '音声プレビューに失敗しました: ${_shortError(e)}',
                                  ),
                                ),
                              );
                            } finally {
                              setModalState(() => previewingVoice = false);
                            }
                          },
                    icon: previewingVoice
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.volume_up_outlined),
                    label: const Text('温柔音声を試す'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '読み上げ・本文の文字サイズ: ${draftFont.round()} pt',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                Slider(
                  value: draftFont,
                  min: SilverLinkTokens.replyFontMin,
                  max: SilverLinkTokens.replyFontMax,
                  divisions:
                      SilverLinkTokens.replyFontMax.round() -
                      SilverLinkTokens.replyFontMin.round(),
                  label: '${draftFont.round()} pt',
                  onChanged: (v) => setModalState(() => draftFont = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('閉じる'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.prefsApiKeyKey, keyCtrl.text.trim());
    await prefs.setString(AppConfig.prefsModelKey, modelCtrl.text.trim());
    await prefs.setString(
      AppConfig.prefsLiveModelKey,
      liveModelCtrl.text.trim(),
    );
    await prefs.setBool(AppConfig.prefsLiveEnabledKey, draftLiveEnabled);
    await prefs.setString(
      AppConfig.prefsGoogleTtsCredentialKey,
      ttsCredentialCtrl.text.trim(),
    );
    await prefs.setString(
      AppConfig.prefsGoogleTtsVoiceKey,
      ttsVoiceCtrl.text.trim(),
    );
    await prefs.setBool(
      AppConfig.prefsGoogleTtsEnabledKey,
      draftGoogleTtsEnabled,
    );
    await prefs.setDouble(AppConfig.prefsReplyFontPtKey, draftFont);
    _googleTts?.dispose();
    _googleTts = null;
    setState(() {
      _config = AppConfig.fromEnvironmentAndPrefs(
        prefsApiKey: keyCtrl.text.trim(),
        prefsModel: modelCtrl.text.trim(),
        prefsLiveModel: liveModelCtrl.text.trim(),
        prefsLiveExperimentalEnabled: draftLiveEnabled,
        prefsGoogleTtsCredential: ttsCredentialCtrl.text.trim(),
        prefsGoogleTtsVoice: ttsVoiceCtrl.text.trim(),
        prefsGoogleTtsEnabled: draftGoogleTtsEnabled,
      );
      _replyFontPt = draftFont;
    });
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    setState(() {
      _phase = LivePhase.speaking;
      _status = _config.googleTtsEnabled && _config.hasGoogleTtsCredential
          ? 'Google Chirp 3 HDで読み上げ中…'
          : '読み上げ中…';
    });
    try {
      if (_config.googleTtsEnabled && _config.hasGoogleTtsCredential) {
        await _speakWithGoogleTts(text);
      } else {
        await _tts.speak(text);
      }
    } catch (_) {
      try {
        await _tts.speak(text);
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Cloud TTSに失敗しました。本体TTSへ戻しました。')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _phase = LivePhase.idle;
          _status = '準備できました';
        });
      }
    }
  }

  Future<void> _speakWithGoogleTts(String text) async {
    final current = _googleTts;
    if (current == null) {
      _googleTts = GoogleCloudTtsService(
        credential: _config.googleTtsCredential,
        voiceName: _config.googleTtsVoice,
      );
    }
    await _googleTts!.speakWarmly(text);
  }

  Future<void> _previewWarmVoice({
    required bool enabled,
    required String credential,
    required String voiceName,
  }) async {
    const sample = '啓子さん、おはようございます。急がなくて大丈夫です。お薬のこと、一緒にゆっくり確認しましょう。';
    if (!enabled || credential.isEmpty) {
      await _tts.speak(sample);
      return;
    }
    final preview = GoogleCloudTtsService(
      credential: credential,
      voiceName: voiceName.isEmpty
          ? AppConfig.defaultGoogleTtsVoice
          : voiceName,
    );
    try {
      await preview.speakWarmly(sample);
    } finally {
      preview.dispose();
    }
  }

  String _shortError(Object error) {
    final text = error.toString().replaceAll(RegExp(r'key=[^&\s]+'), 'key=***');
    if (text.length <= 180) return text;
    return '${text.substring(0, 180)}...';
  }

  Future<void> _rememberReply({
    required String userText,
    required String spoken,
    required String memoryNote,
    String userRole = 'user',
  }) async {
    await _memory?.append(role: userRole, text: userText);
    await _memory?.append(role: 'assistant', text: spoken);
    if (memoryNote.trim().isNotEmpty) {
      await _memory?.append(role: 'baseline', text: memoryNote.trim());
    }
  }

  Future<void> _applyReply({
    required GeminiJsonReply reply,
    required String userText,
    required String status,
    String userRole = 'user',
    bool demoMode = false,
  }) async {
    final spoken = _composeSpoken(reply.replyJp, reply.followUpJp);
    await _rememberReply(
      userText: userText,
      spoken: spoken,
      memoryNote: reply.memoryNoteJp,
      userRole: userRole,
    );
    setState(() {
      _lastReply = spoken;
      _lastMedicineCard = reply.medicineCard;
      _status = demoMode ? '$status（デモモード）' : status;
    });

    if (reply.medicineCard != null) {
      _handoffNotificationTimer?.cancel();
      _handoffNotificationTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted && _lastMedicineCard == reply.medicineCard) {
          _showMockedPushNotification(
            HandoffSummary.fromMedicineCard(reply.medicineCard!),
          );
        }
      });
    }

    await _speak(spoken);
  }

  void _showMockedPushNotification(HandoffSummary summary) {
    if (!mounted) return;
    _notificationOverlay?.remove();
    _notificationOverlay = null;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => TopNotificationBanner(
        summary: summary,
        onTap: () {
          _openHandoffPage(summary);
        },
        onDismiss: () {
          _notificationOverlay?.remove();
          _notificationOverlay = null;
        },
      ),
    );

    overlay.insert(entry);
    _notificationOverlay = entry;
  }

  Future<void> _applyMedicineDemoFallback() async {
    await _applyReply(
      reply: DemoFixtures.medicineImageReply(),
      userText: '（デモモードで薬箱画像を確認しました）',
      status: '薬品カードを表示しました',
      demoMode: true,
    );
  }

  Future<void> _applyAmbientDemoFallback(AmbientSemanticEvent event) async {
    await _memory?.append(role: 'ambient', text: event.toPromptBlock());
    await _applyReply(
      reply: DemoFixtures.ambientReply(event),
      userText: event.labelJp,
      userRole: 'ambient',
      status: '環境シグナルに応答しました',
      demoMode: true,
    );
  }

  Future<void> _onPickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = _mimeForPath(picked.path, bytes);
    await _runVisionOnBytes(bytes, mime);
  }

  Future<void> _onDemoAsset() async {
    try {
      final data = await rootBundle.load('assets/demo/placeholder.png');
      await _runVisionOnBytes(data.buffer.asUint8List(), 'image/png');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('デモ画像を読み込めませんでした: $e')));
    }
  }

  Future<void> _runVisionOnBytes(Uint8List bytes, String mime) async {
    final guardianAi = _guardianAi;
    if (guardianAi == null) {
      setState(() {
        _phase = LivePhase.processing;
        _status = 'デモモードで確認しています…';
      });
      await _applyMedicineDemoFallback();
      return;
    }
    setState(() {
      _phase = LivePhase.processing;
      _status = '写真を確認しています…';
    });
    try {
      final block = _memory?.compactBlock() ?? '';
      final reply = await guardianAi.analyzeImage(
        bytes: bytes,
        mimeType: mime,
        memoryBlock: block,
      );
      await _applyReply(
        reply: reply,
        userText: '（薬や資料の写真を見せました）',
        status: '薬品カードを表示しました',
      );
    } catch (e) {
      setState(() {
        _status = '通信が不安定です。デモモードに切り替えます。';
      });
      await _applyMedicineDemoFallback();
    } finally {
      if (mounted) {
        setState(() {
          if (_phase == LivePhase.processing) _phase = LivePhase.idle;
        });
      }
    }
  }

  Future<void> _onVoiceChat() async {
    if (!_speechReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('この端末では音声入力を利用できません。')));
      return;
    }
    setState(() {
      _phase = LivePhase.listening;
      _status = 'どうぞお話しください';
    });
    final completer = Completer<String>();
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          if (!completer.isCompleted) {
            completer.complete(result.recognizedWords.trim());
          }
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'ja_JP',
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
    String text;
    try {
      text = await completer.future.timeout(
        const Duration(seconds: 35),
        onTimeout: () => '',
      );
    } finally {
      await _speech.stop();
    }
    if (text.isEmpty) {
      setState(() {
        _phase = LivePhase.idle;
        _status = '聞き取れませんでした';
      });
      return;
    }
    setState(() {
      _phase = LivePhase.processing;
      _status = '考えています…';
    });

    final guardianAi = _guardianAi;
    if (guardianAi == null) {
      // API Key / Offline fallback
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      final reply = _localVoiceFallback(text);
      await _applyReply(
        reply: reply,
        userText: text,
        status: '応答しました',
        demoMode: true,
      );
      return;
    }

    try {
      final block = _memory?.compactBlock() ?? '';
      final reply = await guardianAi.chat(userText: text, memoryBlock: block);
      final spoken = _composeSpoken(reply.replyJp, reply.followUpJp);
      await _rememberReply(
        userText: text,
        spoken: spoken,
        memoryNote: reply.memoryNoteJp,
      );
      setState(() {
        _lastReply = spoken;
        _status = '完了';
      });
      await _speak(spoken);
    } catch (e) {
      setState(() {
        _status = '通信が不安定です。デモモードに切り替えます。';
      });
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final reply = _localVoiceFallback(text);
      await _applyReply(
        reply: reply,
        userText: text,
        status: '応答しました',
        demoMode: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          if (_phase == LivePhase.processing) _phase = LivePhase.idle;
        });
      }
    }
  }

  GeminiJsonReply _localVoiceFallback(String text) {
    final query = text.toLowerCase();
    String reply = 'こんにちは。お薬や体調について、何か気になることはありますか？';
    String followUp = 'いつでもお声がけください。';

    if (query.contains('こんにちは') ||
        query.contains('ハロー') ||
        query.contains('元気')) {
      reply = 'こんにちは！はい、今日も元気にお話し相手をさせていただきます。';
      followUp = '今日は朝ごはんの後にお薬は飲まれましたか？';
    } else if (query.contains('薬') ||
        query.contains('くすり') ||
        query.contains('ロキソニン') ||
        query.contains('飲む')) {
      reply = 'お薬の確認ですね。ロキソニンSの箱を見せていただければ、内容を確認してお伝えできますよ。';
      followUp = 'ダブルタップするか、「見る」ボタンからカメラを起動してみてください。';
    } else if (query.contains('しんどい') ||
        query.contains('頭痛') ||
        query.contains('痛い') ||
        query.contains('熱')) {
      reply = 'それは心配です。無理をなさらず、ゆっくり横になって休んでくださいね。';
      followUp = 'お水もしっかり摂ってください。症状が続くようなら、ご家族や薬剤師さんにご連絡しましょうか？';
    } else if (query.contains('ありがとう') ||
        query.contains('助かった') ||
        query.contains('サンキュー')) {
      reply = 'どういたしまして。お役に立てて嬉しいです。';
      followUp = '無理せず、のんびり過ごしてくださいね。';
    }

    return GeminiJsonReply(
      replyJp: reply,
      followUpJp: followUp,
      memoryNoteJp: 'デモ: 発話「$text」に対してローカルキーワードマッチで応答した。',
      rawText: 'local_voice_fallback:$text',
    );
  }

  Future<void> _onAmbientEvent(AmbientSemanticEvent event) async {
    final guardianAi = _guardianAi;
    if (guardianAi == null) {
      setState(() {
        _phase = LivePhase.processing;
        _status = 'デモモードで環境シグナルを確認しています…';
      });
      await _applyAmbientDemoFallback(event);
      return;
    }
    setState(() {
      _phase = LivePhase.processing;
      _status = '${event.labelJp}を確認しています…';
    });
    try {
      final block = _memory?.compactBlock() ?? '';
      await _memory?.append(role: 'ambient', text: event.toPromptBlock());
      final reply = await guardianAi.handleAmbientEvent(
        event: event,
        memoryBlock: block,
      );
      await _applyReply(
        reply: reply,
        userText: event.labelJp,
        userRole: 'ambient',
        status: '環境シグナルに応答しました',
      );
    } catch (e) {
      setState(() {
        _status = '通信が不安定です。デモモードに切り替えます。';
      });
      await _applyAmbientDemoFallback(event);
    } finally {
      if (mounted) {
        setState(() {
          if (_phase == LivePhase.processing) _phase = LivePhase.idle;
        });
      }
    }
  }

  Future<void> _probeLiveTrack() async {
    final guardianAi = _guardianAi;
    if (guardianAi == null) {
      await _openSettings(auto: true);
      return;
    }
    setState(() {
      _phase = LivePhase.processing;
      _status = 'Gemini Liveを確認しています…';
    });
    final result = await guardianAi.probeLive();
    if (!mounted) return;
    setState(() {
      _phase = LivePhase.idle;
      _status = result.ok ? 'Live実験トラック接続済み' : 'Liveは実験中です。安定トラックを使用します';
      _lastReply = result.ok
          ? 'Gemini Live 実験トラックに接続できました。デモ本番では安定トラックを主経路として使います。'
          : result.message;
    });
  }

  Future<void> _openScenarioInjector() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Scenario Injector',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Matter互換エッジで意味化済みのトークンだけを注入します。',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final event in AmbientSemanticEvent.demoEvents())
                  ListTile(
                    leading: const Icon(Icons.sensors_outlined),
                    title: Text(event.labelJp),
                    subtitle: Text('${event.eventName} / ${event.severity}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _onAmbientEvent(event);
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bolt_outlined),
                  title: const Text('Gemini Live 接続テスト'),
                  subtitle: Text(
                    _config.liveExperimentalEnabled
                        ? _config.liveModel
                        : '設定で実験トラックを有効化',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _probeLiveTrack();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _composeSpoken(String main, String followUp) {
    final m = main.trim();
    final f = followUp.trim();
    if (f.isEmpty) return m;
    return '$m $f';
  }

  String _mimeForPath(String path, Uint8List bytes) {
    final fromLookup = lookupMimeType(path, headerBytes: bytes);
    if (fromLookup != null && fromLookup.isNotEmpty) return fromLookup;
    return 'image/jpeg';
  }

  Future<void> _pickSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('アルバムから選ぶ'),
                onTap: () {
                  Navigator.pop(ctx);
                  _onPickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('カメラで撮る'),
                onTap: () {
                  Navigator.pop(ctx);
                  _onPickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('デモ画像（同梱プレースホルダー）'),
                subtitle: const Text('録画リハーサル向け。ご自身の写真も assets/demo/ に追加可能です。'),
                onTap: () {
                  Navigator.pop(ctx);
                  _onDemoAsset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openHandoffPage(HandoffSummary summary) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _HandoffPage(summary: summary)),
    );
  }

  Color _orbColor() {
    switch (_phase) {
      case LivePhase.idle:
        return const Color(0xFF5C6BC0);
      case LivePhase.listening:
        return const Color(0xFF26A69A);
      case LivePhase.processing:
        return const Color(0xFFFFB74D);
      case LivePhase.speaking:
        return const Color(0xFF9575CD);
    }
  }

  String _orbSemanticsLabel() {
    switch (_phase) {
      case LivePhase.idle:
        return 'SilverLink、待機中です';
      case LivePhase.listening:
        return '音声を聞いています';
      case LivePhase.processing:
        return '画像または発話を処理しています';
      case LivePhase.speaking:
        return '読み上げ中です';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SilverLinkTokens.pagePadding,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filledTonal(
                    tooltip: '設定',
                    onPressed: () => _openSettings(),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _config.liveExperimentalEnabled
                              ? Icons.bolt_outlined
                              : Icons.verified_outlined,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$_status  |  ${_config.liveExperimentalEnabled ? 'Live Lab' : 'Stable'}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: (_phase == LivePhase.processing || !_speechReady)
                        ? null
                        : _onVoiceChat,
                    onDoubleTap: _phase == LivePhase.processing
                        ? null
                        : _pickSource,
                    onLongPress: _openScenarioInjector,
                    child: AnimatedBuilder(
                      animation: _orbPulse,
                      builder: (context, child) {
                        final scale = 1.0 + (_orbPulse.value * 0.06);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Semantics(
                        label:
                            '${_orbSemanticsLabel()}。タップで話す、ダブルタップで見る、長押しでScenario Injectorを開きます',
                        button: true,
                        child: Container(
                          key: const ValueKey('ambient-orb'),
                          width: SilverLinkTokens.orbDiameter,
                          height: SilverLinkTokens.orbDiameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _orbColor().withValues(alpha: 0.95),
                                _orbColor().withValues(alpha: 0.35),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _orbColor().withValues(alpha: 0.45),
                                blurRadius: 48,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_lastReply.isNotEmpty)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_lastMedicineCard != null) ...[
                          _medicineCardView(context, _lastMedicineCard!),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              key: const ValueKey('open-handoff-summary'),
                              onPressed: () => _openHandoffPage(
                                HandoffSummary.fromMedicineCard(
                                  _lastMedicineCard!,
                                ),
                              ),
                              icon: const Icon(Icons.handshake_outlined),
                              label: const Text('家族・薬剤師に共有'),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          _lastReply,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: _replyFontPt,
                                height: 1.45,
                                color: scheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(flex: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleButton(
                    context: context,
                    icon: Icons.photo_camera_outlined,
                    label: '見る',
                    onPressed: _phase == LivePhase.processing
                        ? null
                        : _pickSource,
                  ),
                  _circleButton(
                    context: context,
                    icon: Icons.mic_none_rounded,
                    label: '話す',
                    onPressed: (_phase == LivePhase.processing || !_speechReady)
                        ? null
                        : _onVoiceChat,
                  ),
                  _circleButton(
                    context: context,
                    icon: Icons.sensors_outlined,
                    label: 'シグナル',
                    onPressed: _phase == LivePhase.processing
                        ? null
                        : _openScenarioInjector,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '※医療判断はできません。不安なときは医師・薬剤師にご相談ください。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: SilverLinkTokens.disclaimerFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final foreground = enabled ? scheme.onSecondaryContainer : scheme.onSurface;
    return SizedBox(
      width: 88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              fixedSize: const Size.square(SilverLinkTokens.actionButtonSize),
              backgroundColor: enabled
                  ? scheme.secondaryContainer
                  : scheme.surfaceContainerHighest,
              foregroundColor: foreground.withValues(alpha: enabled ? 1 : 0.38),
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
            ),
            icon: Icon(icon, size: 28),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineCardView(BuildContext context, MedicineCard card) {
    final scheme = Theme.of(context).colorScheme;
    final reviewColor = card.needsHumanReview
        ? scheme.tertiary
        : scheme.primary;
    return Card(
      key: const ValueKey('medicine-card'),
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SilverLinkTokens.cardRadius),
        side: BorderSide(color: reviewColor.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: reviewColor.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.medication_outlined,
                          color: reviewColor,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        card.medicineName.isEmpty
                            ? '薬名を確認中'
                            : card.medicineName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _medicineCardRow(context, '用途', card.purposePlainJp),
                _medicineCardRow(context, 'タイミング', card.timingPlainJp),
                _medicineCardRow(context, '確認事項', card.warningsPlainJp),
                const SizedBox(height: 4),
                Text(
                  card.needsHumanReview
                      ? '※処方・説明書と違う場合は、医師・薬剤師に確認してください。'
                      : '※念のため、処方・説明書と照らし合わせてください。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: reviewColor,
                    fontSize: SilverLinkTokens.disclaimerFontSize,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineCardRow(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    final displayValue = value.trim().isEmpty ? '読み取れた範囲では不明です。' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayValue,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HandoffPage extends StatelessWidget {
  const _HandoffPage({required this.summary});

  final HandoffSummary summary;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: summary.toShareText()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('交接メモをコピーしました')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('家族・薬剤師への交接メモ')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SilverLinkTokens.pagePadding),
          child: Card(
            key: const ValueKey('handoff-card'),
            color: scheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SilverLinkTokens.cardRadius),
              side: BorderSide(color: scheme.primary.withValues(alpha: 0.55)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.handshake_outlined,
                            color: scheme.onPrimaryContainer,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '人に渡すためのメモ',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      IconButton.filledTonal(
                        key: const ValueKey('copy-handoff-summary'),
                        tooltip: '交接メモをコピー',
                        onPressed: () => _copy(context),
                        icon: const Icon(Icons.copy_all_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _HandoffRow(label: '今日確認したこと', value: summary.todayJp),
                  _HandoffRow(label: '不確かな点', value: summary.uncertainJp),
                  _HandoffRow(
                    label: '医師・薬剤師に確認すること',
                    value: summary.askProfessionalJp,
                  ),
                  _HandoffRow(label: '家族へ', value: summary.familyNoteJp),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        SilverLinkTokens.cardRadius,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: scheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '診断や用量変更ではありません。家族・薬剤師・医師に確認するための共有メモです。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: scheme.onTertiaryContainer,
                                    height: 1.35,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HandoffRow extends StatelessWidget {
  const _HandoffRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 17,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class TopNotificationBanner extends StatefulWidget {
  final HandoffSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const TopNotificationBanner({
    super.key,
    required this.summary,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<TopNotificationBanner> createState() => _TopNotificationBannerState();
}

class _TopNotificationBannerState extends State<TopNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _dismissTimer = Timer(const Duration(seconds: 5), () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  widget.onTap();
                  _dismiss();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C300),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'LINE 家族のグループ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '新しい服薬確認メモが届きました',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
