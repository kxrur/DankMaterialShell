import QtQuick
import QtQuick.Layouts
import qs.Common
import "layouts.js" as Layouts

Item {
    id: root

    property string layoutName: ""
    property var layouts: Layouts.byName
    readonly property string activeLayoutName: layouts.hasOwnProperty(layoutName) ? layoutName : Layouts.defaultLayout
    readonly property var currentLayout: layouts[activeLayoutName]

    signal cycleLayoutRequested

    implicitWidth: keyRows.implicitWidth
    implicitHeight: keyRows.implicitHeight

    ColumnLayout {
        id: keyRows
        spacing: 5

        Repeater {
            model: root.currentLayout.keys

            delegate: RowLayout {
                required property var modelData
                spacing: 5

                Repeater {
                    model: modelData

                    delegate: OskKey {
                        required property var modelData
                        keyData: modelData
                        layoutLabel: root.currentLayout.name_short ?? ""
                        onCycleLayoutRequested: root.cycleLayoutRequested()
                    }
                }
            }
        }
    }
}
