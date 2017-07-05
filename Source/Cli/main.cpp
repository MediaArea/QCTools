#include <QCoreApplication>
#include "cli.h"

// suppress debug output
#if QT_VERSION >= 0x050000
void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(type);
    Q_UNUSED(context);
    Q_UNUSED(msg);
}
#else
void messageHandler(QtMsgType type, const char* msg)
{
    Q_UNUSED(type);
    Q_UNUSED(msg);
}
#endif

int main(int argc, char *argv[])
{
#if QT_VERSION >= 0x050000
    qInstallMessageHandler(messageHandler);
#else
    qInstallMsgHandler(messageHandler);
#endif
    QCoreApplication a(argc, argv);

    Cli cli;
    return cli.exec(a);
}
