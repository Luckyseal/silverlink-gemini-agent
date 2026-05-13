import 'live_probe_result.dart';

class GeminiLiveConnector {
  GeminiLiveConnector({required String apiKey, required String model});

  Future<LiveProbeResult> probe({
    required String systemInstruction,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    return LiveProbeResult.failed(
      'Gemini Live probe is available on iOS/macOS/Android builds, not this platform.',
    );
  }
}
