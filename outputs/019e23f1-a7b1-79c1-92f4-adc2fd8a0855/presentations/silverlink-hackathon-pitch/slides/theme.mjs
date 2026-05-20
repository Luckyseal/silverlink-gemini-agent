export const C = {
  ink: "#10141C",
  ink2: "#141B26",
  panel: "#1B2431",
  panel2: "#222C3A",
  paper: "#F4EFE5",
  muted: "#AEB8C8",
  faint: "#5E6978",
  mint: "#7CD6C4",
  amber: "#F2C14E",
  coral: "#F08A77",
  blue: "#8CA7FF",
  white: "#FFFFFF",
  none: "#00000000",
};

export function bg(slide, ctx) {
  ctx.addShape(slide, { x: 0, y: 0, w: ctx.W, h: ctx.H, fill: C.ink, line: ctx.line(C.none, 0) });
  ctx.addShape(slide, { x: 0, y: 0, w: 424, h: 118, fill: "#182235", line: ctx.line(C.none, 0) });
  ctx.addShape(slide, { x: 826, y: 656, w: 454, h: 64, fill: "#152622", line: ctx.line(C.none, 0) });
  ctx.addShape(slide, { x: 0, y: 704, w: 1280, h: 16, fill: "#0D1118", line: ctx.line(C.none, 0) });
}

export function footer(slide, ctx, n) {
  ctx.addText(slide, {
    text: "SilverLink Ambient Agent | Gemini Hackathon Tokyo 2026",
    x: 52,
    y: 680,
    w: 500,
    h: 18,
    fontSize: 12,
    color: C.faint,
  });
  ctx.addText(slide, {
    text: String(n).padStart(2, "0"),
    x: 1180,
    y: 674,
    w: 48,
    h: 24,
    fontSize: 14,
    color: C.faint,
    align: "right",
    typeface: ctx.fonts.mono,
  });
}

export function kicker(slide, ctx, text, x = 72, y = 62, color = C.mint) {
  ctx.addShape(slide, { x, y: y + 8, w: 18, h: 3, fill: color, line: ctx.line(C.none, 0) });
  ctx.addText(slide, {
    text,
    x: x + 30,
    y,
    w: 380,
    h: 22,
    fontSize: 13,
    bold: true,
    color,
    typeface: ctx.fonts.mono,
  });
}

export function claim(slide, ctx, text, x = 72, y = 94, w = 760, size = 48) {
  ctx.addText(slide, {
    text,
    x,
    y,
    w,
    h: 156,
    fontSize: size,
    color: C.paper,
    typeface: ctx.fonts.title,
    bold: true,
  });
}

export function note(slide, ctx, text, x, y, w, h, size = 21, color = C.muted) {
  ctx.addText(slide, {
    text,
    x,
    y,
    w,
    h,
    fontSize: size,
    color,
    insets: { left: 0, right: 0, top: 0, bottom: 0 },
  });
}

export function pill(slide, ctx, text, x, y, w, color = C.mint) {
  ctx.addShape(slide, {
    x,
    y,
    w,
    h: 28,
    fill: `${color}22`,
    line: ctx.line(color, 1),
  });
  ctx.addText(slide, {
    text,
    x: x + 10,
    y: y + 5,
    w: w - 20,
    h: 18,
    fontSize: 12,
    bold: true,
    color,
    typeface: ctx.fonts.mono,
    align: "center",
  });
}

export function node(slide, ctx, { title, body, x, y, w, h, color = C.mint, index }) {
  ctx.addShape(slide, { x, y, w, h, fill: C.panel, line: ctx.line(color, 1.2) });
  if (index) {
    ctx.addText(slide, {
      text: index,
      x: x + 14,
      y: y + 14,
      w: 28,
      h: 22,
      fontSize: 14,
      color,
      bold: true,
      typeface: ctx.fonts.mono,
    });
  }
  ctx.addText(slide, {
    text: title,
    x: x + (index ? 48 : 16),
    y: y + 14,
    w: w - (index ? 62 : 32),
    h: 26,
    fontSize: 20,
    color: C.paper,
    bold: true,
  });
  ctx.addText(slide, {
    text: body,
    x: x + 16,
    y: y + 52,
    w: w - 32,
    h: h - 62,
    fontSize: 16,
    color: C.muted,
  });
}

export function label(slide, ctx, text, x, y, w, color = C.mint) {
  ctx.addText(slide, {
    text,
    x,
    y,
    w,
    h: 18,
    fontSize: 12,
    color,
    bold: true,
    typeface: ctx.fonts.mono,
  });
}

export function bar(slide, ctx, x, y, w, h, color = C.faint) {
  ctx.addShape(slide, { x, y, w, h, fill: color, line: ctx.line(C.none, 0) });
}

export function arrowText(slide, ctx, x, y, color = C.faint) {
  ctx.addText(slide, {
    text: "->",
    x,
    y,
    w: 42,
    h: 34,
    fontSize: 24,
    color,
    align: "center",
    valign: "middle",
    typeface: ctx.fonts.mono,
  });
}

export function orb(slide, ctx, x, y, size, color = C.blue) {
  ctx.addShape(slide, {
    geometry: "ellipse",
    x: x - 22,
    y: y - 22,
    w: size + 44,
    h: size + 44,
    fill: `${color}18`,
    line: ctx.line(C.none, 0),
  });
  ctx.addShape(slide, {
    geometry: "ellipse",
    x,
    y,
    w: size,
    h: size,
    fill: `${color}55`,
    line: ctx.line(color, 1.2),
  });
  ctx.addShape(slide, {
    geometry: "ellipse",
    x: x + size * 0.22,
    y: y + size * 0.18,
    w: size * 0.36,
    h: size * 0.36,
    fill: `${C.paper}33`,
    line: ctx.line(C.none, 0),
  });
}

export function miniMetric(slide, ctx, value, labelText, x, y, color) {
  ctx.addText(slide, { text: value, x, y, w: 150, h: 36, fontSize: 30, color, bold: true, typeface: ctx.fonts.title });
  ctx.addText(slide, { text: labelText, x, y: y + 38, w: 190, h: 44, fontSize: 15, color: C.muted });
}
