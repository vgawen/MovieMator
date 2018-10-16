import QtQuick 2.0
import com.moviemator.qml 1.0

Metadata {
    type: Metadata.Filter
    objectName: 'fadeInMovit'
    name: qsTr("Fade In Video")
    mlt_service: "movit.opacity"
    needsGPU: true
    qml: "ui.qml"
    isFavorite: true
    allowMultiple: false
}
