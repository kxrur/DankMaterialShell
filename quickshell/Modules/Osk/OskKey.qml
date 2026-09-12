import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property var keyData
    readonly property string key: keyData.label ?? ""
    readonly property string keytype: keyData.keytype ?? "normal"
    readonly property int keycode: keyData.keycode ?? 0
    readonly property string shape: keyData.shape ?? "normal"
    readonly property bool isShift: Ydotool.shiftKeys.indexOf(keycode) !== -1
    readonly property bool isCaps: keytype === "caps"
    readonly property bool isBackspace: key.toLowerCase() === "backspace"
    readonly property bool isEnter: key.toLowerCase() === "enter" || key.toLowerCase() === "return"
    readonly property bool isEmpty: shape === "empty"
    property bool modToggled: false
    readonly property bool toggled: isShift ? Ydotool.shiftMode > 0 : (isCaps ? Ydotool.shiftMode === 2 : (keytype === "modkey" && modToggled))

    readonly property int shiftKeycode: 42
    readonly property real baseWidth: 45
    readonly property real baseHeight: 45
    readonly property var widthMultiplier: ({
        "normal": 1,
        "fn": 1,
        "tab": 1.6,
        "caps": 1.9,
        "shift": 2.5,
        "control": 1.3,
        "space": 1,
        "expand": 1
    })
    readonly property var heightMultiplier: ({
        "normal": 1,
        "fn": 0.7,
        "tab": 1,
        "caps": 1,
        "shift": 1,
        "control": 1,
        "space": 1,
        "expand": 1
    })

    implicitWidth: baseWidth * (widthMultiplier[shape] ?? 1)
    implicitHeight: baseHeight * (heightMultiplier[shape] ?? 1)
    Layout.fillWidth: shape === "space" || shape === "expand"
    enabled: !isEmpty
    radius: Theme.cornerRadius
    color: isEmpty ? "transparent" : (toggled ? Theme.primarySelected : Theme.withAlpha(Theme.surfaceText, 0.08))

    DankIcon {
        anchors.centerIn: parent
        visible: root.isBackspace || root.isEnter
        name: root.isBackspace ? "backspace" : "keyboard_return"
        size: Theme.iconSize
        color: root.toggled ? Theme.primary : Theme.surfaceText
    }

    StyledText {
        anchors.centerIn: parent
        visible: !root.isBackspace && !root.isEnter
        text: Ydotool.shiftMode === 2 ? (root.keyData.labelCaps ?? root.keyData.labelShift ?? root.key)
            : Ydotool.shiftMode === 1 ? (root.keyData.labelShift ?? root.key)
            : root.key
        font.pixelSize: root.shape === "fn" ? Theme.fontSizeSmall : Theme.fontSizeMedium
        color: root.toggled ? Theme.primary : Theme.surfaceText
    }

    Timer {
        id: capsLockTimer
        interval: 300
        property bool hasStarted: false
        property bool canCaps: false
        onTriggered: canCaps = false
        function startWaiting() {
            hasStarted = true;
            canCaps = true;
            restart();
        }
    }

    Connections {
        target: Ydotool
        function onShiftModeChanged() {
            if (Ydotool.shiftMode === 0)
                capsLockTimer.hasStarted = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.isEmpty
        onPressed: {
            if (root.isCaps) {
                if (Ydotool.shiftMode === 2) {
                    Ydotool.releaseShiftKeys();
                } else {
                    if (Ydotool.shiftMode === 0)
                        Ydotool.press(root.shiftKeycode);
                    Ydotool.shiftMode = 2;
                }
                return;
            }
            Ydotool.press(root.keycode);
            if (root.isShift && Ydotool.shiftMode === 0)
                Ydotool.shiftMode = 1;
        }
        onReleased: {
            if (root.isCaps)
                return;
            if (root.keytype === "normal") {
                Ydotool.release(root.keycode);
                if (Ydotool.shiftMode === 1)
                    Ydotool.releaseShiftKeys();
            } else if (root.isShift) {
                if (Ydotool.shiftMode === 1) {
                    if (!capsLockTimer.hasStarted)
                        capsLockTimer.startWaiting();
                    else if (capsLockTimer.canCaps)
                        Ydotool.shiftMode = 2;
                    else
                        Ydotool.releaseShiftKeys();
                } else if (Ydotool.shiftMode === 2) {
                    Ydotool.releaseShiftKeys();
                }
            } else if (root.keytype === "modkey") {
                root.modToggled = !root.modToggled;
                if (root.modToggled)
                    Ydotool.retainHeld(root.keycode);
                else
                    Ydotool.releaseHeld(root.keycode);
            }
        }
    }
}
