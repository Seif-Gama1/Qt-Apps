#include "networkbackend.h"
#include <QProcess>
#include <QDebug>

NetworkBackend::NetworkBackend(QObject* parent) : QObject(parent) {}

QStringList NetworkBackend::wifiNetworks() const {
    return m_wifiNetworks;
}

void NetworkBackend::scanNetworks() {
    // Start the process
    QProcess *proc = new QProcess(this);

    connect(proc, &QProcess::finished, this, [this, proc](int exitCode, QProcess::ExitStatus) {
        QString output = proc->readAllStandardOutput().trimmed();
        QStringList lines = output.split("\n", Qt::SkipEmptyParts);

        QStringList uniqueList;
        QSet<QString> seenSSIDs;
        QString activeLine = "";

        for (const QString &line : lines) {
            QStringList parts = line.split(":");
            if (parts.size() < 3) continue;

            QString active = parts[0];
            QString ssid = parts[1];

            // 1. If this is the ACTIVE network, save it separately to ensure it's kept
            if (active == "*") {
                activeLine = line;
                seenSSIDs.insert(ssid);
            }
            // 2. If it's a new SSID we haven't seen, add it
            else if (!seenSSIDs.contains(ssid) && !ssid.isEmpty()) {
                uniqueList << line;
                seenSSIDs.insert(ssid);
            }
        }

        // Put the active one at the very top if it exists
        if (!activeLine.isEmpty()) {
            uniqueList.prepend(activeLine);
        }

        m_wifiNetworks = uniqueList;
        emit wifiNetworksChanged();
        proc->deleteLater();
    });

    proc->start("nmcli", QStringList() << "-t" << "-f" << "IN-USE,SSID,SIGNAL" << "dev" << "wifi");
}

void NetworkBackend::connectWifi(const QString &ssid, const QString &password) {
    QProcess *proc = new QProcess(this);
    QStringList args;
    args << "dev" << "wifi" << "connect" << ssid;
    if(!password.isEmpty())
        args << "password" << password;

    connect(proc, &QProcess::finished, this, [this, proc](int exitCode, QProcess::ExitStatus){
        qDebug() << "Connection attempt finished with code:" << exitCode;

        // CRITICAL: Refresh the list so the '*' moves to the new network
        this->scanNetworks();

        proc->deleteLater();
    });

    proc->start("nmcli", args);
}

void NetworkBackend::toggleWifi(bool enabled) {
    if (!enabled) {
        m_wifiNetworks.clear();
        emit wifiNetworksChanged();
    }
    QString state = enabled ? "on" : "off";
    QProcess::startDetached("pkexec", QStringList() << "nmcli" << "radio" << "wifi" << state);
}

// This can be called from Main.qml as: backend.checkWifiStatus()
void NetworkBackend::checkWifiStatus() {
    QProcess *proc = new QProcess(this);
    connect(proc, &QProcess::finished, this, [this, proc](int exitCode, QProcess::ExitStatus){
        QString out = proc->readAllStandardOutput().trimmed();
        // nmcli radio wifi returns "enabled" or "disabled"
        bool isEnabled = (out == "enabled");
        emit wifiStatusChanged(isEnabled);
        proc->deleteLater();
    });
    proc->start("nmcli", QStringList() << "radio" << "wifi");
}


/* bluetooth */
void NetworkBackend::scanBluetooth() {
    QProcess *proc = new QProcess(this);
    connect(proc, &QProcess::finished, this, [this, proc]() {
        QString output = proc->readAllStandardOutput().trimmed();
        QStringList lines = output.split("\n", Qt::SkipEmptyParts);

        QStringList updatedList;

        for (const QString &line : lines) {
            // line format: "Device AA:BB:CC:11:22:33 Name"
            QStringList parts = line.split(" ");
            if (parts.size() >= 3) {
                QString addr = parts[1];
                QString name = line.section(' ', 2);

                // Check if this specific device is connected
                QProcess checkProc;
                checkProc.start("bluetoothctl", QStringList() << "info" << addr);
                checkProc.waitForFinished();
                QString info = checkProc.readAllStandardOutput();
                bool isConnected = info.contains("Connected: yes");
                QString prefix = isConnected ? "*" : " ";

                updatedList << prefix + "|" + addr + "|" + name;
            }
        }
        // Sort: Connected devices at the top
        std::sort(updatedList.begin(), updatedList.end(), [](const QString &a, const QString &b) {
            return a.startsWith('*') && !b.startsWith('*');
        });

        m_bluetoothDevices = updatedList;
        emit bluetoothDevicesChanged();
        proc->deleteLater();
    });
    proc->start("bluetoothctl", QStringList() << "devices");
}

void NetworkBackend::toggleBluetooth(bool enabled) {
    if (!enabled) {
        m_bluetoothDevices.clear();
        emit bluetoothDevicesChanged();
    }
    QString action = enabled ? "unblock" : "block";
    QProcess *proc = new QProcess(this);
    connect(proc, &QProcess::finished, proc, &QObject::deleteLater);
    // We use pkexec if your system requires root to toggle rfkill
    proc->start("pkexec", QStringList() << "rfkill" << action << "bluetooth");
}

void NetworkBackend::checkBluetoothStatus() {
    QProcess *proc = new QProcess(this);
    connect(proc, &QProcess::finished, this, [this, proc]() {
        QString out = proc->readAllStandardOutput().trimmed();
        // If the output contains "unblocked", the switch should be ON (true)
        // If it contains "blocked", it should be OFF (false)
        bool isEnabled = !out.contains("soft: blocked") && !out.contains("hard: blocked");
        emit bluetoothStatusChanged(isEnabled);
        proc->deleteLater();
    });
    proc->start("rfkill", QStringList() << "list" << "bluetooth");
}

void NetworkBackend::connectBluetooth(const QString &address) {
    QProcess *proc = new QProcess(this);

    // We use a bash wrap or direct arguments to ensure the device is
    // trusted and connected. Trusting allows auto-reconnect later.
    QStringList args;
    args << "--" << "connect" << address;

    connect(proc, &QProcess::finished, this, [this, proc, address](int exitCode, QProcess::ExitStatus) {
        if (exitCode == 0) {
            qDebug() << "Successfully connected to:" << address;
        } else {
            qDebug() << "Bluetooth connection failed for:" << address;
        }

        // Refresh the list to update UI states if needed
        this->scanBluetooth();
        proc->deleteLater();
    });

    // Note: Some systems require 'pair' and 'trust' before 'connect'
    // For a simpler implementation, we just call connect:
    proc->start("bluetoothctl", args);
}

void NetworkBackend::disconnectBluetooth(const QString &address) {
    QProcess *proc = new QProcess(this);
    connect(proc, &QProcess::finished, this, [this, proc]() {
        this->scanBluetooth(); // Refresh list to update UI
        proc->deleteLater();
    });
    proc->start("bluetoothctl", QStringList() << "disconnect" << address);
}
