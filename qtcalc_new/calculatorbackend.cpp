#include "calculatorbackend.h"


CalculatorBackend::CalculatorBackend(QObject *parent)
    : QObject(parent),
      m_engine(this)   // optional ownership tie
{
}

void CalculatorBackend::append(const QString &value)
{
    if (m_resultDisplayed)
    {
        if (!value.isEmpty() && value[0].isDigit()){
            m_expression.clear();
        }
        m_resultDisplayed = false;
    }
    if (value == "."){
        int lastOp = -1;

        for (int i = m_expression.size() - 1; i >= 0; --i){
            QChar c = m_expression[i];
            if (c == '+' || c == '-' || c == '*' || c == '/'){
                lastOp = i;
                break;
            }
        }

        QString lastNumber = (lastOp == -1)
                                 ? m_expression
                                 : m_expression.mid(lastOp + 1);

        if (lastNumber.contains("."))
            return;
    }

    m_expression += value;
    m_displayText = (m_expression.isEmpty() ? "0" : m_expression);

    emit displayTextChanged();
}

void CalculatorBackend::clearAll(){
    m_expression = "";
    m_displayText = "0";
    m_resultDisplayed = false;

    emit displayTextChanged();
}

void CalculatorBackend::backspace()
{
    if (!m_expression.isEmpty())
        m_expression.chop(1);

    if (m_expression.isEmpty())
        m_displayText = "0";
    else
        m_displayText = m_expression;

    emit displayTextChanged();
    m_resultDisplayed = false;
}


void CalculatorBackend::evaluate()
{
    if (m_expression.isEmpty())
        return;

    QRegularExpression divByZero(R"((/0(?!\d)))");
    if (divByZero.match(m_expression).hasMatch()){
        m_displayText = "Error";
        emit displayTextChanged();

        m_expression.clear();
        m_resultDisplayed = false;
        return;
    }

    double result = evaluateSimpleExpression(m_expression);

    if (!std::isfinite(result))
    {
        m_displayText = "Error";
        emit displayTextChanged();

        m_expression.clear();
        m_resultDisplayed = false;
        return;
    }

    result = qRound64(result * 1000000.0) / 1000000.0;

    m_expression = QString::number(result, 'g', 15);
    m_displayText = m_expression;
    m_resultDisplayed = true;

    emit displayTextChanged();
}

void CalculatorBackend::showHex()
{
    if (m_expression.isEmpty())
        return;

    bool ok;
    int value = m_expression.toInt(&ok);

    if (!ok){
        m_displayText = "Error";
        emit displayTextChanged();

        return;
    }

    m_displayText = ("0x" + QString::number(value, 16).toUpper());
    m_expression = QString::number(value);
    m_resultDisplayed = true;

    emit displayTextChanged();
}

void CalculatorBackend::showDecimal()
{
    if (m_expression.isEmpty())
        return;

    bool ok;
    int value = m_expression.toInt(&ok);

    if (!ok){
        m_displayText = "Error";
        emit displayTextChanged();

        return;
    }

    m_displayText = QString::number(value, 10);
    m_expression = QString::number(value);
    m_resultDisplayed = true;

    emit displayTextChanged();
}

QString CalculatorBackend::displayText() const {
    return m_displayText;
}

double CalculatorBackend::evaluateSimpleExpression(const QString &expr)
{
    QJSValue result = m_engine.evaluate(expr);
    return result.toNumber();
}
