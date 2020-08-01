import QtQuick 2.7
import QtQuick.Controls 2.0
import QtMultimedia 5.12
import QtQuick.Window 2.0
import Qt.labs.settings 1.1

ApplicationWindow {
    id: app
    visible: true
    visibility: "Windowed"
    width: Screen.width-982
    height: Screen.height-500-40
    color: 'black'
    x:apps.x
    y:apps.y
    title: 'Qml WebCam - by @nextsigner'
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    onXChanged: apps.x=x
    onYChanged: apps.y=y
    Settings{
        id: apps
        fileName: pws+'/qml-webcam.cfg'
        //Ventana
        property int x: 0
        property int y: 0

        //VideoOutPut
        property int px: 0
        property int py: 0
        property int w: xApp.width
        property int h: xApp.height
        property int rotation: -90
    }
    Item{
        id: xApp
        anchors.fill: parent
        Camera {
            id: camera

            imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

            exposure {
                exposureCompensation: -1.0
                exposureMode: Camera.ExposurePortrait
            }
            flash.mode: Camera.FlashRedEyeReduction
        }

        VideoOutput {
            id: videoOutPut
            source: camera
            width: apps.w
            height: apps.h
            //anchors.centerIn: parent
            x: apps.px
            y: apps.py
            rotation:apps.rotation
            //fillMode: VideoOutput.PreserveAspectCrop
            //fillMode: VideoOutput.PreserveAspectFit
            focus : visible // to receive focus and capture key events when visible
            onXChanged: apps.px=x
            onYChanged: apps.py=y
            onWidthChanged: apps.w=width
            onHeightChanged: apps.h=height
            onRotationChanged: apps.rotation=rotation
        }
        Rectangle{
            opacity: grid.opacity
            width: 6
            height: width
            radius: width*0.5
            anchors.centerIn: parent
            color: 'red'
        }
        Rectangle{
            opacity: grid.opacity
            width: 12
            height: width
            radius: width*0.5
            anchors.centerIn: videoOutPut
            color: 'transparent'
            border.width: 2
            border.color: 'red'
        }
        Rectangle{
            opacity: grid.opacity
            anchors.fill: videoOutPut
            color: 'transparent'
            border.width: 4
            border.color: 'red'
            Rectangle{
                width: parent.width-30
                height: parent.height-30
                anchors.centerIn: parent
                color: 'transparent'
                border.width: 3
                border.color: 'red'
            }
            Rectangle{
                width: parent.width-60
                height: parent.height-60
                anchors.centerIn: parent
                color: 'transparent'
                border.width: 2
                border.color: 'red'
            }
            Rectangle{
                width: parent.width-90
                height: parent.height-90
                anchors.centerIn: parent
                color: 'transparent'
                border.width: 1
                border.color: 'red'
            }
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            drag.target: videoOutPut
            drag.axis: Drag.XAndYAxis
            onMouseXChanged: grid.opacity=1.0
            property variant clickPos: "1,1"
            property bool presionado: false
            onReleased: {
                presionado = false
                apps.x = app.x
                apps.y = app.y
            }
            onPressed: {
                presionado = true
                clickPos  = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                if (mouse.modifiers & Qt.ControlModifier) {
                    console.log("Mouse area pressed with control")
                }else{
                    if(presionado){
                        var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                        app.x += delta.x;
                        app.y += delta.y;
                    }
                }
            }
            onDoubleClicked: {
                if(app.visibility===ApplicationWindow.FullScreen){
                    app.visibility="Windowed"
                }else{
                    app.visibility="FullScreen"
                }
            }
        }


        Grid{
            id: grid
            anchors.centerIn: parent
            spacing: 10
            columns: 2
            opacity: 0.0
            Behavior on opacity{
                NumberAnimation{duration: 500}
            }
            Timer{
                id: tHideGrid
                running: grid.opacity===1.0
                repeat: false
                interval: 3000
                onTriggered: {
                    grid.opacity=0.0
                }
            }
            Repeater{
                model: ['z-', 'z+', 's1', 's2', 's3','s4',  'r', 'q']
                Rectangle{
                    width: 20
                    height: width
                    border.width: 2
                    border.color: 'red'
                    Text{
                        text: modelData
                        font.pixelSize: 10
                        anchors.centerIn: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onMouseXChanged: tHideGrid.restart()
                        onMouseYChanged: tHideGrid.restart()
                        onClicked: {
                            app.runAction(index)
                        }
                    }
                }
            }
        }
    }
    function runAction(action){
        if(action===0){
            console.log('----')
            videoOutPut.width-=10
            videoOutPut.height-=10
        }
        if(action===1){
            videoOutPut.width+=10
            videoOutPut.height+=10
            console.log('+++')
        }
        if(action===2){
            setStatus(4)
        }
        if(action===3){
            setStatus(1)
        }
        if(action===4){
            setStatus(3)
        }
        if(action===5){
            setStatus(2)
        }
        if(action===6){
            videoOutPut.rotation-=90
        }
        if(action===7){
            Qt.quit()
        }
    }
    function setStatus(status){
        if(status===1){
            app.x=Screen.width-app.width
            app.y=0
        }
        if(status===2){
            app.x=Screen.width-app.width
            app.y=Screen.height-app.height-35
        }
        if(status===3){
            app.x=0
            app.y=Screen.height-app.height-35
        }
        if(status===4){
            app.x=0
            app.y=0
        }
    }
    Component.onCompleted: {
        let args=''+Qt.application.arguments.toString()
        console.log('Args: '+args)

        if(args.indexOf('-cam=')>=0){
            let numCam=args.split('-cam=')[1].split(' ')[0]
            let deviceId=QtMultimedia.availableCameras[parseInt(numCam)].deviceId
            console.log('Device Camera id: '+deviceId)
            camera.deviceId=deviceId
        }
        if(args.indexOf('-rotation=')>=0){
            let rotation=parseInt(args.split('-rotation=')[1].split(' ')[0])
            videoOutPut.rotation=rotation
        }
        if(Qt.platform.os==='windows'){
            videoOutPut.fillMode = VideoOutput.PreserveAspectCrop
        }
    }
}
