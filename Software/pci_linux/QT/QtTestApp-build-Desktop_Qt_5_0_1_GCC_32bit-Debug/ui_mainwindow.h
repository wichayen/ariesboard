/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 5.0.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QToolBar>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QWidget *centralWidget;
    QPushButton *PCIEable;
    QPushButton *PCIDisable;
    QCheckBox *led2;
    QCheckBox *led3;
    QCheckBox *led4;
    QCheckBox *led5;
    QCheckBox *led6;
    QCheckBox *led7;
    QCheckBox *led8;
    QPushButton *LedSet;
    QLineEdit *DAC1;
    QLineEdit *DAC2;
    QLineEdit *DAC3;
    QLineEdit *DAC4;
    QLabel *label;
    QLabel *label_2;
    QLabel *label_3;
    QLabel *label_4;
    QCheckBox *led1;
    QPushButton *DACSet;
    QLineEdit *ADC1;
    QLineEdit *ADC2;
    QLineEdit *ADC3;
    QLineEdit *ADC4;
    QLineEdit *ADC5;
    QLineEdit *ADC6;
    QLineEdit *ADC7;
    QLineEdit *ADC8;
    QPushButton *ADCGet;
    QPushButton *ADCEable;
    QLineEdit *FPGA_Ver;
    QPushButton *ADCDisable;
    QLineEdit *DIO;
    QPushButton *DIOSet;
    QLabel *label_5;
    QMenuBar *menuBar;
    QToolBar *mainToolBar;
    QStatusBar *statusBar;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName(QStringLiteral("MainWindow"));
        MainWindow->resize(634, 556);
        centralWidget = new QWidget(MainWindow);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        PCIEable = new QPushButton(centralWidget);
        PCIEable->setObjectName(QStringLiteral("PCIEable"));
        PCIEable->setGeometry(QRect(500, 30, 99, 27));
        PCIDisable = new QPushButton(centralWidget);
        PCIDisable->setObjectName(QStringLiteral("PCIDisable"));
        PCIDisable->setGeometry(QRect(500, 70, 99, 27));
        led2 = new QCheckBox(centralWidget);
        led2->setObjectName(QStringLiteral("led2"));
        led2->setGeometry(QRect(20, 60, 98, 22));
        led3 = new QCheckBox(centralWidget);
        led3->setObjectName(QStringLiteral("led3"));
        led3->setGeometry(QRect(20, 90, 98, 22));
        led4 = new QCheckBox(centralWidget);
        led4->setObjectName(QStringLiteral("led4"));
        led4->setGeometry(QRect(20, 120, 98, 22));
        led5 = new QCheckBox(centralWidget);
        led5->setObjectName(QStringLiteral("led5"));
        led5->setGeometry(QRect(20, 210, 98, 22));
        led6 = new QCheckBox(centralWidget);
        led6->setObjectName(QStringLiteral("led6"));
        led6->setGeometry(QRect(20, 180, 98, 22));
        led7 = new QCheckBox(centralWidget);
        led7->setObjectName(QStringLiteral("led7"));
        led7->setGeometry(QRect(20, 150, 98, 22));
        led8 = new QCheckBox(centralWidget);
        led8->setObjectName(QStringLiteral("led8"));
        led8->setGeometry(QRect(20, 240, 98, 22));
        LedSet = new QPushButton(centralWidget);
        LedSet->setObjectName(QStringLiteral("LedSet"));
        LedSet->setGeometry(QRect(20, 270, 99, 27));
        DAC1 = new QLineEdit(centralWidget);
        DAC1->setObjectName(QStringLiteral("DAC1"));
        DAC1->setGeometry(QRect(150, 30, 71, 27));
        DAC2 = new QLineEdit(centralWidget);
        DAC2->setObjectName(QStringLiteral("DAC2"));
        DAC2->setGeometry(QRect(150, 70, 71, 27));
        DAC3 = new QLineEdit(centralWidget);
        DAC3->setObjectName(QStringLiteral("DAC3"));
        DAC3->setGeometry(QRect(150, 110, 71, 27));
        DAC4 = new QLineEdit(centralWidget);
        DAC4->setObjectName(QStringLiteral("DAC4"));
        DAC4->setGeometry(QRect(150, 150, 71, 27));
        label = new QLabel(centralWidget);
        label->setObjectName(QStringLiteral("label"));
        label->setGeometry(QRect(230, 34, 67, 17));
        label_2 = new QLabel(centralWidget);
        label_2->setObjectName(QStringLiteral("label_2"));
        label_2->setGeometry(QRect(230, 73, 67, 20));
        label_3 = new QLabel(centralWidget);
        label_3->setObjectName(QStringLiteral("label_3"));
        label_3->setGeometry(QRect(230, 113, 67, 17));
        label_4 = new QLabel(centralWidget);
        label_4->setObjectName(QStringLiteral("label_4"));
        label_4->setGeometry(QRect(230, 155, 67, 17));
        led1 = new QCheckBox(centralWidget);
        led1->setObjectName(QStringLiteral("led1"));
        led1->setGeometry(QRect(20, 30, 98, 22));
        DACSet = new QPushButton(centralWidget);
        DACSet->setObjectName(QStringLiteral("DACSet"));
        DACSet->setGeometry(QRect(150, 200, 99, 27));
        ADC1 = new QLineEdit(centralWidget);
        ADC1->setObjectName(QStringLiteral("ADC1"));
        ADC1->setGeometry(QRect(300, 30, 91, 27));
        ADC2 = new QLineEdit(centralWidget);
        ADC2->setObjectName(QStringLiteral("ADC2"));
        ADC2->setGeometry(QRect(300, 70, 91, 27));
        ADC3 = new QLineEdit(centralWidget);
        ADC3->setObjectName(QStringLiteral("ADC3"));
        ADC3->setGeometry(QRect(300, 110, 91, 27));
        ADC4 = new QLineEdit(centralWidget);
        ADC4->setObjectName(QStringLiteral("ADC4"));
        ADC4->setGeometry(QRect(300, 150, 91, 27));
        ADC5 = new QLineEdit(centralWidget);
        ADC5->setObjectName(QStringLiteral("ADC5"));
        ADC5->setGeometry(QRect(300, 190, 91, 27));
        ADC6 = new QLineEdit(centralWidget);
        ADC6->setObjectName(QStringLiteral("ADC6"));
        ADC6->setGeometry(QRect(300, 230, 91, 27));
        ADC7 = new QLineEdit(centralWidget);
        ADC7->setObjectName(QStringLiteral("ADC7"));
        ADC7->setGeometry(QRect(300, 270, 91, 27));
        ADC8 = new QLineEdit(centralWidget);
        ADC8->setObjectName(QStringLiteral("ADC8"));
        ADC8->setGeometry(QRect(300, 310, 91, 27));
        ADCGet = new QPushButton(centralWidget);
        ADCGet->setObjectName(QStringLiteral("ADCGet"));
        ADCGet->setGeometry(QRect(300, 350, 99, 27));
        ADCEable = new QPushButton(centralWidget);
        ADCEable->setObjectName(QStringLiteral("ADCEable"));
        ADCEable->setGeometry(QRect(300, 390, 99, 27));
        FPGA_Ver = new QLineEdit(centralWidget);
        FPGA_Ver->setObjectName(QStringLiteral("FPGA_Ver"));
        FPGA_Ver->setGeometry(QRect(500, 150, 91, 27));
        ADCDisable = new QPushButton(centralWidget);
        ADCDisable->setObjectName(QStringLiteral("ADCDisable"));
        ADCDisable->setGeometry(QRect(300, 430, 99, 27));
        DIO = new QLineEdit(centralWidget);
        DIO->setObjectName(QStringLiteral("DIO"));
        DIO->setGeometry(QRect(150, 250, 71, 27));
        DIOSet = new QPushButton(centralWidget);
        DIOSet->setObjectName(QStringLiteral("DIOSet"));
        DIOSet->setGeometry(QRect(150, 290, 99, 27));
        label_5 = new QLabel(centralWidget);
        label_5->setObjectName(QStringLiteral("label_5"));
        label_5->setGeometry(QRect(230, 250, 67, 20));
        MainWindow->setCentralWidget(centralWidget);
        menuBar = new QMenuBar(MainWindow);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        menuBar->setGeometry(QRect(0, 0, 634, 25));
        MainWindow->setMenuBar(menuBar);
        mainToolBar = new QToolBar(MainWindow);
        mainToolBar->setObjectName(QStringLiteral("mainToolBar"));
        MainWindow->addToolBar(Qt::TopToolBarArea, mainToolBar);
        statusBar = new QStatusBar(MainWindow);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        MainWindow->setStatusBar(statusBar);
        QWidget::setTabOrder(PCIEable, led1);
        QWidget::setTabOrder(led1, led2);
        QWidget::setTabOrder(led2, led3);
        QWidget::setTabOrder(led3, led4);
        QWidget::setTabOrder(led4, led5);
        QWidget::setTabOrder(led5, led6);
        QWidget::setTabOrder(led6, led7);
        QWidget::setTabOrder(led7, led8);
        QWidget::setTabOrder(led8, LedSet);
        QWidget::setTabOrder(LedSet, DAC2);
        QWidget::setTabOrder(DAC2, DAC3);
        QWidget::setTabOrder(DAC3, DAC4);
        QWidget::setTabOrder(DAC4, DAC1);
        QWidget::setTabOrder(DAC1, DACSet);
        QWidget::setTabOrder(DACSet, ADC1);
        QWidget::setTabOrder(ADC1, ADC2);
        QWidget::setTabOrder(ADC2, ADC3);
        QWidget::setTabOrder(ADC3, ADC4);
        QWidget::setTabOrder(ADC4, ADC5);
        QWidget::setTabOrder(ADC5, ADC6);
        QWidget::setTabOrder(ADC6, ADC7);
        QWidget::setTabOrder(ADC7, ADC8);
        QWidget::setTabOrder(ADC8, ADCGet);
        QWidget::setTabOrder(ADCGet, ADCEable);
        QWidget::setTabOrder(ADCEable, FPGA_Ver);
        QWidget::setTabOrder(FPGA_Ver, ADCDisable);
        QWidget::setTabOrder(ADCDisable, PCIDisable);

        retranslateUi(MainWindow);

        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QApplication::translate("MainWindow", "MainWindow", 0));
        PCIEable->setText(QApplication::translate("MainWindow", "PCIEable", 0));
        PCIDisable->setText(QApplication::translate("MainWindow", "PCIDisable", 0));
        led2->setText(QApplication::translate("MainWindow", "led2", 0));
        led3->setText(QApplication::translate("MainWindow", "led3", 0));
        led4->setText(QApplication::translate("MainWindow", "led4", 0));
        led5->setText(QApplication::translate("MainWindow", "led7", 0));
        led6->setText(QApplication::translate("MainWindow", "led6", 0));
        led7->setText(QApplication::translate("MainWindow", "led5", 0));
        led8->setText(QApplication::translate("MainWindow", "led8", 0));
        LedSet->setText(QApplication::translate("MainWindow", "LedSet", 0));
        label->setText(QApplication::translate("MainWindow", "DAC1", 0));
        label_2->setText(QApplication::translate("MainWindow", "DAC2", 0));
        label_3->setText(QApplication::translate("MainWindow", "DAC3", 0));
        label_4->setText(QApplication::translate("MainWindow", "DAC4", 0));
        led1->setText(QApplication::translate("MainWindow", "led1", 0));
        DACSet->setText(QApplication::translate("MainWindow", "DACSet", 0));
        ADCGet->setText(QApplication::translate("MainWindow", "ADCGet", 0));
        ADCEable->setText(QApplication::translate("MainWindow", "ADCEable", 0));
        ADCDisable->setText(QApplication::translate("MainWindow", "ADCDisable", 0));
        DIOSet->setText(QApplication::translate("MainWindow", "DIOSet", 0));
        label_5->setText(QApplication::translate("MainWindow", "DIO", 0));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
