import QtQuick

Item {
    id: root

    width: 28
    height: 28

    property string icon: "💡"
    property bool active: false
    property color iconColor: "#A88BFF"
    property string tooltip: ""

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: active ? Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.3) : "#2A1A1A"
        border.color: active ? iconColor : "#4A3A3A"
        border.width: active ? 2 : 1

        Text {
            anchors.centerIn: parent
            text: icon
            color: active ? iconColor : "#5A4A5A"
            font.pixelSize: 14
        }
    }
}