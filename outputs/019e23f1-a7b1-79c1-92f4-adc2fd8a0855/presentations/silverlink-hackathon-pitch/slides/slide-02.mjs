import { C, bg, claim, footer, kicker, note, pill } from "./theme.mjs";

function signal(slide, ctx, x, label, sub, color, height) {
  ctx.addShape(slide, { x, y: 384 - height, w: 4, h: height, fill: color, line: ctx.line(C.none, 0) });
  ctx.addShape(slide, { geometry: "ellipse", x: x - 10, y: 374 - height, w: 24, h: 24, fill: `${color}44`, line: ctx.line(color, 1) });
  ctx.addText(slide, { text: label, x: x - 72, y: 414, w: 150, h: 25, fontSize: 18, color: C.paper, bold: true, align: "center" });
  ctx.addText(slide, { text: sub, x: x - 92, y: 444, w: 190, h: 52, fontSize: 15, color: C.muted, align: "center" });
}

export async function slide02(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "PROBLEM", 72, 58, C.amber);
  claim(slide, ctx, "The most dangerous signal is silence.", 72, 96, 790, 52);
  note(
    slide,
    ctx,
    "Japan is aging. Families are busy. Seniors do not always ask for help. The dangerous part is silence.",
    76,
    224,
    660,
    78,
    23,
  );
  ctx.addShape(slide, { x: 126, y: 382, w: 1008, h: 2, fill: C.faint, line: ctx.line(C.none, 0) });
  signal(slide, ctx, 210, "07:50", "medicine box usually moves", C.mint, 66);
  signal(slide, ctx, 448, "09:10", "no confirmation today", C.amber, 118);
  signal(slide, ctx, 686, "11:30", "voice sounds tired", C.coral, 92);
  signal(slide, ctx, 924, "17:40", "no family touchpoint", C.blue, 76);
  ctx.addShape(slide, { x: 822, y: 162, w: 334, h: 136, fill: C.panel, line: ctx.line(C.amber, 1) });
  ctx.addText(slide, { text: "Families do care.", x: 848, y: 184, w: 282, h: 28, fontSize: 24, color: C.paper, bold: true });
  ctx.addText(slide, { text: "They just discover quiet changes too late.", x: 848, y: 222, w: 260, h: 46, fontSize: 19, color: C.muted });
  pill(slide, ctx, "silent signal detection", 76, 548, 236, C.mint);
  pill(slide, ctx, "low interruption", 334, 548, 168, C.blue);
  pill(slide, ctx, "human response", 524, 548, 164, C.amber);
  footer(slide, ctx, 2);
  return slide;
}
