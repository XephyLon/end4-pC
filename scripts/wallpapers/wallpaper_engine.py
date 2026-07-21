#!/usr/bin/env python3
"""Discover installed Steam Wallpaper Engine projects without loading their assets."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


DEFAULT_ROOTS = (
    Path.home() / ".local/share/Steam/steamapps/workshop/content/431960",
    Path.home() / ".steam/steam/steamapps/workshop/content/431960",
)


def project_roots(configured: str) -> list[Path]:
    if configured:
        candidates = [Path(configured).expanduser()]
    else:
        candidates = list(DEFAULT_ROOTS)
    for steam_root in (() if configured else (Path.home() / ".local/share/Steam", Path.home() / ".steam/steam")):
        libraries = steam_root / "steamapps/libraryfolders.vdf"
        try:
            contents = libraries.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for library in re.findall(r'"path"\s+"([^"]+)"', contents):
            candidates.append(Path(library.replace("\\\\", "\\")) / "steamapps/workshop/content/431960")
    roots: list[Path] = []
    for candidate in candidates:
        resolved = candidate.resolve()
        if resolved.is_dir() and resolved not in roots:
            roots.append(resolved)
    return roots


def scan(configured: str) -> list[dict[str, object]]:
    projects: list[dict[str, object]] = []
    for root in project_roots(configured):
        for manifest in sorted(root.glob("*/project.json")):
            try:
                data = json.loads(manifest.read_text(encoding="utf-8-sig"))
            except (OSError, UnicodeError, json.JSONDecodeError):
                continue
            directory = manifest.parent
            preview_name = data.get("preview", "")
            preview = directory / preview_name if isinstance(preview_name, str) else Path()
            if not preview.is_file():
                preview = next(
                    (path for name in ("preview.jpg", "preview.png", "preview.gif") if (path := directory / name).is_file()),
                    Path(),
                )
            projects.append({
                "id": directory.name,
                "title": str(data.get("title") or directory.name),
                "type": str(data.get("type") or "unknown"),
                "tags": data.get("tags") if isinstance(data.get("tags"), list) else [],
                "path": str(directory),
                "preview": str(preview) if preview else "",
            })
    projects.sort(key=lambda item: str(item["title"]).casefold())
    return projects


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default="")
    args = parser.parse_args()
    print(json.dumps(scan(args.root), ensure_ascii=False))


if __name__ == "__main__":
    main()
