import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import NodoSystem 1.1
import NodoCanvas 1.0


ApplicationWindow {
    id: mainAppWindow
    visible: true
    visibility: "FullScreen"

    modality: Qt.WindowModal
    property int displayRotation: nodoControl.getOrientation()

    contentOrientation: displayRotation == -90 ? Qt.InvertedLandscapeOrientation : displayRotation == 90 ? Qt.LandscapeOrientation : displayRotation == 0 ? Qt.PortraitOrientation : Qt.InvertedPortraitOrientation

    width: displayRotation == 0 || displayRotation == 180 ? 1920 : 1080
    height: displayRotation == 0 || displayRotation == 180 ? 1080 : 1920


    title: qsTr("NodoUI");

    NodoCurrencies{
        id: nodoCurrencies
    }

    NodoTimezones{
        id: nodoTimezones
    }

    property bool screenLocked: false;

    Rectangle {
        id: mainAppWindowMainRect

        rotation: displayRotation

        x: displayRotation == 0 || displayRotation == 180 ? 0 : -420
        y: displayRotation == 0 || displayRotation == 180 ? 0 : 420
        width: displayRotation == 0 || displayRotation == 180 ? mainAppWindow.width : mainAppWindow.height
        height: displayRotation == 0 || displayRotation == 180 ? mainAppWindow.height : mainAppWindow.width

        Connections {
            target: nodoControl
            function onOrientationChanged()
            {
                var orientation = nodoControl.getOrientation()
                mainAppWindow.displayRotation = orientation
                mainAppWindowMainRect.rotation = orientation
                mainAppWindow.contentOrientation = displayRotation == -90 ? Qt.InvertedLandscapeOrientation : displayRotation == 90 ? Qt.LandscapeOrientation : displayRotation == 0 ? Qt.PortraitOrientation : Qt.InvertedPortraitOrientation

            }
        }

        color: "black"

        StackView {
            id: mainAppStackView
            anchors.fill: parent
            initialItem: "NodoHomeScreen.qml"

            pushEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 0
                }
            }
            pushExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 0
                }
            }
            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 0
                }
            }
            popExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 0
                }
            }
        }

        MouseArea {
            id: mainAppMouseAreaClicked
            anchors.fill: parent
            propagateComposedEvents: true

            onPressed: (mouse)=> {
                mouse.accepted = false
                mainAppLockTimer.restart()
                if(screenLocked === true){
                    mainAppWindow.screenLocked = false
                    mainAppLockTimer.restart()
                    mainAppStackView.pop()
                }
            }
        }

        NodoInputFieldPreview
        {
            id: previewPanel
            x: 0
            y: mainAppWindowMainRect.height
            width: mainAppWindowMainRect.width
            height: NodoSystem.infoFieldLabelHeight

            Connections {
                target: nodoControl
                function onInputFieldTextChanged() {
                    previewPanel.text = nodoControl.getInputFieldText()
                }
            }
        }

        InputPanel {
            id: inputPanel
            z: 99
            x: 0
            y: mainAppWindowMainRect.height + previewPanel.height
            width: mainAppWindowMainRect.width

            states: State {
                name: "visible"
                when: inputPanel.active
                PropertyChanges {
                    target: inputPanel
                    y: mainAppWindowMainRect.height + previewPanel.height - inputPanel.height - 70
                }

                PropertyChanges {
                    target: previewPanel
                    y: mainAppWindowMainRect.height - inputPanel.height -70
                }
            }
            transitions: Transition {
                from: ""
                to: "visible"
                reversible: true
                ParallelAnimation {
                    NumberAnimation {
                        properties: "y"
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        function lockSystem()
        {
            if(screenLocked === false){
                mainAppLockTimer.stop()
                screenLocked = true
                systemPopup.close()
                mainAppStackView.pop()
                if(0 === nodoControl.getScreenSaverType()) {
                    mainAppStackView.push("NodoFeederScreenSaver.qml")
                }
                else if(1 === nodoControl.getScreenSaverType())
                {
                    mainAppStackView.push("NodoScreenSaver.qml")
                }
                else if(2 === nodoControl.getScreenSaverType())
                {
                    mainAppStackView.push("NodoDigitalClock.qml")
                }
            }
        }

        Timer {
            id: mainAppLockTimer
            interval: nodoControl.getScreenSaverTimeout(); running: true; repeat: false
            onTriggered: mainAppWindowMainRect.lockSystem()
        }

        Popup {
            id: systemPopup
            x: (mainAppWindowMainRect.width - width)/2
            y: (mainAppWindowMainRect.height - height)/2
            width: 655
            height: 200
            modal: true
            property string applyButtonText: ""
            property int commandID: -1
            parent: mainAppWindowMainRect

            Overlay.modal: Item {
                Rectangle{
                    color: 'black'
                    opacity: 0.3
                    width: mainAppWindowMainRect.width
                    height: mainAppWindowMainRect.height
                }
            }

            background: null
            contentItem: NodoCanvas {
                id: popupContent

                width: systemPopup.width
                height: systemPopup.height

                color: "#141414"

                Text {
                    id: popupMessage
                    anchors.top: popupContent.top
                    anchors.topMargin: 20
                    x: (popupContent.width - popupMessage.paintedWidth)/2

                    text: qsTr("Are you sure?")
                    font.pixelSize: NodoSystem.infoFieldItemFontSize
                    font.family: NodoSystem.fontUrbanist.name
                    color: nodoControl.appTheme ? NodoSystem.dataFieldTextColorNightModeOn  : NodoSystem.dataFieldTextColorNightModeOff
                }

                NodoButton {
                    id: applyButton
                    text: systemPopup.applyButtonText
                    anchors.top: popupMessage.bottom
                    anchors.left: popupContent.left
                    anchors.topMargin: 30
                    anchors.leftMargin: 12
                    height: NodoSystem.nodoItemHeight
                    font.family: NodoSystem.fontUrbanist.name
                    font.pixelSize: NodoSystem.buttonTextFontSize

                    onClicked: {
                        if(0 == systemPopup.commandID)
                        {
                            nodoControl.restartDevice();
                            //console.log("restarting")
                        }
                        else if(1 == systemPopup.commandID)
                        {
                            nodoControl.shutdownDevice();
                            //console.log("shuting down")
                        }
                        else if(2 == systemPopup.commandID)
                        {
                            nodoControl.systemRecovery(deviceSystemRecoveryRecoverFS.checked, deviceSystemRecoveryResyncBlockchain.checked);
                            //console.log("recovering")
                        }
                    }
                }

                NodoButton {
                    id: cancelButton
                    text: qsTr("Cancel")
                    anchors.top: applyButton.top
                    anchors.left: applyButton.right
                    anchors.leftMargin: 16
                    height: NodoSystem.nodoItemHeight
                    font.family: NodoSystem.fontUrbanist.name
                    font.pixelSize: NodoSystem.buttonTextFontSize
                    onClicked: {
                        systemPopup.close()
                    }
                }
            }
        }
    }
}

