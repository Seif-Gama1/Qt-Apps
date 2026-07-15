import QtQuick

Item {
    id: root

    width: 28
    height: 28

    property string icon: "!"
    property bool active: false
    property color iconColor: "#FF4466"
    property string tooltip: ""
    property bool warningFlash: false

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: active ? Qt.rgba(warningFlash ? 1 : 0.5, 0, 0, 0.9) : "#2A1A1A"
        border.color: active ? iconColor : "#4A3A3A"
        border.width: active ? 2 : 1

        Text {
            anchors.centerIn: parent
            text: icon
            color: active ? "white" : "#6A5A5A"
            font.pixelSize: icon.length > 1 ? 11 : 14
            font.bold: true
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
}