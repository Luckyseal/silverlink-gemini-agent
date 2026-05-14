# SilverLink Current Solution

## Positioning

SilverLink Ambient Agent is an iOS-first Flutter MVP for **Ambient Family Intelligence** in Japan's aging society.

It is not a diagnosis app, a medication reminder, or a replacement for family, doctors, or pharmacists. The demo shows the safest executable slice: Gemini reads a medicine/document image, responds in warm Japanese, turns uncertainty into a copyable family/pharmacist handoff memo, and demonstrates ambient semantic-event reasoning through a mocked Matter-compatible Scenario Injector.

## What Is Implemented

| Layer | Current MVP |
| --- | --- |
| Interface | One-screen ambient orb with large text and minimal controls |
| Vision | Gemini stable `generateContent` path for medicine/document photos |
| Voice | Google Cloud TTS Chirp 3 HD path with device TTS fallback |
| Ambient agent loop | Scenario Injector emits semantic tokens such as `medication_missed` |
| Privacy proof | Proactive scenario sends semantic tokens, not raw sensor streams |
| Memory | Local SharedPreferences transcript and baseline notes |
| Handoff | Medicine card plus copyable family/pharmacist memo |
| Reliability | Local fixtures keep the image and scenario demo alive when API keys or network are unavailable |

## Demo Claim

Use this sentence:

> We built the safest executable slice of an ambient family agent: seeing, explaining, remembering, and knowing when to hand off.

Avoid claiming that SilverLink has fully implemented medical reasoning, Matter/Thread hardware, Cloud Run deployment, or realtime Gemini Live voice. Gemini Live is represented as an experimental probe and future realtime track; the stable stage path is Gemini generation plus TTS.

## Why It Fits Gemini

- Gemini multimodal understanding turns medicine boxes and documents into readable support.
- Prompted Observe-Reason-Decide logic interprets semantic ambient tokens against a lightweight baseline.
- Structured JSON output becomes a large-text medicine card and a human handoff memo.
- The product uses Gemini as a reasoning layer inside an ambient relationship experience, not just as a chatbot.

## Next Delivery Track

1. Add a companion PWA or Cloud Run-hosted review build.
2. Add backend-issued ephemeral tokens for the Gemini Live experimental track.
3. Replace mocked semantic events with a real Matter/Thread gateway.
4. Add share/export channels beyond the implemented copy action.
5. Evaluate a future medical/privacy reasoning layer without making dosage or diagnosis decisions.
