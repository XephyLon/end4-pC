#!/usr/bin/env python3
import subprocess, unittest
from pathlib import Path

LIB = Path(__file__).resolve().parents[1] / "lib/migrate-existing.sh"


def run(installed_list):
    fake = f"printf '%s\\n' {installed_list}"
    return subprocess.run(
        ["bash", "-c", f'IMI_PKG_QUERY_CMD="{fake}" source "{LIB}"; has_legacy_packages && echo YES || echo NO'],
        capture_output=True, text=True,
    ).stdout.strip()


class MigrateDetectTests(unittest.TestCase):
    def test_detects_legacy(self):
        self.assertEqual(run("illogical-impulse-basic illogical-impulse-audio foo"), "YES")

    def test_no_legacy(self):
        self.assertEqual(run("immaterial-impulse-basic bar"), "NO")


if __name__ == "__main__":
    unittest.main()
