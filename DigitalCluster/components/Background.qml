import QtQuick

Item {
    id: root

    property color glowColor: "#A88BFF"
    property real glowOpacity: 0.045

    Rectangle {
        anchors.fill: parent
        color: "#18151F"
    }

    Canvas {
        id: gridCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var spacing = 32;
            ctx.fillStyle = Qt.rgba(0.55, 0.85, 0.9, 0.05);
            var dotR = 1.1;

            for (var y = spacing / 2; y < parent.height; y += spacing) {
                for (var x = spacing / 2; x < parent.width; x += spacing) {
                    ctx.beginPath();
                    ctx.arc(x, y, dotR, 0, 2 * Math.PI);
                    ctx.fill();
                }
            }
        }
    }

    Canvas {
        id: glowCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var cx = parent.width / 2;
            var cy = parent.height / 2;
            var maxR = Math.max(parent.width, parent.height) * 0.65;

            var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, maxR);
            var c = root.glowColor;
            grad.addColorStop(0.0, Qt.rgba(c.r, c.g, c.b, root.glowOpacity));
            grad.addColorStop(0.5, Qt.rgba(c.r, c.g, c.b, root.glowOpacity * 0.35));
            grad.addColorStop(1.0, Qt.rgba(c.r, c.g, c.b, 0.0));
            ctx.fillStyle = grad;
            ctx.fillRect(0, 0, parent.width, parent.height);
        }
    }

    Canvas {
        id: horizonCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var y = parent.height * 0.62;
            var c = root.glowColor;

            ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, 0.10);
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(parent.width, y);
            ctx.stroke();

            var grad = ctx.createLinearGradient(0, y - 60, 0, y);
            grad.addColorStop(0.0, Qt.rgba(c.r, c.g, c.b, 0.0));
            grad.addColorStop(1.0, Qt.rgba(c.r, c.g, c.b, 0.05));
            ctx.fillStyle = grad;
            ctx.fillRect(0, y - 60, parent.width, 60);
        }
    }

    Canvas {
        id: vignette
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = parent.width / 2;
            var cy = parent.height / 2;
            var maxR = Math.sqrt(cx * cx + cy * cy);
            var grad = ctx.createRadialGradient(cx, cy, maxR * 0.55, cx, cy, maxR);
            grad.addColorStop(0.0, Qt.rgba(0, 0, 0, 0.0));
            grad.addColorStop(1.0, Qt.rgba(0, 0, 0, 0.55));
            ctx.fillStyle = grad;
            ctx.fillRect(0, 0, parent.width, parent.height);
        }
    }

    onGlowColorChanged: {
        glowCanvas.requestPaint();
        horizonCanvas.requestPaint();
    }
    Component.onCompleted: {
        gridCanvas.requestPaint();
        glowCanvas.requestPaint();
        horizonCanvas.requestPaint();
        vignette.requestPaint();
    }
}
