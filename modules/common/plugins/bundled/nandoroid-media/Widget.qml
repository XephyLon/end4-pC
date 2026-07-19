import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import "../../designsystem/widgets" as Expressive

Item {
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Expressive.DesktopMediaWidget {
        id: content
        width: implicitWidth
        height: implicitHeight
        showLyrics: PluginState.option("nandoroid_media", "showLyrics", false)
        useRomaji: PluginState.option("nandoroid_media", "useRomaji", false)
    }
}
