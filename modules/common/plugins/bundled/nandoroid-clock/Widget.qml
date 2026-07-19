import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import "../../designsystem/widgets" as Expressive

Item {
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Expressive.NandoClock {
        id: content
        width: implicitWidth
        height: implicitHeight
        isLockscreen: false
        style: PluginState.option("nandoroid_clock", "style", "digital")
        showDate: PluginState.option("nandoroid_clock", "showDate", true)
    }
}
