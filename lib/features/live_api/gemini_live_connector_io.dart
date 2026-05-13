import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'live_probe_result.dart';

class GeminiLiveConnector {
  GeminiLiveConnector({required String apiKey, required String model})
    : _apiKey = apiKey,
      _model = model;

  static final Uri _endpoint = Uri.parse(
    'wss://generativelanguage.googleapis.com/ws/'
    'google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
  );

  final String _apiKey;
  final String _model;

  Future<LiveProbeResult> probe({
    required String systemInstruction,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    WebSocket? socket;
    try {
      final uri = _endpoint.replace(queryParameters: {'key': _apiKey});
      socket = await WebSocket.connect(uri.toString()).timeout(timeout);
      socket.add(
        jsonEncode({
          'setup': {
            'model': 'models/$_model',
            'generationConfig': {
              'responseModalities': ['AUDIO'],
            },
            'systemInstruction': {
              'parts': [
                {'text': systemInstruction},
              ],
            },
            'tools': [
              {
                'functionDeclarations': [
                  {
                    'name': 'record_semantic_signal',
                    'description':
                        'Records a Matter-compatible semantic event token.',
                    'parameters': {
                      'type': 'object',
                      'properties': {
                        'event': {'type': 'string'},
                        'severity': {'type': 'string'},
                      },
                    },
                  },
                ],
              },
            ],
          },
        }),
      );

      final raw = await socket.first.timeout(timeout);
      return LiveProbeResult.connected(raw.toString());
    } catch (e) {
      return LiveProbeResult.failed('Gemini Live probe failed: $e');
    } finally {
      await socket?.close();
    }
  }
}
