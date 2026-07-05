import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root
    configEntryName: "weather"

    property real widgetWidth: 420
    property real widgetHeight: 70
    property real shapeSize: 50

    implicitHeight: card.implicitHeight
    implicitWidth: card.implicitWidth

    Rectangle {
        id: card
        implicitWidth: root.widgetWidth
        implicitHeight: root.widgetHeight
        radius: Appearance.rounding?.verylarge ?? 30
        color: Appearance.colors.colPrimaryContainer

        StyledRectangularShadow {
            target: card
            z: -2
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 16
            spacing: 12

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 10

                MaterialShapeWrappedMaterialSymbol {
                    shape: MaterialShape.Shape.Cookie12Sided
                    color: Appearance.colors.colPrimary
                    colSymbol: Appearance.colors.colOnPrimary
                    text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                    iconSize: 24
                    fill: 1
                    padding: 10
                    implicitWidth: root.shapeSize
                    implicitHeight: root.shapeSize
                }

                StyledText {
                    Layout.topMargin: -5
                    text: Weather.data?.temp ?? "--°"
                    font {
                        pixelSize: 32
                        family: Appearance.font.family.expressive
                        weight: Font.Medium
                    }
                    color: Appearance.colors.colPrimary
                }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2
                Layout.rightMargin: 8

                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: Weather.data?.city ?? "--"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnPrimaryContainer
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: Weather.data?.description ?? ""
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnPrimaryContainer
                    opacity: 0.6
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8

                    RowLayout {
                        spacing: 2
                        MaterialSymbol {
                            iconSize: Appearance.font.pixelSize.smaller
                            text: "humidity_mid"
                            color: Appearance.colors.colOnPrimaryContainer
                            opacity: 0.6
                        }
                        StyledText {
                            text: Weather.data?.humidity ?? "--"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnPrimaryContainer
                            opacity: 0.6
                        }
                    }

                    RowLayout {
                        spacing: 2
                        MaterialSymbol {
                            iconSize: Appearance.font.pixelSize.smaller
                            text: "air"
                            color: Appearance.colors.colOnPrimaryContainer
                            opacity: 0.6
                        }
                        StyledText {
                            text: Weather.data?.wind ?? "--"
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnPrimaryContainer
                            opacity: 0.6
                        }
                    }
                }
            }
        }
    }
}