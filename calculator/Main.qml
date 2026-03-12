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

    property string expression: ""
    property bool resultDisplayed: false

    function append(value) {

        if(resultDisplayed && value.match(/[0-9]/)){
            expression = ""
            resultDisplayed = false
        }

        if(value === "."){
            let parts = expression.split(/[\+\-\*\/]/)
            if(parts[parts.length-1].includes(".")) return
        }

        expression += value
        display.text = expression
    }

    function clearAll(){
        expression = ""
        display.text = "0"
        resultDisplayed = false
    }

    function backspace(){
        expression = expression.slice(0,-1)
        display.text = expression === "" ? "0" : expression
    }

    function evaluateExpression(){

        try{

            if(expression === "")
                return

            if(/\/0(?!\d)/.test(expression)){
                display.text="Error"
                expression=""
                return
            }

            let result = Function("return " + expression)()

            if(!isFinite(result)){
                display.text="Error"
                expression=""
                return
            }

            result = parseFloat(result.toFixed(6))

            display.text = result
            expression = result.toString()

            resultDisplayed = true
        }
        catch(e){
            display.text="Invalid"
            expression=""
        }
    }

    function showDecimal(){
        display.text = parseInt(expression).toString(10)
    }

    function showHex(){
        display.text = "0x" + parseInt(expression).toString(16).toUpperCase()
    }


    Item {
        id: root
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event)=>{

            if(event.key >= Qt.Key_0 && event.key <= Qt.Key_9)
                append(String.fromCharCode(event.key))

            else if(event.key === Qt.Key_Plus) append("+")
            else if(event.key === Qt.Key_Minus) append("-")
            else if(event.key === Qt.Key_Asterisk) append("*")
            else if(event.key === Qt.Key_Slash) append("/")
            else if(event.key === Qt.Key_Period) append(".")
            else if(event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                evaluateExpression()
            else if(event.key === Qt.Key_Backspace)
                backspace()
            else if(event.key === Qt.Key_Escape)
                clearAll()
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
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 15
                    text:"0"
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
                    onClicked: showDecimal()
                }

                Button{
                    text:"HEX"
                    Layout.fillWidth: true
                    font.pixelSize: 12
                    onClicked: showHex()
                }
            }

            GridLayout {
                columns: 4
                rowSpacing: 10
                columnSpacing: 10
                Layout.fillWidth: true

                Button { text:"C"; onClicked: clearAll(); palette.button:"#f44336" }
                Button { text:"⌫"; onClicked: backspace() }
                Button { text:"/"; onClicked: append("/"); palette.button:"#ff9800" }
                Button { text:"*"; onClicked: append("*"); palette.button:"#ff9800" }

                Button { text:"7"; onClicked: append("7") }
                Button { text:"8"; onClicked: append("8") }
                Button { text:"9"; onClicked: append("9") }
                Button { text:"-"; onClicked: append("-"); palette.button:"#ff9800" }

                Button { text:"4"; onClicked: append("4") }
                Button { text:"5"; onClicked: append("5") }
                Button { text:"6"; onClicked: append("6") }
                Button { text:"+"; onClicked: append("+"); palette.button:"#ff9800" }

                Button { text:"1"; onClicked: append("1") }
                Button { text:"2"; onClicked: append("2") }
                Button { text:"3"; onClicked: append("3") }

                Button {
                    text:"="
                    onClicked: evaluateExpression()
                    palette.button:"#4caf50"
                }

                Button {
                    text:"0"
                    Layout.columnSpan:2
                    onClicked: append("0")
                }

                Button { text:"."; onClicked: append(".") }
            }
        }
    }
}
