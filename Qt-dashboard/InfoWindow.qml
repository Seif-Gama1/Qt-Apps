import QtQuick
import QtQuick.Controls

Item {
    id: infoWindow
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "#1e1e1e"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "SnapDash Info"
                font.pixelSize: 30
                font.bold: true
                color: "#00cfff"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Dummy Description
            Text {
                text: "SnapDash is my first project, Dashboard App.\n" +
                      "It shows current time, weather info,\n" +
                      "and allows navigation to Info & Gallery pages."
                font.pixelSize: 20
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            Button {
                text: "Back"
                width: 150
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: {
                    root.pageLoader.source = ""
                }
            }
        }
    }
}
