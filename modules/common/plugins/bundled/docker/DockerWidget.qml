import QtQuick
import qs.modules.common
import qs.modules.common.plugins
import qs.modules.common.widgets
import QtQuick.Layouts
import "."

BarWidgetSwitcherArea {
    id: root

    readonly property var manifest: PluginManager.manifestsMap["docker_plugin"]

    hoverEnabled: !Config.options.bar.tooltips.clickToShow
    onClicked: dockerPopup.pinnedOpen = !dockerPopup.pinnedOpen
    rowDefault: rowContent
    rowMaterial: rowContent
    colDefault: colContent
    colMaterial: colContent

    Component {
        id: rowContent
        RowLayout {
            spacing: Appearance.spacing.space75
            MaterialSymbol {
                text: "deployed_code"
                iconSize: Appearance.font.pixelSize.normal
                color: !DockerService.dockerAvailable ? Appearance.colors.colError
                    : DockerService.runningCount > 0 ? Appearance.colors.colPrimary
                    : Appearance.colors.colOnLayer1
            }
            StyledText {
                text: `${DockerService.runningCount}/${DockerService.totalCount}`
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    Component {
        id: colContent
        ColumnLayout {
            spacing: Appearance.spacing.space25
            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: "deployed_code"
                iconSize: Appearance.font.pixelSize.normal
                color: !DockerService.dockerAvailable ? Appearance.colors.colError
                    : DockerService.runningCount > 0 ? Appearance.colors.colPrimary
                    : Appearance.colors.colOnLayer1
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: DockerService.runningCount
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    DockerPopup {
        id: dockerPopup
        hoverTarget: root
    }
}
