import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    Timer {
        // Keep this here to only update when this page is active
        running: Qt.application.state === Qt.ApplicationActive ? (config.autoUpdate && page.status == PageStatus.Active) : config.backgroundAutoUpdate
        repeat: true
        interval: (Qt.application.state === Qt.ApplicationActive ? config.backgroundUpdateInterval : config.updateInterval) * 1000
        onTriggered: update()
    }

    SilicaFlickable {
        id: listView
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            busy: appWindow.refreshing && !appWindow.loading

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push("AboutPage.qml")
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push("SettingsPage.qml")
            }
            MenuItem {
                text: qsTr("Enjoy in Browser")
                onClicked: Qt.openUrlExternally(externalUrl)
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    appWindow.refreshing = true
                    appWindow.update()
                }
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium
            opacity: loading ? 0 : 1
            Behavior on opacity { FadeAnimator {} }

            PageHeader {
                title: qsTr("J2: Enjoyer!")
                description: productTitle
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                //bottomPadding: Theme.paddingMedium
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge * 2
                text: number
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("sold out of %n", "after a number of units, e.g. 1500 [in big] <new line> sold out of 2000", total)
            }

            ProgressBar {
                width: parent.width
                minimumValue: 0
                maximumValue: total
                value: number
                valueText: qsTr("%Ln% funded", '', percentage)
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                //bottomPadding: Theme.paddingMedium
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                text: (endTime < approximateCurrentTime
                       ? (total > number
                          ? qsTr("The product will not be produced as %n units were not supported by %1", "%1 is date", total)
                          : qsTr("The product will be produced as %n units were supported by %1", "%1 is date", total))
                       : qsTr("The product will only be produced if %n units are supported by %1", "%1 is date", total)
                       ).arg(Format.formatDate(new Date(endTime*1000), Formatter.DateFull))
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                //bottomPadding: Theme.paddingMedium
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge

                Timer {
                    running: !loading && Qt.application.state === Qt.ApplicationActive
                    triggeredOnStart: true
                    repeat: true
                    interval: 1000
                    onTriggered:
                        parent.text = Format.formatDate(new Date(endTime*1000), Formatter.DurationElapsed)
                }
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
                text: endTime < approximateCurrentTime
                      ? qsTr("ended", "after the duration before the deadline, e.g. 3 MONTHS AGO <new line> ended")
                      : qsTr("will end", "after the duration before the deadline, e.g. IN 3 MONTHS <new line> will end")
            }

            PagedView {
                id: picturesView
                width: parent.width
                height: Theme.itemSizeExtraLarge * 3
                model: images

                delegate: Image {
                    id: image
                    width: PagedView.contentWidth
                    height: PagedView.contentHeight
                    source: modelData
                    fillMode: Image.PreserveAspectCrop

                    // HighlightImage is kinda broken, so we use this
                    layer {
                        enabled: imageMouseArea.containsPress
                        effect: PressEffect { source: image }
                    }

                    MouseArea {
                        id: imageMouseArea
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(modelData)
                    }
                }
            }

            Item {height:1; width: Theme.paddingLarge}
        }

        VerticalScrollDecorator {}
    }

    BusyLabel {
        running: loading
    }
}
