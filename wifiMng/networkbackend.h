#ifndef NETWORKBACKEND_H
#define NETWORKBACKEND_H

#include <QObject>
#include <QStringList>

class NetworkBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList wifiNetworks READ wifiNetworks NOTIFY wifiNetworksChanged)
    Q_PROPERTY(QStringList bluetoothDevices READ bluetoothDevices NOTIFY bluetoothDevicesChanged)

public:
    explicit NetworkBackend(QObject* parent = nullptr);

    /* wifi */
    QStringList wifiNetworks() const;
    Q_INVOKABLE void scanNetworks();
    Q_INVOKABLE void connectWifi(const QString &ssid, const QString &password);
    Q_INVOKABLE void toggleWifi(bool enabled);
    Q_INVOKABLE void checkWifiStatus();

    /* bluetooth */
    QStringList bluetoothDevices() const { return m_bluetoothDevices; }
    Q_INVOKABLE void scanBluetooth();
    Q_INVOKABLE void toggleBluetooth(bool enabled);
    Q_INVOKABLE void connectBluetooth(const QString &address);
    Q_INVOKABLE void checkBluetoothStatus();
    Q_INVOKABLE void disconnectBluetooth(const QString &address);

signals:
    void wifiNetworksChanged();
    void wifiStatusChanged(bool enabled);

    void bluetoothDevicesChanged();
    void bluetoothStatusChanged(bool enabled);

private:
    QStringList m_wifiNetworks;
    QStringList m_bluetoothDevices;
};

#endif
