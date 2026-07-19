#!/usr/bin/env python3
"""Structural guarantees for the shared expressive library and widget plugins."""

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
DESIGN_SYSTEM = ROOT / "modules/common/plugins/designsystem"
PLUGIN_ROOT = ROOT / "modules/common/plugins/bundled"
PLUGIN_DIRS = (
    "nandoroid-clock",
    "nandoroid-at-a-glance",
    "nandoroid-media",
    "nandoroid-system-monitor",
    "nandoroid-weather",
    "nandoroid-currency",
)
EXPECTED_OPTIONS = {
    "nandoroid-clock": {"style", "showDate"},
    "nandoroid-at-a-glance": {
        "showGreeting", "showDate", "showEvents", "showQuote", "alignment", "fontSize"
    },
    "nandoroid-media": {"showLyrics", "useRomaji"},
    "nandoroid-system-monitor": {"vertical"},
    "nandoroid-weather": {"sizeMode"},
    "nandoroid-currency": {"sizeMode", "baseCurrency", "quote1", "quote2", "quote3", "quote4"},
}
EXPECTED_ENTRY_TYPES = {
    "nandoroid-clock": "Expressive.NandoClock",
    "nandoroid-at-a-glance": "Expressive.AtAGlance",
    "nandoroid-media": "Expressive.DesktopMediaWidget",
    "nandoroid-system-monitor": "Expressive.DesktopSystemMonitorWidget",
    "nandoroid-weather": "Expressive.DesktopWeatherWidget",
    "nandoroid-currency": "Expressive.DesktopCurrencyWidget",
}


class ExpressiveDesignSystemTest(unittest.TestCase):
    def test_library_is_not_a_plugin(self):
        self.assertFalse((DESIGN_SYSTEM / "manifest.json").exists())
        self.assertTrue((DESIGN_SYSTEM / "ExpressiveTokens.qml").exists())
        self.assertTrue((DESIGN_SYSTEM / "ComponentRegistry.qml").exists())

    def test_complete_widget_source_is_present(self):
        qml_files = list((DESIGN_SYSTEM / "widgets").rglob("*.qml"))
        self.assertGreaterEqual(len(qml_files), 94)
        weather_icons = list((ROOT / "assets/icons/google-weather").glob("*.svg"))
        self.assertEqual(len(weather_icons), 60)

    def test_nandoroid_scale_compatibility_is_finite(self):
        appearance = (ROOT / "modules/common/Appearance.qml").read_text(encoding="utf-8")
        self.assertIn("readonly property real effectiveScale: 1.0", appearance)

    def test_user_widgets_are_independent_attributed_plugins(self):
        ids = set()
        for directory in PLUGIN_DIRS:
            package = PLUGIN_ROOT / directory
            manifest = json.loads((package / "manifest.json").read_text(encoding="utf-8"))
            self.assertNotIn(manifest["id"], ids)
            ids.add(manifest["id"])
            self.assertTrue(manifest.get("author"))
            self.assertEqual(manifest.get("license"), "AGPL-3.0")
            self.assertTrue(manifest.get("sourceUrl"))
            self.assertTrue(manifest.get("upstreamRevision"))
            self.assertEqual(manifest["desktopWidget"]["component"], "Widget.qml")
            self.assertTrue((package / "Widget.qml").exists())
            option_keys = {option["key"] for option in manifest.get("options", [])}
            self.assertEqual(option_keys, EXPECTED_OPTIONS[directory])

            wrapper = (package / "Widget.qml").read_text(encoding="utf-8")
            self.assertNotIn("target: Config.options", wrapper)
            self.assertIn(EXPECTED_ENTRY_TYPES[directory], wrapper)
            self.assertIn("width: implicitWidth", wrapper)
            self.assertIn("height: implicitHeight", wrapper)
            for option_key in option_keys:
                self.assertIn(f'PluginState.option("{manifest["id"]}", "{option_key}"', wrapper)

    def test_currency_is_startup_safe(self):
        currency = json.loads(
            (PLUGIN_ROOT / "nandoroid-currency" / "manifest.json").read_text(encoding="utf-8")
        )
        self.assertTrue(currency["startupSafe"])
        self.assertNotIn("defaultWidth", currency)
        self.assertNotIn("defaultHeight", currency)
        background = (ROOT / "modules/ii/background/Background.qml").read_text(encoding="utf-8")
        self.assertIn("modelData.startupSafe !== false", background)
        host = (ROOT / "modules/common/plugins/PluginWidget.qml").read_text(encoding="utf-8")
        self.assertIn("id: blurredBackdrop\n        z: -1", host)
        self.assertIn("id: pluginNode\n        z: 1", host)
        currency_widget = (
            DESIGN_SYSTEM / "widgets" / "DesktopCurrencyWidget.qml"
        ).read_text(encoding="utf-8")
        self.assertNotIn("Config.options.appearance.currencyWidget.baseCurrency =", currency_widget)
        self.assertNotIn("Config.options.appearance.currencyWidget.quote", currency_widget)
        self.assertIn("signal baseCurrencyRequested", currency_widget)
        self.assertIn("signal quoteCurrencyRequested", currency_widget)
        self.assertIn("signal sizeModeRequested", currency_widget)


if __name__ == "__main__":
    unittest.main()
