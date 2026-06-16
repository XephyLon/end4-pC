pragma ComponentBehavior: Bound
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import qs.modules.ii.sidebarRight.quickToggles.androidStyle

AbstractQuickPanel {
    id: root
    property bool editMode: false
    Layout.fillWidth: true

    // Sizes
    implicitHeight: contentItem.implicitHeight + root.padding * 2
    Behavior on implicitHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    property real spacing: 6
    property real padding: 6
    readonly property real baseCellWidth: {
        const availableWidth = root.width - (root.padding * 2) - (root.spacing * (root.columns))
        return availableWidth / root.columns
    }
    readonly property real baseCellHeight: 56

    // Toggles
    readonly property list<string> availableToggleTypes: ["network", "bluetooth", "idleInhibitor", "easyEffects", "nightLight", "darkMode", "cloudflareWarp", "gameMode", "screenSnip", "colorPicker", "onScreenKeyboard", "mic", "audio", "notifications", "powerProfile", "musicRecognition", "antiFlashbang"]
    readonly property int columns: Config.options.sidebar.quickToggles.android.columns
    readonly property list<var> toggles: Config.ready ? Config.options.sidebar.quickToggles.android.toggles : []
    readonly property list<var> unusedToggles: {
        const types = availableToggleTypes.filter(type => !toggles.some(toggle => (toggle && toggle.type === type)))
        return types.map(type => { return { type: type, size: 1 } })
    }

    // Drag state 
    property int draggingIndex: -1

    function findNewIndex(dragX, dragY) {
        let newIndex = draggingIndex
        let minDist = Infinity
        for (let i = 0; i < usedRepeater.count; i++) {
            if (i === draggingIndex) continue
            const child = usedRepeater.itemAt(i)
            if (!child) continue
            const childCenter = child.mapToItem(null, child.width / 2, child.height / 2)
            const dx = dragX - childCenter.x
            const dy = dragY - childCenter.y
            const dist = Math.sqrt(dx * dx + dy * dy)
            if (dist < minDist) {
                minDist = dist
                newIndex = i
            }
        }
        return newIndex
    }

    function handleDragStart(index) {
        draggingIndex = index
    }

    function handleDragMove(index, dragX, dragY) {
        const newIndex = findNewIndex(dragX, dragY)
        if (newIndex !== index && newIndex >= 0) {
            const refChild = usedRepeater.itemAt(newIndex)
            if (refChild) {
                const refLocal = refChild.mapToItem(usedFlow, 0, 0)
                dropIndicator.x = newIndex < index
                    ? refLocal.x - 5
                    : refLocal.x + refChild.width + 1
                dropIndicator.y = refLocal.y
                dropIndicator.height = refChild.height
                dropIndicator.visible = true
                dropIndicator.targetIndex = newIndex
            }
        } else {
            dropIndicator.visible = false
            dropIndicator.targetIndex = -1
        }
    }

    function handleDragEnd(index, dragX, dragY) {
        dropIndicator.visible = false
        dropIndicator.targetIndex = -1
        draggingIndex = -1

        const newIndex = findNewIndex(dragX, dragY)
        if (newIndex !== index && newIndex >= 0) {
            let list = root.toggles.slice()
            const item = list.splice(index, 1)[0]
            list.splice(newIndex, 0, item)
            Config.options.sidebar.quickToggles.android.toggles = list
        }
    }

    Column {
        id: contentItem
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 12

        // Used toggles 
        Item {
            width: parent.width
            implicitHeight: usedFlow.implicitHeight

            Flow {
                id: usedFlow
                anchors.fill: parent
                spacing: root.spacing

                Repeater {
                    id: usedRepeater
                    model: ScriptModel {
                        values: root.toggles
                    }

                    delegate: AndroidToggleDelegateChooser {
                        property int index: 0       
                        property var modelData: null   

                        startingIndex: index
                        editMode: root.editMode
                        baseCellWidth: root.baseCellWidth
                        baseCellHeight: root.baseCellHeight
                        spacing: root.spacing

                        onDragStart: (idx) => root.handleDragStart(idx)
                        onDragMove: (idx, x, y) => root.handleDragMove(idx, x, y)
                        onDragEnd: (idx, x, y) => root.handleDragEnd(idx, x, y)

                        onOpenAudioOutputDialog: root.openAudioOutputDialog()
                        onOpenAudioInputDialog: root.openAudioInputDialog()
                        onOpenBluetoothDialog: root.openBluetoothDialog()
                        onOpenNightLightDialog: root.openNightLightDialog()
                        onOpenWifiDialog: root.openWifiDialog()
                    }
                }
            }

            // Drop indicator
            Rectangle {
                id: dropIndicator
                property int targetIndex: -1
                visible: false
                width: 3
                height: 56
                radius: 2
                color: Appearance.colors.colPrimary
                z: 10

                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: -4
                    width: 8; height: 8; radius: 4
                    color: Appearance.colors.colPrimary
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -4
                    width: 8; height: 8; radius: 4
                    color: Appearance.colors.colPrimary
                }
            }
        }

        // Separator
        FadeLoader {
            shown: root.editMode
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: root.baseCellHeight / 2
                rightMargin: root.baseCellHeight / 2
            }
            sourceComponent: Rectangle {
                implicitHeight: 1
                color: Appearance.colors.colOutlineVariant
            }
        }

        // Unused toggles 
        FadeLoader {
            shown: root.editMode
            width: parent.width
            sourceComponent: Flow {
                id: unusedFlow
                width: parent?.width ?? 0
                spacing: root.spacing

                Repeater {
                    model: ScriptModel {
                        values: root.unusedToggles
                    }
                    delegate: AndroidToggleDelegateChooser {
                        property int index: 0
                        property var modelData: null
                        startingIndex: -1
                        editMode: root.editMode
                        baseCellWidth: root.baseCellWidth
                        baseCellHeight: root.baseCellHeight
                        spacing: root.spacing
                    }
                }
            }
        }
        ConfigSpinBox {
            width: parent.width 
            enabled: Config.options.sidebar.quickToggles.style === "android"
            visible: root.editMode
            icon: "add_column_left"
            text: Translation.tr("Columns")
            value: Config.options.sidebar.quickToggles.android.columns
            from: 1
            to: 8
            stepSize: 1
            onValueChanged: {
                Config.options.sidebar.quickToggles.android.columns = value;
            }
        }
    }
}
