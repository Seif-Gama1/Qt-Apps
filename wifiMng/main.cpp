#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>
#include <QQmlContext>
#include "networkbackend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    NetworkBackend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);
    // engine.load(QUrl(QStringLiteral("qrc:/Main.qml"))); // if in resources
    // engine.load(QUrl::fromLocalFile("Main.qml"));
    engine.loadFromModule("wifiMng", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
