import qs.modules.common.plugins

PluginNode {
    id: root
    property string pluginId: ""
    readonly property var manifest: PluginManager.manifestsMap[pluginId]
    manifestNode: manifest?.barWidget ?? null
    optionDefinitions: manifest?.options ?? []
    basePath: manifest?._basePath ?? ""
}
