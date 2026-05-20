# SilverLink Repo Review

## Current State

- Flutter prototype with one-screen Live orb UI.
- Gemini multimodal image flow for medication/document photos.
- Japanese TTS/STT support, with STT disabled on web.
- SharedPreferences-based conversation memory.
- iOS privacy strings are already present for camera, microphone, photo library, and speech recognition.

## Gaps Closed In This MVP Pass

- Added a hidden Scenario Injector through long-press on the orb.
- Added Matter-compatible semantic event tokens for proactive care scenarios.
- Added a Guardian AI service boundary so the UI can use stable Gemini and an experimental Live probe through one interface.
- Added Google Cloud Text-to-Speech Chirp 3 HD as the primary warm voice path, with device TTS fallback.
- Added structured medicine cards and family/pharmacist handoff memos so uncertainty is handed back to humans.
- Added a copy action for the family/pharmacist handoff memo so the demo visibly moves responsibility back to people.
- Persisted Gemini `memory_note_jp` into the baseline memory instead of discarding it.
- Added application materials and a review report for registration and judging.

## Verified Baseline

- `flutter test` passes after the latest demo hardening.
- `flutter analyze` reports no issues after the latest demo hardening.

## Remaining Risks

- Gemini Live remains experimental in this Flutter app. The stable demo path continues to use Gemini content generation.
- Live audio playback is not part of the guaranteed demo path; the Live track is a connection probe and architecture proof.
- Google Cloud TTS requires a valid Cloud Text-to-Speech credential and enabled billing/API. If unavailable, the app falls back to device TTS.
- Scenario tokens are mocked for MVP. If Gemini/API keys are unavailable, the Scenario Injector uses local fixtures to preserve the stage agent loop.
- Real Matter/Thread device integration remains future work.
- This is not a medical device and must not provide diagnosis, treatment instruction, or medication dosage decisions.

## Post-Mortem & Lessons Learned (Hackathon Execution Phase)

### 1. TTS API Payload Strictness & Silent Fallback Trap
- **Issue**: The Google Cloud TTS API (`v1beta1`) rejected our payload because we included experimental Gemini-like fields (`markup` and `prompt`) inside the `input` object. This resulted in a HTTP 400.
- **Trap**: The UI layer wrapped the TTS call in a generic `try-catch` that silently fell back to the local device's `flutter_tts`. This masked the API failure, leading to a degraded UX (a harsh mechanical voice) instead of an immediate developer error.
- **Lesson**: Cloud APIs have strict schemas that do not cross over (e.g., Gemini prompts do not work in standard GCP TTS). Furthermore, silent fallbacks are dangerous during development; network/API failures must be logged or surfaced visibly before falling back to local mocks.

### 2. Ambient UI vs. Tool App UI (Cognitive Dissonance)
- **Issue**: Initially, the UI featured explicit "See" (見る) and "Speak" (話す) buttons, and rendered the complex "Handoff to Pharmacist/Family" text card directly on the elder's screen.
- **Trap**: This broke the "Ambient Intelligence" positioning. The app felt like a traditional utility tool rather than a "quiet family presence layer". Displaying complex medical handoffs to the elder also increased their cognitive load unnecessarily.
- **Lesson**: "Human-centered escalation" means routing uncertainty to the *right* human in the background. The elder's UI must remain absolutely minimal (e.g., hidden gestures on the Orb). The complex handoff data (JSON) must be routed silently to the family via background channels (mocked in our demo via a Top Notification Banner + `url_launcher` to iMessage). When building Ambient AI, UI reduction is as important as AI generation.
