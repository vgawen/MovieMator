
import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import MovieMator.Controls 1.0

Item {
    width: 300
    height: 250
    Component.onCompleted: {
        if (filter.isNew) {
            // Set default parameter values
            filter.set('0', 0)
            filter.set('1', 0)
            filter.set('2', .51)
            filter.savePreset(preset.parameters)
        }
        setControls()
        timer.start()
    }

    function setControls() {
        sliderInput.value = filter.getDouble('0')
        sliderLimit.value = filter.getDouble('1')
        sliderRelease.value = filter.get('2')
    }

    Timer {
        id: timer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            grGauge.value = filter.get('3[0]') * -1.0
        }
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 8
        columns: 3

        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignRight
            color: '#ffffff'
        }
        Preset {
            id: preset
            parameters: ['0', '1', '2']
            Layout.columnSpan: 2
            onPresetSelected: setControls()
        }

        Label {
            text: qsTr('Input gain')
            Layout.alignment: Qt.AlignRight
            color: '#ffffff'
            ToolTip {text: qsTr('Gain that is applied to the input stage. Can be used to trim gain to bring it roughly under the limit or to push the signal against the limit.')}
        }
        SliderSpinner {
            id: sliderInput
            minimumValue: -20
            maximumValue: 20
            suffix: ' dB'
            decimals: 1
            spinnerWidth: 80
            value: filter.getDouble('0')
            onValueChanged: {
                filter.set('0', value)
            }
        }
        UndoButton {
            onClicked: sliderInput.value = 0
        }

        Label {
            text: qsTr('Limit')
            Layout.alignment: Qt.AlignRight
            color: '#ffffff'
            ToolTip {text: qsTr('The maximum output amplitude. Peaks over this level will be attenuated as smoothly as possible to bring them as close as possible to this level.')}
        }
        SliderSpinner {
            id: sliderLimit
            minimumValue: -20
            maximumValue: 0
            suffix: ' dB'
            decimals: 1
            spinnerWidth: 80
            value: filter.getDouble('1')
            onValueChanged: {
                filter.set('1', value)
            }
        }
        UndoButton {
            onClicked: sliderLimit.value = 0
        }

        Label {
            text: qsTr('Release')
            Layout.alignment: Qt.AlignRight
            color: '#ffffff'
            ToolTip {text: qsTr('The time taken for the limiter\'s attenuation to return to 0 dB\'s.')}
        }
        SliderSpinner {
            id: sliderRelease
            minimumValue: .01
            maximumValue: 2
            suffix: ' s'
            decimals: 2
            spinnerWidth: 80
            value: filter.get('2')
            onValueChanged: {
                filter.set('2', value)
            }
        }
        UndoButton {
            onClicked: sliderRelease.value = .51
        }

        Rectangle {
            Layout.columnSpan: 3
            Layout.fillWidth: true
            Layout.minimumHeight: 12
            color: 'transparent'
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 2
                radius: 2
                color: activePalette.text
            }
        }
        
        Component {
            id: gaugeStyle
            GaugeStyle {
                valueBar: Rectangle {
                    implicitWidth: 16
                    color: 'transparent'
                    Rectangle {
                        anchors.right: parent.right
                        width: parent.width
                        height: 5
                        radius: 3
                        color: activePalette.highlight
                    }
                }
                tickmark: Item {
                    implicitWidth: 9
                    implicitHeight: 1
                    Rectangle {
                        color: activePalette.windowText
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.rightMargin: 2
                    }
                }
                minorTickmark: Item {
                    implicitWidth: 6
                    implicitHeight: 1
                    Rectangle {
                        color: activePalette.windowText
                        anchors.fill: parent
                        anchors.leftMargin: 2
                        anchors.rightMargin: 2
                    }
                }
                tickmarkLabel: Text {
                    font.pixelSize: 12
                    text: Math.round(parseFloat(styleData.value))
                    color: activePalette.windowText
                    antialiasing: true
                 }
            }
        }
        
        Label {
            text: qsTr('Gain Reduction')
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            color: '#ffffff'
            ToolTip {text: qsTr('Status indicator showing the gain reduction applied by the compressor.')}
        }
        Gauge {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            id: grGauge
            minimumValue: -24
            value: 0
            maximumValue: 0
            orientation: Qt.Horizontal
            style: gaugeStyle
        }

        Item {
            Layout.fillHeight: true;
        }
    }
}
