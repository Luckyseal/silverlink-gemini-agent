import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class GoogleCloudTtsService {
  GoogleCloudTtsService({
    required String credential,
    required String voiceName,
    http.Client? client,
    AudioPlayer? player,
  }) : _credential = credential,
       _voiceName = voiceName,
       _client = client ?? http.Client(),
       _player = player ?? AudioPlayer();

  static final Uri _endpoint = Uri.parse(
    'https://texttospeech.googleapis.com/v1beta1/text:synthesize',
  );

  final String _credential;
  final String _voiceName;
  final http.Client _client;
  final AudioPlayer _player;

  Future<void> speakWarmly(String text) async {
    final audioBytes = await synthesizeWarmVoice(text);
    await _player.play(BytesSource(audioBytes), mode: PlayerMode.mediaPlayer);
    await _player.onPlayerComplete.first.timeout(
      const Duration(seconds: 45),
      onTimeout: () {},
    );
  }

  Future<Uint8List> synthesizeWarmVoice(String text) async {
    final response = await _client.post(
      _requestUri(),
      headers: _headers(),
      body: jsonEncode(buildWarmJapaneseRequest(text, voiceName: _voiceName)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Google TTS failed: ${response.statusCode} ${response.body}',
      );
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final audioContent = payload['audioContent']?.toString();
    if (audioContent == null || audioContent.isEmpty) {
      throw StateError('Google TTS returned empty audioContent');
    }
    return base64Decode(audioContent);
  }

  Uri _requestUri() {
    if (_usesBearerToken) return _endpoint;
    return _endpoint.replace(queryParameters: {'key': _credential});
  }

  Map<String, String> _headers() {
    final headers = {'content-type': 'application/json; charset=utf-8'};
    if (_usesBearerToken) {
      headers['authorization'] = _credential.startsWith('Bearer ')
          ? _credential
          : 'Bearer $_credential';
    }
    return headers;
  }

  bool get _usesBearerToken =>
      _credential.startsWith('Bearer ') || _credential.startsWith('ya29.');

  static Map<String, dynamic> buildWarmJapaneseRequest(
    String text, {
    required String voiceName,
  }) {
    return {
      'input': {
        'markup': toWarmMarkup(text),
        'prompt':
            'Speak in natural Japanese keigo with a warm, gentle, emotionally present tone. '
            'Sound like a kind late-night diner owner speaking softly to an elderly neighbor. '
            'Avoid a cold announcer voice.',
      },
      'voice': {'languageCode': 'ja-JP', 'name': voiceName},
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': 0.88,
        'pitch': -1.0,
        'volumeGainDb': 0.0,
        'effectsProfileId': ['handset-class-device'],
      },
    };
  }

  static String toWarmMarkup(String text) {
    final normalized = text
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return '';
    return normalized
        .replaceAll('。', '。[pause short] ')
        .replaceAll('、', '、[pause short] ')
        .replaceAll('？', '？[pause short] ')
        .replaceAll('?', '？[pause short] ')
        .replaceAll('！', '。[pause short] ')
        .replaceAll('!', '。[pause short] ')
        .trim();
  }

  void dispose() {
    _client.close();
    _player.dispose();
  }
}
