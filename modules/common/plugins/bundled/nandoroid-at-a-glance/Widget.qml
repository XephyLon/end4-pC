import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import "../../designsystem/widgets" as Expressive

Item {
    // The original At-a-Glance widget is typography without a card.
    readonly property var blurRegions: []
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight
    Expressive.AtAGlance {
        id: content
        width: implicitWidth
        height: implicitHeight
        cfg: ({
            showGreeting: PluginState.option("nandoroid_at_a_glance", "showGreeting", true),
            showDate: PluginState.option("nandoroid_at_a_glance", "showDate", true),
            showEvents: PluginState.option("nandoroid_at_a_glance", "showEvents", true),
            showQuote: PluginState.option("nandoroid_at_a_glance", "showQuote", true),
            alignment: PluginState.option("nandoroid_at_a_glance", "alignment", "left"),
            fontSize: PluginState.option("nandoroid_at_a_glance", "fontSize", 24),
            customWidth: 0,
            fontFamily: "",
            greetingColorStyle: "primary",
            dateColorStyle: "onLayer1",
            quoteColorStyle: "onLayer1",
            locked: false
        })
    }
}
