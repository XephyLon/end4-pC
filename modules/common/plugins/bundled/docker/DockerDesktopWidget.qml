pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import "."

Rectangle {
    id: root
    implicitWidth: 360
    implicitHeight: 300
    radius: Appearance.rounding.large
    color: Appearance.colors.colLayer0
    border.width: Appearance.borderWidth.standard
    border.color: Appearance.colors.colLayer0Border

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.spacing.space200
        spacing: Appearance.spacing.space150

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.space100

            MaterialShapeWrappedMaterialSymbol {
                text: "deployed_code"
                shape: MaterialShape.Shape.Cookie7Sided
                implicitSize: 42
                color: DockerService.dockerAvailable
                    ? Appearance.colors.colPrimaryContainer : Appearance.colors.colErrorContainer
                colSymbol: DockerService.dockerAvailable
                    ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnErrorContainer
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: "Docker Manager"
                    font.weight: Font.DemiBold
                    font.pixelSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: DockerService.dockerAvailable
                        ? `${DockerService.runningCount} running · ${DockerService.totalCount} total`
                        : DockerService.lastError
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: DockerService.dockerAvailable
                        ? Appearance.colors.colSubtext : Appearance.colors.colError
                }
            }
            RippleButton {
                implicitWidth: 36
                implicitHeight: 36
                buttonRadius: Appearance.rounding.full
                enabled: !DockerService.refreshing
                releaseAction: () => DockerService.refresh()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: DockerService.refreshing ? "progress_activity" : "refresh"
                    color: Appearance.colors.colOnLayer0
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1
            clip: true

            StyledText {
                anchors.centerIn: parent
                visible: DockerService.containers.length === 0
                text: DockerService.dockerAvailable ? "No containers" : "Container runtime unavailable"
                color: Appearance.colors.colSubtext
            }

            ListView {
                anchors.fill: parent
                anchors.margins: Appearance.spacing.space100
                visible: DockerService.containers.length > 0
                spacing: Appearance.spacing.space75
                model: DockerService.containers
                clip: true

                delegate: Rectangle {
                    id: containerRow
                    required property var modelData
                    width: ListView.view.width
                    height: 48
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.spacing.space100
                        anchors.rightMargin: Appearance.spacing.space75
                        spacing: Appearance.spacing.space100

                        MaterialSymbol {
                            text: containerRow.modelData.isPaused ? "pause_circle"
                                : containerRow.modelData.isRunning ? "check_circle" : "cancel"
                            color: containerRow.modelData.isRunning
                                ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                Layout.fillWidth: true
                                text: containerRow.modelData.name
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colOnLayer1
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: containerRow.modelData.status
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: Appearance.colors.colSubtext
                            }
                        }
                        RippleButton {
                            implicitWidth: 34
                            implicitHeight: 34
                            buttonRadius: Appearance.rounding.full
                            releaseAction: () => DockerService.executeAction(
                                containerRow.modelData.id,
                                containerRow.modelData.isRunning ? "stop" : "start")
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: containerRow.modelData.isRunning ? "stop" : "play_arrow"
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                    }
                }
            }
        }
    }
}
