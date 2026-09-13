import QtQuick
import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property int keycode: 0
    property int altKeycode: 0
    property string label: ""
    property bool wide: false

    readonly property real baseSize: 60

    implicitWidth: wide ? baseSize * 1.8 : baseSize
    implicitHeight: baseSize
    radius: Theme.cornerRadius
    color: keyArea.pressed ? Theme.primarySelected : Theme.withAlpha(Theme.surfaceText, 0.08)

    StyledText {
        anchors.centerIn: parent
        text: root.label
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.surfaceText
    }

    MouseArea {
        id: keyArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.altKeycode > 0) {
                    Ydotool.press(root.altKeycode);
                    Ydotool.release(root.altKeycode);
                }
                return;
            }
            Ydotool.press(root.keycode);
        }

        onReleased: mouse => {
            if (mouse.button === Qt.LeftButton)
                Ydotool.release(root.keycode);
        }

        onCanceled: Ydotool.release(root.keycode)
    }
}
