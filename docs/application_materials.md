# SilverLink Application Materials

## English

**Project name:** SilverLink Ambient Agent

**One-line pitch:** An ambient AI guardian for Japan's aging society that senses unspoken needs through privacy-preserving semantic signals.

**Description:**  
As a 19-year IT management veteran in Tokyo, I have seen how traditional reactive apps often fail elderly users: they still require the user to notice, open, type, and navigate. SilverLink explores a different model: an AI-native, Zero-UI guardian powered by Gemini, designed around ambient intelligence rather than menus.

For the MVP, we demonstrate a Matter-compatible edge privacy architecture through semantic event tokens such as missed medication, low activity, long silence, and loneliness signals. Raw video and audio are not part of the demo flow; the app sends only local, privacy-preserving semantic tokens into Gemini's reasoning loop. Gemini then follows an Observe-Reason-Decide pattern and responds in gentle natural Japanese, avoiding commands and medical diagnosis.

SilverLink shows how Gemini can move from a reactive tool to a proactive life guardian for social welfare DX in Japan: respectful, quiet, emotionally aware, and designed for people who should not have to learn another app.

## Japanese

**プロジェクト名:** SilverLink Ambient Agent

**一行ピッチ:** 日本の超高齢社会に向けた、言葉にならない不安をプライバシー保護型の意味信号から察知する環境知能エージェント。

**説明:**  
私は東京で19年にわたりITマネジメントに携わる中で、高齢者向けの従来型アプリの限界を感じてきました。多くのアプリは、利用者が自分で気づき、開き、入力し、操作することを前提にしています。しかし本当に支援が必要な瞬間ほど、その操作自体が負担になります。

SilverLinkは、メニュー操作を前提にしないZero-UIの見守りエージェントです。MVPでは、Matter互換のエッジプライバシー構成を、服薬忘れ、活動量低下、長い静けさ、孤独の兆しといった意味トークンでデモします。原始映像や原始音声ではなく、ローカルで意味化されたトークンだけをGeminiの推論ループに渡します。

GeminiはObserve-Reason-Decideの流れで状況を判断し、命令や診断ではなく、自然な敬語でそっと声をかけます。SilverLinkは、AIを「使う道具」から「そばにいる生活の守り手」へ変える、日本の社会福祉DXのための提案です。

## Technical Blueprint

| Layer | Choice | MVP implementation |
| --- | --- | --- |
| Sensory | Matter & Thread compatible edge gateway | Mocked semantic event tokens via Scenario Injector |
| Cognitive | Gemini stable API + Gemini Live experimental track | Stable `generateContent` path for demo, Live probe behind a settings toggle |
| Interaction | Flutter Zero-UI + Google Chirp 3 HD TTS | Pulsing ambient sphere, warm natural Japanese voice, image, hidden debug injector |
| Memory | Baseline memory | SharedPreferences transcript and memory notes |
| Privacy | Edge semantic processing | No raw sensor feed in scenario demo, only semantic tokens |

## 8-hour Implementation Story

1. Establish the Flutter Zero-UI shell with a single ambient orb.
2. Integrate Gemini multimodal image understanding for medication and documents.
3. Add Japanese natural-keigo system instruction and non-medical safety boundaries.
4. Add Matter-compatible semantic token injection for proactive scenarios.
5. Add Google Cloud Text-to-Speech Chirp 3 HD output for a warmer, more human demo voice.
6. Add Gemini Live experimental connection probe without blocking the stable demo path.
7. Prepare iOS-first demo script, review report, and bilingual application copy.

## Q&A Defense

**Privacy:**  
SilverLink's architecture assumes an edge gateway that converts sensor data into semantic tokens locally. The MVP demonstrates this by sending only tokens such as `medication_missed` or `low_activity` to Gemini, not raw video or raw audio.

**Difference from companion bots:**  
Companion bots solve conversation. SilverLink focuses on responsibility: it observes ambient life patterns, reasons against a baseline, and decides whether to stay quiet or gently check in.

**8-hour feasibility:**  
The implementation prioritizes the core reasoning loop: semantic event → Gemini reasoning → respectful Japanese response → ambient orb feedback. Distributed IoT is mocked behind a standard token interface to prove the commercial architecture without overbuilding hardware integration.
