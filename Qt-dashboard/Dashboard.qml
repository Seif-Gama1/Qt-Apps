import QtQuick
import QtQuick.Controls

Item {
    id:root
    Rectangle {
        anchors.fill: parent
        color: "#121212"

        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            width: parent.width
            padding: 20

            property date currentTime: new Date()

            Timer {
                id: clockTimer
                repeat: true
                running: true
                onTriggered: {
                    parent.currentTime = new Date()
                    interval = 1000
                }
            }

            Component.onCompleted: {
                let now = new Date()
                clockTimer.interval = 1000 - now.getMilliseconds()
            }

            Text {
                id: timeID
                text: Qt.formatDateTime(parent.currentTime, "hh:mm:ss")
                font.pixelSize: 35
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Text {
                id: appNameID
                text: "SnapDash"
                font.pixelSize: 28
                color: "#00cfff"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
        }

        Row {
            anchors.top: parent.top
            anchors.topMargin: 200
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            // --- Card A: Weather Temperature ---
            Rectangle {
                width: 150
                height: 200
                radius: 15
                color: "#1e1e1e"
                border.color: "#00cfff"
                border.width: 2

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Image {
                        source: "qrc:/cloudy.png"
                        width: 80
                        height: 80
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Cairo"
                        font.pixelSize: 18
                        color: "white"
                    }

                    Text {
                        id: tempText
                        text: "--°C"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#ffcc00"
                    }
                }
            }

            // --- Card B: Info Icon ---
            Rectangle {
                width: 150
                height: 200
                radius: 15
                color: "#1e1e1e"
                border.color: "#00cfff"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // navigate to InfoWindow.qml
                        dashboardLoader.source = "InfoWindow.qml"
                    }
                }

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/info.png"
                    width: 60
                    height: 60
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    text: "Info"
                    color: "white"
                }
            }

            // --- Card C: Gallery Icon ---
            Rectangle {
                width: 150
                height: 200
                radius: 15
                color: "#1e1e1e"
                border.color: "#00cfff"
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dashboardLoader.source = "GalleryWindow.qml"
                    }
                }

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/gallery.png"
                    width: 60
                    height: 60
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    text: "Gallery"
                    color: "white"
                }
            }
        }
    }

    // Fetch weather
    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        var apiKey = "8ca0c7374f4e4d6aadd191556260103";
        var city = "Cairo";

        // WeatherAPI endpoint for current weather
        var url = "https://api.weatherapi.com/v1/current.json?key=" + apiKey + "&q=" + city;

        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    // WeatherAPI returns temperature in response.current.temp_c
                    tempText.text = response.current.temp_c + "°C";
                } else {
                    tempText.text = "N/A";
                }
            }
        }
        xhr.send();
    }
    // https://api.weatherapi.com/v1/current.json?key=API_KEY&q=CITY
    // Response=
    // {
    //     "location": {
    //         "name": "Cairo",
    //         ...
    //     },
    //     "current": {
    //         "temp_c": 27.0,
    //         "condition": { "text": "Sunny", "icon": "//cdn.weatherapi.com/..." }
    //     }
    // }


    Loader {
        id: dashboardLoader
        anchors.fill: parent
        visible: dashboardLoader.source !== ""
    }

    property alias pageLoader: dashboardLoader
}
