import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property var projects: []
    property bool loading: false
    property string error: ""
    readonly property bool available: projects.length > 0
    readonly property string scannerPath: `${Directories.scriptPath}/wallpapers/wallpaper_engine.py`
    readonly property string runnerPath: `${Directories.scriptPath}/wallpapers/wallpaper-engine.sh`

    signal refreshed()
    signal applied(string projectId)

    function load() {
        if (!Config.ready || scanProcess.running) return;
        refresh();
    }

    function refresh() {
        root.loading = true;
        root.error = "";
        scanProcess.command = ["python3", root.scannerPath, "--root", Config.options.wallpaperSelector.wallpaperEngine.libraryPath];
        scanProcess.running = true;
    }

    function apply(project) {
        if (!project || !project.path) return;
        Config.options.wallpaperSelector.wallpaperEngine.activeProject = project.id;
        Config.options.wallpaperSelector.wallpaperEngine.activePath = project.path;
        Config.options.wallpaperSelector.wallpaperEngine.activePreview = project.preview;
        Quickshell.execDetached([
            root.runnerPath, "apply", project.path,
            String(Config.options.wallpaperSelector.wallpaperEngine.fps),
            Config.options.wallpaperSelector.wallpaperEngine.scaling,
            Config.options.wallpaperSelector.wallpaperEngine.silent ? "true" : "false"
        ]);
        if (project.preview)
            Wallpapers.applyColorsOnly(project.preview, Appearance.m3colors.darkmode);
        root.applied(project.id);
    }

    function stop() {
        Quickshell.execDetached([root.runnerPath, "stop"]);
        Config.options.wallpaperSelector.wallpaperEngine.activeProject = "";
        Config.options.wallpaperSelector.wallpaperEngine.activePath = "";
        Config.options.wallpaperSelector.wallpaperEngine.activePreview = "";
    }

    Process {
        id: scanProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    root.projects = Array.isArray(parsed) ? parsed : [];
                } catch (e) {
                    root.projects = [];
                    root.error = `Could not read Wallpaper Engine projects: ${e}`;
                }
            }
        }
        onExited: exitCode => {
            root.loading = false;
            if (exitCode !== 0)
                root.error = "Wallpaper Engine library scan failed";
            root.refreshed();
        }
    }
}
