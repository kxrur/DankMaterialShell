import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets
import "layouts.js" as Layouts

Scope {
    id: root

    property bool oskOpen: false
    property string fallbackLayout: "English (US)"
    readonly property string niriLayout: NiriService.getCurrentKeyboardLayoutName()
    readonly property string layout: niriLayout !== "" && Layouts.byName.hasOwnProperty(niriLayout) ? niriLayout : fallbackLayout

    function toggle() {
        oskOpen = !oskOpen;
    }

    function show() {
        oskOpen = true;
    }

    function hide() {
        oskOpen = false;
    }

    function cycleLayout() {
        NiriService.cycleKeyboardLayout();
    }

    Loader {
        id: oskLoader
        active: root.oskOpen && !SessionService.locked
        onActiveChanged: {
            if (!oskLoader.active)
                Ydotool.releaseAllKeys();
        }

        sourceComponent: PanelWindow {
            id: window

            visible: oskLoader.active
            color: "transparent"
            anchors {
                top: true
                right: true
            }
            exclusiveZone: 0
            implicitWidth: card.implicitWidth + Theme.spacingL * 2
            implicitHeight: card.implicitHeight + Theme.spacingL * 2
            WlrLayershell.namespace: "dms:osk"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            mask: Region {
                item: card
            }

            WindowBlur {
                targetWindow: window
                blurX: card.x
                blurY: card.y
                blurWidth: window.visible ? card.width : 0
                blurHeight: window.visible ? card.height : 0
                blurRadius: Theme.cornerRadius
            }

            StyledRect {
                id: card
                anchors.centerIn: parent
                color: Theme.surfaceContainer
                radius: Theme.cornerRadius
                implicitWidth: oskContent.implicitWidth + Theme.spacingM * 2
                implicitHeight: oskContent.implicitHeight + Theme.spacingM * 2

                OskContent {
                    id: oskContent
                    anchors.centerIn: parent
                    layoutName: root.layout
                    onCycleLayoutRequested: root.cycleLayout()
                }
            }
        }
    }

    IpcHandler {
        target: "osk"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.show();
        }

        function close(): void {
            root.hide();
        }

        function cycleLayout(): void {
            root.cycleLayout();
        }
    }
}
