#!/usr/bin/env python3
"""Guard bundled plugins against unthrottled long-running Process loops."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
PLUGIN_ROOT = ROOT / "modules/common/plugins/bundled"
STREAMING_COMMANDS = re.compile(r'\b(events|monitor|subscribe|follow)\b|["\']-f["\']')


def process_blocks(text: str):
    for match in re.finditer(r"\bProcess\s*\{", text):
        depth = 1
        index = match.end()
        quote = None
        escaped = False
        while index < len(text) and depth:
            char = text[index]
            if quote:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = None
            elif char in "\"'`":
                quote = char
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
            index += 1
        yield text[match.start():index]


failures = []
for path in PLUGIN_ROOT.rglob("*.qml"):
    for block in process_blocks(path.read_text(encoding="utf-8")):
        if STREAMING_COMMANDS.search(block) and re.search(r"\brunning\s*:\s*(?!false\b)", block):
            if "process-lifecycle: restart-safe" not in block:
                failures.append(f"{path.relative_to(ROOT)}: streaming Process has an unguarded running binding")

if failures:
    print("\n".join(failures), file=sys.stderr)
    sys.exit(1)
print("Plugin process lifecycle lint passed: no unthrottled streaming processes")
