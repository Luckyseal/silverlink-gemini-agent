import 'dart:typed_data';

import '../../core/prompts/japanese_prompts.dart';
import '../ambient/ambient_semantic_event.dart';
import '../live_api/gemini_live_connector.dart';
import '../live_api/live_probe_result.dart';
import '../vision/gemini_multimodal_service.dart';

abstract interface class GuardianAiService {
  String get label;

  Future<GeminiJsonReply> analyzeImage({
    required Uint8List bytes,
    required String mimeType,
    required String memoryBlock,
  });

  Future<GeminiJsonReply> chat({
    required String userText,
    required String memoryBlock,
  });

  Future<GeminiJsonReply> handleAmbientEvent({
    required AmbientSemanticEvent event,
    required String memoryBlock,
  });

  Future<LiveProbeResult> probeLive();
}

class GeminiGuardianAiService implements GuardianAiService {
  GeminiGuardianAiService({
    required String apiKey,
    required String model,
    required String liveModel,
    required bool liveExperimentalEnabled,
  }) : _stable = GeminiMultimodalService(apiKey: apiKey, model: model),
       _liveConnector = GeminiLiveConnector(apiKey: apiKey, model: liveModel),
       _liveExperimentalEnabled = liveExperimentalEnabled;

  final GeminiMultimodalService _stable;
  final GeminiLiveConnector _liveConnector;
  final bool _liveExperimentalEnabled;

  @override
  String get label =>
      _liveExperimentalEnabled ? 'Gemini Stable + Live Lab' : 'Gemini Stable';

  @override
  Future<GeminiJsonReply> analyzeImage({
    required Uint8List bytes,
    required String mimeType,
    required String memoryBlock,
  }) {
    return _stable.analyzeImage(
      bytes: bytes,
      mimeType: mimeType,
      memoryBlock: memoryBlock,
    );
  }

  @override
  Future<GeminiJsonReply> chat({
    required String userText,
    required String memoryBlock,
  }) {
    return _stable.chat(userText: userText, memoryBlock: memoryBlock);
  }

  @override
  Future<GeminiJsonReply> handleAmbientEvent({
    required AmbientSemanticEvent event,
    required String memoryBlock,
  }) {
    return _stable.ambientEvent(event: event, memoryBlock: memoryBlock);
  }

  @override
  Future<LiveProbeResult> probeLive() {
    if (!_liveExperimentalEnabled) {
      return Future.value(
        LiveProbeResult.failed('Gemini Live experimental track is disabled.'),
      );
    }
    return _liveConnector.probe(
      systemInstruction: JapanesePrompts.systemInstruction,
    );
  }
}
