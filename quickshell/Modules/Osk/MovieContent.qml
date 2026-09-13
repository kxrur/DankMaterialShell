import QtQuick
import QtQuick.Layouts
import qs.Common

Item {
    id: root

    implicitWidth: keys.implicitWidth
    implicitHeight: keys.implicitHeight

    RowLayout {
        id: keys
        spacing: Theme.spacingS

        MovieKey {
            keycode: 105
            altKeycode: 36
            label: "←"
        }

        MovieKey {
            keycode: 57
            label: "──"
            wide: true
        }

        MovieKey {
            keycode: 106
            altKeycode: 38
            label: "→"
        }
    }
}
