class MedicineCard {
  const MedicineCard({
    required this.medicineName,
    required this.purposePlainJp,
    required this.timingPlainJp,
    required this.warningsPlainJp,
    required this.confidence,
    required this.needsHumanReview,
  });

  final String medicineName;
  final String purposePlainJp;
  final String timingPlainJp;
  final String warningsPlainJp;
  final double confidence;
  final bool needsHumanReview;

  bool get hasContent =>
      medicineName.trim().isNotEmpty ||
      purposePlainJp.trim().isNotEmpty ||
      timingPlainJp.trim().isNotEmpty ||
      warningsPlainJp.trim().isNotEmpty;

  static MedicineCard? fromJson(Map<String, dynamic> json) {
    final cardJson = json['medicine_card'] ?? json['medicineCard'];
    final source = cardJson is Map<String, dynamic> ? cardJson : json;
    final card = MedicineCard(
      medicineName: (source['medicine_name'] ?? source['medicineName'] ?? '')
          .toString(),
      purposePlainJp:
          (source['purpose_plain_ja'] ?? source['purposePlainJa'] ?? '')
              .toString(),
      timingPlainJp:
          (source['timing_plain_ja'] ?? source['timingPlainJa'] ?? '')
              .toString(),
      warningsPlainJp:
          (source['warnings_plain_ja'] ?? source['warningsPlainJa'] ?? '')
              .toString(),
      confidence: _parseConfidence(source['confidence']),
      needsHumanReview: _parseBool(
        source['needs_human_review'] ?? source['needsHumanReview'],
      ),
    );
    if (!card.hasContent) return null;
    return card;
  }

  Map<String, dynamic> toJson() => {
    'medicine_name': medicineName,
    'purpose_plain_ja': purposePlainJp,
    'timing_plain_ja': timingPlainJp,
    'warnings_plain_ja': warningsPlainJp,
    'confidence': confidence,
    'needs_human_review': needsHumanReview,
  };

  static double _parseConfidence(Object? value) {
    if (value is num) return value.toDouble().clamp(0, 1);
    return double.tryParse(value?.toString() ?? '')?.clamp(0, 1) ?? 0;
  }

  static bool _parseBool(Object? value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }
}
