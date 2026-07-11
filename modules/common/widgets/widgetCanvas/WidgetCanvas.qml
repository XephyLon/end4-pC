import QtQuick
import qs.modules.common

MouseArea {
    id: root
    property int gridSize: 24
    property bool showGrid: false
    readonly property bool isWidgetCanvas: true

    function setDragging(active) {
        root.showGrid = active
    }

    Repeater {
        model: root.showGrid ? Math.ceil(root.width / root.gridSize) : 0
        delegate: Rectangle {
            required property int index
            x: index * root.gridSize
            width: 1
            height: root.height
            color: Appearance.colors.colLayer0Border
        }
    }

    Repeater {
        model: root.showGrid ? Math.ceil(root.height / root.gridSize) : 0
        delegate: Rectangle {
            required property int index
            y: index * root.gridSize
            width: root.width
            height: 1
            color: Appearance.colors.colLayer0Border
        }
    }
}