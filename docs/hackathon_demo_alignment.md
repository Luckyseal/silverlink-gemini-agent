# Hackathon Demo Alignment

## Positioning

This document maps the award-oriented guidance in `SilverLink Ambient Agent 获奖执行报告.pdf` to the current Flutter/iOS demo.

The PDF is the winning strategy. The repository is the executable demo asset. They do not need to be identical. The goal on stage is to show a stable, emotionally convincing MVP while explaining the larger architecture with clear boundaries.

The competition positioning is **Ambient Family Intelligence**, not "elderly monitoring" or "medication reminder." The medicine flow is the safest demo slice of a larger relationship-presence layer.

## What Is Ready To Demo

| Story beat | Current implementation | Demo wording |
| --- | --- | --- |
| Zero-UI ambient interface | Single-screen Flutter orb | "The interface is intentionally reduced to one living orb." |
| Medicine/document understanding | Image picker + Gemini multimodal call | "The user shows a medicine box or document, and Gemini explains what can be safely read." |
| Warm Japanese response | SilverLink Guardian system instruction | "It speaks in natural keigo and avoids commands." |
| Warm voice | Google Cloud TTS Chirp 3 HD with device TTS fallback | "For the demo, we use a warmer Google voice path; if it fails, the device voice keeps the flow alive." |
| Proactive ambient scenario | Hidden Scenario Injector with semantic tokens and local fallback | "Real sensors are mocked as Matter-compatible semantic tokens to prove the agent loop." |
| Privacy narrative | `edge_semantic_token_only` event payloads | "The demo sends semantic tokens, not raw sensor feeds." |
| Gemini Live direction | Experimental Live connection probe | "Live is represented as a future realtime direction; the stable path is used for the stage demo." |
| Memory/baseline | SharedPreferences transcript and memory notes | "For the MVP, baseline memory is local and lightweight." |
| Safety boundary | Non-medical prompt + disclaimer + copyable handoff memo | "It supports understanding and handoff, not diagnosis or dosage changes." |

## What To Say As Architecture Proof

- Matter/Thread devices are not physically integrated in this MVP. The Scenario Injector stands in for an edge gateway that emits semantic tokens and has a local fallback for stage reliability.
- Gemini Live is not the guaranteed main voice loop. It is shown as an experimental probe and future realtime direction while the reliable demo uses Gemini stable generation plus TTS.
- Google Cloud TTS is used because the emotional quality of the voice matters in eldercare. The fallback is intentional resilience, not a weakness.
- Long-term memory and Cloud Run deployment are roadmap items for the post-hackathon build. Family/pharmacist handoff is represented in the current demo as a structured handoff memo.

## What Not To Overclaim

- Do not say the app diagnoses illness, gives medication dosage advice, or replaces a doctor/pharmacist.
- Do not say raw video/audio never leaves the device for every feature. Say the proactive scenario demo uses semantic tokens, and future production architecture would minimize raw data through edge processing.
- Do not say Gemini Live realtime voice is fully implemented. Say the Live track is experimental and the stable demo path is intentionally conservative.
- Do not say MedGemma is implemented. Say it is a future privacy/medical reasoning layer.
- Do not say the current repo is web-first PWA or Cloud Run deployed. The current executable demo is Flutter/iOS-first.

## 90-second Demo Script

1. Open the app on iOS. Show the single orb.
   - "SilverLink starts without menus. The first interaction is presence, not navigation."
2. Tap **見る** and use the demo image or a medicine box photo.
   - "Gemini reads what it can see and responds in short, respectful Japanese."
3. Open **設定** and tap **温柔音声を試す**.
   - "For elderly users, voice quality is part of trust. We use Google Chirp 3 HD for a warmer voice and fall back safely."
4. Long-press the orb to open **Scenario Injector**.
   - "Here we simulate the edge gateway. It sends only semantic tokens such as `medication_missed`."
5. Inject `服薬サインなし`.
   - "Notice the agent does not command the user to take medicine. It gently opens a conversation."
6. Point to the medicine card and handoff memo.
   - "The agent turns uncertainty into a human handoff artifact instead of pretending to be a doctor."
7. Tap the handoff memo copy button.
   - "This is designed to leave the AI and move back into a family or pharmacist conversation."
8. Point to the disclaimer.
   - "SilverLink is an information and handoff assistant. It knows when to step back."

## 3-minute Pitch

What if the most important family technology for older adults had almost no interface?

This is SilverLink Ambient Agent.

In Japan, the issue is not only that older adults are offline. The deeper issue is that families are farther apart, daily changes are easy to miss, and the last step of digital care is still too hard: reading a medicine box, understanding instructions, remembering yesterday's condition, and knowing when to ask a human.

SilverLink reduces that burden to one calm ambient interface. The user can show a medicine box, speak naturally, or simply be supported by semantic signals from the environment.

In this MVP, we demonstrate three loops.

First, Gemini sees and explains medicine or document photos in respectful Japanese.

Second, SilverLink speaks back with a warmer Google Cloud Text-to-Speech voice, because emotional tone is not decoration in eldercare. It is trust.

Third, we simulate a Matter-compatible edge gateway. Instead of sending raw sensor streams, the demo sends semantic tokens such as missed medication, low activity, or long silence. Gemini then follows an Observe-Reason-Decide loop and chooses whether to stay quiet or gently check in.

We are careful about the boundary. SilverLink does not diagnose, change dosage, or replace pharmacists and doctors. It helps people understand, remember, and hand off to humans when uncertainty appears.

That is why this is an agent, not just a chatbot. It observes context, remembers baseline, responds with care, and knows when not to act.

Our larger hackathon strategy points toward web-first deployment, Cloud Run, ephemeral Live tokens, and stronger automation. But for this stage demo, we prioritize the safest executable slice: Flutter on iOS, Gemini stable generation, semantic-token scenarios, a warm voice, and a handoff memo that gives responsibility back to people.

Technology should not replace relationships. It should quietly protect them.

## Judge Q&A

**Why Flutter if the winning guide recommends web-first PWA?**  
The guide describes the optimal live-hackathon delivery stack. This repo started as a Flutter/iOS prototype, so the best competition move is to preserve the stable asset and align the story around an iOS-first demo. Web/Cloud Run is the next delivery track.

**Is Matter really integrated?**  
Not physically in this MVP. We mock a Matter-compatible edge gateway through semantic tokens. This proves the privacy-preserving agent loop without spending hackathon time on hardware reliability.

**Is Gemini Live fully implemented?**  
No. Live is an experimental track in this repo. The guaranteed demo path uses Gemini stable generation plus Google TTS, which is more reliable for judging.

**Why use Google Cloud TTS?**  
Because for eldercare, a cold mechanical voice can break trust. Chirp 3 HD gives a warmer Japanese voice path while device TTS remains the fallback.

**How do you avoid medical risk?**  
The prompt, UI copy, and demo script all frame SilverLink as information support and human handoff. It does not diagnose, prescribe, or change dosage. The medicine card also creates a family/pharmacist memo so uncertainty becomes a handoff, not an AI decision.

**What is the strongest winning point?**  
The product is not feature-heavy; it is interaction-light. It turns Gemini from a tool the user must operate into a quiet agent that adapts to the user's context.

## Roadmap After The Hackathon

1. Move stable demo to a web-first PWA or add a companion PWA for judges and deployment.
2. Add backend-issued ephemeral tokens for the Gemini Live experimental track.
3. Add Cloud Run deployment and GitHub Actions smoke checks.
4. Add share/export channels beyond the implemented copy action for the family/pharmacist handoff memo.
5. Replace mock scenario tokens with real Matter/Thread gateway integration.
6. Evaluate MedGemma as a second-layer explanation or privacy-enhanced local reasoning path.
