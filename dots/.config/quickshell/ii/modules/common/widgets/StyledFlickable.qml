import QtQuick
import QtQuick.Controls
import qs.modules.common

Flickable {
    id: root
    maximumFlickVelocity: 3500

    property real touchpadScrollFactor: Config?.options.interactions.scrolling.touchpadScrollFactor ?? 100
    property real mouseScrollFactor: Config?.options.interactions.scrolling.mouseScrollFactor ?? 50
    property real mouseScrollDeltaThreshold: Config?.options.interactions.scrolling.mouseScrollDeltaThreshold ?? 120
    // Accumulated scroll destination so wheel deltas stack while animating
    property real scrollTargetY: 0
    // Opt-in M3 Expressive springy scroll. In-bounds wheel scrolling settles on
    // a spatial curve; scrolling past an edge that's already at the end pushes a
    // damped overshoot and springs back (rubber-band) - works on a mouse wheel,
    // not just drag. Off by default so other scroll surfaces are unchanged.
    property bool expressiveScroll: false
    property real maxOverscroll: 56

    boundsBehavior: root.expressiveScroll ? Flickable.OvershootBounds : Flickable.DragOverBounds

    ScrollBar.vertical: StyledScrollBar {}

    // ── Non-expressive path: accumulating animated-decel wheel (unchanged) ──
    MouseArea {
        visible: !root.expressiveScroll && Config?.options.interactions.scrolling.fasterTouchpadScroll
        enabled: visible
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheelEvent) {
            const delta = wheelEvent.angleDelta.y / root.mouseScrollDeltaThreshold;
            var scrollFactor = Math.abs(wheelEvent.angleDelta.y) >= root.mouseScrollDeltaThreshold ? root.mouseScrollFactor : root.touchpadScrollFactor;

            const maxY = Math.max(0, root.contentHeight - root.height);
            const base = scrollAnim.running ? root.scrollTargetY : root.contentY;
            var targetY = Math.max(0, Math.min(base - delta * scrollFactor, maxY));

            root.scrollTargetY = targetY;
            root.contentY = targetY;
            wheelEvent.accepted = true;
        }
    }

    Behavior on contentY {
        enabled: !root.expressiveScroll
        NumberAnimation {
            id: scrollAnim
            duration: Appearance.animation.scroll.duration
            easing.type: Appearance.animation.scroll.type
            easing.bezierCurve: Appearance.animation.scroll.bezierCurve
        }
    }

    onContentYChanged: {
        if (!scrollAnim.running && !root.expressiveScroll) {
            root.scrollTargetY = root.contentY;
        }
    }

    // ── Expressive path: animated in-bounds scroll + rubber-band at edges ──
    MouseArea {
        visible: root.expressiveScroll
        enabled: visible
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheelEvent) {
            const maxY = Math.max(0, root.contentHeight - root.height);
            var scrollFactor = Math.abs(wheelEvent.angleDelta.y) >= root.mouseScrollDeltaThreshold ? root.mouseScrollFactor : root.touchpadScrollFactor;
            const delta = wheelEvent.angleDelta.y / root.mouseScrollDeltaThreshold;

            const anchoredY = (settleAnim.running || bounceAnim.running) ? root.scrollTargetY : root.contentY;
            const raw = anchoredY - delta * scrollFactor;
            const scrollingDown = raw > anchoredY; // moving toward the bottom
            const atBottom = anchoredY >= maxY - 0.5;
            const atTop = anchoredY <= 0.5;

            // Rubber-band ONLY when already pinned to an edge and pushing past it.
            // Every other scroll (including the step that reaches an edge) just
            // settles springily at the clamped target.
            if ((scrollingDown && atBottom) || (!scrollingDown && atTop)) {
                const bound = scrollingDown ? maxY : 0;
                const overshoot = Math.min(Math.abs(raw - bound) * 0.35, root.maxOverscroll);
                root.scrollTargetY = bound;
                settleAnim.stop();
                bounceAnim.overshootY = bound + (scrollingDown ? overshoot : -overshoot);
                bounceAnim.boundY = bound;
                bounceAnim.restart();
            } else {
                const target = Math.max(0, Math.min(raw, maxY));
                root.scrollTargetY = target;
                bounceAnim.stop();
                settleAnim.stop();
                settleAnim.to = target;
                settleAnim.start();
            }
            wheelEvent.accepted = true;
        }
    }

    // In-bounds settle (springy fast-spatial curve).
    NumberAnimation {
        id: settleAnim
        target: root
        property: "contentY"
        duration: Appearance.animationCurves.expressiveFastSpatialDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
    }

    // Edge rubber-band: quick push out, then a springy settle back to the bound.
    SequentialAnimation {
        id: bounceAnim
        property real overshootY: 0
        property real boundY: 0
        NumberAnimation {
            target: root; property: "contentY"; to: bounceAnim.overshootY
            duration: Appearance.animationCurves.expressiveEffectsDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animationCurves.emphasizedDecel
        }
        NumberAnimation {
            target: root; property: "contentY"; to: bounceAnim.boundY
            duration: Appearance.animationCurves.expressiveDefaultSpatialDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
        }
    }
}
