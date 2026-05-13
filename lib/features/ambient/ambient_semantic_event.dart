enum AmbientEventType {
  medicationMissed,
  longSilence,
  lowActivity,
  lonelinessSignal,
}

class AmbientSemanticEvent {
  const AmbientSemanticEvent({
    required this.type,
    required this.severity,
    required this.source,
    required this.observationJp,
    required this.baselineDeltaJp,
    required this.careHintJp,
  });

  final AmbientEventType type;
  final String severity;
  final String source;
  final String observationJp;
  final String baselineDeltaJp;
  final String careHintJp;

  String get eventName => switch (type) {
    AmbientEventType.medicationMissed => 'medication_missed',
    AmbientEventType.longSilence => 'long_silence',
    AmbientEventType.lowActivity => 'low_activity',
    AmbientEventType.lonelinessSignal => 'loneliness_signal',
  };

  String get labelJp => switch (type) {
    AmbientEventType.medicationMissed => '服薬サインなし',
    AmbientEventType.longSilence => '長い静けさ',
    AmbientEventType.lowActivity => '活動量の低下',
    AmbientEventType.lonelinessSignal => '寂しさの兆し',
  };

  Map<String, String> toSemanticToken() => {
    'event': eventName,
    'severity': severity,
    'source': source,
    'observation_jp': observationJp,
    'baseline_delta_jp': baselineDeltaJp,
    'care_hint_jp': careHintJp,
    'privacy_mode': 'edge_semantic_token_only',
  };

  String toPromptBlock() {
    final token = toSemanticToken();
    return token.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  static List<AmbientSemanticEvent> demoEvents() => const [
    AmbientSemanticEvent(
      type: AmbientEventType.medicationMissed,
      severity: 'medium',
      source: 'matter.medication_box.open_state',
      observationJp: 'いつもの朝の時間帯に薬箱が開いた記録がありません。',
      baselineDeltaJp: '普段は午前8時から9時の間に開閉があります。',
      careHintJp: '薬を強く促さず、朝の様子や天気の話から自然に声をかける。',
    ),
    AmbientSemanticEvent(
      type: AmbientEventType.longSilence,
      severity: 'low',
      source: 'matter.room_audio.semantic_activity',
      observationJp: 'リビングで長い静けさが続いています。',
      baselineDeltaJp: '普段は午前中にテレビや会話の小さな音があります。',
      careHintJp: '心配を押しつけず、休めているかを柔らかく確認する。',
    ),
    AmbientSemanticEvent(
      type: AmbientEventType.lowActivity,
      severity: 'medium',
      source: 'matter.motion_sensor.activity_score',
      observationJp: '午前中の移動量がいつもより少ないようです。',
      baselineDeltaJp: '普段の同じ時間帯より動きが少ない状態です。',
      careHintJp: '体調不良と決めつけず、水分や室温の話題で様子を見る。',
    ),
    AmbientSemanticEvent(
      type: AmbientEventType.lonelinessSignal,
      severity: 'medium',
      source: 'matter.voice_affect.semantic_mood',
      observationJp: 'ため息に近い音声パターンと独り言の増加がありました。',
      baselineDeltaJp: '家族との通話がない日の夕方に近い傾向です。',
      careHintJp: '孫や家族の記憶に触れながら、会話のきっかけを作る。',
    ),
  ];
}
