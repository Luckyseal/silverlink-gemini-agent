import { C, bg, claim, footer, kicker, note, orb, pill } from "./theme.mjs";

export async function slide07(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "WHY GOOGLE CLOUD + GEMINI", 72, 58, C.mint);
  claim(slide, ctx, "Google Cloud is visible in the demo, not only in the stack.", 72, 96, 900, 45);
  note(slide, ctx, "The event has a hard rule: Google Cloud products must be integrated. SilverLink makes that concrete through Gemini and cloud voice.", 76, 204, 790, 54, 21);
  const caps = [
    ["Gemini Vision", "medicine / document understanding", 116, 346, C.blue],
    ["Gemini Reasoning", "Observe, reason, decide loop", 424, 306, C.mint],
    ["Structured Output", "cards and handoff memos", 732, 346, C.amber],
    ["Cloud TTS", "Chirp 3 HD Japanese voice", 270, 510, C.coral],
    ["Cloud Run Next", "review build and Live tokens", 578, 510, C.blue],
  ];
  caps.forEach(([title, body, x, y, color]) => {
    ctx.addShape(slide, { x, y, w: 260, h: 100, fill: C.panel, line: ctx.line(color, 1.1) });
    ctx.addText(slide, { text: title, x: x + 20, y: y + 18, w: 220, h: 24, fontSize: 22, color: C.paper, bold: true, align: "center" });
    ctx.addText(slide, { text: body, x: x + 20, y: y + 54, w: 220, h: 30, fontSize: 14, color: C.muted, align: "center" });
  });
  orb(slide, ctx, 980, 128, 126, C.mint);
  pill(slide, ctx, "Prize rule satisfied by visible Cloud integration", 76, 618, 432, C.mint);
  footer(slide, ctx, 7);
  return slide;
}
