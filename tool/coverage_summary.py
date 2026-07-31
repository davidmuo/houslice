"""Prints a coverage summary from coverage/lcov.info.

`flutter test --coverage` writes lcov.info but no readable summary, and lcov's
own genhtml is not installed on Windows by default. This reads the tracefile
directly and reports the total plus a per-feature breakdown:

    flutter test --coverage
    python tool/coverage_summary.py
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LCOV = ROOT / "coverage" / "lcov.info"


def area_of(source: str) -> str:
    """Groups a source path into the area shown in the breakdown."""
    parts = source.replace("\\", "/").split("/")
    if "features" in parts:
        i = parts.index("features")
        if i + 1 < len(parts):
            return f"features/{parts[i + 1]}"
    if "core" in parts:
        return "core"
    return "lib (root)"


def main() -> int:
    if not LCOV.exists():
        print("coverage/lcov.info not found — run: flutter test --coverage")
        return 1

    found: defaultdict[str, int] = defaultdict(int)
    hit: defaultdict[str, int] = defaultdict(int)
    current = ""

    for line in LCOV.read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            current = area_of(line[3:])
        elif line.startswith("DA:"):
            _, _, payload = line.partition(":")
            _, _, count = payload.partition(",")
            found[current] += 1
            if int(count or 0) > 0:
                hit[current] += 1

    if not found:
        print("no coverage data in lcov.info")
        return 1

    total_found = sum(found.values())
    total_hit = sum(hit.values())

    print("Houseslice — test coverage")
    print("-" * 52)
    for area in sorted(found, key=lambda a: -found[a]):
        pct = hit[area] / found[area] * 100 if found[area] else 0.0
        print(f"  {area:<28} {pct:5.1f}%   {hit[area]:>5} / {found[area]:<5}")
    print("-" * 52)
    print(
        f"  {'TOTAL':<28} {total_hit / total_found * 100:5.1f}%   "
        f"{total_hit:>5} / {total_found:<5}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
