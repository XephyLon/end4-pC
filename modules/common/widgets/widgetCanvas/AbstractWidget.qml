import QtQuick
import Quickshell
import qs.modules.common

/*
 * Widget to be placed on a WidgetCanvas
 */
MouseArea {
    id: root
    property alias animateXPos: xBehavior.enabled
    property alias animateYPos: yBehavior.enabled
    property bool draggable: true
    property int gridSize: 6
    property bool snapEnabled: true
    readonly property bool dragging: drag.active

    drag.target: draggable ? dragProxy : undefined
    cursorShape: (draggable && containsPress) ? Qt.ClosedHandCursor : draggable ? Qt.OpenHandCursor : Qt.ArrowCursor

    function center() {
        root.x = (root.parent.width - root.width) / 2
        root.y = (root.parent.height - root.height) / 2
    }

    function snap(value) {
        return Math.round(value / root.gridSize) * root.gridSize
    }

    function findCanvas(item) {
        var p = item
        while (p) {
            if (p.isWidgetCanvas === true) return p
            p = p.parent
        }
        return null
    }

    Item {
        id: dragProxy
        parent: root.parent
        x: root.x
        y: root.y
    }

    Binding {
        target: root
        property: "x"
        value: root.snapEnabled ? root.snap(dragProxy.x) : dragProxy.x
        when: root.dragging
        restoreMode: Binding.RestoreNone
    }
    Binding {
        target: root
        property: "y"
        value: root.snapEnabled ? root.snap(dragProxy.y) : dragProxy.y
        when: root.dragging
        restoreMode: Binding.RestoreNone
    }

    onDraggingChanged: {
        var canvas = findCanvas(root.parent)
        if (canvas) canvas.setDragging(dragging)

        if (dragging) {
            dragProxy.x = root.x
            dragProxy.y = root.y
        } else {
            dragProxy.x = root.x
            dragProxy.y = root.y
        }
    }

    Behavior on x {
        id: xBehavior
        enabled: !root.dragging
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    Behavior on y {
        id: yBehavior
        enabled: !root.dragging
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
}