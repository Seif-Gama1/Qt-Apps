import QtQuick
import QtMultimedia

Item {
    id:root
    signal bootFinished
    opacity: 1

    Behavior on opacity {
        NumberAnimation { duration: 800 }
    }

    MediaPlayer {
        id: player
        source: "qrc:/splash_scr_audio.wav"
        audioOutput: AudioOutput {}
        loops: MediaPlayer.Infinite
    }
    Component.onCompleted: {
        player.play()
    }
    Rectangle {
        anchors.fill: parent
        color: "black"

        AnimatedImage {
            id: logoGif
            source: "qrc:/splash_screen.gif"
            anchors.centerIn: parent
            width: 300
            height: 300
            fillMode: Image.PreserveAspectFit
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: false

        onTriggered: {
            player.stop()
            console.log("final stopping")
            root.opacity = 0
            fadeDelay.start()
        }
    }

    Timer {
        id: fadeDelay
        interval: 800   // same as animation
        repeat: false

        onTriggered: bootFinished()
    }


}
