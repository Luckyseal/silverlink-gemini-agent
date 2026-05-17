import { C, bg, claim, footer, kicker, note, pill } from "./theme.mjs";

function market(slide, ctx, x, y, title, bullets, color) {
  ctx.addShape(slide, { x, y, w: 456, h: 270, fill: C.panel, line: ctx.line(color, 1.2) });
  ctx.addText(slide, { text: title, x: x + 30, y: y + 26, w: 396, h: 34, fontSize: 30, color: C.paper, bold: true });
  bullets.forEach((bullet, i) => {
    ctx.addShape(slide, { geometry: "ellipse", x: x + 34, y: y + 90 + i * 42, w: 10, h: 10, fill: color, line: ctx.line(C.none, 0) });
    ctx.addText(slide, { text: bullet, x: x + 58, y: y + 82 + i * 42, w: 350, h: 24, fontSize: 19, color: C.muted });
  });
}

export async function slide09(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "GO TO MARKET", 72, 58, C.blue);
  claim(slide, ctx, "Japan first. Global next.", 72, 96, 690, 54);
  note(slide, ctx, "Japan gives the sharpest first wedge: aging society, older adults living alone, respectful language, family and pharmacist connection, and low interruption.", 76, 214, 820, 58, 21);
  market(slide, ctx, 112, 350, "Japan version", ["独居高齢者", "敬語 and calm voice", "family / pharmacist link", "low-interruption trust"], C.mint);
  market(slide, ctx, 710, 350, "Global version", ["remote family care", "chronic condition support", "care coordination", "ambient relationship layer"], C.amber);
  pill(slide, ctx, "From 見守り to ambient family intelligence", 76, 616, 392, C.mint);
  footer(slide, ctx, 9);
  return slide;
}
