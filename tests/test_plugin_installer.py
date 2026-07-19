#!/usr/bin/env python3

import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "plugin_installer", ROOT / "scripts/plugins/install_plugin.py")
INSTALLER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(INSTALLER)


class PluginInstallerPathTests(unittest.TestCase):
    def test_accepts_nested_package_path(self):
        self.assertEqual(
            INSTALLER.safe_relative_path("components/Widget.qml"),
            Path("components/Widget.qml"))

    def test_rejects_parent_escape(self):
        with self.assertRaises(ValueError):
            INSTALLER.safe_relative_path("../Widget.qml")

    def test_rejects_absolute_path(self):
        with self.assertRaises(ValueError):
            INSTALLER.safe_relative_path("/tmp/Widget.qml")


if __name__ == "__main__":
    unittest.main()
