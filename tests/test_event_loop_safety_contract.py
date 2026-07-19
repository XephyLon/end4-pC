from pathlib import Path


def test_removed_notification_timer_is_a_noop():
    source = Path("services/Notifications.qml").read_text()
    guard = source.index("if (!notifObject)")
    dereference = source.index("if (notifObject.isTransient)")
    assert guard < dereference
    assert "destroy();\n                return;" in source[guard:dereference]


def test_system_icon_loader_has_no_item_size_feedback_loop():
    source = Path("modules/ii/bar/SystemIcons.qml").read_text()
    assert "width: active ? item?.implicitWidth" not in source
    assert "height: active ? item?.implicitHeight" not in source
    assert "implicitWidth: active ? item?.implicitWidth" not in source
    assert "implicitHeight: active ? item?.implicitHeight" not in source


def test_system_icons_use_stable_implicit_layout_geometry():
    source = Path("modules/ii/bar/SystemIcons.qml").read_text()
    assert "GridLayout {\n        id: flow" in source
    assert "columns: root.vertical ? 1 : -1" in source
    assert "Flow {\n        id: flow" not in source


def test_bar_only_assigns_mirrored_to_visualizers():
    source = Path("modules/ii/bar/BarContent.qml").read_text()
    assert 'hasOwnProperty("mirrored")' not in source
    assert source.count('modelData === "visualizer"') >= source.count("item.mirrored =")


def test_keyboard_indicator_honors_container_theme_color():
    source = Path("modules/ii/bar/HyprlandXkbIndicator.qml").read_text()
    assert "property color color:" in source
    assert "color: root.color" in source
    assert "color: Appearance.colors.colOnLayer0" not in source
