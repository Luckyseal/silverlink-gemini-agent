import { C, bg, claim, footer, kicker, note, orb, pill } from "./theme.mjs";

export async function slide01(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "FINAL POSITIONING", 72, 58, C.mint);
  claim(slide, ctx, "SilverLink Ambient Agent", 72, 110, 710, 58);
  note(slide, ctx, "Ambient Family Intelligence for Aging Societies", 78, 248, 650, 42, 28, C.paper);
  note(
    slide,
    ctx,
    "An ambient AI presence that quietly understands daily changes and reconnects aging families before small signals become serious problems.",
    80,
    334,
    642,
    94,
    23,
    C.muted,
  );
  orb(slide, ctx, 846, 112, 286, C.blue);
  ctx.addText(slide, {
    text: "SilverLink",
    x: 832,
    y: 230,
    w: 285,
    h: 44,
    fontSize: 36,
    color: C.paper,
    bold: true,
    align: "center",
    typeface: ctx.fonts.title,
  });
  ctx.addText(slide, {
    text: "quiet presence layer",
    x: 862,
    y: 278,
    w: 225,
    h: 24,
    fontSize: 18,
    color: C.muted,
    align: "center",
  });
  pill(slide, ctx, "not a senior app", 80, 506, 170, C.coral);
  pill(slide, ctx, "not monitoring", 272, 506, 150, C.amber);
  pill(slide, ctx, "family intelligence", 444, 506, 194, C.mint);
  ctx.addShape(slide, { x: 806, y: 458, w: 340, h: 78, fill: "#7CD6C418", line: ctx.line(C.mint, 1) });
  ctx.addText(slide, { text: "She never learned the app.", x: 830, y: 478, w: 292, h: 22, fontSize: 21, color: C.paper, bold: true, align: "center" });
  ctx.addText(slide, { text: "The app learned how to care.", x: 830, y: 506, w: 292, h: 20, fontSize: 17, color: C.mint, align: "center" });
  footer(slide, ctx, 1);
  return slide;
}
