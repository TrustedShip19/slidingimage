/*
 *   Copyright 2017 thevladsoft <thevladsoft2@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 */

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    width: 350
    height: 350

    property var arreglo: []
    property var vecinos: []
    property var cuadros: []
    property int pasos
    property int ancho: Plasmoid.configuration.tamano
    property int alto: ancho
    property string imagen
    property var distros: [
        "images/distros/arch.png",
        "images/distros/debian.png",
        "images/distros/fedora.png",
        "images/distros/kde.png",
        "images/distros/kubuntu.png",
        "images/distros/neon.png",
        "images/distros/suse.png",
        "images/distros/ubuntu.png"
    ]
    property var photos: [
        "images/photos/arcobaleno.png.jpg",
        "images/photos/bored.png.jpg",
        "images/photos/coffee.png.jpg",
        "images/photos/paris.png.jpg",
        "images/photos/snack.png.jpg",
        "images/photos/the-garden.png.jpg",
        "images/photos/trevi.png.jpg"
    ]
    property var extensions: ["png", "PNG", "jpg", "JPG", "svg", "SVG", "bmp", "BMP", "gif", "GIF"]
    property var customimages: []

    // Modern Plasma 6 contextual action (replaces plasmoid.setAction)
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Restart")
            icon.name: "view-refresh"
            onTriggered: inicializar()
        }
    ]

    Component.onCompleted: {
        inicializar()
    }

    Connections {
        target: Plasmoid.configuration
        function onTamanoChanged() { inicializar() }
        function onDirsourceChanged() { inicializar() }
        function onWichsourceChanged() { inicializar() }
        function onUsedistroChanged() { inicializar() }
        function onUsephotoChanged() { inicializar() }
    }

    function recheckdir() {
        dir.ls(Plasmoid.configuration.dirsource)
    }

    function shuffleArray(array) {
        for (var i = array.length - 2; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1))
            var temp = array[i]
            array[i] = array[j]
            array[j] = temp
        }
    }

    function buscaVecinos(array) {
        var left = array.slice(1).map(function(num, index) {
            if (index % ancho == ancho - 1) return 1
                else return num
        })
        left.push(1)

        var right = array.slice(0, -1)
        right.splice(0, 0, 1)
        right = right.map(function(num, index) {
            if (index % ancho == 0) return 1
                else return num
        })

        var up = array.slice(ancho)
        for (var i = 0; i < ancho; i++) {
            up.push(1)
        }

        var down = array.slice(0, -ancho)
        for (var i = 0; i < ancho; i++) {
            down.unshift(1)
        }

        var result = []
        for (var i = 0; i < ancho * alto; i++) {
            result[i] = left[i] * right[i] * up[i] * down[i]
        }
        return result
    }

    function inicializar() {
        arreglo = []
        pasos = 0
        covertura.visible = false
        recheckdir()

        if (Plasmoid.configuration.wichsource) {
            if (Plasmoid.configuration.usedistro && !Plasmoid.configuration.usephoto) {
                root.imagen = root.distros[Math.floor(Math.random() * root.distros.length)]
            } else if (!Plasmoid.configuration.usedistro && Plasmoid.configuration.usephoto) {
                root.imagen = root.photos[Math.floor(Math.random() * root.photos.length)]
            } else if (Plasmoid.configuration.usedistro && Plasmoid.configuration.usephoto) {
                root.imagen = root.photos.concat(root.distros)[Math.floor(Math.random() * (root.photos.length + root.distros.length))]
            }
        } else {
            root.imagen = Plasmoid.configuration.dirsource + "/" + customimages[Math.floor(Math.random() * root.customimages.length)]
            console.log("----------" + root.imagen)
        }

        for (var i = 0; i < ancho * alto - 1; i++) {
            arreglo[i] = i + 1
        }

        var solvable = false
        while (!solvable || isordered(arreglo, false)) {
            shuffleArray(arreglo)
            arreglo[ancho * alto - 1] = 0
            solvable = isSolvable(arreglo)
        }

        vecinos = buscaVecinos(arreglo)

        for (var i = 0; i < cuadros.length; i++) {
            cuadros[i].destroy()
        }
        cuadros = []

        for (var i = 0; i < ancho * alto - 1; i++) {
            cuadros[i] = Qt.createQmlObject(
                'import QtQuick; \
                Item { \
                clip: true; \
                width: Math.floor(root.width / ancho) - 1; \
                height: Math.floor(root.height / alto) - 1; \
                x: 0; y: 0; \
                Image { \
                source: root.imagen; \
                width: root.width; \
                height: root.height; \
                x: -((' + i + ') % ancho * Math.floor(root.width / ancho)); \
                y: -(Math.floor((' + i + ') / ancho)) * Math.floor(root.height / alto); \
        } \
        MouseArea { \
        anchors.fill: parent; \
        onClicked: rectangleclicked(' + i + ', arreglo) \
        } \
        Behavior on x { NumberAnimation { duration: 300 } } \
        Behavior on y { NumberAnimation { duration: 300 } } \
        Rectangle { \
        color: "transparent"; \
        border.color: "black"; \
        width: Math.floor(root.width / ancho) - 1; \
        height: Math.floor(root.height / alto) - 1; \
        } \
        }',
        fondo, "dynamicSnippet1"
            )
        }
        reposiciona(cuadros)
    }

    function reposiciona(arr) {
        for (var i = 0; i < arr.length; i++) {
            arr[i].x = (arreglo.indexOf(i + 1) % ancho * Math.floor(root.width / ancho))
            arr[i].y = (Math.floor(arreglo.indexOf(i + 1) / ancho)) * Math.floor(root.height / alto)
        }
    }

    function isSolvable(puzzle) {
        var parity = 0
        var gridWidth = Math.floor(Math.sqrt(puzzle.length))
        var row = 0
        var blankRow = 0

        for (var i = 0; i < puzzle.length; i++) {
            if (i % gridWidth == 0) {
                row++
            }
            if (puzzle[i] == 0) {
                blankRow = row
                continue
            }
            for (var j = i + 1; j < puzzle.length; j++) {
                if (puzzle[i] > puzzle[j] && puzzle[j] != 0) {
                    parity++
                }
            }
        }

        if (gridWidth % 2 == 0) {
            if (blankRow % 2 == 0) {
                return parity % 2 == 0
            } else {
                return parity % 2 != 0
            }
        } else {
            return parity % 2 == 0
        }
    }

    function rectangleclicked(j, arreglo) {
        var i = arreglo.indexOf(j + 1)
        if (!vecinos[i]) {
            pasos += 1
            arreglo[arreglo.indexOf(0)] = arreglo[i]
            arreglo[i] = 0
            vecinos = buscaVecinos(arreglo)
            reposiciona(cuadros)
        }
        if (isordered(arreglo)) {
            covertura.visible = true
        }
    }

    function isordered(arr, ceroend) {
        ceroend = ceroend || 1
        var gane = true
        for (var i = 0; i < ancho * alto - 1 - ceroend; i++) {
            if (arr[i + 1] < arr[i]) {
                gane = false
            }
        }
        if (ceroend) {
            if (arr[ancho * alto - 1] && arr[ancho * alto - 1] < arr[ancho * alto - 2]) {
                gane = false
            }
        }
        return gane
    }

    Rectangle {
        id: fondo
        width: root.width
        height: root.height
        color: "transparent"
        border.color: "black"
        border.width: 1
        clip: true

        onWidthChanged: reposiciona(cuadros)
        onHeightChanged: reposiciona(cuadros)

        MouseArea {
            anchors.fill: parent
            onClicked: { }
        }

        Rectangle {
            id: covertura
            width: root.width
            height: root.height
            color: "lightgray"
            border.color: "red"
            border.width: 3
            z: 1000
            visible: false
            opacity: visible ? 0.85 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 700
                    easing.type: Easing.InExpo
                }
            }

            Image {
                source: root.imagen
                width: fondo.width
                height: fondo.height
                x: 0
                y: 0
            }

            Text {
                text: "YOU WIN\nin " + pasos + " steps\n\nClick to restart"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: parent.height
                color: "white"
                styleColor: "red"
                style: Text.Outline
                font.letterSpacing: 1
                elide: Text.ElideMiddle
                font.weight: Font.ExtraBold
                font.pointSize: 12
            }

            MouseArea {
                anchors.fill: parent
                onClicked: inicializar()
            }
        }
    }

    Plasma5Support.DataSource {
        id: dir
        engine: "filebrowser"

        onNewData: {
            disconnectSource(sourceName)
            customimages = data["files.visible"].filter(
                /./.test.bind(new RegExp(extensions.join("$|") + "$"))
            )
        }

        function ls(directorio) {
            connectSource(directorio)
        }
    }
}
