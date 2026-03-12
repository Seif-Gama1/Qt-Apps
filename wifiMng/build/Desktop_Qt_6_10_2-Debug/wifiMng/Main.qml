import QtQuick
import QtQuick.Controls
import QtQuick.Layouts // Ensure this is imported

Window {
    visible: true
    width: 800
    height: 600
    title: "Network Manager"

    Component.onCompleted: {
        backend.checkWifiStatus()
        backend.scanNetworks() // scan at the start
        backend.checkBluetoothStatus()
        backend.scanBluetooth()
    }

    Connections {
        target: backend
        function onWifiStatusChanged(enabled) {
            wifiSwitch.checked = enabled
        }
        function onBluetoothStatusChanged(enabled) {
            btSwitch.checked = enabled
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: bar
            Layout.fillWidth: true
            TabButton { text: "Wi-Fi" }
            TabButton { text: "Bluetooth" }
        }

        StackLayout {
            id: stack
            currentIndex: bar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.margins: 10
                spacing: 10

                ToolBar {
                    Layout.fillWidth: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 20

                        Switch {
                            id: wifiSwitch
                            text: "Wi-Fi"
                            // Use positionChanged for manual toggle
                            onClicked: backend.toggleWifi(checked)
                        }

                        Button {
                            text: "Refresh"
                            enabled: wifiSwitch.checked
                            onClicked: backend.scanNetworks()
                        }
                    }
                }

                ListView {
                    id: wifiList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true // Prevents delegate text from bleeding out of the list area
                    model: backend.wifiNetworks

                    delegate: ItemDelegate { // Using ItemDelegate is better for interactivity
                        width: wifiList.width
                        height: 50

                        property var parts: modelData.split(":")
                        property bool isActive: parts[0] === "*"
                        property string ssid: parts[1]

                        background: Rectangle {
                            color: isActive ? "#e1f5fe" : "transparent"
                            border.color: isActive ? "#03a9f4" : "transparent"
                            border.width: 1
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Text {
                                text: ssid + (isActive? " (Connected)":"") // SSID
                                font.bold: isActive
                                Layout.fillWidth: true        // Takes up remaining space
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                text: parts[2] + "%" // SIGNAL
                                Layout.preferredWidth: 40
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                            }

                            Button {
                                text: isActive ? "Disconnect" : "Connect"
                                Layout.preferredWidth: 100
                                highlighted: isActive
                                onClicked: {
                                    if (isActive) {
                                        backend.disconnectWifi(ssid)
                                    } else {
                                        backend.connectWifi(ssid, "")
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: wifiSwitch.checked ? "No networks found or scanning..." : "Wi-Fi is turned off"
                        visible: wifiList.count === 0
                        color: "gray"
                    }
                }
            }

            ColumnLayout {
                Layout.margins: 10
                spacing: 10

                ToolBar {
                    Layout.fillWidth: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 20

                        Switch {
                            id: btSwitch
                            text: "Bluetooth"
                            onClicked: backend.toggleBluetooth(checked)
                        }
                        Button {
                            text: "Scan"
                            enabled: btSwitch.checked
                            onClicked: backend.scanBluetooth()
                        }
                    }
                }

                ListView {
                    id: btList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: backend.bluetoothDevices
                    delegate: ItemDelegate {
                        width: btList.width
                        height: 50

                        property var parts: modelData.split("|")
                        property bool isActive: parts[0] === "*"
                        property string deviceAddr: parts[1]
                        property string deviceName: parts[2]

                        background: Rectangle {
                            color: isActive ? "#f1f8e9" : "transparent" // Light green for Bluetooth
                            border.color: isActive ? "#4caf50" : "transparent"
                            border.width: 1
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Text {
                                text: (deviceName === "" ? "Unknown" : deviceName) + (isActive ? " (Connected)" : "")
                                font.bold: isActive
                                Layout.fillWidth: true
                            }
                            Text {
                                text: deviceAddr
                                font.pixelSize: 10
                                color: "gray"
                            }
                            Button {
                                text: isActive ? "Disconnect" : "Connect"
                                highlighted: isActive
                                onClicked: {
                                    if (isActive) {
                                        backend.disconnectBluetooth(deviceAddr)
                                    } else {
                                        backend.connectBluetooth(deviceAddr)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
