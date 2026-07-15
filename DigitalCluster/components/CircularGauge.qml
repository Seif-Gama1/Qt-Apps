import QtQuick

Item {
    id: root
    width: 380
    height: 380

    property real value: 0
    property real maxValue: 180
    property var tickValues: [0, 45, 90, 135, 180]
    property int decimals: 0
    property string unit: "km/h"
    property string bottomLabel: ""

    property color accentColor: "#A88BFF"

    property color trackColor: "#342E47"
    property color outerTrackColor: "#272134"

    property color labelColor: "#AEA6C5"
    property color valueColor: "#F7F5FF"

    property color panelColor: "#211B2E"
    property color borderColor: "#3B3552"

    property real speedLimit: 130
    property real redlineThreshold: 0.85

    property real smoothValue: value
    Behavior on smoothValue {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    //onValueChanged: smoothValue = value

    property real startupPhase: 0
    property bool startupDone: false

    readonly property real cx: width / 2
    readonly property real cy: width / 2 - 10
    readonly property real vr: 128
    readonly property real tubeWidth: 18

    readonly property real outerSpacing: 12
    readonly property real outerWidth: 4
    readonly property real outerRadius: vr + tubeWidth / 2 + outerSpacing + outerWidth / 2

    readonly property var angles: [
        247.5, 202.5, 157.5, 112.5, 67.5, 22.5, 337.5, 292.5
    ]

    function vpos(angleDeg, r) {
        var a = angleDeg * Math.PI / 180;
        return { x: cx + r * Math.cos(a), y: cy - r * Math.sin(a) };
    }

    readonly property var verts: {
        var arr = [];
        for (var i = 0; i < 8; i++) arr.push(vpos(angles[i], vr));
        return arr;
    }

readonly property var outerVerts: {
        var arr = [];
        for (var i = 0; i < 8; i++) arr.push(vpos(angles[i], outerRadius));
        return arr;
    }

    function edgeLen(i) {
        var a = verts[i], b = verts[i + 1];
        var dx = b.x - a.x, dy = b.y - a.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    readonly property real totalLen: {
        var s = 0;
        for (var i = 0; i < 7; i++) s += edgeLen(i);
        return s;
    }

    readonly property real progress: Math.max(0, Math.min(1, smoothValue / maxValue))

    readonly property real minorStep: {
        if (tickValues.length < 2) return maxValue / 20
        return (tickValues[1] - tickValues[0]) / 5
    }

    function pointAt(d) {
        var acc = 0;
        for (var i = 0; i < 7; i++) {
            var len = edgeLen(i);
            if (acc + len >= d) {
                var t = (d - acc) / len;
                var a = verts[i], b = verts[i + 1];
                return { x: a.x + t * (b.x - a.x), y: a.y + t * (b.y - a.y) };
            }
            acc += len;
        }
        return verts[7];
    }

    property real currentMinorTickValue: 0
    readonly property real minorTickSpacing: minorStep

    Timer {
        id: startupTimer
        interval: 16
        running: false
        repeat: true
        onTriggered: {
            if (startupPhase < 1) {
                startupPhase += 0.015;
                if (startupPhase >= 1) {
                    startupPhase = 1;
                    startupDone = true;
                    startupTimer.stop();
                }
            }
        }
    }

    onValueChanged: {
        canvas.requestPaint();
        updateCurrentMinorTick();
    }

    onMaxValueChanged: updateCurrentMinorTick()

    function updateCurrentMinorTick() {
        var val = smoothValue;
        var step = minorStep;
        currentMinorTickValue = Math.round(val / step) * step;
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            var effectiveProgress = startupDone ? progress : startupPhase;

            ctx.strokeStyle = Qt.rgba(0.66, 0.55, 1.0, 0.22);
            ctx.lineWidth = root.outerWidth;
            ctx.beginPath();
            ctx.moveTo(outerVerts[0].x, outerVerts[0].y);
            for (var k = 1; k < 8; k++) ctx.lineTo(outerVerts[k].x, outerVerts[k].y);
            ctx.stroke();

            ctx.strokeStyle = root.trackColor;
            ctx.lineWidth = root.tubeWidth;
            ctx.beginPath();
            ctx.moveTo(verts[0].x, verts[0].y);
            for (var i = 1; i < 8; i++) ctx.lineTo(verts[i].x, verts[i].y);
            ctx.stroke();

            var d = effectiveProgress * root.totalLen;
            if (d > 0.5) {
                var grad = ctx.createLinearGradient(
                    verts[0].x, verts[0].y, verts[7].x, verts[7].y
                );
                grad.addColorStop(0, "#8571D9");
                grad.addColorStop(0.55, "#A88BFF");
                grad.addColorStop(1, "#C8BCFF");

                ctx.strokeStyle = grad;
                ctx.lineWidth = root.tubeWidth;

                var inRedline = effectiveProgress >= root.redlineThreshold;
                var inSpeedLimit = (root.maxValue > 100) && (root.smoothValue >= root.speedLimit);

                if (inRedline && root.startupDone) {
                    ctx.shadowColor = Qt.rgba(1, 0.2, 0.4, 0.6);
                    ctx.shadowBlur = 16;
                } else if (inSpeedLimit && root.startupDone) {
                    ctx.shadowColor = Qt.rgba(1, 0.3, 0.2, 0.6);
                    ctx.shadowBlur = 14;
                } else {
                    ctx.shadowColor = Qt.rgba(0, 0, 0, 0.15);
                    ctx.shadowBlur = 2;
                }

                ctx.beginPath();
                ctx.moveTo(verts[0].x, verts[0].y);
                var acc = 0;
                for (var j = 0; j < 7; j++) {
                    var len = edgeLen(j);
                    if (acc + len <= d) {
                        ctx.lineTo(verts[j + 1].x, verts[j + 1].y);
                        acc += len;
                    } else {
                        var t = (d - acc) / len;
                        var a = verts[j], b = verts[j + 1];
                        ctx.lineTo(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y));
                        break;
                    }
                }
                ctx.stroke();
                ctx.shadowBlur = 0;
            }

            ctx.strokeStyle = Qt.rgba(0.6, 0.85, 0.9, 0.55)
            ctx.lineWidth = 2
            ctx.lineCap = "round"
            for (var v = 0; v <= root.maxValue + 0.001; v += root.minorStep) {
                var isMajor = false
                for (var m = 0; m < root.tickValues.length; m++) {
                    if (Math.abs(v - root.tickValues[m]) < 0.001) { isMajor = true; break }
                }
                if (isMajor) continue

                var mp = v / root.maxValue
                var mpos = root.pointAt(mp * root.totalLen)
                var mdx = mpos.x - root.cx
                var mdy = mpos.y - root.cy
                var mmag = Math.sqrt(mdx * mdx + mdy * mdy) || 1
                var mnx = mdx / mmag
                var mny = mdy / mmag

                var isCurrentTick = Math.abs(v - root.currentMinorTickValue) < root.minorStep / 2
                var tickOpacity = isCurrentTick ? 0.95 : 0.55
                var tickWidth = isCurrentTick ? 3 : 2
                var tickLen = isCurrentTick ? 12 : 9

                ctx.strokeStyle = Qt.rgba(0.6, 0.85, 0.9, tickOpacity)
                ctx.lineWidth = tickWidth

                var sx = mpos.x - mnx * (root.tubeWidth / 2)
                var sy = mpos.y - mny * (root.tubeWidth / 2)
                var ex = sx - mnx * tickLen
                var ey = sy - mny * tickLen

                ctx.beginPath()
                ctx.moveTo(sx, sy)
                ctx.lineTo(ex, ey)
                ctx.stroke()
            }
        }
    }

    onSmoothValueChanged: {
        updateCurrentMinorTick();
    }
    onAccentColorChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onSpeedLimitChanged: canvas.requestPaint()
    onRedlineThresholdChanged: canvas.requestPaint()
    Component.onCompleted: {
        startupTimer.start();
        canvas.requestPaint();
    }

    Repeater {
        model: root.tickValues.length
        delegate: Text {
            property real tickValue: root.tickValues[index]
            property real tickProgress: tickValue / root.maxValue
            property var pos: root.pointAt(tickProgress * root.totalLen)
            property real dx: pos.x - root.cx
            property real dy: pos.y - root.cy
            property real mag: Math.sqrt(dx * dx + dy * dy) || 1
            x: pos.x - dx / mag * 26 - width / 2
            y: pos.y - dy / mag * 26 - height / 2
            text: tickValue
            color: root.labelColor
            font.pixelSize: 16
            font.bold: true
        }
    }

    Text {
        id: centerValue
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -18
        text: root.smoothValue.toFixed(root.decimals)
        color: root.maxValue > 100 && root.smoothValue >= root.speedLimit ? "#FF4466"
             : root.smoothValue / root.maxValue >= root.redlineThreshold ? "#FF4466"
             : root.valueColor
        font.pixelSize: 78
        font.weight: Font.DemiBold
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.cy + 58
        text: root.unit
        color: root.labelColor
        font.pixelSize: 15
        font.weight: Font.Light
        font.letterSpacing: 1
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.cy + 138
        width: 74
        height: 46
        radius: 12
        color: "#091211"
        border.color: root.bottomLabel !== "" ? root.borderColor : "transparent"
        border.width: 1
        visible: root.bottomLabel !== ""

        Text {
            anchors.centerIn: parent
            text: root.bottomLabel
            color: root.accentColor
            font.pixelSize: 22
            font.weight: Font.DemiBold
        }
    }
}
