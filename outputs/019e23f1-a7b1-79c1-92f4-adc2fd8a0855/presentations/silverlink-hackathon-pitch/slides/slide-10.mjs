import { C, bg, claim, footer, kicker, note, orb, pill } from "./theme.mjs";

export async function slide10(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "CLOSING", 72, 58, C.mint);
  claim(slide, ctx, "Technology should not replace relationships.", 72, 104, 820, 54);
  note(slide, ctx, "It should quietly protect them.", 80, 254, 560, 44, 32, C.paper);
  note(slide, ctx, "SilverLink quietly senses small daily changes through Gemini's multimodal capabilities, remembers recent context, responds with respectful voice interaction, and reconnects older adults with family or professionals before silence becomes risk.", 80, 356, 724, 108, 22, C.muted);
  orb(slide, ctx, 886, 120, 236, C.mint);
  ctx.addShape(slide, { x: 738, y: 438, w: 416, h: 98, fill: "#7CD6C418", line: ctx.line(C.mint, 1) });
  ctx.addText(slide, { text: "She never learned the app.", x: 770, y: 462, w: 352, h: 28, fontSize: 23, color: C.paper, bold: true, align: "center" });
  ctx.addText(slide, { text: "The app learned how to care.", x: 770, y: 500, w: 352, h: 22, fontSize: 18, color: C.mint, align: "center" });
  pill(slide, ctx, "AI should adapt to people", 80, 570, 248, C.blue);
  pill(slide, ctx, "not the other way around", 350, 570, 252, C.mint);
  footer(slide, ctx, 10);
  return slide;
}
