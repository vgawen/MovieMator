import QtQuick 2.0
import com.moviemator.qml 1.0

Metadata {
    type: Metadata.Filter
    name: qsTr("Diffusion")
    mlt_service: "movit.diffusion"
    needsGPU: true
    qml: "ui.qml"
}
