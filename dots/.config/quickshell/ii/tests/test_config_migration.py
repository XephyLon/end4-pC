#!/usr/bin/env python3
import os, subprocess, tempfile, unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATE = ROOT / "scripts/migrate-config-dir.sh"


class ConfigMigrationTests(unittest.TestCase):
    def _run(self, home):
        subprocess.run(["bash", str(MIGRATE)],
                       env=dict(os.environ, HOME=str(home)), check=True)

    def test_moves_old_dir_when_new_absent(self):
        with tempfile.TemporaryDirectory() as d:
            home = Path(d)
            old = home / ".config/illogical-impulse"
            old.mkdir(parents=True)
            (old / "config.json").write_text('{"marker": 1}')
            self._run(home)
            new = home / ".config/immaterial-impulse"
            self.assertTrue(new.is_dir())
            self.assertEqual((new / "config.json").read_text(), '{"marker": 1}')
            self.assertFalse(old.exists())

    def test_noop_when_new_exists(self):
        with tempfile.TemporaryDirectory() as d:
            home = Path(d)
            (home / ".config/illogical-impulse").mkdir(parents=True)
            new = home / ".config/immaterial-impulse"
            new.mkdir(parents=True)
            (new / "config.json").write_text('{"keep": 1}')
            self._run(home)
            self.assertEqual((new / "config.json").read_text(), '{"keep": 1}')
            self.assertTrue((home / ".config/illogical-impulse").exists())

    def test_noop_when_nothing_to_migrate(self):
        with tempfile.TemporaryDirectory() as d:
            self._run(Path(d))  # must exit 0, create nothing


if __name__ == "__main__":
    unittest.main()
