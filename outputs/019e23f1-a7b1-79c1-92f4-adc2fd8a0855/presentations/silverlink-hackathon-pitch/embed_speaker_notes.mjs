import fs from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";

const workspace = "/Users/yancy/Documents/GeminiHackathon2026Tokyo/outputs/019e23f1-a7b1-79c1-92f4-adc2fd8a0855/presentations/silverlink-hackathon-pitch";
const input = path.join(workspace, "output", "silverlink-winner-level-pitch.pptx");
const output = path.join(workspace, "output", "silverlink-winner-level-pitch-speaker-notes.pptx");
const workdir = path.join(workspace, "notes-pptx-work");

const notes = [
  [
    "18s | Title",
    "Good afternoon. This is SilverLink Ambient Agent.",
    "It is not another senior app. It is Ambient Family Intelligence for aging societies.",
    "It quietly understands daily changes, and reconnects families before small signals become serious problems.",
    "Cue: set the category first. Do not start with features.",
  ],
  [
    "20s | Problem",
    "In aging societies, families often do not miss big emergencies. They miss small changes.",
    "A medicine box does not move. A voice sounds tired. A room becomes quiet. The dangerous signal is silence.",
    "Cue: read silence slowly.",
  ],
  [
    "18s | Insight",
    "Older adults do not need another app to learn.",
    "Most apps ask people to tap, search, and explain themselves.",
    "SilverLink asks less. One calm orb, large text, gentle voice, and human handoff.",
    "Cue: the app adapts to people.",
  ],
  [
    "20s | Solution",
    "SilverLink is one ambient interface.",
    "It can see, listen, remember, gently act, and hand off to humans.",
    "It does not interrupt. It does not judge. It simply notices earlier.",
  ],
  [
    "28s | Demo",
    "Here is the demo. The older adult does not open a complex app. A medicine box is on the table.",
    "SilverLink notices the quiet signal and says in Japanese: お薬を一緒に確認しましょうか。",
    "Then Gemini reads what can be safely read, creates a large-text card, and prepares a family or pharmacist summary.",
    "Cue: switch to live app here if presenting live.",
  ],
  [
    "24s | Architecture",
    "Environment signals come from camera, voice, and routine context.",
    "Gemini provides multimodal understanding and reasoning.",
    "Then the agent core handles perception, memory, triage, and communication.",
    "The final action is not an AI decision. It is a human handoff.",
  ],
  [
    "24s | Why Gemini",
    "Gemini is not used as a chatbot.",
    "It is the perception and reasoning layer behind the ambient agent.",
    "Vision understands medicine boxes and documents. Voice creates low-friction conversation. Structured output keeps cards and summaries stable.",
    "Cue: not chatbot; perception and reasoning layer.",
  ],
  [
    "22s | Safety",
    "Safety is part of the product.",
    "SilverLink does not diagnose. It does not change dosage. It does not replace doctors or family.",
    "It notices uncertainty, speaks gently, and escalates to the right human.",
  ],
  [
    "18s | Japan First",
    "Japan is the first wedge.",
    "The product fits older adults living alone, respectful Japanese language, family connection, pharmacist confirmation, and low interruption.",
    "Globally, this becomes remote family care as an ambient relationship layer.",
  ],
  [
    "18s | Closing",
    "SilverLink is not about replacing family. It is about making care visible earlier.",
    "Technology should not replace relationships. It should quietly protect them.",
    "She never learned the app. The app learned how to care.",
    "Cue: slow down and pause after the last sentence.",
  ],
];

function escapeXml(text) {
  return String(text)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function notesBody(lines) {
  const paragraphs = lines
    .map(
      (line) =>
        `<a:p xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:r><a:rPr lang="en-US" sz="1200" /><a:t>${escapeXml(line)}</a:t></a:r><a:endParaRPr lang="en-US" /></a:p>`,
    )
    .join("");
  return `<a:bodyPr xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" /><a:lstStyle xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" />${paragraphs}`;
}

async function main() {
  await fs.rm(workdir, { recursive: true, force: true });
  await fs.mkdir(workdir, { recursive: true });

  let result = spawnSync("unzip", ["-q", input, "-d", workdir], { encoding: "utf8" });
  if (result.status !== 0) {
    throw new Error(`unzip failed: ${result.stderr || result.stdout}`);
  }

  for (let index = 0; index < notes.length; index += 1) {
    const notesPath = path.join(workdir, "ppt", "notesSlides", `notesSlide${index + 1}.xml`);
    const xml = await fs.readFile(notesPath, "utf8");
    const replacement = `$1${notesBody(notes[index])}$3`;
    const patched = xml.replace(
      /(<p:cNvPr id="3" name="Notes Placeholder 2"[\s\S]*?<p:txBody>)([\s\S]*?)(<\/p:txBody>)/,
      replacement,
    );
    if (patched === xml) {
      throw new Error(`Could not patch notes body for slide ${index + 1}`);
    }
    await fs.writeFile(notesPath, patched, "utf8");
  }

  await fs.rm(output, { force: true });
  result = spawnSync("zip", ["-qr", output, "."], { cwd: workdir, encoding: "utf8" });
  if (result.status !== 0) {
    throw new Error(`zip failed: ${result.stderr || result.stdout}`);
  }
  await fs.rm(workdir, { recursive: true, force: true });
  console.log(output);
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
