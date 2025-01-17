
import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

RowLayout {
    id: root
    property int minimumValue: 0
    property int maximumValue: 99
    property int value: 0
    signal setDefaultClicked()
    signal saveDefaultClicked()

    spacing: 0

    TextField {
        id: timeField
        text: filter.timeFromFrames(value)
        horizontalAlignment: TextInput.AlignRight
        validator: RegExpValidator {regExp: /^\s*(\d*:){0,2}(\d*[.;:])?\d*\s*$/}
        onEditingFinished: value = clamp(filter.framesFromTime(text), minimumValue, maximumValue)
        Keys.onDownPressed: decrementAction.trigger()
        Keys.onUpPressed: incrementAction.trigger()
        onFocusChanged: if (focus) selectAll()
    }

    DeleteButton {
        id: decrementButton

        tooltip: qsTr('Decrement')

        MouseArea {
            anchors.fill: parent
            onPressed: decrementAction.trigger()
            onPressAndHold: decrementTimer.start()
            onReleased: decrementTimer.stop()
        }
        Timer {
            id: decrementTimer
            repeat: true
            interval: 200
            triggeredOnStart: true
            onTriggered: decrementAction.trigger()
        }
    }
    AddButton {
        id: incrementButton
        tooltip: qsTr('Increment')

        MouseArea {
            anchors.fill: parent
            onPressed: incrementAction.trigger()
            onPressAndHold: incrementTimer.start()
            onReleased: incrementTimer.stop()
        }
        Timer {
            id: incrementTimer
            repeat: true
            interval: 200
            triggeredOnStart: true
            onTriggered: incrementAction.trigger()
        }
    }



    UndoButton {
        onClicked: root.setDefaultClicked()
    }
    SaveDefaultButton {
        onClicked: root.saveDefaultClicked()
    }
    Action {
        id: decrementAction
        onTriggered: value = value = Math.max(value - 1, minimumValue)
    }
    Action {
        id: incrementAction
        onTriggered: value = Math.min(value + 1, maximumValue)
    }

    function clamp(x, min, max) {
        return Math.max(min, Math.min(max, x))
    }
}
