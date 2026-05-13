import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String _kTurnsKey = 'silverlink_conversation_turns_v1';
const int _kMaxTurnChars = 6000;

/// Persists a lightweight transcript for cross-session follow-ups (demo scope).
class ConversationMemory {
  ConversationMemory(this._prefs);

  final SharedPreferences _prefs;

  static Future<ConversationMemory> open() async {
    final prefs = await SharedPreferences.getInstance();
    return ConversationMemory(prefs);
  }

  List<MemoryTurn> loadTurns() {
    final raw = _prefs.getString(_kTurnsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MemoryTurn.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> append({required String role, required String text}) async {
    final turns = loadTurns()
      ..add(MemoryTurn(role: role, text: text, at: DateTime.now().toUtc()));
    while (_serializedLength(turns) > _kMaxTurnChars && turns.length > 2) {
      turns.removeAt(0);
    }
    await _prefs.setString(
      _kTurnsKey,
      jsonEncode(turns.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() => _prefs.remove(_kTurnsKey);

  /// Compact block injected into prompts.
  String compactBlock() {
    final turns = loadTurns();
    if (turns.isEmpty) return '';
    final lines = <String>[];
    for (final t in turns.reversed.take(10).toList().reversed) {
      final prefix = switch (t.role) {
        'user' => '利用者',
        'assistant' => 'SilverLink',
        'ambient' => '環境トークン',
        'baseline' => 'ベースライン',
        _ => '記憶',
      };
      lines.add('$prefix: ${t.text.trim()}');
    }
    return lines.join('\n');
  }

  int _serializedLength(List<MemoryTurn> turns) =>
      jsonEncode(turns.map((e) => e.toJson()).toList()).length;
}

class MemoryTurn {
  MemoryTurn({required this.role, required this.text, required this.at});

  final String role;
  final String text;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    'at': at.toIso8601String(),
  };

  static MemoryTurn fromJson(Map<String, dynamic> json) => MemoryTurn(
    role: json['role'] as String,
    text: json['text'] as String,
    at: DateTime.parse(json['at'] as String),
  );
}
