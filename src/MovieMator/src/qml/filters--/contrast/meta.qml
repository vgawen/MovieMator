import QtQuick 2.0
import com.moviemator.qml 1.0

Metadata {
    type: Metadata.Filter
    name: qsTr("Contrast")
    objectName: "contrast"
    mlt_service: "lift_gamma_gain"
    qml: "ui.qml"
    isFavorite: true
    gpuAlt: "movit.lift_gamma_gain"
}
