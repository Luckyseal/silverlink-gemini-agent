import { C, bg, claim, footer, kicker, note, orb, pill } from "./theme.mjs";

export async function slide03(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "INSIGHT", 72, 58, C.blue);
  claim(slide, ctx, "Older adults do not need another app to learn.", 72, 96, 820, 48);
  note(slide, ctx, "They need technology that quietly adapts to them.", 78, 220, 650, 42, 28, C.paper);
  ctx.addShape(slide, { x: 92, y: 344, w: 420, h: 176, fill: C.panel, line: ctx.line(C.coral, 1) });
  ctx.addText(slide, { text: "Most apps ask Keiko to:", x: 120, y: 374, w: 330, h: 26, fontSize: 22, color: C.paper, bold: true });
  ctx.addText(slide, { text: "tap, search, learn menus,\nand explain her own context.", x: 120, y: 416, w: 330, h: 76, fontSize: 24, color: C.muted });
  ctx.addShape(slide, { x: 660, y: 330, w: 430, h: 206, fill: "#18312E", line: ctx.line(C.mint, 1.2) });
  ctx.addText(slide, { text: "SilverLink asks less:", x: 692, y: 360, w: 330, h: 26, fontSize: 22, color: C.paper, bold: true });
  ctx.addText(slide, { text: "one calm orb,\nlarge text,\ngentle voice,\nhuman handoff.", x: 692, y: 400, w: 326, h: 116, fontSize: 23, color: C.mint });
  orb(slide, ctx, 1072, 120, 104, C.mint);
  pill(slide, ctx, "AI adapts to people", 80, 574, 212, C.mint);
  pill(slide, ctx, "not the other way around", 314, 574, 250, C.blue);
  footer(slide, ctx, 3);
  return slide;
}
