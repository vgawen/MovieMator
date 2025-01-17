
import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0
import MovieMator.Controls 1.0

Item {
    property var defaultParameters: ['lift_r', 'lift_g', 'lift_b', 'gamma_r', 'gamma_g', 'gamma_b', 'gain_r', 'gain_g', 'gain_b']
    property var gammaFactor: 2.0
    property var gainFactor: 4.0
    width: 300
    height: 250
    
    function loadWheels() {
        liftwheel.color = Qt.rgba( filter.getDouble("lift_r"),
                                   filter.getDouble("lift_g"),
                                   filter.getDouble("lift_b"),
                                   1.0 )
        gammawheel.color = Qt.rgba( filter.getDouble("gamma_r") / gammaFactor,
                                    filter.getDouble("gamma_g") / gammaFactor,
                                    filter.getDouble("gamma_b") / gammaFactor,
                                    1.0 )
        gainwheel.color = Qt.rgba( filter.getDouble("gain_r") / gainFactor,
                                   filter.getDouble("gain_g") / gainFactor,
                                   filter.getDouble("gain_b") / gainFactor,
                                   1.0 )
    }
    
    Component.onCompleted: {
        if (filter.isNew) {
            // Set default parameter values
            filter.set("lift_r", 0.0);
            filter.set("lift_g", 0.0);
            filter.set("lift_b", 0.0);
            filter.set("gamma_r", 1.0);
            filter.set("gamma_g", 1.0);
            filter.set("gamma_b", 1.0);
            filter.set("gain_r", 1.0);
            filter.set("gain_g", 1.0);
            filter.set("gain_b", 1.0);
            filter.savePreset(defaultParameters)
        }
        loadWheels()
    }

    GridLayout {
        columns: 6
        anchors.fill: parent
        anchors.margins: 8

        // Row 1
        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignLeft
            color: '#ffffff'
        }
        Preset {
            Layout.columnSpan: 5
            parameters: defaultParameters
            onPresetSelected: {
                loadWheels()
            }
        }

        // Row 2
        Label {
            text: qsTr('Shadows')
            color: '#ffffff'

        }
        UndoButton {
            Layout.alignment: Qt.AlignCenter
            onClicked: liftwheel.color = Qt.rgba( 0.0, 0.0, 0.0, 1.0 )
        }
        Label {
            text: qsTr('Midtones')
            color: '#ffffff'

        }
        UndoButton {
            Layout.alignment: Qt.AlignCenter
            onClicked: gammawheel.color = Qt.rgba( 1.0 / gammaFactor, 1.0 / gammaFactor, 1.0 / gammaFactor, 1.0 )
        }
        Label {
            text: qsTr('Highlights')
            color: '#ffffff'
        }
        UndoButton {
            Layout.alignment: Qt.AlignCenter
            onClicked: gainwheel.color = Qt.rgba( 1.0 / gainFactor, 1.0 / gainFactor, 1.0 / gainFactor, 1.0 )
        }
        
        // Row 3
        ColorWheelItem {
            id: liftwheel
            Layout.columnSpan: 2
            implicitWidth: parent.width / 3 - parent.columnSpacing
            implicitHeight: implicitWidth / 1.1
            Layout.alignment : Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: 75
            Layout.maximumHeight: 300
            onColorChanged: {
                filter.set("lift_r", liftwheel.red / 255.0 );
                filter.set("lift_g", liftwheel.green / 255.0 );
                filter.set("lift_b", liftwheel.blue / 255.0 );
            }
        }
        ColorWheelItem {
            id: gammawheel
            Layout.columnSpan: 2
            implicitWidth: parent.width / 3 - parent.columnSpacing
            implicitHeight: implicitWidth / 1.1
            Layout.alignment : Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: 75
            Layout.maximumHeight: 300
            onColorChanged: {
                filter.set("gamma_r", (gammawheel.red / 255.0) * gammaFactor);
                filter.set("gamma_g", (gammawheel.green / 255.0) * gammaFactor);
                filter.set("gamma_b", (gammawheel.blue / 255.0) * gammaFactor);
            }
        }
        ColorWheelItem {
            id: gainwheel
            Layout.columnSpan: 2
            implicitWidth: parent.width / 3 - parent.columnSpacing
            implicitHeight: implicitWidth / 1.1
            Layout.alignment : Qt.AlignLeft | Qt.AlignTop
            Layout.minimumHeight: 75
            Layout.maximumHeight: 300
            onColorChanged: {
                filter.set("gain_r", (gainwheel.red / 255.0) * gainFactor);
                filter.set("gain_g", (gainwheel.green / 255.0) * gainFactor);
                filter.set("gain_b", (gainwheel.blue / 255.0) * gainFactor);
            }
        }

        Item { Layout.fillHeight: true }
    }
}
