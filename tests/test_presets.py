#!/usr/bin/env python3
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PRESETS = ROOT / "scripts/presets.sh"


class PresetTests(unittest.TestCase):
    def test_wallpaper_engine_preset_transitions_before_runtime_swap(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            config_dir = home / ".config/illogical-impulse"
            script_dir = home / ".config/quickshell/end4-pC/scripts"
            wallpaper_dir = script_dir / "wallpapers"
            colors_dir = script_dir / "colors"
            bin_dir = home / "bin"
            project_dir = home / "workshop/123"
            for path in (config_dir / "presets", wallpaper_dir, colors_dir, bin_dir, project_dir):
                path.mkdir(parents=True, exist_ok=True)
            event_log = home / "events.log"

            current = {
                "background": {"wallpaperPath": "/tmp/static-before.jpg"},
                "wallpaperSelector": {"wallpaperEngine": {
                    "activeProject": "", "activePath": "", "activeStill": "", "activePreview": "",
                }},
            }
            target = {
                **current,
                "wallpaperSelector": {"wallpaperEngine": {
                    "activeProject": "123", "activePath": str(project_dir),
                    "activeStill": "/tmp/123.png", "activePreview": "/tmp/123-preview.jpg",
                    "fps": 30, "scaling": "fill", "silent": True,
                }},
            }
            (config_dir / "config.json").write_text(json.dumps(current))
            (config_dir / "plugin-state.json").write_text(json.dumps({
                "version": 2, "desktopPositions": {}, "pluginOptions": {},
            }))
            (config_dir / "presets/live.json").write_text(json.dumps(target))

            helpers = {
                colors_dir / "switchwall.sh": 'printf "theme\\n" >> "$PRESET_EVENT_LOG"',
                wallpaper_dir / "wallpaper-engine.sh": 'printf "runtime %s\\n" "$1" >> "$PRESET_EVENT_LOG"',
                bin_dir / "qs": 'printf "transition %s\\n" "$*" >> "$PRESET_EVENT_LOG"',
            }
            for helper, body in helpers.items():
                helper.write_text(f"#!/usr/bin/env bash\n{body}\n")
                helper.chmod(0o755)

            env = dict(os.environ,
                HOME=str(home),
                PATH=f"{bin_dir}:{os.environ.get('PATH', '')}",
                PRESET_EVENT_LOG=str(event_log))
            subprocess.run(["bash", str(PRESETS), "--apply", "live"], env=env, check=True)

            events = event_log.read_text().splitlines()
            self.assertEqual(events[0], "theme")
            self.assertTrue(events[1].startswith("transition -p "))
            self.assertEqual(events[2], "runtime apply")
            self.assertIn("/tmp/static-before.jpg", events[1])
            self.assertIn("/tmp/123-preview.jpg", events[1])

    def test_wallpaper_transition_paths_share_the_selected_animation(self):
        engine = (ROOT / "services/WallpaperEngine.qml").read_text()
        selector = (ROOT / "modules/ii/wallpaperSelector/WallpaperSelector.qml").read_text()
        background = (ROOT / "modules/ii/background/Background.qml").read_text()

        self.assertIn("root.requestTransition(fromStill, project.previousPreview", engine)
        self.assertIn('target: "wallpaperEngine"', selector)
        self.assertIn("WallpaperEngine.requestTransition", selector)
        self.assertIn("onWallpaperPathChanged:", background)
        self.assertIn("transitionAnim.restart()", background)
        self.assertIn("function onScreenLockedChanged()", background)
        self.assertIn("bgRoot.wallpaperEngineLockProgress = GlobalStates.screenLocked ? 1 : 0", background)

    def test_live_plugin_widgets_resync_when_persisted_state_changes(self):
        widget = (ROOT / "modules/common/plugins/PluginWidget.qml").read_text()

        self.assertIn("function applyPersistedPosition()", widget)
        self.assertIn("onCurrentConfigChanged: applyPersistedPosition()", widget)
        self.assertIn("Component.onCompleted: applyPersistedPosition()", widget)

    def test_plugin_positions_round_trip_without_replacing_options(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            config_dir = home / ".config/illogical-impulse"
            script_dir = home / ".config/quickshell/end4-pC/scripts"
            wallpaper_dir = script_dir / "wallpapers"
            colors_dir = script_dir / "colors"
            config_dir.mkdir(parents=True)
            wallpaper_dir.mkdir(parents=True)
            colors_dir.mkdir(parents=True)

            config_file = config_dir / "config.json"
            state_file = config_dir / "plugin-state.json"
            config_file.write_text(json.dumps({
                "background": {"wallpaperPath": "/tmp/wallpaper.jpg"},
                "wallpaperSelector": {"wallpaperEngine": {"activePath": ""}},
            }))
            state_file.write_text(json.dumps({
                "version": 2,
                "desktopPositions": {
                    "DP-1": {"weather": {"x": 120, "y": 240, "placementStrategy": "free"}}
                },
                "pluginOptions": {"weather": {"blurEnabled": True}},
            }))

            for helper in (wallpaper_dir / "wallpaper-engine.sh", colors_dir / "switchwall.sh"):
                helper.write_text("#!/usr/bin/env bash\nexit 0\n")
                helper.chmod(0o755)

            env = dict(os.environ, HOME=str(home))
            subprocess.run(["bash", str(PRESETS), "--save", "layout"], env=env, check=True)
            preset = json.loads((config_dir / "presets/layout.json").read_text())
            self.assertEqual(preset["_pluginState"]["desktopPositions"]["DP-1"]["weather"]["x"], 120)

            state_file.write_text(json.dumps({
                "version": 2,
                "desktopPositions": {"DP-1": {"weather": {"x": 999, "y": 999}}},
                "pluginOptions": {"weather": {"blurEnabled": False, "fontSize": 24}},
            }))
            subprocess.run(["bash", str(PRESETS), "--apply", "layout"], env=env, check=True)

            restored = json.loads(state_file.read_text())
            self.assertEqual(restored["desktopPositions"]["DP-1"]["weather"]["x"], 120)
            self.assertEqual(restored["pluginOptions"]["weather"], {
                "blurEnabled": False,
                "fontSize": 24,
            })
            self.assertNotIn("_pluginState", json.loads(config_file.read_text()))

    def test_legacy_preset_keeps_current_plugin_positions(self):
        source = PRESETS.read_text()
        self.assertIn('._pluginState.desktopPositions // empty', source)
        self.assertIn('if [ -n "$preset_positions" ]', source)


if __name__ == "__main__":
    unittest.main()
