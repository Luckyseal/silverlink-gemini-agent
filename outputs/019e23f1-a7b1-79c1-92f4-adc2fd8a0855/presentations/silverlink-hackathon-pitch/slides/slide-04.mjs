import { C, bg, claim, footer, kicker, note, orb } from "./theme.mjs";

function verb(slide, ctx, x, y, word, detail, color) {
  ctx.addShape(slide, { x, y, w: 184, h: 148, fill: C.panel, line: ctx.line(color, 1.1) });
  ctx.addText(slide, { text: word, x: x + 18, y: y + 20, w: 148, h: 34, fontSize: 26, color: C.paper, bold: true, align: "center" });
  ctx.addText(slide, { text: detail, x: x + 18, y: y + 72, w: 148, h: 50, fontSize: 16, color: C.muted, align: "center" });
}

export async function slide04(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "SOLUTION", 72, 58, C.mint);
  claim(slide, ctx, "One ambient interface: see, listen, remember, gently act, hand off.", 72, 96, 900, 46);
  note(slide, ctx, "The product is not a dashboard. It is a low-interruption layer between daily life and family response.", 76, 200, 770, 54, 21);
  verb(slide, ctx, 76, 328, "See", "medicine box, table, document", C.blue);
  verb(slide, ctx, 300, 328, "Listen", "question, tone, hesitation", C.mint);
  verb(slide, ctx, 524, 328, "Remember", "recent lightweight context", C.amber);
  verb(slide, ctx, 748, 328, "Act", "calm voice, large card", C.coral);
  verb(slide, ctx, 972, 328, "Hand off", "family or pharmacist memo", C.mint);
  orb(slide, ctx, 1014, 114, 106, C.blue);
  ctx.addShape(slide, { x: 318, y: 552, w: 644, h: 54, fill: "#7CD6C41A", line: ctx.line(C.mint, 1) });
  ctx.addText(slide, { text: "It does not interrupt. It does not judge. It simply notices earlier.", x: 346, y: 566, w: 588, h: 28, fontSize: 22, color: C.paper, bold: true, align: "center" });
  footer(slide, ctx, 4);
  return slide;
}
