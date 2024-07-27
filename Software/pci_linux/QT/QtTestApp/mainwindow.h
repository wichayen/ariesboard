#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    
private slots:
    void on_PCIEable_clicked();

    void on_PCIDisable_clicked();

    void on_LedSet_clicked();

    void on_DACSet_clicked();

    void on_ADCEable_clicked();

    void on_ADCGet_clicked();

    void on_ADCDisable_clicked();

    void on_DACSet_2_clicked();

    void on_DIOSet_clicked();

private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
