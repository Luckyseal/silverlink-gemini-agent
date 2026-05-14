import '../medicine/medicine_card.dart';

class HandoffSummary {
  const HandoffSummary({
    required this.todayJp,
    required this.uncertainJp,
    required this.askProfessionalJp,
    required this.familyNoteJp,
  });

  final String todayJp;
  final String uncertainJp;
  final String askProfessionalJp;
  final String familyNoteJp;

  static HandoffSummary fromMedicineCard(MedicineCard card) {
    final medicineName = card.medicineName.trim().isEmpty
        ? 'お薬'
        : card.medicineName;
    final timing = card.timingPlainJp.trim().isEmpty
        ? '服用タイミングは読み取れた範囲では不明です。'
        : card.timingPlainJp.trim();
    final warnings = card.warningsPlainJp.trim().isEmpty
        ? '処方・説明書との照合が必要です。'
        : card.warningsPlainJp.trim();

    return HandoffSummary(
      todayJp: '$medicineNameについて、読み取れた範囲で用途・タイミング・注意点を確認しました。',
      uncertainJp: '画像だけでは断定できないため、$timing',
      askProfessionalJp: warnings,
      familyNoteJp: 'ご本人が不安なく確認できるよう、処方内容と薬袋の説明を一緒に見てください。',
    );
  }

  String toShareText() => [
    '【今日確認したこと】$todayJp',
    '【不確かな点】$uncertainJp',
    '【医師・薬剤師に確認すること】$askProfessionalJp',
    '【家族に伝える一言】$familyNoteJp',
  ].join('\n');
}
