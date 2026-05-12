/// Runtime configuration for Gemini (API key + model id).
///
/// Prefer `--dart-define=GEMINI_API_KEY=...` for local runs; optional SharedPreferences
/// can override at runtime from the in-app settings sheet.
class AppConfig {
  AppConfig({
    required this.apiKey,
    required this.model,
  });

  static const String prefsApiKeyKey = 'gemini_api_key';
  static const String prefsModelKey = 'gemini_model';
  static const String prefsReplyFontPtKey = 'reply_font_pt';

  /// Default model id for Google AI Studio / Gemini API (override via dart-define or prefs).
  static const String defaultModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.0-flash',
  );

  final String apiKey;
  final String model;

  static AppConfig fromEnvironmentAndPrefs({String? prefsApiKey, String? prefsModel}) {
    const envKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    final key = (prefsApiKey?.trim().isNotEmpty ?? false) ? prefsApiKey!.trim() : envKey.trim();
    final model = (prefsModel?.trim().isNotEmpty ?? false)
        ? prefsModel!.trim()
        : defaultModel;
    return AppConfig(apiKey: key, model: model);
  }

  bool get hasApiKey => apiKey.isNotEmpty;
}
