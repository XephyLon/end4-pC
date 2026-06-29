import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.common.models
import Quickshell.Hyprland

ContentPage {
    id: page
    property string descriptionMode: {
        if (Config.options.profile.descriptionText === "::uptime::") return "uptime"
        return "distro"
    }

    FolderListModel {
        id: avatarFolderModel
        folder: Config.options.profile.avatarPath !== "" ? Qt.resolvedUrl(Config.options.profile.avatarPath) : ""
        showDirs: false
        nameFilters: ["*.png", "*.svg", "*.jpg", "*.jpeg", "*.webp"]
    }

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        ContentSection {
            icon: "person"
            shape: MaterialShape.Shape.Circle
            title: Translation.tr("Avatar")

            ConfigRow {
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Avatar path (leave empty to use ~/.face) eg /home/youruser/Pictures/avatar")
                    text: Config.options.profile.avatarPath
                    wrapMode: TextEdit.Wrap

                    Timer {
                        id: avatarDebounceTimer
                        interval: 1000
                        running: false
                        onTriggered: {
                            Config.options.profile.avatarPath = parent.text
                        }
                    }

                    onTextChanged: {
                        avatarDebounceTimer.restart()
                    }
                }
                ToolbarPairedFab {
                    visible: Config.options.profile.avatarPath !== ""
                    iconText: "add"
                    onClicked: {
                        GlobalStates.settingsOpen = false
                        if (Config.options.profile.avatarPath !== "") {
                            Quickshell.execDetached(["dolphin", Config.options.profile.avatarPath])
                        }
                    }
                }
            }

            Flow {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                spacing: 12
                visible: Config.options.profile.avatarPath !== ""

                Repeater {
                    model: avatarFolderModel
                    delegate: Rectangle {
                        required property string fileName
                        required property string filePath
                        width: 64
                        height: 64
                        radius: width / 2
                        color: Appearance.colors.colLayer2

                        property bool isSelected: FileUtils.trimFileProtocol(filePath.toString()) === Config.options.profile.avatarPicture

                        Image {
                            id: avatarImage
                            anchors.fill: parent
                            source: filePath
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: avatarImage.width * 2
                            sourceSize.height: avatarImage.height * 2
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: 64; height: width; radius: width / 2 
                                }
                            }
                        }

                        Rectangle {
                            visible: parent.isSelected
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: 2
                            anchors.bottomMargin: 2
                            width: 20
                            height: width
                            radius: width / 2
                            color: Appearance.colors.colPrimary

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "check"
                                iconSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnPrimary
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Config.options.profile.avatarPicture = FileUtils.trimFileProtocol(filePath.toString())
                        }
                    }
                }
            }

            ContentSubsection {
                title: Translation.tr("Description Text")

                ConfigSelectionArray {
                    currentValue: Config.options.profile.descriptionText === "::uptime::" ? "uptime" : "distro"
                    onSelected: newValue => {
                        page.descriptionMode = newValue
                        if (newValue === "distro") Config.options.profile.descriptionText = "::distro::"
                        if (newValue === "uptime") Config.options.profile.descriptionText = "::uptime::"
                    }
                    options: [
                        { displayName: Translation.tr("Distro"), icon: "deployed_code", value: "distro" },
                        { displayName: Translation.tr("Uptime"), icon: "timelapse",     value: "uptime" },
                    ]
                }
            }
        }

        ContentSection {
            icon: "wall_art"
            shape: MaterialShape.Shape.Pentagon
            title: Translation.tr("Presets (Soon)")
        }
    }
}