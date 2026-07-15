import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: root

    property string transmission: "D"
    property string driveMode: "DRIVE"

    property real rpm: 2500
    property real speed: 80
    property real targetRpm: 2500
    property real targetSpeed: 80

    property int gear: 3

    property real simFuel: 60
    property real simTemp: 65
    property real simBattery: 78
    property real simRange: 318
    property real simMotorTemp: 42
    property real simOutsideTemp: 24
    property real simDistance: 142
    property real simEtaMin: 105

    property real odometer: 125483
    property int simulationTick: 0

    property bool showMap: false

    // TPMS values (bar)
    property real tpmsFL: 2.2
    property real tpmsFR: 2.2
    property real tpmsRL: 2.3
    property real tpmsRR: 2.3

    // Signal states
    property bool leftSignal: true
    property bool rightSignal: false
    property bool hazardSignal: false

    // Warning states
    property bool warningCheckEngine: true
    property bool warningABS: false
    property bool warningOil: false
    property bool warningBattery: false
    property bool warningHandbrake: true
    property bool warningDoors: false
    property bool warningSeatbelt: false

    // Light states
    property bool lightLowBeam: true
    property bool lightHighBeam: false
    property bool lightFogFront: false
    property bool lightFogRear: false

    property color primary     : "#00E68A"
    property color background  : "#050807"
    property color surface     : "#0A1110"
    property color surface2    : "#101918"
    property color border       : "#18352E"
    property color text         : "#F6FFFF"
    property color secondary    : "#8AA7A0"

    property var modeMap: ({
                              "IDLE": {
                                  rpmTarget: 900,
                                  speedTarget: 0,
                                  color: "#8E82C9"
                              },

                              "DRIVE": {
                                  rpmTarget: 2500,
                                  speedTarget: 80,
                                  color: "#A88BFF"
                              },

                              "SPORT": {
                                  rpmTarget: 4500,
                                  speedTarget: 130,
                                  color: "#C4B6FF"
                              },

                              "REDLINE": {
                                  rpmTarget: 7200,
                                  speedTarget: 180,
                                  color: "#FF7EB8"
                              }
                          })

    property var transMap: ({
                              "P": { rpmTarget: 900,  speedTarget: 0 },
                              "R": { rpmTarget: 1500, speedTarget: -15 },
                              "N": { rpmTarget: 900,  speedTarget: 0 },
                              "D": { rpmTarget: 2500, speedTarget: 80 }
                          })

    function applyTargets() {
        if (transmission === "D") {
            targetRpm = modeMap[driveMode].rpmTarget
            targetSpeed = modeMap[driveMode].speedTarget
        } else {
            targetRpm = transMap[transmission].rpmTarget
            targetSpeed = transMap[transmission].speedTarget
        }
    }

    function setMode(mode) {
        driveMode = mode
        applyTargets()
    }

    function setTransmission(t) {
        transmission = t
        applyTargets()
    }

    function motorTempColor(t) {
        if (t > 110 || t < 85) return "#ff4466"
        if (t >= 90 && t <= 105) return "#00ff88"
        return "#ffcc00"
    }

    function fuelColor(p) {
        if (p < 25) return "#ff4466"
        if (p <= 50) return "#ffcc00"
        return "#00ff88"
    }

    function batteryColor(p) {
        if (p < 20) return "#ff4466"
        if (p <= 40) return "#ffcc00"
        return "#00ff88"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var d = new Date()
            var h = d.getHours() % 12 || 12
            var m = d.getMinutes()
            clockText.text = (h < 10 ? "0" : "") + h + ":" +
                             (m < 10 ? "0" : "") + m
            ampmText.text = d.getHours() < 12 ? "AM" : "PM"
        }
    }

    Timer {
        interval: 16
        running: true
        repeat: true

        onTriggered: {
            simulationTick++

            var rpmNoise = Math.sin(simulationTick * 0.08) * 80 +
                           Math.sin(simulationTick * 0.17) * 40
            var desiredRpm = targetRpm + rpmNoise
            rpm += (desiredRpm - rpm) * 0.05

            var speedNoise = Math.sin(simulationTick * 0.03) * 3
            var desiredSpeed = targetSpeed + speedNoise
            speed += (desiredSpeed - speed) * 0.03

            var absSpeed = Math.abs(speed)
            if (absSpeed < 5) gear = 1
            else if (absSpeed < 40) gear = 2
            else if (absSpeed < 80) gear = 3
            else if (absSpeed < 120) gear = 4
            else if (absSpeed < 150) gear = 5
            else gear = 6

            simFuel = Math.max(0, simFuel - 0.0004 * (rpm / 1000))
            simRange = Math.max(0, simFuel * 5.3)

            var targetTemp = 60 + (rpm / 8000) * 40
            simTemp += (targetTemp - simTemp) * 0.02

            var targetMotorTemp = 35 + (rpm / 8000) * 25
            simMotorTemp += (targetMotorTemp - simMotorTemp) * 0.015

            simBattery = Math.max(0, simBattery - 0.0008 * (rpm / 8000))

            if (simDistance > 0 && absSpeed > 0)
                simDistance = Math.max(0, simDistance - absSpeed / 360000)

            if (absSpeed > 5 && simDistance > 0)
                simEtaMin = Math.min(simEtaMin, simDistance / absSpeed * 60)
            else if (simDistance <= 0)
                simEtaMin = 0

            odometer += absSpeed / 360000
        }
    }

    Timer {
        id: signalTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if (leftSignal || rightSignal || hazardSignal) {
                leftSignal ? leftSignalBlink = !leftSignalBlink : leftSignalBlink = false
                rightSignal ? rightSignalBlink = !rightSignalBlink : rightSignalBlink = false
            }
        }
    }

    property bool leftSignalBlink: false
    property bool rightSignalBlink: false

    Timer {
        id: warningFlashTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            warningFlash = !warningFlash
        }
    }

    property bool warningFlash: false

    // Reusable component definitions
    Component {
        id: warningIconComponent
        Item {
            width: 28
            height: 28

            property string icon: "!"
            property bool active: false
            property color color: "#FF4466"
            property string tooltip: ""

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: active ? Qt.rgba(warningFlash ? 1 : 0.5, 0, 0, 0.9) : "#2A1A1A"
                border.color: active ? color : "#4A3A3A"
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
    }

    Component {
        id: lightIconComponent
        Item {
            width: 28
            height: 28

            property string icon: "💡"
            property bool active: false
            property color color: "#A88BFF"
            property string tooltip: ""

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: active ? Qt.rgba(color.r, color.g, color.b, 0.3) : "#2A1A1A"
                border.color: active ? color : "#4A3A3A"
                border.width: active ? 2 : 1

                Text {
                    anchors.centerIn: parent
                    text: icon
                    color: active ? color : "#5A4A5A"
                    font.pixelSize: 14
                }
            }
        }
    }

    Component {
        id: tpmsIconComponent
        Item {
            width: 70
            height: 55

            property string label: "FL"
            property real pressure: 2.2
            property color color: "#00E68A"

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: "#1A1A2A"
                border.color: color
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: label
                        color: "#8A8A9A"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Text {
                        text: pressure.toFixed(1) + " bar"
                        color: color
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#04080a"
    }

    Background {
        anchors.fill: parent
        glowColor: root.modeMap[root.driveMode].color
    }

    Row {
        anchors.fill: parent

        Item {
            width: parent.width / 3
            height: parent.height

            CircularGauge {
                id: speedGauge
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 50

                value: Math.abs(root.speed)
                maxValue: 180
                tickValues: [0, 45, 90, 135, 180]
                decimals: 0
                unit: "km/h"
                bottomLabel: root.transmission
                speedLimit: 130
                redlineThreshold: 0.9

                accentColor: root.modeMap[root.driveMode].color
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                spacing: 10

                IconInfoTile {
                    iconText: "->"; iconColor: "#00E68A"
                    title: "RANGE"; value: Math.round(root.simRange) + " km"
                }
                IconInfoTile {
                    iconText: "M"; iconColor: root.motorTempColor(root.simMotorTemp)
                    title: "MOTOR"; value: Math.round(root.simMotorTemp) + " C"
                    valueColor: root.motorTempColor(root.simMotorTemp)
                }
                IconInfoTile {
                    iconText: "F"; iconColor: root.fuelColor(root.simFuel)
                    title: "FUEL"; value: Math.round(root.simFuel) + " %"
                    valueColor: root.fuelColor(root.simFuel)
                }
            }
        }

        Item {
            width: parent.width / 3
            height: parent.height

            Row {
                id: clockRow
                anchors.top: parent.top
                anchors.topMargin: 35
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    id: clockText
                    text: {
                        var d = new Date()
                        var h = d.getHours() % 12 || 12
                        var m = d.getMinutes()
                        return (h < 10 ? "0" : "") + h + ":" +
                               (m < 10 ? "0" : "") + m
                    }
                    color: "#F7F5FF"
                    font.pixelSize: 54
                    font.bold: true
                }

                Text {
                    id: ampmText
                    text: "AM"
                    color: "#A88BFF"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.baseline: clockText.baseline
                }
            }

            // Turn signals - spaced ~20% from center
            Text {
                anchors.top: clockRow.bottom
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -93
                text: "◀"
                color: leftSignal && leftSignalBlink ? "#00E68A" : "#5A4E5E"
                font.pixelSize: 32; font.bold: true
            }

            Text {
                anchors.top: clockRow.bottom
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 93
                text: "▶"
                color: rightSignal && rightSignalBlink ? "#00E68A" : "#5A4E5E"
                font.pixelSize: 32; font.bold: true
            }

            Item {
                id: centerStage
                anchors.top: clockRow.bottom
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                width: 360; height: 240

                CarOnRoad {
                    anchors.fill: parent
                    speed: root.speed
                    accent: root.modeMap[root.driveMode].color
                    driveMode: root.driveMode
                    brakeState: root.simBattery < 30
                    leftSignal: root.leftSignal
                    rightSignal: root.rightSignal
                    leftSignalBlink: root.leftSignalBlink
                    rightSignalBlink: root.rightSignalBlink
                    lightBeam: root.lightLowBeam || root.lightHighBeam
                    visible: !root.showMap
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#0A1418"
                    border.color: "#3B3552"
                    visible: root.showMap

                    Text {
                        anchors.centerIn: parent
                        text: "IVI MAP\n(not available)"
                        color: "#AEA6C5"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Row {
                anchors.top: centerStage.bottom
                anchors.topMargin: 14
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30

                Column {
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.gear
                        color: "#A88BFF"
                        font.pixelSize: 24; font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "GEAR"
                        color: "#AEA6C5"
                        font.pixelSize: 11
                    }
                }

                Column {
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(root.odometer)
                        color: "#F7F5FF"
                        font.pixelSize: 24; font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ODO km"
                        color: "#AEA6C5"
                        font.pixelSize: 11
                    }
                }
            }

            // Indicators section - TPMS at top, warnings+headlights in 2 rows
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 60
                height: 155

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20

                        TPMSIcon { label: "FL"; pressure: root.tpmsFL; color: root.tpmsFL >= 2.0 && root.tpmsFL <= 2.5 ? "#00E68A" : "#FF4466" }
                        TPMSIcon { label: "FR"; pressure: root.tpmsFR; color: root.tpmsFR >= 2.0 && root.tpmsFR <= 2.5 ? "#00E68A" : "#FF4466" }
                        TPMSIcon { label: "RL"; pressure: root.tpmsRL; color: root.tpmsRL >= 2.0 && root.tpmsRL <= 2.5 ? "#00E68A" : "#FF4466" }
                        TPMSIcon { label: "RR"; pressure: root.tpmsRR; color: root.tpmsRR >= 2.0 && root.tpmsRR <= 2.5 ? "#00E68A" : "#FF4466" }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        WarningIcon { icon: "⚙"; active: warningCheckEngine; iconColor: "#FF4466"; tooltip: "Check Engine"; warningFlash: root.warningFlash }
                        WarningIcon { icon: "ABS"; active: warningABS; iconColor: "#FFCC00"; tooltip: "ABS"; warningFlash: root.warningFlash }
                        WarningIcon { icon: "💧"; active: warningOil; iconColor: "#FF4466"; tooltip: "Oil Pressure"; warningFlash: root.warningFlash }
                        WarningIcon { icon: "🔋"; active: warningBattery; iconColor: "#FFCC00"; tooltip: "Battery"; warningFlash: root.warningFlash }
                        WarningIcon { icon: "🅿"; active: warningHandbrake; iconColor: "#FF4466"; tooltip: "Handbrake"; warningFlash: root.warningFlash }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        WarningIcon { icon: "🚪"; active: warningDoors; iconColor: "#FFCC00"; tooltip: "Doors Open"; warningFlash: root.warningFlash }
                        WarningIcon { icon: "🔒"; active: warningSeatbelt; iconColor: "#FF4466"; tooltip: "Seatbelt"; warningFlash: root.warningFlash }

                        Rectangle { width: 1; height: 28; color: "#3B3552" }

                        LightIcon { icon: "💡"; active: lightLowBeam; iconColor: "#A88BFF"; tooltip: "Low Beam" }
                        LightIcon { icon: "🔦"; active: lightHighBeam; iconColor: "#00E68A"; tooltip: "High Beam" }
                        LightIcon { icon: "🌫"; active: lightFogFront; iconColor: "#FFCC00"; tooltip: "Fog Front" }
                        LightIcon { icon: "🌫🔴"; active: lightFogRear; iconColor: "#FF4466"; tooltip: "Fog Rear" }
                    }
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Repeater {
                    model: ["IDLE", "DRIVE", "SPORT", "REDLINE"]
                    delegate: Rectangle {
                        width: 82; height: 30; radius: 6
                        property bool active: root.driveMode === modelData && root.transmission === "D"
                        color: active ? "#0A2A2A" : "#0A1418"
                        border.color: active ? root.modeMap[modelData].color : "#3B3552"
                        border.width: 1
                        opacity: root.transmission === "D" ? 1.0 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: parent.active ? root.modeMap[modelData].color : "#AEA6C5"
                            font.pixelSize: 10; font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (root.transmission === "D") root.setMode(modelData)
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width / 3
            height: parent.height

            CircularGauge {
                id: rpmGauge
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 50

                value: root.rpm / 1000
                maxValue: 8
                tickValues: [0, 2, 4, 6, 8]
                decimals: 1
                unit: "x1000"
                bottomLabel: Math.round(root.simMotorTemp) + "°C"
                redlineThreshold: 0.85

                accentColor: root.modeMap[root.driveMode].color
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                spacing: 10

                IconInfoTile {
                    iconText: "W"; iconColor: "#FFCC00"
                    title: "WEATHER"; value: Math.round(root.simOutsideTemp) + " C"
                }
                IconInfoTile {
                    iconText: "D"; iconColor: "#00E5FF"
                    title: "DST"; value: Math.round(root.simDistance) + " km"
                }
                IconInfoTile {
                    iconText: "E"; iconColor: "#A88BFF"
                    title: "ETA"
                    value: Math.floor(root.simEtaMin / 60) + "h " +
                           Math.round(root.simEtaMin % 60) + "m"
                }
            }
        }
    }
}
