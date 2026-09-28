import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property alias cfg_tamano: sizeSlider.value
    property alias cfg_dirsource: imagedir.text
    property alias cfg_wichsource: fromPredefined.checked
    property alias cfg_usedistro: distros.checked
    property alias cfg_usephoto: photos.checked

    Kirigami.FormLayout {
        anchors.fill: parent

        // Size slider
        QQC2.Label {
            Kirigami.FormData.label: i18n("Puzzle size:")
            text: sizeSlider.value + "×" + sizeSlider.value
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Size")
            Layout.fillWidth: true

            QQC2.Label { text: "2×2" }

            QQC2.Slider {
                id: sizeSlider
                from: 2
                to: 9
                stepSize: 1
                Layout.fillWidth: true
            }

            QQC2.Label { text: "9×9" }
        }

        // Image source selection
        QQC2.ButtonGroup { id: sourceGroup }

        QQC2.RadioButton {
            id: fromPredefined
            Kirigami.FormData.label: i18n("Image source:")
            text: i18n("Predefined images")
            QQC2.ButtonGroup.group: sourceGroup
            checked: true
        }

        ColumnLayout {
            Layout.leftMargin: Kirigami.Units.gridUnit * 2
            spacing: Kirigami.Units.smallSpacing

            QQC2.CheckBox {
                id: distros
                text: i18n("Distro logos")
                enabled: fromPredefined.checked
                onCheckedChanged: {
                    if (!checked && !photos.checked)
                        checked = true
                }
            }

            QQC2.CheckBox {
                id: photos
                text: i18n("Photos")
                enabled: fromPredefined.checked
                onCheckedChanged: {
                    if (!checked && !distros.checked)
                        distros.checked = true
                }
            }
        }

        QQC2.RadioButton {
            id: fromDirectory
            text: i18n("From a directory")
            QQC2.ButtonGroup.group: sourceGroup
            checked: !fromPredefined.checked
            onCheckedChanged: {
                if (checked)
                    fromPredefined.checked = false
            }
        }

        RowLayout {
            visible: fromDirectory.checked
            Layout.fillWidth: true

            QQC2.TextField {
                id: imagedir
                Layout.fillWidth: true
                placeholderText: i18n("Choose a directory with images")
            }

            QQC2.Button {
                text: "…"
                onClicked: folderDialog.open()
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: i18n("Please choose a directory with images")
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)

        onAccepted: {
            // Remove the "file://" prefix
            imagedir.text = selectedFolder.toString().replace(/^file:\/\//, "")
        }
    }
}
