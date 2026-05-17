# SilverLink Judge Brief

## One-line Pitch

SilverLink is an ambient family intelligence layer that quietly notices changes in an older adult's daily rhythm and turns uncertainty into warm support and human handoff.

## What

SilverLink is a Flutter/iOS-first Gemini demo for Japan's aging society. It reduces the interface to one calm orb, then demonstrates three executable loops:

1. Medicine/document photo -> Gemini multimodal understanding -> large-text medicine card.
2. Medicine uncertainty -> copyable family/pharmacist handoff memo.
3. Matter-style semantic event token -> Gemini reasoning -> gentle Japanese check-in.

The product position is **Ambient Family Intelligence**, not an elderly monitoring app and not a medication reminder.

## Why

Older adults and families often miss small changes before they become larger worries: an unopened medicine box, a quieter room, lower activity, or a lonely evening. Traditional apps wait for the user to open and operate them. SilverLink explores a quieter model: the agent notices context, speaks gently, and hands uncertainty back to humans.

The core sentence for the demo:

> Technology should not replace relationships. It should quietly protect them.

## How It Uses Gemini

| Capability | Demo proof |
| --- | --- |
| Multimodal understanding | Gemini reads medicine/document images and returns structured JSON. |
| Reasoning loop | Prompts follow Observe-Reason-Decide for ambient events. |
| Structured output | Gemini output becomes a medicine card and handoff memo. |
| Context and memory | Local baseline notes are included in future prompts. |
| Realtime direction | Gemini Live is represented as an experimental probe, while the stable stage path uses Gemini generation plus TTS. |

## 90-second Demo Path

1. Open the app and show the single orb.
2. Tap **見る** and select **デモ画像（同梱プレースホルダー）**.
3. Show the large medicine card and warm Japanese response.
4. Show the **家族・薬剤師への交接メモ** and tap the copy icon.
5. Long-press the orb, open **Scenario Injector**, and inject **服薬サインなし**.
6. Explain that the proactive flow sends semantic tokens such as `medication_missed`, not raw sensor feeds.
7. Point to the disclaimer and state that SilverLink supports understanding and handoff, not diagnosis or dosage changes.

## What Is Mocked

| Area | Current MVP boundary |
| --- | --- |
| Matter/Thread | Mocked through Scenario Injector semantic tokens. |
| Raw sensor privacy | Proactive demo sends only semantic tokens, not raw video/audio. |
| Gemini Live | Experimental connection probe only; not the main voice loop. |
| Backend/Cloud Run | Not deployed in this repo; future delivery track. |
| Medical reasoning | No diagnosis, prescription, or dosage decision. Human review is required. |

## Reliability

The demo is designed to survive weak network or missing credentials:

- Without a Gemini API key, the demo image path falls back to local medicine fixtures.
- Without a Gemini API key, Scenario Injector falls back to local ambient replies.
- If Google Cloud TTS fails, device TTS keeps the flow alive.
- Gemini Live is optional and never blocks the main demo.

## Judge-safe Claim

Use:

> We built the safest executable slice of an ambient family agent: seeing, explaining, remembering, and knowing when to hand off.

Avoid:

- "SilverLink diagnoses illness."
- "SilverLink gives medication dosage advice."
- "Matter/Thread hardware is physically integrated."
- "Gemini Live realtime voice is fully implemented."
- "This repo is Cloud Run deployed."

## Why It Can Win

The strongest point is restraint. The demo does not try to be a full healthcare platform. It shows one memorable, responsible moment: Gemini understands the real world, SilverLink speaks with warmth, and uncertainty becomes a human handoff artifact instead of an AI decision.
