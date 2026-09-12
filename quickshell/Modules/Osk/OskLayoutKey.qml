import QtQuick
import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property string layoutLabel: ""
    signal clicked

    implicitWidth: content.implicitWidth + Theme.spacingM * 2
    implicitHeight: 36
    radius: Theme.cornerRadius
    color: mouse.containsMouse ? Theme.primarySelected : Theme.withAlpha(Theme.surfaceText, 0.08)

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        DankIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "language"
            size: Theme.fontSizeMedium + 4
            color: Theme.surfaceText
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.layoutLabel
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
