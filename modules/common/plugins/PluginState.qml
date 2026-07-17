pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root

    readonly property int schemaVersion: 1
    readonly property string filePath: `${Directories.shellConfig}/plugin-state.json`
    property var state: root.emptyState()
    property bool ready: false

    function emptyState() {
        return {
            version: root.schemaVersion,
            desktopPositions: {}
        };
    }

    function defaultPosition() {
        return {
            x: 100,
            y: 100,
            placementStrategy: "free"
        };
    }

    function validNumber(value, fallback) {
        return typeof value === "number" && Number.isFinite(value) ? value : fallback;
    }

    function normalizedPosition(value) {
        const fallback = root.defaultPosition();
        if (!value || typeof value !== "object" || Array.isArray(value)) return fallback;
        return {
            x: root.validNumber(value.x, fallback.x),
            y: root.validNumber(value.y, fallback.y),
            placementStrategy: typeof value.placementStrategy === "string"
                ? value.placementStrategy
                : fallback.placementStrategy
        };
    }

    function position(pluginId, screenName) {
        const screens = root.state?.desktopPositions;
        const saved = screens?.[screenName]?.[pluginId];
        return root.normalizedPosition(saved);
    }

    function setPosition(pluginId, screenName, value) {
        if (!pluginId || !screenName) return;

        const nextState = Object.assign({}, root.state);
        const nextScreens = Object.assign({}, nextState.desktopPositions || {});
        const nextScreen = Object.assign({}, nextScreens[screenName] || {});
        nextScreen[pluginId] = root.normalizedPosition(value);
        nextScreens[screenName] = nextScreen;
        nextState.version = root.schemaVersion;
        nextState.desktopPositions = nextScreens;
        root.state = nextState;
        writeTimer.restart();
    }

    function loadText(text) {
        try {
            const parsed = JSON.parse(text);
            if (!parsed || typeof parsed !== "object" || Array.isArray(parsed))
                throw new Error("root value must be an object");

            root.state = {
                version: root.schemaVersion,
                desktopPositions: parsed.desktopPositions
                    && typeof parsed.desktopPositions === "object"
                    && !Array.isArray(parsed.desktopPositions)
                    ? parsed.desktopPositions
                    : {}
            };
        } catch (error) {
            console.warn("[PluginState] Ignoring invalid state file: " + error);
            root.state = root.emptyState();
        }
        root.ready = true;
    }

    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: stateFile.reload()
    }

    Timer {
        id: writeTimer
        interval: 100
        onTriggered: stateFile.setText(JSON.stringify(root.state, null, 2))
    }

    FileView {
        id: stateFile
        path: root.filePath
        watchChanges: true
        onFileChanged: reloadTimer.restart()
        onLoaded: root.loadText(stateFile.text())
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                root.state = root.emptyState();
                root.ready = true;
                writeTimer.restart();
            } else {
                console.warn("[PluginState] Failed to load state file: " + error);
            }
        }
    }
}
