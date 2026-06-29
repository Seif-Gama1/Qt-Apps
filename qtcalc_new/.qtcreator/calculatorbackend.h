#ifndef CALCULATORBACKEND_H
#define CALCULATORBACKEND_H

#include <QObject>
#include <QString>
#include <QChar>
#include <QJSEngine>

class CalculatorBackend : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString displayText
                READ displayText
                NOTIFY displayTextChanged)

public:
    explicit CalculatorBackend(QObject *parent = nullptr);

    Q_INVOKABLE void append(const QString &value);
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE void backspace();
    Q_INVOKABLE void evaluate();
    Q_INVOKABLE void showHex();
    Q_INVOKABLE void showDecimal();

    QString displayText() const;
    double evaluateSimpleExpression(const QString &expr);

signals:
    void displayTextChanged();

private:
    QString m_displayText = "0";
    QString m_expression;
    bool m_resultDisplayed = false;
    QJSEngine m_engine;
};

#endif // CALCULATORBACKEND_H
