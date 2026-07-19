import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import "../../designsystem/widgets" as Expressive

Item {
    readonly property var blurRegions: content.blurRegions
    readonly property bool managesBlurTint: content.managesBlurTint
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Expressive.DesktopWeatherWidget {
        id: content
        width: implicitWidth
        height: implicitHeight
        sizeMode: PluginState.option("nandoroid_weather", "sizeMode", "3x1")
        useBlurBackground: PluginState.option("nandoroid_weather", "blurEnabled", false)
        backgroundOpacity: PluginState.option("nandoroid_weather", "blurTintOpacity", 0.1)
    }
}
