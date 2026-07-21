pragma Singleton
pragma ComponentBehavior: Bound

import qs
import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Automatically reloads generated material colors.
 * It is necessary to run reapplyTheme() on startup because Singletons are lazily loaded.
 */
Singleton {
    id: root
    property string filePath: Directories.generatedMaterialThemePath
    property string lockFilePath: Directories.generatedLockMaterialThemePath

    property var desktopColors: ({})
    property var lockColors: ({})

    function reapplyTheme() {
        themeFileView.reload()
    }

    function applyColorsObject(json) {
        for (const key in json) {
            if (json.hasOwnProperty(key)) {
                const camelCaseKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
                const m3Key = `m3${camelCaseKey}`
                if (Appearance.m3colors.hasOwnProperty(m3Key)) {
                    Appearance.m3colors[m3Key] = json[key]
                }
            }
        }
        Appearance.m3colors.darkmode = (Appearance.m3colors.m3background.hslLightness < 0.5)
    }

    function applyColors(fileContent) {
        const json = JSON.parse(fileContent)
        root.desktopColors = json
        if (!GlobalStates.screenLocked) applyColorsObject(json)
    }

    function applyLockColors(fileContent) {
        const json = JSON.parse(fileContent)
        root.lockColors = json
        if (GlobalStates.screenLocked) applyColorsObject(json)
    }

    function resetFilePathNextTime() {
        resetFilePathNextWallpaperChange.enabled = true
    }

    Connections {
        id: resetFilePathNextWallpaperChange
        enabled: false
        target: Config.options.background
        function onWallpaperPathChanged() {
            root.filePath = ""
            root.filePath = Directories.generatedMaterialThemePath
            resetFilePathNextWallpaperChange.enabled = false
        }
    }

    Connections {
        target: Config.options.background
        function onLockWallChanged() {
            root.lockColors = ({})
        }
    }

    Connections {
        target: GlobalStates
        function onScreenLockedChanged() {
            if (GlobalStates.screenLocked && Object.keys(root.lockColors).length > 0) {
                root.applyColorsObject(root.lockColors)
            } else if (!GlobalStates.screenLocked && Object.keys(root.desktopColors).length > 0) {
                root.applyColorsObject(root.desktopColors)
            }
        }
    }

    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        repeat: false
        running: false
        onTriggered: root.applyColors(themeFileView.text())
    }

    Timer {
        id: delayedLockFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        repeat: false
        running: false
        onTriggered: root.applyLockColors(lockThemeFileView.text())
    }

    FileView {
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: root.applyColors(themeFileView.text())
        onLoadFailed: root.resetFilePathNextTime();
    }

    FileView {
        id: lockThemeFileView
        path: Qt.resolvedUrl(root.lockFilePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedLockFileRead.start()
        }
        onLoadedChanged: {
            const content = lockThemeFileView.text()
            if (content && content.length > 0) root.applyLockColors(content)
        }
        onLoadFailed: {}
    }
}