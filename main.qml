import QtQuick 2.7
import QtQuick.Controls 2.0
import QtMultimedia 5.12
import QtQuick.Window 2.0
import Qt.labs.settings 1.1

ApplicationWindow {
    id: app
    visible: true
    visibility: "Windowed"
    width: apps.aw
    height: apps.ah
    color: 'black'
    x:apps.x
    y:apps.y
    title: 'Qml WebCam - by @nextsigner'
    flags: Qt.Window | Qt.Tool | Qt.WindowStaysOnTopHint//Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    onXChanged: apps.x=x
    onYChanged: apps.y=y
    onWidthChanged: apps.aw=width
    onHeightChanged: apps.ah=height
    property int ppx: 0
    property int ppy: 0
    property int ppw: 100
    property int pph: 100

    property int appw: 100
    property int apph: 100

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
        property int apx: 0
        property int apy: 0
        property int aw: 500
        property int ah: 500
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
            //focus : visible // to receive focus and capture key events when visible
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
//        MouseArea{
//            enabled: app.visibility===ApplicationWindow.FullScreen
//            anchors.fill: parent
//            onDoubleClicked: app.visibility=ApplicationWindow.Windowed
//        }
        MouseArea{
            //enabled: app.visibility!==ApplicationWindow.FullScreen
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
                let isFull=app.width===Screen.width-2

                if(isFull){
                    //app.visibility="Windowed"
                    console.log('Poniendo fullscreen')
                    tW.restart()
                }else{
                    console.log('Sacando fullscreen')
                    app.ppx=videoOutPut.x
                    app.ppy=videoOutPut.y
                    app.ppw=videoOutPut.width
                    app.pph=videoOutPut.height
                    app.appw=app.width
                    app.apph=app.height
                    app.width=Screen.width-2
                    app.height=Screen.height-2
                    app.x=1
                    app.y=1
                    //app.visibility="FullScreen"
                    tFS.restart()
                }
            }
            onClicked:grid.opacity=grid.opacity===0.0?1.0:0.0
        }
        Timer{
            id: tFS
            running: false
            repeat: false
            interval: 500
            onTriggered: {
                videoOutPut.width=xApp.width
                videoOutPut.height=xApp.height
                videoOutPut.x=(xApp.width-videoOutPut.width)/2
                videoOutPut.y=(xApp.height-videoOutPut.height)/2
            }
        }
        Timer{
            id: tW
            running: false
            repeat: false
            interval: 500
            onTriggered: {
                videoOutPut.x=app.ppx
                videoOutPut.y=app.ppy
                videoOutPut.width=app.ppw
                videoOutPut.height=app.pph
                app.width=app.appw
                app.height=app.apph
                console.log('x:'+app.x)
                console.log('y:'+app.y)
                console.log('w:'+app.width)
                console.log('h:'+app.height)
            }
        }
        Timer{
            id: tSP
            running: app.width===Screen.width-2&&(app.x!==1||app.y!==1)
            repeat: true
            interval: 500
            onTriggered: {
                app.x=1
                app.y=1
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
                model: ['z-', 'z+', 's1', 's2', 's3','s4',  'r','c', 'q']
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
            videoOutPut.x=(app.width-videoOutPut.width)/2
            videoOutPut.y=(app.height-videoOutPut.height)/2
        }
        if(action===8){
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
            //videoOutPut.fillMode = VideoOutput.PreserveAspectCrop
            videoOutPut.fillMode = VideoOutput.PreserveAspectFit
        }
        console.log('x:'+app.x)
        console.log('y:'+app.y)
        console.log('w:'+app.width)
        console.log('h:'+app.height)
        if(app.x>=Screen.width)app.x=0
        if(app.y>=Screen.height)app.y=0
        if(app.width>=Screen.width)app.width=Screen.width
        if(app.height>=Screen.height)app.height=Screen.height
    }
}
