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
    final isChirp3Hd = voiceName.contains('Chirp3-HD');
    return {
      'input': isChirp3Hd
          ? {'markup': toWarmMarkup(text)}
          : {'ssml': toSeniorFriendlySsml(text)},
      'voice': {'languageCode': 'ja-JP', 'name': voiceName},
      'audioConfig': isChirp3Hd
          ? {
              'audioEncoding': 'MP3',
              'speakingRate': 0.78,
              'pitch': -0.5,
              'volumeGainDb': 0.0,
            }
          : {
              'audioEncoding': 'MP3',
              'speakingRate': 1.0,
              'pitch': -2.5,
              'volumeGainDb': 3.5,
              'effectsProfileId': ['small-bluetooth-speaker-class-device'],
            },
    };
  }

  static String toSeniorFriendlySsml(String text) {
    final body = _normalize(text);
    if (body.isEmpty) return '<speak></speak>';
    return '<speak><prosody rate="82%" pitch="-2st" volume="loud">${_toSeniorBreaks(_escapeSsml(body))}</prosody></speak>';
  }

  static String toWarmMarkup(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) return '';
    return normalized
        .replaceAll('。', '。[pause long] ')
        .replaceAll('、', '、[pause short] ')
        .replaceAll('？', '？[pause long] ')
        .replaceAll('?', '？[pause long] ')
        .replaceAll('！', '！[pause long] ')
        .replaceAll('!', '！[pause long] ')
        .trim();
  }

  static String _normalize(String text) {
    return text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _escapeSsml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _toSeniorBreaks(String text) {
    return text
        .replaceAll('。', '。<break time="650ms"/>')
        .replaceAll('、', '、<break time="320ms"/>')
        .replaceAll('？', '？<break time="650ms"/>')
        .replaceAll('?', '？<break time="650ms"/>')
        .replaceAll('！', '！<break time="650ms"/>')
        .replaceAll('!', '！<break time="650ms"/>')
        .trim();
  }

  void dispose() {
    _client.close();
    _player.dispose();
  }
}
