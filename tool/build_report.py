"""Builds Group22_Final_Project_Submission.pdf from docs/REPORT.md.

The submission must be Times New Roman, 12 pt body and 14 pt headings. Rather
than pasting into Word by hand every time the report changes, this script
converts the Markdown to styled HTML and prints it with headless Chrome, so the
PDF can be regenerated from the source of truth in one command:

    python tool/build_report.py

No third-party packages are used: the Markdown subset here is only what the
report actually contains (headings, tables, fenced code, lists, blockquotes,
bold/italic/inline code, links, images and horizontal rules).
"""

from __future__ import annotations

import base64
import html
import mimetypes
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPORT = ROOT / "docs" / "REPORT.md"
SCREENSHOTS = ROOT / "docs" / "screenshots"
OUT_HTML = ROOT / "docs" / "build" / "report.html"
OUT_PDF = ROOT / "docs" / "Group22_Final_Project_Submission.pdf"

BROWSERS = [
    Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe"),
    Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
    Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
]

# Figures 1-11 already exist as screenshots. Each is inserted after the
# paragraph that first cites it, so the reader sees the image in context
# rather than hunting for it in an appendix.
FIGURES = {
    1: ("01-register.png", "Registration screen with university-email validation"),
    2: ("02-quiz.png", "Lifestyle questionnaire"),
    3: ("03-home.png", "Home feed with compatibility scores and host badges"),
    4: ("04-details.png", "Listing details screen"),
    5: ("05-why-compatible.png", '"Why are we compatible?" breakdown sheet'),
    6: ("06-explore.png", "Explore grid"),
    7: ("07-favorites.png", "Favourites"),
    8: ("08-bookings.png", "My Bookings across status tabs"),
    9: ("09-profile.png", "Profile"),
    10: ("10-settings-light.png", "Settings in light theme"),
    11: ("11-settings-dark.png", "Settings in dark theme"),
}

CSS = """
@page { size: A4; margin: 25mm 20mm; }
body {
  font-family: "Times New Roman", Times, serif;
  font-size: 12pt;
  line-height: 1.5;
  color: #000;
  text-align: justify;
}
h1, h2, h3, h4 {
  font-family: "Times New Roman", Times, serif;
  font-size: 14pt;
  font-weight: bold;
  text-align: left;
  margin: 18pt 0 8pt;
  page-break-after: avoid;
}
h1 { page-break-before: always; }
h1.title-block, h1:first-of-type { page-break-before: avoid; }
p { margin: 0 0 10pt; }
ul, ol { margin: 0 0 10pt 18pt; padding: 0; }
li { margin-bottom: 4pt; }
table {
  border-collapse: collapse;
  width: 100%;
  margin: 10pt 0 14pt;
  font-size: 10.5pt;
  page-break-inside: avoid;
}
th, td {
  border: 1px solid #000;
  padding: 5pt 6pt;
  text-align: left;
  vertical-align: top;
}
th { font-weight: bold; }
code {
  font-family: Consolas, "Courier New", monospace;
  font-size: 10pt;
}
pre {
  font-family: Consolas, "Courier New", monospace;
  font-size: 9.5pt;
  line-height: 1.35;
  background: #f5f5f5;
  border: 1px solid #ccc;
  padding: 8pt 10pt;
  white-space: pre-wrap;
  page-break-inside: avoid;
  text-align: left;
}
blockquote {
  margin: 10pt 0;
  padding: 8pt 12pt;
  border-left: 3px solid #888;
  background: #fafafa;
  font-size: 11pt;
}
hr { border: none; border-top: 1px solid #999; margin: 14pt 0; }
a { color: #000; text-decoration: underline; }
figure { margin: 12pt 0 16pt; text-align: center; page-break-inside: avoid; }
figure img { max-width: 62%; height: auto; border: 1px solid #bbb; }
figure.wide img { max-width: 100%; border: none; }
figcaption {
  font-size: 11pt;
  font-style: italic;
  margin-top: 6pt;
  text-align: center;
}
.insert {
  background: #fff2a8;
  border: 1px solid #d4b106;
  padding: 1pt 3pt;
  font-style: italic;
}
.cover { text-align: center; page-break-after: always; padding-top: 40mm; }
.cover .main { font-size: 16pt; font-weight: bold; line-height: 1.6; }
.cover .sub { font-size: 13pt; margin-top: 30mm; line-height: 1.6; }
.cover .date { font-size: 13pt; font-weight: bold; margin-top: 40mm; }
"""


def data_uri(path: Path) -> str:
    """Inlines an image so the PDF has no external file dependencies."""
    mime = mimetypes.guess_type(path.name)[0] or "image/png"
    return f"data:{mime};base64,{base64.b64encode(path.read_bytes()).decode()}"


def inline(text: str) -> str:
    """Inline Markdown: code, bold, italic, links, [INSERT] markers."""
    out = html.escape(text)
    # Code spans first, so their contents are not treated as markup.
    spans: list[str] = []

    def stash(m: re.Match[str]) -> str:
        spans.append(f"<code>{m.group(1)}</code>")
        return f"\x00{len(spans) - 1}\x00"

    out = re.sub(r"`([^`]+)`", stash, out)
    out = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', out)
    out = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", out)
    out = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", out)
    # Highlight the outstanding-insertion markers so they cannot be missed.
    out = re.sub(r"(\[INSERT[^\]]*\])", r'<span class="insert">\1</span>', out)
    for i, span in enumerate(spans):
        out = out.replace(f"\x00{i}\x00", span)
    return out


def figure_html(number: int) -> str:
    name, caption = FIGURES[number]
    path = SCREENSHOTS / name
    if not path.exists():
        return ""
    return (
        f'<figure><img src="{data_uri(path)}" alt="{html.escape(caption)}">'
        f"<figcaption>Figure {number}. {html.escape(caption)}</figcaption></figure>"
    )


def erd_figure() -> str:
    """Figure 12: the entity-relationship diagram, drawn as SVG."""
    svg = ROOT / "docs" / "erd.svg"
    if not svg.exists():
        return "<p><em>[ERD diagram missing: docs/erd.svg]</em></p>"
    return (
        f'<figure class="wide"><img src="{data_uri(svg)}" '
        'alt="Entity-relationship diagram">'
        "<figcaption>Figure 12. Entity–relationship diagram. Solid lines are "
        "stored relationships; dashed lines are embedded or device-local "
        "data.</figcaption></figure>"
    )


def cover_html() -> str:
    return """
<div class="cover">
  <div class="main">
    GROUP 22 SUMMATIVE PROJECT — HOUSESLICE<br>
    MOBILE APPLICATION IN FLUTTER
  </div>
  <div class="sub">
    SOFTWARE ENGINEERING — GROUP 22 SUMMATIVE<br>
    AFRICAN LEADERSHIP UNIVERSITY<br>
    KIGALI, RWANDA
  </div>
  <div class="sub">
    NAME OF FACILITATOR<br>
    <span class="insert">[INSERT FACILITATOR NAME]</span>
  </div>
  <div class="date">July, 2026</div>
</div>
"""


def convert(md: str) -> str:
    """Converts the report's Markdown subset to HTML."""
    lines = md.split("\n")
    out: list[str] = []
    i = 0
    # Figures are emitted after the paragraph that first cites them.
    pending: list[int] = []
    seen: set[int] = set()

    def flush_figures() -> None:
        while pending:
            out.append(figure_html(pending.pop(0)))

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped:
            i += 1
            continue

        # Fenced code. Mermaid is kept verbatim: the ERD is reproduced as a
        # diagram in docs/ERD.md, and rendering it here would need a browser
        # round trip for no benefit in a printed document.
        if stripped.startswith("```"):
            lang = stripped[3:].strip()
            i += 1
            body: list[str] = []
            while i < len(lines) and not lines[i].strip().startswith("```"):
                body.append(lines[i])
                i += 1
            i += 1
            # The ERD is kept as Mermaid in the Markdown so GitHub renders it,
            # but a printed report needs a real diagram — so the equivalent
            # hand-drawn SVG is substituted here.
            if lang == "mermaid":
                out.append(erd_figure())
            else:
                out.append("<pre>" + html.escape("\n".join(body)) + "</pre>")
            continue

        # Tables.
        if stripped.startswith("|") and i + 1 < len(lines) and re.match(
            r"^\s*\|[\s:|-]+\|\s*$", lines[i + 1]
        ):
            header = [c.strip() for c in stripped.strip("|").split("|")]
            i += 2
            rows: list[list[str]] = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")])
                i += 1
            cells = "".join(f"<th>{inline(c)}</th>" for c in header)
            body_html = "".join(
                "<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>"
                for r in rows
            )
            out.append(f"<table><thead><tr>{cells}</tr></thead><tbody>{body_html}</tbody></table>")
            continue

        # Headings.
        m = re.match(r"^(#{1,4})\s+(.*)$", stripped)
        if m:
            flush_figures()
            level = len(m.group(1))
            out.append(f"<h{level}>{inline(m.group(2))}</h{level}>")
            i += 1
            continue

        if re.match(r"^(---+|\*\*\*+)$", stripped):
            out.append("<hr>")
            i += 1
            continue

        # Blockquote. Notes addressed to the team rather than the marker are
        # marked "not part of the submission" and dropped from the PDF.
        if stripped.startswith(">"):
            body = []
            while i < len(lines) and lines[i].strip().startswith(">"):
                body.append(lines[i].strip().lstrip(">").strip())
                i += 1
            text = " ".join(body)
            if "not part of the submission" not in text.lower():
                out.append(f"<blockquote>{inline(text)}</blockquote>")
            continue

        # Lists.
        if re.match(r"^[-*]\s+|^\d+\.\s+", stripped):
            ordered = bool(re.match(r"^\d+\.\s+", stripped))
            tag = "ol" if ordered else "ul"
            items: list[str] = []
            while i < len(lines) and re.match(r"^\s*([-*]|\d+\.)\s+", lines[i]):
                item = re.sub(r"^\s*([-*]|\d+\.)\s+", "", lines[i])
                i += 1
                # Continuation lines of the same bullet.
                while (
                    i < len(lines)
                    and lines[i].strip()
                    and lines[i].startswith("  ")
                    and not re.match(r"^\s*([-*]|\d+\.)\s+", lines[i])
                ):
                    item += " " + lines[i].strip()
                    i += 1
                items.append(f"<li>{inline(item)}</li>")
            out.append(f"<{tag}>{''.join(items)}</{tag}>")
            continue

        # Paragraph.
        para: list[str] = []
        while i < len(lines) and lines[i].strip() and not re.match(
            r"^(#{1,4}\s|```|\||>|---+$|\s*([-*]|\d+\.)\s)", lines[i].strip()
        ):
            para.append(lines[i].strip())
            i += 1
        text = " ".join(para)
        out.append(f"<p>{inline(text)}</p>")

        # Queue any figure this paragraph cites, once each. Handles the
        # singular ("Figure 3"), the plural, and lists ("Figures 10 and 11").
        cited: set[int] = set()
        for group in re.findall(
            r"Figures?\s+(\d+(?:\s*(?:,|and)\s*\d+)*)", text
        ):
            cited.update(int(x) for x in re.findall(r"\d+", group))
        for n in sorted(cited):
            if n in FIGURES and n not in seen:
                seen.add(n)
                pending.append(n)
        flush_figures()

    flush_figures()
    return "\n".join(out)


def main() -> int:
    if not REPORT.exists():
        print(f"error: {REPORT} not found", file=sys.stderr)
        return 1

    md = REPORT.read_text(encoding="utf-8")

    # The Markdown title block is replaced by a proper cover page; drop
    # everything before the first horizontal rule.
    parts = md.split("\n---\n", 1)
    body_md = parts[1] if len(parts) == 2 else md

    document = (
        "<!doctype html><html><head><meta charset='utf-8'>"
        "<title>Group 22 — Final Project Submission</title>"
        f"<style>{CSS}</style></head><body>"
        + cover_html()
        + convert(body_md)
        + "</body></html>"
    )

    OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
    OUT_HTML.write_text(document, encoding="utf-8")
    print(f"html  -> {OUT_HTML}  ({len(document) // 1024} KB)")

    browser = next((b for b in BROWSERS if b.exists()), None)
    if browser is None:
        print("error: no Chrome or Edge found to print the PDF", file=sys.stderr)
        return 1

    if OUT_PDF.exists():
        OUT_PDF.unlink()

    profile = OUT_HTML.parent / ".chrome-profile"
    subprocess.run(
        [
            str(browser),
            "--headless",
            "--disable-gpu",
            "--no-sandbox",
            f"--user-data-dir={profile}",
            "--no-pdf-header-footer",
            f"--print-to-pdf={OUT_PDF}",
            OUT_HTML.as_uri(),
        ],
        check=True,
        capture_output=True,
        timeout=180,
    )
    shutil.rmtree(profile, ignore_errors=True)

    if not OUT_PDF.exists():
        print("error: the browser did not produce a PDF", file=sys.stderr)
        return 1

    print(f"pdf   -> {OUT_PDF}  ({OUT_PDF.stat().st_size // 1024} KB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
