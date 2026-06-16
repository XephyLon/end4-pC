import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.functions
import qs.modules.common.widgets

GroupButton {
    id: root
    
    required property int buttonIndex
    required property var buttonData
    required property bool expandedSize
    required property real baseCellWidth
    required property real baseCellHeight
    required property real cellSpacing
    required property int cellSize

    signal openMenu()

    property var onDragStart: null
    property var onDragMove: null
    property var onDragEnd: null
    property bool isUsed: true

    property QuickToggleModel toggleModel
    property string name: toggleModel?.name ?? ""
    property string statusText: (toggleModel?.hasStatusText) ? (toggleModel?.statusText || (toggled ? Translation.tr("On") : Translation.tr("Off"))) : ""
    property string tooltipText: toggleModel?.tooltipText ?? ""
    property string buttonIcon: toggleModel?.icon ?? "close"
    property bool available: toggleModel?.available ?? true
    toggled: toggleModel?.toggled ?? false
    property var mainAction: toggleModel?.mainAction ?? null
    altAction: toggleModel?.hasMenu ? (() => root.openMenu()) : (toggleModel?.altAction ?? null)

    property bool editMode: false

    baseWidth: root.baseCellWidth * cellSize + cellSpacing * (cellSize - 1)
    baseHeight: root.baseCellHeight
    enableImplicitWidthAnimation: !editMode && root.mouseArea.containsMouse
    enableImplicitHeightAnimation: !editMode && root.mouseArea.containsMouse
    Behavior on baseWidth {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    Behavior on baseHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    opacity: 0
    Component.onCompleted: { opacity = 1 }
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    enabled: available || editMode
    padding: 6
    horizontalPadding: padding
    verticalPadding: padding

    colBackground: Appearance.colors.colLayer2
    colBackgroundToggled: (altAction && expandedSize) ? Appearance.colors.colLayer2 : Appearance.colors.colPrimary
    colBackgroundToggledHover: (altAction && expandedSize) ? Appearance.colors.colLayer2Hover : Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: (altAction && expandedSize) ? Appearance.colors.colLayer2Active : Appearance.colors.colPrimaryActive
    buttonRadius: toggled ? Appearance.rounding.large : height / 2
    buttonRadiusPressed: Appearance.rounding.normal
    property color colText: (toggled && !(altAction && expandedSize) && enabled) ? Appearance.colors.colOnPrimary : ColorUtils.transparentize(Appearance.colors.colOnLayer2, enabled ? 0 : 0.7)
    property color colIcon: expandedSize ? ((root.toggled) ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer3) : colText

    onClicked: {
        if (root.expandedSize && root.altAction) root.altAction();
        else root.mainAction();
    }

    // Wiggle >> thinking it would be nice if the toggles moved but I didn't like it x|
    property real wigglePhaseOffset: (root.buttonIndex % 3) * 60
    SequentialAnimation on rotation {
        running: root.editMode && !dragHandler.active && root.isUsed
        loops: Animation.Infinite
        PauseAnimation { duration: root.wigglePhaseOffset }
        SequentialAnimation {
            loops: Animation.Infinite
            NumberAnimation { to: 2;  duration: 0;  easing.type: Easing.InOutSine }
            NumberAnimation { to: -2; duration: 0; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0;  duration: 0;  easing.type: Easing.InOutSine }
        }
    }
    NumberAnimation on rotation {
        running: !root.editMode
        to: 0
        duration: 150
    }

    contentItem: RowLayout {
        spacing: 4
        anchors {
            centerIn: root.expandedSize ? undefined : parent
            fill: root.expandedSize ? parent : undefined
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }

        MouseArea {
            id: iconMouseArea
            hoverEnabled: true
            acceptedButtons: (root.expandedSize && root.altAction) ? Qt.LeftButton : Qt.NoButton
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.topMargin: root.verticalPadding
            Layout.bottomMargin: root.verticalPadding
            implicitHeight: iconBackground.implicitHeight
            implicitWidth: iconBackground.implicitWidth
            cursorShape: Qt.PointingHandCursor
            onClicked: root.mainAction()

            Rectangle {
                id: iconBackground
                anchors.fill: parent
                implicitWidth: height
                radius: root.radius - root.verticalPadding
                color: {
                    const baseColor = root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colLayer3
                    const transparentizeAmount = (root.altAction && root.expandedSize) ? 0 : 1
                    return ColorUtils.transparentize(baseColor, transparentizeAmount)
                }
                Behavior on radius { animation: Appearance.animation.elementMove.numberAnimation.createObject(this) }
                Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }

                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: root.toggled ? 1 : 0
                    iconSize: root.expandedSize ? 22 : 24
                    color: root.colIcon
                    text: root.buttonIcon
                }

                Loader {
                    anchors.fill: parent
                    active: (root.expandedSize && root.altAction)
                    sourceComponent: Rectangle {
                        radius: iconBackground.radius
                        color: ColorUtils.transparentize(root.colIcon, iconMouseArea.containsPress ? 0.88 : iconMouseArea.containsMouse ? 0.95 : 1)
                        Behavior on color { animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this) }
                    }
                }
            }
        }

        Loader {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            visible: root.expandedSize
            active: visible
            sourceComponent: Column {
                spacing: -2
                StyledText {
                    anchors { left: parent.left; right: parent.right }
                    font.pixelSize: Appearance.font.pixelSize.smallie
                    font.weight: 600
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.name
                }
                StyledText {
                    visible: root.statusText
                    anchors { left: parent.left; right: parent.right }
                    font { pixelSize: Appearance.font.pixelSize.smaller; weight: 100 }
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.statusText
                }
            }
        }
    }

    MouseArea {
        id: editModeInteraction
        visible: root.editMode
        anchors.fill: parent
        cursorShape: dragHandler.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons

        function toggleEnabled() {
            const index = root.buttonIndex;
            const toggleList = Config.options.sidebar.quickToggles.android.toggles;
            const buttonType = root.buttonData.type;
            if (!toggleList.find(toggle => toggle.type === buttonType)) {
                toggleList.push({ type: buttonType, size: 1 });
            } else {
                toggleList.splice(index, 1);
            }
        }

        function toggleSize() {
            const index = root.buttonIndex;
            const toggleList = Config.options.sidebar.quickToggles.android.toggles;
            const buttonType = root.buttonData.type;
            if (!toggleList.find(toggle => toggle.type === buttonType)) return;
            toggleList[index].size = 3 - toggleList[index].size;
        }

        onReleased: (event) => {
            if (!root.isUsed && event.button === Qt.LeftButton) toggleEnabled();
        }
        onPressed: (event) => {
            if (root.isUsed && event.button === Qt.RightButton) toggleSize();
        }
        onPressAndHold: {
            if (root.isUsed) toggleSize();
        }
        onWheel: (event) => {
            if (!root.isUsed) return;
            const index = root.buttonIndex;
            const toggleList = Config.options.sidebar.quickToggles.android.toggles;
            const offset = event.angleDelta.y < 0 ? 1 : -1;
            const targetIndex = index + offset;
            if (targetIndex < 0 || targetIndex >= toggleList.length) return;
            const temp = toggleList[index];
            toggleList[index] = toggleList[targetIndex];
            toggleList[targetIndex] = temp;
            event.accepted = true;
        }
    }

    DragHandler {
        id: dragHandler
        enabled: root.editMode && root.isUsed
        target: null
        onActiveChanged: {
            if (active) {
                if (root.onDragStart) root.onDragStart(root.buttonIndex)
            } else {
                const pos = dragHandler.centroid.scenePosition
                if (root.onDragEnd) root.onDragEnd(root.buttonIndex, pos.x, pos.y)
            }
        }
        onCentroidChanged: {
            if (!active) return
            const pos = dragHandler.centroid.scenePosition
            if (root.onDragMove) root.onDragMove(root.buttonIndex, pos.x, pos.y)
        }
    }

    // delete
    Loader {
        active: root.editMode && root.isUsed
        anchors { top: parent.top; left: parent.left; topMargin: -7; leftMargin: -7 }
        z: 20
        sourceComponent: Rectangle {
            width: 20; height: 20; radius: 10
            color: Appearance.colors.colError
            border.width: 2
            border.color: Appearance.colors.colLayer2
            MaterialSymbol {
                anchors.centerIn: parent
                text: "remove"
                iconSize: 13
                color: Appearance.colors.colOnError
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: editModeInteraction.toggleEnabled()
            }
        }
    }

    // expand/compress
    Loader {
        active: root.editMode && root.isUsed
        anchors { bottom: parent.bottom; right: parent.right; bottomMargin: -7; rightMargin: -7 }
        z: 20
        sourceComponent: Rectangle {
            width: 20; height: 20; radius: 10
            color: Appearance.colors.colPrimary
            border.width: 2
            border.color: Appearance.colors.colLayer2
            MaterialSymbol {
                anchors.centerIn: parent
                text: root.expandedSize ? "close_fullscreen" : "open_in_full"
                iconSize: 12
                color: Appearance.colors.colOnPrimary
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: editModeInteraction.toggleSize()
            }
        }
    }

    StyledToolTip {
        extraVisibleCondition: root.tooltipText !== ""
        text: root.tooltipText
    }
}