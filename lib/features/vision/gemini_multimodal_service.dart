import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/prompts/japanese_prompts.dart';
import '../ambient/ambient_semantic_event.dart';

class GeminiJsonReply {
  GeminiJsonReply({
    required this.replyJp,
    required this.followUpJp,
    required this.memoryNoteJp,
    required this.rawText,
  });

  final String replyJp;
  final String followUpJp;
  final String memoryNoteJp;
  final String rawText;
}

/// Calls Gemini with multimodal or text-only content; parses JSON-shaped replies.
class GeminiMultimodalService {
  GeminiMultimodalService({required String apiKey, required String model})
    : _apiKey = apiKey,
      _model = model;

  final String _apiKey;
  final String _model;

  GenerativeModel _modelWithInstruction() {
    return GenerativeModel(
      model: _model,
      apiKey: _apiKey,
      systemInstruction: Content.system(JapanesePrompts.systemInstruction),
    );
  }

  Future<GeminiJsonReply> analyzeImage({
    required Uint8List bytes,
    required String mimeType,
    required String memoryBlock,
  }) {
    final prompt = JapanesePrompts.visionUserPrompt(memoryBlock);
    final content = Content.multi([
      TextPart(prompt),
      DataPart(mimeType, bytes),
    ]);
    return _generateSingle(content);
  }

  Future<GeminiJsonReply> chat({
    required String userText,
    required String memoryBlock,
  }) {
    final prompt = JapanesePrompts.chatUserPrompt(userText, memoryBlock);
    final content = Content('user', [TextPart(prompt)]);
    return _generateSingle(content);
  }

  Future<GeminiJsonReply> ambientEvent({
    required AmbientSemanticEvent event,
    required String memoryBlock,
  }) {
    final prompt = JapanesePrompts.ambientEventPrompt(event, memoryBlock);
    final content = Content('user', [TextPart(prompt)]);
    return _generateSingle(content);
  }

  Future<GeminiJsonReply> _generateSingle(Content content) async {
    const delaysMs = [400, 1200, 2800];
    Object? lastError;
    for (var attempt = 0; attempt <= delaysMs.length; attempt++) {
      try {
        final model = _modelWithInstruction();
        final response = await model.generateContent([content]);
        final text = response.text;
        if (text == null || text.trim().isEmpty) {
          throw StateError('Empty response from model');
        }
        return parseReply(text.trim());
      } catch (e) {
        lastError = e;
        if (attempt == delaysMs.length) break;
        await Future<void>.delayed(Duration(milliseconds: delaysMs[attempt]));
      }
    }
    throw lastError ?? StateError('Gemini request failed');
  }

  static GeminiJsonReply parseReply(String rawText) {
    final extracted = _extractJsonObject(rawText);
    if (extracted == null) {
      return GeminiJsonReply(
        replyJp: rawText,
        followUpJp: '',
        memoryNoteJp: '',
        rawText: rawText,
      );
    }
    try {
      final map = jsonDecode(extracted) as Map<String, dynamic>;
      return GeminiJsonReply(
        replyJp: (map['reply_jp'] ?? map['replyJp'] ?? '').toString(),
        followUpJp: (map['follow_up_jp'] ?? map['followUpJp'] ?? '').toString(),
        memoryNoteJp: (map['memory_note_jp'] ?? map['memoryNoteJp'] ?? '')
            .toString(),
        rawText: rawText,
      );
    } catch (_) {
      return GeminiJsonReply(
        replyJp: rawText,
        followUpJp: '',
        memoryNoteJp: '',
        rawText: rawText,
      );
    }
  }

  static String? _extractJsonObject(String text) {
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final match = fence.firstMatch(text);
    final candidate = (match?.group(1) ?? text).trim();
    final start = candidate.indexOf('{');
    final end = candidate.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return candidate.substring(start, end + 1);
  }
}
