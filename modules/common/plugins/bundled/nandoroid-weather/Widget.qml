import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import "../../designsystem/widgets" as Expressive

Item {
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Expressive.DesktopWeatherWidget {
        id: content
        width: implicitWidth
        height: implicitHeight
        sizeMode: PluginState.option("nandoroid_weather", "sizeMode", "3x1")
    }
}
