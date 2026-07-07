#pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts

BarWidgetSwitcherArea {
    id: root
    property bool hovered: false

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    onPressed: {
        if (mouse.button === Qt.RightButton) {
            Weather.getData();
            Quickshell.execDetached(["notify-send",
                Translation.tr("Weather"),
                Translation.tr("Refreshing (manually triggered)"),
                "-a", "Shell"
            ])
            mouse.accepted = false
        }
    }

    rowDefault: Component {
        RowLayout {
            MaterialSymbol {
                fill: 0
                text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer1
                Layout.alignment: Qt.AlignVCenter
            }
            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: Weather.data?.temp ?? "--°"
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    rowMaterial: Component {
        MaterialPill {
            vertical: false
            mainAxisPadding: 8

            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colPrimary
                text: Weather.data?.temp ?? "--°"
                Layout.alignment: Qt.AlignVCenter
                leftPadding: 5
            }

            Rectangle {
                width: 25
                height: 25
                radius: Appearance.rounding.full
                color: Appearance.colors.colPrimary

                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: 0
                    text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnPrimary
                }
            }
        }
    }

    colDefault: Component {
        ColumnLayout {
            spacing: 4
            MaterialSymbol {
                fill: 0
                text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer1
                Layout.alignment: Qt.AlignHCenter
            }
            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                text: (Weather.data?.temp ?? "--°").replace(/[CF]$/, "")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    colMaterial: Component {
        MaterialPill {
            vertical: true

            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colPrimary
                text: (Weather.data?.temp ?? "--°").replace(/[CF]$/, "")
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 3
            }

            Rectangle {
                width: 25
                height: 25
                radius: Appearance.rounding.full
                color: Appearance.colors.colPrimary
                Layout.alignment: Qt.AlignHCenter

                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: 0
                    text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnPrimary
                }
            }
        }
    }

    WeatherPopup {
        id: weatherPopup
        hoverTarget: root
    }
}