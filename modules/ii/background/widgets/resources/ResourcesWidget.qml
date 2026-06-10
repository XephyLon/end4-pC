import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root

    configEntryName: "resources"

    property real pillHeight:  54
    property real pillPadding: 14
    property real pillRadius:  Appearance.rounding?.verylarge ?? 30
    property real iconSize:    20
    property real valueRadius: Appearance.rounding?.large ?? 16

    property real cpuTextWidth:  38   
    property real tempTextWidth: 44   
    property real ramTextWidth:  52   

    implicitWidth:  row.implicitWidth
    implicitHeight: row.implicitHeight

    function pct(v)  { return Math.round(v * 100) + "%" }
    function temp(v) { return (v > 0 ? v.toFixed(0) : "--") + "°C" }
    function memGb(kb) {
        const gb = kb / (1024 * 1024)
        return gb >= 10 ? gb.toFixed(0) : gb.toFixed(1)
    }

    RowLayout {
        id: row
        spacing: 16

        // ── CPU pill ─────────────────────────────────────────────
        Rectangle {
            id: cpuCard
            implicitHeight: root.pillHeight
            implicitWidth:  cpuRow.implicitWidth + root.pillPadding * 2
            radius:         root.pillRadius
            color:          Appearance.colors.colPrimaryContainer

            StyledRectangularShadow { target: cpuCard; z: -1 }

            RowLayout {
                id: cpuRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: root.pillPadding
                spacing: 10

                MaterialSymbol {
                    text: "planner_review"
                    iconSize: root.iconSize
                    fill: 1
                    color: Appearance.colors.colOnPrimaryContainer
                }

                Rectangle {
                    width:          root.cpuTextWidth + root.tempTextWidth + 36 + 20
                    implicitHeight: root.pillHeight - 16
                    radius:         root.valueRadius
                    color:          Appearance.colors.colPrimary

                    RowLayout {
                        id: cpuInner
                        anchors.centerIn: parent
                        spacing: 6

                        StyledText {
                            width:          root.cpuTextWidth
                            horizontalAlignment: Text.AlignHCenter
                            text:           pct(ResourceUsage.cpuUsage)
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight:    Font.SemiBold
                            color:          Appearance.colors.colOnPrimary
                        }

                        StyledText {
                            text:    "/"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color:   Appearance.colors.colOnPrimary
                            opacity: 0.5
                        }

                        StyledText {
                            width:          root.tempTextWidth
                            horizontalAlignment: Text.AlignHCenter
                            text:           temp(ResourceUsage.cpuTemp)
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight:    Font.SemiBold
                            color:          Appearance.colors.colOnPrimary
                        }
                    }
                }
            }
        }

        // ── RAM pill ─────────────────────────────────────────────
        Rectangle {
            id: ramCard
            implicitHeight: root.pillHeight
            implicitWidth:  ramRow.implicitWidth + root.pillPadding * 2
            radius:         root.pillRadius
            color:          Appearance.colors.colPrimaryContainer

            StyledRectangularShadow { target: ramCard; z: -1 }

            RowLayout {
                id: ramRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: root.pillPadding
                spacing: 10

                MaterialSymbol {
                    text: "memory"
                    iconSize: root.iconSize
                    fill: 1
                    color: Appearance.colors.colOnPrimaryContainer
                }

                Rectangle {
                    width:          root.ramTextWidth * 2 + 36 + 20
                    implicitHeight: root.pillHeight - 16
                    radius:         root.valueRadius
                    color:          Appearance.colors.colPrimary

                    RowLayout {
                        id: ramInner
                        anchors.centerIn: parent
                        spacing: 6

                        StyledText {
                            width:          root.ramTextWidth
                            horizontalAlignment: Text.AlignHCenter
                            text:           memGb(ResourceUsage.memoryUsed) + " GB"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight:    Font.SemiBold
                            color:          Appearance.colors.colOnPrimary
                        }

                        StyledText {
                            text:    "/"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color:   Appearance.colors.colOnPrimary
                            opacity: 0.5
                        }

                        StyledText {
                            width:          root.ramTextWidth
                            horizontalAlignment: Text.AlignHCenter
                            text:           memGb(ResourceUsage.memoryTotal) + " GB"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight:    Font.SemiBold
                            color:          Appearance.colors.colOnPrimary
                        }
                    }
                }
            }
        }
    }
}
