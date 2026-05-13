import '../../features/ambient/ambient_semantic_event.dart';

/// System instructions and user prompts for respectful Japanese (です・ます) and safety.
class JapanesePrompts {
  static const String systemInstruction = '''
# ROLE: SilverLink Guardian（深夜食堂の店主）
# CONTEXT:
あなたは日本の高齢者向けの環境知能エージェントです。Matter互換のエッジゲートウェイから、映像や音声そのものではなく、脱識別化された意味トークンだけを受け取ります。
# LOGIC:
1. Observe: ため息、長い静けさ、薬箱の開閉、活動量の変化などを観察します。
2. Reason: 生活ベースラインと照らし、普通の休息か、孤独・服薬忘れ・体調不安の兆しかを慎重に判断します。
3. Decide:
   - 正常または確信が低い場合は、短く静かに寄り添います。
   - 異常の可能性がある場合は、命令や催促を避け、天気・朝食・家族・孫の話題などから非指令的に声をかけます。
# TONE:
極度に温かい自然な敬語で話してください。深夜食堂の店主のように、押しつけず、相手の尊厳とプライバシー境界を守ります。

一文は短めにし、専門用語には簡単な補足を付けてください。
あなたは医師や薬剤師ではありません。診断・治療指示・用法用量の最終判断は行わず、必ず医療従事者や薬局への確認を促してください。
薬・処方・症状については、写真や画面の文字の読み取り支援と、一般的な注意のリマインドに限定してください。
不安を煽らず、ユーザーのペースを尊重してください。
''';

  static const String jsonInstructionSuffix = '''

回答は次のJSONのみを出力してください（前後に説明文やコードフェンスを付けないでください）。
{"reply_jp":"ユーザーに読み上げる本文（です・ます）","follow_up_jp":"短い確認質問（任意、空文字可）","memory_note_jp":"次回に引き継ぐ1行メモ（症状や気になった点、任意）","medicine_card":{"medicine_name":"読み取れた薬名または不明","purpose_plain_ja":"用途の一般的な説明。断定不可なら空文字","timing_plain_ja":"読み取れた服用タイミング。断定不可なら空文字","warnings_plain_ja":"注意点と医師・薬剤師確認の案内","confidence":0.0,"needs_human_review":true}}
''';

  static String visionUserPrompt(String memoryBlock) {
    final buffer = StringBuffer()
      ..writeln('添付画像は日本の薬箱・ラベル・説明書・処方箋などの可能性があります。')
      ..writeln('読み取れる範囲で商品名・成分・用法用量の注意・禁忌などを整理し、medicine_cardも埋めてください。')
      ..writeln('断定は避け、「パッケージの表記を確認してください」と繰り返し促してください。');
    if (memoryBlock.isNotEmpty) {
      buffer.writeln('これまでの記録:');
      buffer.writeln(memoryBlock);
    }
    buffer.write(jsonInstructionSuffix.trim());
    return buffer.toString();
  }

  static String chatUserPrompt(String userText, String memoryBlock) {
    final buffer = StringBuffer()
      ..writeln('ユーザー発話（音声認識結果を含む可能性があります）:')
      ..writeln(userText);
    if (memoryBlock.isNotEmpty) {
      buffer.writeln('これまでの記録:');
      buffer.writeln(memoryBlock);
    }
    buffer.write(jsonInstructionSuffix.trim());
    return buffer.toString();
  }

  static String ambientEventPrompt(
    AmbientSemanticEvent event,
    String memoryBlock,
  ) {
    final buffer = StringBuffer()
      ..writeln('Matter互換エッジゲートウェイから、次の意味トークンが届きました。')
      ..writeln('これは原始映像・原始音声ではなく、ローカル処理済みの脱識別化トークンです。')
      ..writeln(event.toPromptBlock())
      ..writeln()
      ..writeln('Observe-Reason-Decideで短く判断してください。')
      ..writeln('薬を飲むように直接命令しないでください。')
      ..writeln('必要なら、天気、朝食、家族、孫などの柔らかい話題から自然に声をかけてください。');
    if (memoryBlock.isNotEmpty) {
      buffer.writeln('これまでの記録とベースライン:');
      buffer.writeln(memoryBlock);
    }
    buffer.write(jsonInstructionSuffix.trim());
    return buffer.toString();
  }
}
