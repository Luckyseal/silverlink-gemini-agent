/// Runtime configuration for Gemini (API key + model id).
///
/// Prefer `--dart-define=GEMINI_API_KEY=...` for local runs; optional SharedPreferences
/// can override at runtime from the in-app settings sheet.
class AppConfig {
  AppConfig({
    required this.apiKey,
    required this.model,
    required this.liveModel,
    required this.liveExperimentalEnabled,
    required this.googleTtsCredential,
    required this.googleTtsVoice,
    required this.googleTtsEnabled,
  });

  static const String prefsApiKeyKey = 'gemini_api_key';
  static const String prefsModelKey = 'gemini_model';
  static const String prefsLiveModelKey = 'gemini_live_model';
  static const String prefsLiveEnabledKey = 'gemini_live_enabled';
  static const String prefsGoogleTtsCredentialKey = 'google_tts_credential';
  static const String prefsGoogleTtsVoiceKey = 'google_tts_voice';
  static const String prefsGoogleTtsEnabledKey = 'google_tts_enabled';
  static const String prefsReplyFontPtKey = 'reply_font_pt';

  /// Default model id for Google AI Studio / Gemini API (override via dart-define or prefs).
  static const String defaultModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.0-flash',
  );

  static const String defaultLiveModel = String.fromEnvironment(
    'GEMINI_LIVE_MODEL',
    defaultValue: 'gemini-3.1-flash-live-preview',
  );

  static const String defaultGoogleTtsCredential = String.fromEnvironment(
    'GOOGLE_TTS_API_KEY',
    defaultValue: '',
  );

  static const String defaultGoogleTtsVoice = String.fromEnvironment(
    'GOOGLE_TTS_VOICE',
    defaultValue: 'ja-JP-Chirp3-HD-Aoede',
  );

  final String apiKey;
  final String model;
  final String liveModel;
  final bool liveExperimentalEnabled;
  final String googleTtsCredential;
  final String googleTtsVoice;
  final bool googleTtsEnabled;

  static AppConfig fromEnvironmentAndPrefs({
    String? prefsApiKey,
    String? prefsModel,
    String? prefsLiveModel,
    bool? prefsLiveExperimentalEnabled,
    String? prefsGoogleTtsCredential,
    String? prefsGoogleTtsVoice,
    bool? prefsGoogleTtsEnabled,
  }) {
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    final key = (prefsApiKey?.trim().isNotEmpty ?? false)
        ? prefsApiKey!.trim()
        : envKey.trim();
    final model = (prefsModel?.trim().isNotEmpty ?? false)
        ? prefsModel!.trim()
        : defaultModel;
    final liveModel = (prefsLiveModel?.trim().isNotEmpty ?? false)
        ? prefsLiveModel!.trim()
        : defaultLiveModel;
    final googleTtsCredential =
        (prefsGoogleTtsCredential?.trim().isNotEmpty ?? false)
        ? prefsGoogleTtsCredential!.trim()
        : defaultGoogleTtsCredential.trim();
    final googleTtsVoice = (prefsGoogleTtsVoice?.trim().isNotEmpty ?? false)
        ? prefsGoogleTtsVoice!.trim()
        : defaultGoogleTtsVoice;
    return AppConfig(
      apiKey: key,
      model: model,
      liveModel: liveModel,
      liveExperimentalEnabled: prefsLiveExperimentalEnabled ?? false,
      googleTtsCredential: googleTtsCredential,
      googleTtsVoice: googleTtsVoice,
      googleTtsEnabled:
          prefsGoogleTtsEnabled ?? googleTtsCredential.trim().isNotEmpty,
    );
  }

  bool get hasApiKey => apiKey.isNotEmpty;

  bool get hasGoogleTtsCredential => googleTtsCredential.isNotEmpty;
}
