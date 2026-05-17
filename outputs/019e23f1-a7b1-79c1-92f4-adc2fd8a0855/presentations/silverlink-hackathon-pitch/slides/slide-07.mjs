import { C, bg, claim, footer, kicker, note, orb, pill } from "./theme.mjs";

export async function slide07(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "WHY GEMINI", 72, 58, C.mint);
  claim(slide, ctx, "Gemini is the perception and reasoning layer behind the ambient agent.", 72, 96, 900, 45);
  note(slide, ctx, "Not a chatbot. One coherent stack turns weak daily signals into structured, respectful, human-actionable support.", 76, 204, 790, 54, 21);
  const caps = [
    ["Vision", "medicine box / document understanding", 116, 346, C.blue],
    ["Live Voice", "low-latency respectful conversation", 424, 306, C.mint],
    ["Function Calling", "record, notify, hand off", 732, 346, C.amber],
    ["Context Memory", "yesterday's dizziness, last check", 270, 510, C.coral],
    ["Structured Output", "cards and summaries stay stable", 578, 510, C.blue],
  ];
  caps.forEach(([title, body, x, y, color]) => {
    ctx.addShape(slide, { x, y, w: 260, h: 100, fill: C.panel, line: ctx.line(color, 1.1) });
    ctx.addText(slide, { text: title, x: x + 20, y: y + 18, w: 220, h: 24, fontSize: 22, color: C.paper, bold: true, align: "center" });
    ctx.addText(slide, { text: body, x: x + 20, y: y + 54, w: 220, h: 30, fontSize: 14, color: C.muted, align: "center" });
  });
  orb(slide, ctx, 980, 128, 126, C.mint);
  pill(slide, ctx, "Gemini as ambient intelligence, not chat UI", 76, 618, 378, C.mint);
  footer(slide, ctx, 7);
  return slide;
}
