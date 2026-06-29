import QtQuick
import QtQuick.Controls

Window {
    width: 1000
    height: 666
    visible: true
    title: "SnapDash Main"

    Loader {
        id: screenLoader
        anchors.fill: parent
        source: "SplashScreen.qml"

        onItemChanged: {
            if (screenLoader.item && screenLoader.item.bootFinished) {
                screenLoader.item.bootFinished.connect(function() {
                    screenLoader.source = "Dashboard.qml"
                })
            }
        }
    }
}

