import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    onStatusChanged:
        if (status == PageStatus.Deactivating || status == PageStatus.Inactive) {
            config.pagePath = pathField.text
            config.host = hostField.text
            if (updateIntervalField.validator.regExp.test(updateIntervalField.text))
                config.updateInterval = Number(updateIntervalField.text)
            if (backgroundUpdateIntervalField.validator.regExp.test(backgroundUpdateIntervalField.text))
                config.backgroundUpdateInterval = Number(backgroundUpdateIntervalField.text)
        }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            TextField {
                id: hostField
                label: qsTr("URL")
                text: config.host
                onFocusChanged: if (!focus) config.host = text

                rightItem: IconButton {
                    onClicked: hostField.text = config.host = "https://commerce.jolla.com"

                    width: icon.width
                    height: icon.height
                    icon.source: "image://theme/icon-splus-remove"
                    opacity: hostField.text == "https://commerce.jolla.com" ? 0 : 1
                    Behavior on opacity { FadeAnimator {} }
                }
            }

            TextField {
                id: pathField
                label: qsTr("Page path")
                text: config.pagePath
                onFocusChanged: if (!focus) config.pagePath = text

                labelComponent: Component {
                    MiniComboBox {
                        label: qsTr("Page path")
                        onCurrentItemChanged:
                            if (currentItem !== null) currentItem = null
                        menu: ContextMenu {
                            MenuItem {
                                text: qsTr("Jolla Phone")
                                onClicked:
                                    pathField.text = config.pagePath = "/products/jolla-phone-preorder"
                            }
                            MenuItem {
                                text: qsTr("Jolla Phone (Sep 2026)")
                                onClicked:
                                    pathField.text = config.pagePath = "/products/jolla-phone-sept-26"
                            }
                        }
                    }
                }
            }

            TextSwitch {
                text: qsTr("Auto-update")
                checked: config.autoUpdate
                onCheckedChanged: config.autoUpdate = checked
            }

            TextField {
                id: updateIntervalField
                height: config.autoUpdate ? implicitHeight : 0
                Behavior on height { NumberAnimation { duration: 200 } }
                opacity: config.autoUpdate ? 1 : 0
                Behavior on opacity { FadeAnimator {} }

                label: validator.regExp.test(text)
                       ? qsTr("Auto-update interval, in seconds: %1").arg(Format.formatDuration(Number(text)))
                       : qsTr("Auto-update interval, in seconds")
                inputMethodHints: Qt.ImhDigitsOnly // ImhDigitsOnly and ImhFormattedNumbersOnly seem to have no difference
                validator: RegExpValidator { regExp: /^[1-9]\d*$/ }
                text: config.updateInterval
                onFocusChanged: if (!focus && validator.regExp.test(text)) config.updateInterval = Number(text)

                rightItem: IconButton {
                    onClicked: {
                        config.updateInterval = 30
                        updateIntervalField.text = "30"
                    }

                    width: icon.width
                    height: icon.height
                    icon.source: "image://theme/icon-splus-remove"
                    opacity: updateIntervalField.text == "30" ? 0 : 1
                    Behavior on opacity { FadeAnimator {} }
                }
            }

            TextSwitch {
                text: qsTr("Auto-update in background")
                checked: config.backgroundAutoUpdate
                onCheckedChanged: config.backgroundAutoUpdate = checked
            }

            TextField {
                id: backgroundUpdateIntervalField
                height: config.backgroundAutoUpdate ? implicitHeight : 0
                Behavior on height { NumberAnimation { duration: 200 } }
                opacity: config.backgroundAutoUpdate ? 1 : 0
                Behavior on opacity { FadeAnimator {} }

                label: validator.regExp.test(text)
                       ? qsTr("Background auto-update interval, in seconds: %1").arg(Format.formatDuration(Number(text)))
                       : qsTr("Background auto-update interval, in seconds")
                inputMethodHints: Qt.ImhDigitsOnly // ImhDigitsOnly and ImhFormattedNumbersOnly seem to have no difference
                validator: RegExpValidator { regExp: /^[1-9]\d*$/ }
                text: config.backgroundUpdateInterval
                onFocusChanged: if (!focus && validator.regExp.test(text)) config.backgroundUpdateInterval = Number(text)

                rightItem: IconButton {
                    onClicked: {
                        config.backgroundUpdateInterval = 1800
                        backgroundUpdateIntervalField.text = "1800"
                    }

                    width: icon.width
                    height: icon.height
                    icon.source: "image://theme/icon-splus-remove"
                    opacity: backgroundUpdateIntervalField.text == "1800" ? 0 : 1
                    Behavior on opacity { FadeAnimator {} }
                }
            }


            TextSwitch {
                text: qsTr("Show info messages in notifications")
                checked: config.infoInNotifications
                onCheckedChanged: config.infoInNotifications = checked
            }
        }
    }
}
