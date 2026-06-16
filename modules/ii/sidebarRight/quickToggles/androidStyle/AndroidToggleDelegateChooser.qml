pragma ComponentBehavior: Bound
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

DelegateChooser {
    id: root
    property bool editMode: false
    required property real baseCellWidth
    required property real baseCellHeight
    required property real spacing
    required property int startingIndex
    property bool isUsed: startingIndex !== -1
    property var onDragStart: null
    property var onDragMove: null
    property var onDragEnd: null

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()

    role: "type"

    DelegateChoice { roleValue: "antiFlashbang"; AndroidAntiFlashbangToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
        onOpenMenu: root.openNightLightDialog()
    } }

    DelegateChoice { roleValue: "audio"; AndroidAudioToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
        onOpenMenu: root.openAudioOutputDialog()
    } }

    DelegateChoice { roleValue: "bluetooth"; AndroidBluetoothToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
        onOpenMenu: root.openBluetoothDialog()
    } }

    DelegateChoice { roleValue: "cloudflareWarp"; AndroidCloudflareWarpToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "colorPicker"; AndroidColorPickerToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "darkMode"; AndroidDarkModeToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "easyEffects"; AndroidEasyEffectsToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "gameMode"; AndroidGameModeToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "idleInhibitor"; AndroidIdleInhibitorToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "mic"; AndroidMicToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
        onOpenMenu: root.openAudioInputDialog()
    } }

    DelegateChoice { roleValue: "musicRecognition"; AndroidMusicRecognition {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "network"; AndroidNetworkToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
        onOpenMenu: root.openWifiDialog()
    } }

    DelegateChoice { roleValue: "nightLight"; AndroidNightLightToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
        onOpenMenu: root.openNightLightDialog()
    } }

    DelegateChoice { roleValue: "notifications"; AndroidNotificationToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "onScreenKeyboard"; AndroidOnScreenKeyboardToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "powerProfile"; AndroidPowerProfileToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }

    DelegateChoice { roleValue: "screenSnip"; AndroidScreenSnipToggle {
        required property int index; required property var modelData
        buttonIndex: root.startingIndex + index; buttonData: modelData
        editMode: root.editMode; expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth; baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing; cellSize: modelData.size
        isUsed: root.isUsed
        onDragStart: root.onDragStart; onDragMove: root.onDragMove; onDragEnd: root.onDragEnd
    } }
}