import QtQuick 2.0
import com.moviemator.qml 1.0

Metadata {
    type: Metadata.Filter
    name: qsTr("Saturation")
    mlt_service: "frei0r.saturat0r"
    qml: "ui_frei0r.qml"
    gpuAlt: "movit.saturation"
}
