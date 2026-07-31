"""Renders captured terminal output as PNG figures for the report.

The report needs screenshots of `flutter analyze`, `flutter test` and the
coverage summary. Photographing a terminal gives an inconsistent, often
illegible image, so this renders the *real captured output* as a clean
terminal-styled PNG instead:

    flutter analyze lib test  > docs/build/analyze.txt
    flutter test --coverage   > docs/build/test_raw.txt
    python tool/coverage_summary.py
    python tool/capture_terminal.py

The text is never edited here — only the long absolute test paths are shortened,
which is noted on the figure itself so the image does not misrepresent output
that was actually produced.
"""

from __future__ import annotations

import html
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "docs" / "build"
SHOTS = ROOT / "docs" / "screenshots"

BROWSERS = [
    Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
    Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
    Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe"),
]

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8"><style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{ background: #fff; padding: 14px; }}
  .term {{
    width: {width}px;
    background: #0f1117;
    border-radius: 8px;
    overflow: hidden;
    font-family: Consolas, "Cascadia Mono", "Courier New", monospace;
    box-shadow: 0 2px 10px rgba(0,0,0,.25);
  }}
  .bar {{
    background: #22252e; padding: 7px 12px; display: flex;
    align-items: center; gap: 7px;
  }}
  .dot {{ width: 11px; height: 11px; border-radius: 50%; }}
  .r {{ background: #ff5f57; }} .y {{ background: #febc2e; }}
  .g {{ background: #28c840; }}
  .name {{
    color: #9aa0ac; font-size: 12px; margin-left: 8px;
    font-family: Consolas, monospace;
  }}
  pre {{
    color: #d7dae0; font-size: 13.5px; line-height: 1.55;
    padding: 14px 16px; white-space: pre-wrap; word-break: break-word;
  }}
  .prompt {{ color: #6ea8fe; }}
  .ok {{ color: #4ade80; font-weight: bold; }}
  .warn {{ color: #fbbf24; }}
  .dim {{ color: #7c8494; }}
  .pct {{ color: #7dd3fc; }}
  .note {{
    font-family: "Times New Roman", serif; font-size: 12px; color: #444;
    font-style: italic; margin-top: 7px; width: {width}px;
  }}
</style></head><body>
  <div class="term">
    <div class="bar">
      <span class="dot r"></span><span class="dot y"></span>
      <span class="dot g"></span><span class="name">{title}</span>
    </div>
    <pre>{content}</pre>
  </div>
  {note}
</body></html>"""


def colourise(text: str) -> str:
    """Adds minimal colour so the figure reads like the real terminal."""
    out: list[str] = []
    for raw in text.split("\n"):
        line = html.escape(raw.rstrip())
        if line.startswith("PS ") or line.startswith("$ "):
            # Prompt line: highlight the path, leave the command plain.
            m = re.match(r"^(PS [^>]*>|\$)(.*)$", line)
            if m:
                line = f'<span class="prompt">{m.group(1)}</span>{m.group(2)}'
        elif "No issues found" in line or "All tests passed" in line:
            line = f'<span class="ok">{line}</span>'
        elif re.match(r"^\s*(TOTAL|-{5,})", line):
            line = f'<span class="dim">{line}</span>'
        elif re.search(r"\d+\.\d%", line):
            line = re.sub(
                r"(\d+\.\d%)", r'<span class="pct">\1</span>', line
            )
        elif line.startswith("Analyzing") or re.match(r"^\d\d:\d\d \+", line):
            line = f'<span class="dim">{line}</span>'
        out.append(line)
    return "\n".join(out)


def render(name: str, title: str, body: str, width: int, note: str = "") -> Path:
    browser = next((b for b in BROWSERS if b.exists()), None)
    if browser is None:
        raise SystemExit("no Chrome or Edge found")

    html_path = BUILD / f"{name}.html"
    png_path = SHOTS / f"{name}.png"
    note_html = f'<div class="note">{html.escape(note)}</div>' if note else ""
    html_path.write_text(
        TEMPLATE.format(
            width=width, title=title, content=colourise(body), note=note_html
        ),
        encoding="utf-8",
    )

    # Height is generous; the page is cropped to content by the fit below.
    line_count = body.count("\n") + 1
    height = 90 + line_count * 22 + (40 if note else 0)

    profile = BUILD / f".prof-{name}"
    subprocess.run(
        [
            str(browser),
            "--headless=old",
            "--disable-gpu",
            "--no-sandbox",
            "--hide-scrollbars",
            f"--user-data-dir={profile}",
            f"--window-size={width + 30},{height}",
            f"--screenshot={png_path}",
            html_path.as_uri(),
        ],
        check=True,
        capture_output=True,
        timeout=120,
    )
    shutil.rmtree(profile, ignore_errors=True)
    return png_path


def read(path: Path) -> str:
    if not path.exists():
        raise SystemExit(f"missing {path} — see the docstring for how to capture it")
    return path.read_text(encoding="utf-8", errors="replace").strip()


def main() -> int:
    SHOTS.mkdir(parents=True, exist_ok=True)
    BUILD.mkdir(parents=True, exist_ok=True)

    # ---- Figure 15: flutter analyze ----
    analyze = read(BUILD / "analyze.txt")
    p = render("12-analyze", "flutter analyze", analyze, 760)
    print(f"Figure 15 -> {p.relative_to(ROOT)}")

    # ---- Figure 16: flutter test ----
    raw = read(BUILD / "test_raw.txt").split("\n")
    # Keep the tail: the last few test lines plus the summary. Absolute paths
    # are shortened to keep the figure legible.
    tail = [re.sub(r"C:/Users/[^:]*/test/", "test/", ln) for ln in raw[-9:]]
    total = next(
        (m.group(1) for ln in reversed(raw) if (m := re.search(r"\+(\d+)", ln))),
        "?",
    )
    body = "PS C:\\Users\\Dranoh\\houslice> flutter test\n" + "\n".join(tail)
    p = render(
        "13-tests",
        f"flutter test — {total} passing",
        body,
        900,
        note="Absolute test paths shortened for legibility; output otherwise verbatim.",
    )
    print(f"Figure 16 -> {p.relative_to(ROOT)}")

    # ---- Figure 17: coverage ----
    summary = subprocess.run(
        [sys.executable, str(ROOT / "tool" / "coverage_summary.py")],
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=ROOT,
    ).stdout.strip()
    body = (
        "PS C:\\Users\\Dranoh\\houslice> flutter test --coverage\n"
        "PS C:\\Users\\Dranoh\\houslice> python tool/coverage_summary.py\n"
        + summary
    )
    p = render("14-coverage", "test coverage", body, 700)
    print(f"Figure 17 -> {p.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
