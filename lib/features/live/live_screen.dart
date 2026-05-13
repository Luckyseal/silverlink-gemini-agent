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
import '../../features/guardian/guardian_ai_service.dart';
import '../../features/memory/conversation_memory.dart';
import '../../features/tts/google_cloud_tts_service.dart';

enum LivePhase { idle, listening, processing, speaking }

/// Single-screen “Gemini Live orb” experience for SilverLink (demo).
class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbPulse;
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  GoogleCloudTtsService? _googleTts;

  ConversationMemory? _memory;
  AppConfig _config = AppConfig.fromEnvironmentAndPrefs();
  LivePhase _phase = LivePhase.idle;
  String _status = '準備できました';
  String _lastReply = '';
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
                TextField(
                  controller: ttsVoiceCtrl,
                  enabled: draftGoogleTtsEnabled,
                  decoration: const InputDecoration(
                    labelText: 'TTS voice（例: ja-JP-Chirp3-HD-Aoede）',
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
          const SnackBar(content: Text('Google TTSに失敗しました。本体の読み上げに戻しました。')),
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

  Future<void> _onPickImage(ImageSource source) async {
    if (_guardianAi == null) {
      await _openSettings(auto: true);
      return;
    }
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = _mimeForPath(picked.path, bytes);
    await _runVisionOnBytes(bytes, mime);
  }

  Future<void> _onDemoAsset() async {
    if (_guardianAi == null) {
      await _openSettings(auto: true);
      return;
    }
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
      await _openSettings(auto: true);
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
      final spoken = _composeSpoken(reply.replyJp, reply.followUpJp);
      await _rememberReply(
        userText: '（薬や資料の写真を見せました）',
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
        _status = '通信に失敗しました。もう一度お試しください。';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          if (_phase == LivePhase.processing) _phase = LivePhase.idle;
        });
      }
    }
  }

  Future<void> _onVoiceChat() async {
    final guardianAi = _guardianAi;
    if (guardianAi == null) {
      await _openSettings(auto: true);
      return;
    }
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
      setState(() => _status = '通信に失敗しました。');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          if (_phase == LivePhase.processing) _phase = LivePhase.idle;
        });
      }
    }
  }

  Future<void> _onAmbientEvent(AmbientSemanticEvent event) async {
    final guardianAi = _guardianAi;
    if (guardianAi == null) {
      await _openSettings(auto: true);
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
      final spoken = _composeSpoken(reply.replyJp, reply.followUpJp);
      await _rememberReply(
        userText: event.labelJp,
        spoken: spoken,
        memoryNote: reply.memoryNoteJp,
        userRole: 'ambient',
      );
      setState(() {
        _lastReply = spoken;
        _status = '環境シグナルに応答しました';
      });
      await _speak(spoken);
    } catch (e) {
      setState(() {
        _status = '安定トラックでの応答に失敗しました。';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
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
    return Scaffold(
      backgroundColor: const Color(0xFF0E1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: '設定',
                    onPressed: () => _openSettings(),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_status  |  ${_config.liveExperimentalEnabled ? 'Live Lab' : 'Stable'}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: SilverLinkTokens.statusFontSize,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onLongPress: _openScenarioInjector,
                    child: AnimatedBuilder(
                      animation: _orbPulse,
                      builder: (context, child) {
                        final scale = 1.0 + (_orbPulse.value * 0.06);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Semantics(
                        label:
                            '${_orbSemanticsLabel()}。長押しでScenario Injectorを開きます',
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
                    child: Text(
                      _lastReply,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: _replyFontPt,
                        height: 1.45,
                        color: Colors.white,
                      ),
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
                    icon: Icons.photo_camera_outlined,
                    label: '見る',
                    onPressed: _phase == LivePhase.processing
                        ? null
                        : _pickSource,
                  ),
                  _circleButton(
                    icon: Icons.mic_none_rounded,
                    label: '話す',
                    onPressed: (_phase == LivePhase.processing || !_speechReady)
                        ? null
                        : _onVoiceChat,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '※医療判断はできません。不安なときは医師・薬剤師にご相談ください。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
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
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.08),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Icon(
                icon,
                size: 34,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
