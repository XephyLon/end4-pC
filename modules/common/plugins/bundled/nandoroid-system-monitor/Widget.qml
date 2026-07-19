import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import "../../designsystem/widgets" as Expressive

Item {
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Expressive.DesktopSystemMonitorWidget {
        id: content
        width: implicitWidth
        height: implicitHeight
        isVertical: PluginState.option("nandoroid_system_monitor", "vertical", false)
    }
}
