import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0

ApplicationWindow {
    id: appWindow
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    property bool loading: true
    property bool refreshing
    property int number
    property int total
    property int percentage
    property int endTime
    property var images: []
    property string productTitle
    property url externalUrl

    Notification {
        id: notifier
        replacesId: 0
        onReplacesIdChanged: if (replacesId !== 0) replacesId = 0
        isTransient: !config.infoInNotifications
        appIcon: 'image://theme/icon-lock-warning'
        summary: qsTr("Enjoying failure!")
    }

    WorkerScript {
        id: worker
        source: Qt.resolvedUrl("js/worker.js")

        onMessage: {
            var v = messageObject.v
            switch (messageObject.t) {
            case 'url':
                externalUrl = v
                break
            case 'number':
                number = v
                break
            case 'total':
                total = v
                break
            case 'percentage':
                percentage = v
                break
            case 'endTime':
                endTime = v
                break
            case 'productTitle':
                productTitle = v
                break
            case 'images':
                if (images !== v)
                    images = v
                break
            case 'loaded':
                loading = refreshing = false
                break
            case 'error':
                console.log("Error", v)
                notifier.body = JSON.stringify(v)
                notifier.publish()
                break
            case 'error2':
                console.log("Error2", v)
                notifier.body = qsTr("Error %1").arg(v)
                notifier.publish()
                break
            }
        }
    }

    function update() {
        worker.sendMessage({
                               host: config.host,
                               pagePath: config.pagePath
                           })
    }

    Connections {
        target: config
        onHostChanged: {
            loading = true
            update()
        }
        onPagePathChanged: {
            loading = true
            update()
        }
    }

    Component.onCompleted: update()

    ConfigurationGroup {
        id: config
        path: '/apps/harbour-j2enjoyer'

        property string host: 'https://commerce.jolla.com'
        property string pagePath: '/products/jolla-phone-sept-26'
        property bool autoUpdate: true
        property real updateInterval: 30 // while real value can't be customized in the app, it can be by editing dconf value manually
        property bool backgroundAutoUpdate: true
        property real backgroundUpdateInterval: 1800 // 30 minutes

        property bool infoInNotifications: false
    }
}
