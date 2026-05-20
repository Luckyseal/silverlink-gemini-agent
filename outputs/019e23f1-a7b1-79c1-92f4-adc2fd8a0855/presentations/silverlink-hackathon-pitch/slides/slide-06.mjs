import { C, arrowText, bg, claim, footer, kicker, note } from "./theme.mjs";

function lane(slide, ctx, x, y, title, items, color) {
  ctx.addShape(slide, { x, y, w: 186, h: 248, fill: C.panel, line: ctx.line(color, 1.1) });
  ctx.addText(slide, { text: title, x: x + 14, y: y + 16, w: 158, h: 24, fontSize: 19, color: C.paper, bold: true, align: "center" });
  items.forEach((item, i) => {
    ctx.addShape(slide, { x: x + 18, y: y + 62 + i * 48, w: 150, h: 32, fill: `${color}18`, line: ctx.line(`${color}66`, 1) });
    ctx.addText(slide, { text: item, x: x + 24, y: y + 70 + i * 48, w: 138, h: 18, fontSize: 13, color: C.muted, align: "center" });
  });
}

export async function slide06(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "ARCHITECTURE", 72, 58, C.blue);
  claim(slide, ctx, "Environment to Gemini to agents to humans.", 72, 96, 870, 48);
  note(slide, ctx, "This is the product system: perception and reasoning are useful only when they end in a calm human handoff.", 76, 200, 760, 50, 21);
  const y = 326;
  lane(slide, ctx, 72, y, "Signals", ["camera", "voice", "routine"], C.blue);
  arrowText(slide, ctx, 266, y + 98, C.faint);
  lane(slide, ctx, 314, y, "Gemini", ["vision", "voice", "reasoning"], C.mint);
  arrowText(slide, ctx, 508, y + 98, C.faint);
  lane(slide, ctx, 556, y, "Agent Core", ["perception", "memory", "triage"], C.amber);
  arrowText(slide, ctx, 750, y + 98, C.faint);
  lane(slide, ctx, 798, y, "Actions", ["voice", "large card", "family memo"], C.coral);
  arrowText(slide, ctx, 992, y + 98, C.faint);
  lane(slide, ctx, 1040, y, "Safety", ["no diagnosis", "handoff", "privacy"], C.mint);
  ctx.addShape(slide, { x: 300, y: 604, w: 680, h: 42, fill: "#F2C14E18", line: ctx.line(C.amber, 1) });
  ctx.addText(slide, { text: "Privacy choice: semantic event tokens, not raw life streams.", x: 330, y: 616, w: 620, h: 18, fontSize: 18, color: C.paper, bold: true, align: "center" });
  footer(slide, ctx, 6);
  return slide;
}
