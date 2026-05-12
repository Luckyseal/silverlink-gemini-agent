# SilverLink Gemini Agent

Flutter prototype for **SilverLink**（银发族数字助手）：单页「Live orb」UI + Gemini 多模态（药盒/文书照片）+ 日语敬语 system prompt + 会话记忆（SharedPreferences）+ 日语 TTS / STT。

## Prerequisites

- Flutter SDK（channel stable）
- [Google AI Studio](https://aistudio.google.com/) の API Key（Gemini）

## Configure API key

変数名は [.env.example](.env.example) と同一です（`GEMINI_API_KEY` / `GEMINI_MODEL`）。キーをリポジトリにコミットしないでください。

**Option A — dart-define（推荐用于本地 / CI）**

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY --dart-define=GEMINI_MODEL=gemini-2.0-flash
```

**Option B — アプリ内設定**

初回起動で設定ダイアログが開きます。右上の「設定」からも変更可能。値は端末の SharedPreferences に保存されます（デモ用途）。文字サイズ（本文・読み上げ対象）もここで変更できます。

## Demo script（録画 / レビュー用）

1. `flutter run --dart-define=GEMINI_API_KEY=...` で起動。
2. **見る** → 「デモ画像（同梱プレースホルダー）」で API 呼び出し〜 orb 色変化〜 JSON 応答の読み上げまでを見せる。
3. **設定** を開き、文字サイズスライダーを動かして高齢向け表示をアピール。
4. （実機）薬箱の写真を **アルバム / カメラ** から選択し、パッケージ文字の読み取り補助と注意書きを説明。
5. （実機）**話す** で短文の日本語を話し、記憶に基づく追質問があれば「記一记」ストーリーを説明。
6. フッターの非診療ディスクレーマーを指し、医学判断は行わないことを宣言。

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

产品叙事与技术叙述见 [docs/solutions.md](docs/solutions.md)。
