import { C, bg, claim, footer, kicker, note } from "./theme.mjs";

function safety(slide, ctx, x, y, title, body, color) {
  ctx.addShape(slide, { x, y, w: 252, h: 138, fill: C.panel, line: ctx.line(color, 1.1) });
  ctx.addText(slide, { text: title, x: x + 18, y: y + 20, w: 216, h: 42, fontSize: 22, color: C.paper, bold: true, align: "center" });
  ctx.addText(slide, { text: body, x: x + 20, y: y + 66, w: 212, h: 46, fontSize: 15, color: C.muted, align: "center" });
}

export async function slide08(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "SAFETY", 72, 58, C.amber);
  claim(slide, ctx, "The boundary is part of the product.", 72, 96, 790, 52);
  note(slide, ctx, "SilverLink earns trust by refusing to overreach. It notices earlier, speaks gently, and escalates to humans.", 76, 212, 760, 56, 22);
  safety(slide, ctx, 90, 346, "No diagnosis", "It explains visible text and uncertainty, not medical truth.", C.coral);
  safety(slide, ctx, 380, 346, "No dosage change", "It never tells a person to start, stop, or change medicine.", C.amber);
  safety(slide, ctx, 670, 346, "Human escalation", "Family, pharmacist, doctor, or emergency path stays explicit.", C.mint);
  safety(slide, ctx, 960, 346, "Privacy memory", "Remember lightweight context, not unnecessary raw audio or video.", C.blue);
  ctx.addShape(slide, { x: 190, y: 558, w: 900, h: 54, fill: "#F08A7718", line: ctx.line(C.coral, 1) });
  ctx.addText(slide, { text: "Triage: Green | Yellow family | Orange pharmacist | Red doctor / emergency", x: 220, y: 574, w: 840, h: 24, fontSize: 17, color: C.paper, bold: true, align: "center" });
  footer(slide, ctx, 8);
  return slide;
}
