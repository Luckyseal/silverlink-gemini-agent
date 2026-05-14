# SilverLink Application Materials

## English

**Project name:** SilverLink Ambient Agent

**One-line pitch:** An ambient family intelligence layer that quietly notices changes in an older adult's daily rhythm and turns uncertainty into warm support and human handoff.

**Description:**  
As a 19-year IT management veteran in Tokyo, I have seen how traditional reactive apps often fail older adults and their families: they still require the user to notice, open, type, and navigate. SilverLink explores a different model: Ambient Family Intelligence powered by Gemini, designed around quiet presence rather than menus.

For the MVP, we demonstrate the safest executable slice of this future: medicine photo understanding, semantic event tokens such as missed medication or low activity, a warm Japanese voice, and a family/pharmacist handoff memo. Raw video and audio are not part of the proactive scenario demo flow; the app sends privacy-preserving semantic tokens into Gemini's reasoning loop. Gemini then follows an Observe-Reason-Decide pattern and responds in gentle natural Japanese, avoiding commands, monitoring language, and medical diagnosis.

SilverLink shows how Gemini can move from a reactive tool to a quiet relationship layer for social welfare DX in Japan. Technology should not replace relationships. It should quietly protect them.

## Japanese

**プロジェクト名:** SilverLink Ambient Agent

**一行ピッチ:** 高齢者の日々のリズムの小さな変化をそっと察知し、不確かさを温かな支援と人への引き継ぎに変える Ambient Family Intelligence。

**説明:**  
私は東京で19年にわたりITマネジメントに携わる中で、高齢者と家族をつなぐ従来型アプリの限界を感じてきました。多くのアプリは、利用者が自分で気づき、開き、入力し、操作することを前提にしています。しかし本当に支援が必要な瞬間ほど、その操作自体が負担になります。

SilverLinkは、メニュー操作を前提にしない静かな家族のプレゼンス層です。MVPでは、Matter互換のエッジプライバシー構成を、服薬忘れ、活動量低下、長い静けさ、孤独の兆しといった意味トークンでデモします。原始映像や原始音声ではなく、ローカルで意味化されたトークンだけをGeminiの推論ループに渡します。

GeminiはObserve-Reason-Decideの流れで状況を判断し、命令や診断ではなく、自然な敬語でそっと声をかけます。さらに不確かな点を家族・薬剤師へ渡すメモに変換します。SilverLinkは、AIを「使う道具」から「関係性を静かに守る層」へ変える、日本の社会福祉DXのための提案です。

## Technical Blueprint

| Layer | Choice | MVP implementation |
| --- | --- | --- |
| Sensory | Matter & Thread compatible edge gateway | Mocked semantic event tokens via Scenario Injector |
| Cognitive | Gemini stable API + Gemini Live experimental track | Stable `generateContent` path for demo, Live probe behind a settings toggle |
| Interaction | Flutter Zero-UI + Google Chirp 3 HD TTS | Pulsing ambient sphere, warm natural Japanese voice, medicine card, handoff memo, hidden debug injector |
| Memory | Baseline memory | SharedPreferences transcript and memory notes |
| Privacy | Edge semantic processing | No raw sensor feed in scenario demo, only semantic tokens |

## 8-hour Implementation Story

1. Establish the Flutter Zero-UI shell with a single ambient orb.
2. Integrate Gemini multimodal image understanding for medication and documents.
3. Add Japanese natural-keigo system instruction and non-medical safety boundaries.
4. Add Matter-compatible semantic token injection for proactive scenarios.
5. Add Google Cloud Text-to-Speech Chirp 3 HD output for a warmer, more human demo voice.
6. Add structured medicine cards and family/pharmacist handoff memos to show responsible escalation.
7. Add Gemini Live experimental connection probe without blocking the stable demo path.
8. Prepare iOS-first demo script, review report, and bilingual application copy.

## Q&A Defense

**Privacy:**  
SilverLink's architecture assumes an edge gateway that converts sensor data into semantic tokens locally. The MVP demonstrates this by sending only tokens such as `medication_missed` or `low_activity` to Gemini, not raw video or raw audio.

**Difference from companion bots:**  
Companion bots solve conversation. SilverLink focuses on responsibility: it observes ambient life patterns, reasons against a baseline, and decides whether to stay quiet or gently check in.

**8-hour feasibility:**  
The implementation prioritizes the core reasoning loop: semantic event → Gemini reasoning → respectful Japanese response → medicine card / handoff memo → ambient orb feedback. Distributed IoT is mocked behind a standard token interface to prove the commercial architecture without overbuilding hardware integration.
