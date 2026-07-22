import QtQuick
import Quickshell.WallpaperEngine

// Thin wrapper around the embedded Wallpaper Engine surface. Kept in its own
// file and loaded via a source-URL Loader so that on a Quickshell binary
// WITHOUT the Quickshell.WallpaperEngine module compiled in (the stock build),
// only this Loader fails - the rest of Background.qml, and the static-image
// wallpaper path, keep working.
WallpaperEngineSurface {
    live: true
    fps: 60
}
