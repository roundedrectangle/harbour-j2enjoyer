TARGET = harbour-j2enjoyer

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-j2enjoyer.qml \
    qml/cover/CoverPage.qml \
    qml/js/dom-parser.js \
    qml/js/worker.js \
    qml/pages/AboutPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/PressEffect.qml \
    rpm/harbour-j2enjoyer.changes.in \
    rpm/harbour-j2enjoyer.changes.run.in \
    rpm/harbour-j2enjoyer.spec \
    translations/*.ts \
    harbour-j2enjoyer.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-j2enjoyer-ru.ts \
    translations/harbour-j2enjoyer-it.ts

images.files = images
images.path = /usr/share/$${TARGET}

INSTALLS += images
