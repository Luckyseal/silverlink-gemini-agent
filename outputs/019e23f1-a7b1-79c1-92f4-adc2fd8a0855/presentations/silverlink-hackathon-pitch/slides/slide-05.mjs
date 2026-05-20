import { C, bg, claim, footer, kicker, note, pill } from "./theme.mjs";

function scene(slide, ctx, x, y, time, title, body, color, w = 214) {
  ctx.addShape(slide, { x, y, w, h: 166, fill: C.panel, line: ctx.line(color, 1) });
  ctx.addText(slide, { text: time, x: x + 16, y: y + 14, w: 72, h: 18, fontSize: 12, color, bold: true, typeface: ctx.fonts.mono });
  ctx.addText(slide, { text: title, x: x + 16, y: y + 42, w: w - 34, h: 28, fontSize: 21, color: C.paper, bold: true });
  ctx.addText(slide, { text: body, x: x + 16, y: y + 82, w: w - 34, h: 60, fontSize: 15, color: C.muted });
}

function phone(slide, ctx, x, y) {
  ctx.addShape(slide, { x, y, w: 206, h: 356, fill: "#0C1018", line: ctx.line("#566172", 2) });
  ctx.addShape(slide, { x: x + 16, y: y + 22, w: 174, h: 314, fill: C.ink2, line: ctx.line("#273142", 1) });
  ctx.addShape(slide, { geometry: "ellipse", x: x + 63, y: y + 46, w: 80, h: 80, fill: "#8CA7FF55", line: ctx.line(C.blue, 1) });
  ctx.addText(slide, { text: "お薬を一緒に確認しましょうか。", x: x + 28, y: y + 144, w: 150, h: 44, fontSize: 16, color: C.paper, align: "center" });
  ctx.addShape(slide, { x: x + 28, y: y + 212, w: 150, h: 48, fill: "#222C3A", line: ctx.line(C.amber, 1) });
  ctx.addText(slide, { text: "今日確認", x: x + 42, y: y + 225, w: 122, h: 20, fontSize: 16, color: C.paper, bold: true, align: "center" });
  ctx.addText(slide, { text: "薬剤師に確認", x: x + 42, y: y + 246, w: 122, h: 16, fontSize: 10, color: C.amber, align: "center" });
  ctx.addShape(slide, { x: x + 28, y: y + 280, w: 150, h: 38, fill: "#18312E", line: ctx.line(C.mint, 1) });
  ctx.addText(slide, { text: "家族へ共有", x: x + 42, y: y + 291, w: 122, h: 16, fontSize: 14, color: C.mint, bold: true, align: "center" });
}

export async function slide05(presentation, ctx) {
  const slide = presentation.slides.add();
  bg(slide, ctx);
  kicker(slide, ctx, "2 MIN SOLO DEMO", 72, 58, C.amber);
  claim(slide, ctx, "A solo-safe slice judges can see in two minutes.", 72, 96, 800, 48);
  note(slide, ctx, "One builder, one stable loop: ambient orb, Gemini vision, Google Cloud voice, semantic event, and human handoff.", 76, 206, 744, 62, 21);
  scene(slide, ctx, 76, 338, "0-15s", "Category", "Ambient Family Intelligence, not another senior app.", C.coral);
  scene(slide, ctx, 324, 338, "15-40s", "Gemini vision", "Medicine image becomes a structured card.", C.blue);
  scene(slide, ctx, 572, 338, "40-65s", "Cloud voice", "Chirp 3 HD or device fallback.", C.mint);
  scene(slide, ctx, 820, 338, "65-95s", "Signal", "semantic token,\nno raw stream.", C.amber, 176);
  ctx.addShape(slide, { x: 76, y: 548, w: 912, h: 50, fill: "#7CD6C418", line: ctx.line(C.mint, 1) });
  ctx.addText(slide, { text: "95-120s | Copy handoff memo, then close: no diagnosis, no dosage change.", x: 104, y: 563, w: 856, h: 20, fontSize: 19, color: C.paper, bold: true, align: "center" });
  phone(slide, ctx, 1022, 140);
  pill(slide, ctx, "solo executable", 76, 620, 170, C.coral);
  pill(slide, ctx, "Google Cloud visible", 266, 620, 210, C.blue);
  pill(slide, ctx, "ambient family intelligence", 496, 620, 260, C.mint);
  footer(slide, ctx, 5);
  return slide;
}
