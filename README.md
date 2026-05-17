# SilverLink Ambient Agent

Flutter/iOS-first prototype for **SilverLink**, an **Ambient Family Intelligence** layer for Japan's aging society. The demo shows the safest executable slice: one calm orb, Gemini multimodal medicine/document understanding, Matter-style semantic event injection, warm Japanese voice, local baseline memory, and a family/pharmacist handoff memo.

## Judge Quick Start

**Best Luma 2-minute solo path**

1. Run `flutter run` or launch the iOS build.
2. Open with: "SilverLink is Ambient Family Intelligence, not another senior app."
3. Tap **見る** → **デモ画像（同梱プレースホルダー）** and show Gemini vision + structured medicine card.
4. Trigger **温柔音声を試す** if configured to show Google Cloud Text-to-Speech / Chirp 3 HD voice quality.
5. Show **家族・薬剤師への交接メモ** and tap the copy icon.
6. Long-press the orb → **Scenario Injector** → **服薬サインなし**.
7. Say: "The proactive demo sends semantic tokens, not raw sensor streams."
8. Close on the footer disclaimer: SilverLink supports understanding and handoff; it does not diagnose or change dosage.

The demo has local fixtures, so the medicine card and Scenario Injector still work when API keys or network are unavailable. With valid Google Cloud/Gemini credentials, the same flow shows Gemini stable generation for image/text reasoning and Google Cloud Text-to-Speech for warmer Japanese voice. The Gemini Live item is an experimental probe and future realtime direction, not the guaranteed stage voice loop.

For a judge-facing one-page summary, see [docs/judge_brief.md](docs/judge_brief.md).
For Luma event constraints and solo strategy, see [docs/luma_event_solo_alignment.md](docs/luma_event_solo_alignment.md).

## Prerequisites

- Flutter SDK（channel stable）
- [Google AI Studio](https://aistudio.google.com/) の API Key（Gemini）

## Configure API key

変数名は [.env.example](.env.example) と同一です（`GEMINI_API_KEY` / `GEMINI_MODEL` / `GOOGLE_TTS_API_KEY` / `GOOGLE_TTS_VOICE`）。キーをリポジトリにコミットしないでください。Gemini Live 実験プローブと Google Chirp 3 HD 音声はアプリ内設定から有効化できます。

**Option A — dart-define（推荐用于本地 / CI）**

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=YOUR_KEY \
  --dart-define=GEMINI_MODEL=gemini-2.0-flash \
  --dart-define=GOOGLE_TTS_API_KEY=YOUR_GOOGLE_CLOUD_TTS_KEY \
  --dart-define=GOOGLE_TTS_VOICE=ja-JP-Chirp3-HD-Aoede
```

**Option B — アプリ内設定**

初回起動で設定ダイアログが開きます。右上の「設定」からも変更可能。値は端末の SharedPreferences に保存されます（デモ用途）。文字サイズ（本文・読み上げ対象）と Google Chirp 3 HD voice（推奨: `ja-JP-Chirp3-HD-Aoede`）もここで変更できます。

## Demo script（録画 / レビュー用）

1. `flutter run --dart-define=GEMINI_API_KEY=...` で起動。
2. 冒頭で一言だけ伝える: **"Technology should not replace relationships. It should quietly protect them."**
3. **見る** → 「デモ画像（同梱プレースホルダー）」で API 呼び出し〜 orb 色変化〜 大字の薬品カード〜家族・薬剤師への交接メモ〜読み上げ〜交接メモのコピーまでを見せる。
4. API key 未設定または通信が不安定な場合も、デモ画像と Scenario Injector はローカル fixtures へ自動フォールバックし、大字の薬品カード、交接メモ、温かい応答を維持する。
5. orb を長押しして hidden **Scenario Injector** を開き、`medication_missed` を注入。Matter 互換エッジで意味化されたトークンだけを Gemini に渡す流れを説明。
6. **設定** を開き、文字サイズスライダー、Google Chirp 3 HD 音声、Gemini Live 実験プローブのトグルを見せる。「温柔音声を試す」で声の温度を先に確認する。TTS / Live probe は失敗時に安定トラックへ戻る。
7. （iOS 実機）薬箱の写真を **アルバム / カメラ** から選択し、パッケージ文字の読み取り補助と注意書きを説明。
8. （iOS 実機）**話す** で短文の日本語を話し、記憶に基づく追質問があれば「記一记」ストーリーを説明。
9. フッターの非診療ディスクレーマーを指し、医学判断は行わないことを宣言。

## Run / Test

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Notes / 非診療

アプリは医療機器ではありません。出力は補助情報であり、服薬・処置の判断は医師・薬剤師に任せてください。

## Docs

产品叙事与技术叙述见 [docs/solutions.md](docs/solutions.md)。该文档描述当前 Flutter/iOS MVP，不把路线图能力写成已实现能力。

- Application copy: [docs/application_materials.md](docs/application_materials.md)
- Judge brief: [docs/judge_brief.md](docs/judge_brief.md)
- Luma solo event alignment: [docs/luma_event_solo_alignment.md](docs/luma_event_solo_alignment.md)
- Narrative architecture: [docs/narrative_architecture.md](docs/narrative_architecture.md)
- Review notes: [docs/review_report.md](docs/review_report.md)
- Hackathon demo alignment: [docs/hackathon_demo_alignment.md](docs/hackathon_demo_alignment.md)
