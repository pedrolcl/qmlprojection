import QtQuick 2.13
import QtQuick.Window 2.13

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Timer { repeat: true; running: true; onTriggered: canvas.requestPaint(); interval: 16 }

    property int elapsed: 0
    property bool fill: true

    property real angleX: 2 * Math.PI / 1480
    property real angleY: 2 * Math.PI / 1480
    property real angleZ: 2 * Math.PI / 1480

    property bool rotX: true
    property bool rotY: true
    property bool rotZ: true

    property vector3d bl: Qt.vector3d(-1, -1, 5)
    property vector3d br: Qt.vector3d(1, -1, 5)
    property vector3d tl: Qt.vector3d(-1, 1, 5)
    property vector3d tr: Qt.vector3d(1, 1, 5)

    property vector3d blz: Qt.vector3d(-1, -1, 7)
    property vector3d brz: Qt.vector3d(1, -1, 7)
    property vector3d tlz: Qt.vector3d(-1, 1, 7)
    property vector3d trz: Qt.vector3d(1, 1, 7)

function worldToScreen(p) {
    let factor = canvas.width;
    var screen = {x: p.x / p.z * factor + (canvas.width/2), y: p.y / p.z * factor + (canvas.height / 2)}

    screen.y = screen.y + 40*Math.sin(elapsed / 20);
    return screen
}

function rotateZ(p) {
  return Qt.vector3d(p.x*Math.cos(angleZ) - p.y*Math.sin(angleZ), p.y*Math.cos(angleZ) + p.x*Math.sin(angleZ), p.z);
}

function rotateX(p) {
    let z = p.z - 6
    let y = p.y*Math.cos(angleX) - z*Math.sin(angleX)
    let zz = (p.y*Math.sin(angleX) + z*Math.cos(angleX)) + 6
    return Qt.vector3d(p.x, y, zz);
}

function rotateY(p) {
    let z = p.z - 6
    let x = p.x*Math.cos(angleY) + z*Math.sin(angleY)
    let zz = (-p.x*Math.sin(angleY) + z*Math.cos(angleY)) + 6
    return Qt.vector3d(x, p.y, zz);
}

function drawPixel(point) {
     context.fillStyle = "#222"
     context.fillRect(point.x, point.y, 1, 1)
   }


function drawLine(p0, p1) {
    context.beginPath();
    context.moveTo(p0.x, p0.y);
    context.lineTo(p1.x, p1.y);
    context.lineWidth = "2"
    context.strokeStyle = "#222";
    context.stroke();
}

Canvas {
    id: canvas
    anchors.fill: parent

    property var context

    onPaint: {

    canvas.context = canvas.getContext("2d");

    canvas.context.fillStyle = "darkgrey";
    canvas.context.fillRect(0, 0, canvas.width, canvas.height);

    if (rotZ === true) {
        bl = rotateZ(bl)
        br = rotateZ(br)
        tl = rotateZ(tl)
        tr = rotateZ(tr)
        blz = rotateZ(blz)
        brz = rotateZ(brz)
        tlz = rotateZ(tlz)
        trz = rotateZ(trz)
    }

    if (rotY === true) {
        bl = rotateY(bl)
        br = rotateY(br)
        tl = rotateY(tl)
        tr = rotateY(tr)
        blz = rotateY(blz)
        brz = rotateY(brz)
        tlz = rotateY(tlz)
        trz = rotateY(trz)
    }

    if (rotZ === true) {
        bl = rotateX(bl)
        br = rotateX(br)
        tl = rotateX(tl)
        tr = rotateX(tr)
        blz = rotateX(blz)
        brz = rotateX(brz)
        tlz = rotateX(tlz)
        trz = rotateX(trz)
    }

    var blr = worldToScreen(bl)
    var brr = worldToScreen(br)
    var tlr = worldToScreen(tl)
    var trr = worldToScreen(tr)
    var blrz = worldToScreen(blz)
    var brrz = worldToScreen(brz)
    var tlrz = worldToScreen(tlz)
    var trrz = worldToScreen(trz)

    let face1z = (bl.z + br.z + tr.z + tl.z) / 4;
    let face2z = (blz.z + brz.z + trz.z + tlz.z) / 4;
    let face3z = (bl.z + tl.z + tlz.z + blz.z) / 4;
    let face4z = (br.z + tr.z + trz.z + brz.z) / 4;
    let face5z = (tl.z + tr.z + trz.z + tlz.z) / 4;
    let face6z = (bl.z + br.z + brz.z + blz.z) / 4;

    let front = {p1: blr, p2: brr, p3: trr, p4: tlr, color: "#bb2222", z: face1z};
    let back = {p1: blrz, p2: brrz, p3: trrz, p4: tlrz, color: "#22bb22", z: face2z};
    let left = {p1: blr, p2: tlr, p3: tlrz, p4: blrz, color: "#2222bb", z: face3z};
    let right = {p1: brr, p2: trr, p3: trrz, p4: brrz, color: "#22bbbb", z: face4z};
    let top = {p1: tlr, p2: trr, p3: trrz, p4: tlrz, color: "#bb22bb", z: face5z};
    let bottom = {p1: blr, p2: brr, p3: brrz, p4: blrz, color: "#bbbb22", z: face6z};

    var faces = [front, back, left, right, top, bottom];
    faces.sort(zSort);
    faces.forEach(drawFace);

    elapsed++;

    if (elapsed === 500) {
        fill = !fill;
        var min = 360;
        var max = 3600;

        angleX = 2 * Math.PI / (Math.random()*(max - min) + min);
        angleY = 2 * Math.PI / (Math.random()*(max - min) + min);
        angleZ = 2 * Math.PI / (Math.random()*(max - min) + min);

        elapsed = 0;
    }
   }
}
   function zSort(a, b) {
       let aZ = a.z;
       let bZ = b.z;

       if (aZ < bZ) { return 1; }
       if (aZ > bZ) { return -1; }

       return 0;
   }

   function drawFace(face) {
    var ctx = canvas.context

    let p1 = face.p1;
    let p2 = face.p2;
    let p3 = face.p3;
    let p4 = face.p4;

    ctx.beginPath();
    ctx.moveTo(p1.x, p1.y);
    ctx.lineTo(p2.x, p2.y);
    ctx.lineTo(p3.x, p3.y);
    ctx.lineTo(p4.x, p4.y);
    ctx.closePath();
    ctx.stroke();
    ctx.fillStyle = face.color;

    if (fill === true)  {
        ctx.fill();
    }
   }
}
