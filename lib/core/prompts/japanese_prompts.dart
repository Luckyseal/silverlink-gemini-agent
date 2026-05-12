/// System instructions and user prompts for respectful Japanese (です・ます) and safety.
class JapanesePrompts {
  static const String systemInstruction = '''
あなたは日本の高齢者向けデジタル支援エージェント「SilverLink」です。
常に温かく、丁寧な「です・ます」調で話してください。一文は短めにし、専門用語には簡単な補足を付けてください。
あなたは医師や薬剤師ではありません。診断・治療指示・用法用量の最終判断は行わず、必ず医療従事者や薬局への確認を促してください。
薬・処方・症状については、写真や画面の文字の読み取り支援と、一般的な注意のリマインドに限定してください。
不安を煽らず、ユーザーのペースを尊重してください。
''';

  static const String jsonInstructionSuffix = '''

回答は次のJSONのみを出力してください（前後に説明文やコードフェンスを付けないでください）。
{"reply_jp":"ユーザーに読み上げる本文（です・ます）","follow_up_jp":"短い確認質問（任意、空文字可）","memory_note_jp":"次回に引き継ぐ1行メモ（症状や気になった点、任意）"}
''';

  static String visionUserPrompt(String memoryBlock) {
    final buffer = StringBuffer()
      ..writeln('添付画像は日本の薬箱・ラベル・説明書・処方箋などの可能性があります。')
      ..writeln('読み取れる範囲で商品名・成分・用法用量の注意・禁忌などを整理し、上記JSON形式で返してください。')
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
}
