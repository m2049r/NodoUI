#ifndef DAEMON_H
#define DAEMON_H

#include <QObject>
#include <QtDBus/QDBusConnection>
#include <QTimer>
#include <QHostAddress>
#include <QNetworkInterface>
#include "PowerKeyThread.h"
#include "RecoveryKeyThread.h"
#include "ServiceManagerThread.h"
#include "MoneroLWSND.h"
#include "UserAuthentication.h"
#include "nodo_dbus_adaptor.h"

#define PING_PERIOD_NOT_CONNECTED 3*1000
#define PING_PERIOD_CONNECTED 7*1000


typedef enum {
    NM_STATUS_WAITING,
    NM_STATUS_CONNECTED,
    NM_STATUS_NO_INTERNET,
    NM_STATUS_DISCONNECTED,
} network_status_t;

class Daemon : public QObject
{
    Q_OBJECT
public:
    Daemon();

public slots:
    void startRecovery(int recoverFS, int rsyncBlockchain);
    void changeServiceStatus(QString operation, QString service);
    void restart(void);
    void update(void);
    void shutdown(void);
    void setBacklightLevel(int backlightLevel);
    int getBacklightLevel(void);

    void setPassword(QString pw);
    void changePassword(QString oldPassword, QString newPassword);
    int getBlockchainStorageStatus(void);
    void factoryResetApproved(void);

    void moneroLWSAddAccount(QString address, QString privateKey);
    void moneroLWSDeleteAccount(QString address);
    void moneroLWSReactivateAccount(QString address);
    void moneroLWSDeactivateAccount(QString address);

    void moneroLWSRescan(QString address, QString height);
    void moneroLWSAcceptAllRequests(QString requests);
    void moneroLWSAcceptRequest(QString address);
    void moneroLWSRejectRequest(QString address);

    QString moneroLWSGetAccountList(void);
    QString moneroLWSGetRequestList(void);

    void moneroLWSListAccounts(void);
    void moneroLWSListRequests(void);

    int getConnectionStatus(void);

signals:
    void startRecoveryNotification(const QString &message);
    void serviceManagerNotification(const QString &message);
    void serviceStatusReadyNotification(const QString &message);
    void passwordChangeStatus(int status);

    void updateRequested(void);
    void updateStarted(void);
    void updateCompleted(void);
    void factoryResetStarted(void);
    void factoryResetRequested(void);
    void factoryResetCompleted(void);
    void powerButtonPressDetected(void);
    void powerButtonReleaseDetected(void);
    void hardwareStatusReadyNotification(const QString &message);

    void moneroLWSListAccountsCompleted(void);
    void moneroLWSListRequestsCompleted(void);
    void moneroLWSAccountAdded(void);

    void connectionStatusChanged(void);

private:
    int m_prevIdleTime = 0;
    int m_prevTotalTime = 0;
    double m_CPUUsage = 0;
    double m_AverageCPUFreq = 0;
    double m_RAMUsage = 0;
    double m_TotalRAM = 0;
    double m_CPUTemperature = 0;
    double m_blockChainStorageUsed = 0;
    double m_blockChainStorageTotal = 0;
    double m_systemStorageUsed = 0;
    double m_systemStorageTotal = 0;
    double m_GPUUsage = 0;
    double m_maxGPUFreq = 0;
    double m_currentGPUFreq = 0;

    QString m_hardwareStatus;

    QTimer *m_hardwareStatusTimer;
    QTimer *m_serviceStatusTimer;

    PowerKeyThread *powerKeyThread;
    RecoveryKeyThread *recoveryKeyThread;
    MoneroLWS *moneroLWS;

    QTimer *m_pingTimer;
    network_status_t m_connStat;
    QTimer *m_setupDomainsTimer;

    QString m_firstBootFileName = "/root/nododaemonfirstboot";


    void readCPUUsage(void);
    void readAverageCPUFreq(void);
    void readRAMUsage(void);
    void readCPUTemperature(void);
    void readGPUUsage(void);
    void readMaxGPUSpeed(void);
    void readCurrentGPUSpeed(void);
    void readBlockchainStorageUsage(void);
    void readSystemStorageUsage(void);

private slots:
    void updateHardwareStatus(void);
    void updateServiceStatus(void);
    void serviceStatusReceived(const QString &message);
    void ping(void);
    void setupDomains(void);
    void passwordChangeStatusReceived(int status);
};

#endif // DAEMON_H
