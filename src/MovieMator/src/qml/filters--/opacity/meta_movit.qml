import QtQuick 2.0
import com.moviemator.qml 1.0

Metadata {
    type: Metadata.Filter
    objectName: 'movitOpacity'
    name: qsTr("Opacity")
    mlt_service: "movit.opacity"
    needsGPU: true
    qml: "ui.qml"
}
