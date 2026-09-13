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
    property bool movieMode: false
    property string fallbackLayout: "English (US)"
    readonly property string niriLayout: NiriService.getCurrentKeyboardLayoutName()
    readonly property string layout: niriLayout !== "" && Layouts.byName.hasOwnProperty(niriLayout) ? niriLayout : fallbackLayout

    function toggle() {
        if (oskOpen) {
            hide();
            return;
        }
        movieMode = false;
        oskOpen = true;
    }

    function show() {
        movieMode = false;
        oskOpen = true;
    }

    function hide() {
        oskOpen = false;
    }

    function toggleMovie() {
        if (oskOpen && movieMode) {
            hide();
            return;
        }
        movieMode = true;
        oskOpen = true;
    }

    function cycleLayout() {
        if (movieMode)
            return;
        NiriService.cycleKeyboardLayout();
    }

    onMovieModeChanged: Ydotool.releaseAllKeys()

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
                right: !root.movieMode
                left: root.movieMode
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
                implicitWidth: contentLoader.implicitWidth + Theme.spacingM * 2
                implicitHeight: contentLoader.implicitHeight + Theme.spacingM * 2

                Loader {
                    id: contentLoader
                    anchors.centerIn: parent
                    sourceComponent: root.movieMode ? movieContent : keyboardContent
                }

                Component {
                    id: keyboardContent

                    OskContent {
                        layoutName: root.layout
                        onCycleLayoutRequested: root.cycleLayout()
                    }
                }

                Component {
                    id: movieContent

                    MovieContent {}
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

        function movie(): void {
            root.toggleMovie();
        }

        function movieOpen(): void {
            root.movieMode = true;
            root.oskOpen = true;
        }

        function movieClose(): void {
            root.hide();
        }
    }
}
