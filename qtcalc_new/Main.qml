import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    width: 370
    height: 520
    minimumWidth: 370
    maximumWidth: 360
    minimumHeight: 520
    maximumHeight: 520
    visible: true
    color: "#1e1e1e"
    title: "Calculator"

    Item {
        id: root
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event)=>{

            if(event.key >= Qt.Key_0 && event.key <= Qt.Key_9)
                // calculatorBackend.append(String.fromCharCode(event.key))
                calculatorBackend.append(event.text)

            else if(event.key === Qt.Key_Plus) calculatorBackend.append("+")
            else if(event.key === Qt.Key_Minus) calculatorBackend.append("-")
            else if(event.key === Qt.Key_Asterisk) calculatorBackend.append("*")
            else if(event.key === Qt.Key_Slash) calculatorBackend.append("/")
            else if(event.key === Qt.Key_Period) calculatorBackend.append(".")
            else if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                calculatorBackend.evaluate()
            else if(event.key === Qt.Key_Backspace)
                calculatorBackend.backspace()
            else if(event.key === Qt.Key_Escape)
                calculatorBackend.clearAll()
        }

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle{
                Layout.fillWidth: true
                height: 90
                radius: 10
                color:"#121212"

                Text{
                    id: display
                    text: calculatorBackend.displayText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 15
                    font.pixelSize: 40
                    color:"white"
                }
            }

            RowLayout{
                Layout.fillWidth: true
                spacing: 6

                Button{
                    text:"DEC"
                    Layout.fillWidth: true
                    font.pixelSize: 12
                    onClicked: calculatorBackend.showDecimal()
                }

                Button{
                    text:"HEX"
                    Layout.fillWidth: true
                    font.pixelSize: 12
                    onClicked: calculatorBackend.showHex()
                }
            }

            GridLayout {
                columns: 4
                rowSpacing: 10
                columnSpacing: 10
                Layout.fillWidth: true

                Button { text:"C"; onClicked: calculatorBackend.clearAll(); palette.button:"#f44336" }
                Button { text:"⌫"; onClicked: calculatorBackend.backspace(); }
                Button { text:"/"; onClicked: calculatorBackend.append("/"); palette.button:"#ff9800" }
                Button { text:"*"; onClicked: calculatorBackend.append("*"); palette.button:"#ff9800" }

                Button { text:"7"; onClicked: calculatorBackend.append("7") }
                Button { text:"8"; onClicked: calculatorBackend.append("8") }
                Button { text:"9"; onClicked: calculatorBackend.append("9") }
                Button { text:"-"; onClicked: calculatorBackend.append("-"); palette.button:"#ff9800" }

                Button { text:"4"; onClicked: calculatorBackend.append("4") }
                Button { text:"5"; onClicked: calculatorBackend.append("5") }
                Button { text:"6"; onClicked: calculatorBackend.append("6") }
                Button { text:"+"; onClicked: calculatorBackend.append("+"); palette.button:"#ff9800" }

                Button { text:"1"; onClicked: calculatorBackend.append("1") }
                Button { text:"2"; onClicked: calculatorBackend.append("2") }
                Button { text:"3"; onClicked: calculatorBackend.append("3") }

                Button {
                    text:"="
                    onClicked: calculatorBackend.evaluate()
                    palette.button:"#4caf50"
                }

                Button {
                    text:"0"
                    Layout.columnSpan:2
                    onClicked: calculatorBackend.append("0")
                }

                Button { text:"."; onClicked: calculatorBackend.append(".") }
            }
        }
    }
}
