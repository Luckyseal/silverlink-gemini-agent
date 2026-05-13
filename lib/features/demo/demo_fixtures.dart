import '../ambient/ambient_semantic_event.dart';
import '../medicine/medicine_card.dart';
import '../vision/gemini_multimodal_service.dart';

abstract final class DemoFixtures {
  static GeminiJsonReply medicineImageReply() => GeminiJsonReply(
    replyJp: '拝見しました。画面の文字からは、解熱鎮痛薬の可能性があるお薬として読めます。',
    followUpJp: '処方や薬剤師さんの説明と違うところがないか、一緒に確認しましょう。',
    memoryNoteJp: 'デモ: 薬箱画像から、薬名・タイミング・確認事項を大字カードで案内した。',
    rawText: 'local_demo_fixture:medicine_image',
    medicineCard: const MedicineCard(
      medicineName: 'ロキソニンS（デモ）',
      purposePlainJp: '痛みや発熱をやわらげる目的で使われることがあります。',
      timingPlainJp: '一般には食後など、胃に負担が少ないタイミングで確認されます。',
      warningsPlainJp: '胃の不調、他のお薬との飲み合わせ、処方内容との違いは薬剤師または医師に確認してください。',
      confidence: 0.82,
      needsHumanReview: true,
    ),
  );

  static GeminiJsonReply ambientReply(AmbientSemanticEvent event) {
    final reply = switch (event.type) {
      AmbientEventType.medicationMissed =>
        'おはようございます。今朝は少し静かな朝ですね。お薬箱の様子も、いつもと少し違うようです。',
      AmbientEventType.longSilence =>
        'お部屋がしばらく静かでしたので、少しだけお声がけします。ゆっくり休めていますか。',
      AmbientEventType.lowActivity =>
        '今日は午前中の動きが少なめのようです。無理はなさらず、お水を少し口にされてもよいかもしれません。',
      AmbientEventType.lonelinessSignal =>
        '夕方は少し寂しく感じる時間もありますね。お孫さんのお話、また聞かせていただけますか。',
    };
    final followUp = switch (event.type) {
      AmbientEventType.medicationMissed => '朝のお茶のあとに、いつもの確認だけしてみましょうか。',
      AmbientEventType.longSilence => '寒かったり、少ししんどかったりしませんか。',
      AmbientEventType.lowActivity => 'お部屋の温度は、ちょうどよさそうですか。',
      AmbientEventType.lonelinessSignal => '今日はどんな一日でしたか。',
    };
    return GeminiJsonReply(
      replyJp: reply,
      followUpJp: followUp,
      memoryNoteJp:
          'デモ: ${event.eventName} を semantic token として受け取り、非指令的に声をかけた。',
      rawText: 'local_demo_fixture:${event.eventName}',
    );
  }
}
