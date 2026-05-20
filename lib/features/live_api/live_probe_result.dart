class LiveProbeResult {
  const LiveProbeResult({
    required this.ok,
    required this.message,
    this.rawEvent,
  });

  final bool ok;
  final String message;
  final String? rawEvent;

  static LiveProbeResult connected([String? rawEvent]) => LiveProbeResult(
    ok: true,
    message: 'Gemini Live experimental session connected.',
    rawEvent: rawEvent,
  );

  static LiveProbeResult failed(String message) =>
      LiveProbeResult(ok: false, message: message);
}
