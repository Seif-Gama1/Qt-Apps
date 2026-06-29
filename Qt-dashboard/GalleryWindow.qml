import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Item {
    id: galleryRoot
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#121212"   // opaque background to cover anything behind
    }

    // Back button
    Button {
        text: "← Back"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        width: 100
        height: 40
        onClicked: {
            root.pageLoader.source = ""
        }
    }

    // Dim overlay when modal is active
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: "black"
        opacity: infoPopup.visible ? 0.5 : 0
        z: 1
        visible: infoPopup.visible
    }

    // Popup with info
    Rectangle {
        id: infoPopup
        width: 300
        height: 250
        color: "#1e1e1e"
        radius: 15
        border.color: "#00cfff"
        border.width: 2
        anchors.centerIn: parent
        visible: false
        z: 2

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Text { id: popupName; text: "Name"; color: "white"; font.pixelSize: 20; font.bold: true }
            Text { id: popupColor; text: "Color"; color: "white"; font.pixelSize: 18 }
            Text { id: popupType; text: "Type"; color: "white"; font.pixelSize: 18 }
            Text { id: popupAvail; text: "Availability"; color: "white"; font.pixelSize: 18 }

            Button {
                text: "X"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: infoPopup.visible = false
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10
        padding: 20

        // Title
        Text {
            text: "Gallery"
            font.pixelSize: 32
            font.bold: true
            anchors.topMargin: 20
            color: "#00cfff"
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Scrollable area for cards
        Flickable {
            id: scrollArea
            contentWidth: grid.width
            contentHeight: grid.implicitHeight
            width: parent.width - 40   // 20px margin on each side
            height: parent.height - 100 // adjust as needed
            clip: true
            // anchors.left: parent.left
            // anchors.right: parent.right
            // anchors.top: parent.top
            // anchors.topMargin: 80
            // anchors.leftMargin: 30
            // anchors.rightMargin: 30
            // anchors.bottom: parent.bottom
            // contentWidth: parent.width
            // contentHeight: grid.implicitHeight


            GridLayout {
                id: grid
                columns: 3
                columnSpacing: 15
                rowSpacing: 15
                width: scrollArea.width

                Repeater {
                    model: 18 // create 18 cards
                    Rectangle {
                        width: (grid.width - 30) / 3
                        height: 180
                        radius: 10
                        color: "#1e1e1e"
                        border.color: "#00cfff"
                        border.width: 2

                        // Fetch random placeholder images
                        Image {
                            anchors.fill: parent
                            anchors.margins: 5
                            source: "https://picsum.photos/200/150?random=" + index
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                popupName.text = "Product #" + (index+1)
                                popupColor.text = "Color: " + ["Red","Blue","Green","Yellow"][index%4]
                                popupType.text = "Type: Item"
                                popupAvail.text = "Availability: " + ["In Stock","Out of Stock"][index%2]
                                infoPopup.visible = true
                            }
                        }
                    }
                }
            }
        }
    }
}
