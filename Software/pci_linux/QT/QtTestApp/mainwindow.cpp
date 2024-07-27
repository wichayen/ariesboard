#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "AriesPCI.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/fcntl.h>

#include <QtGui>
#include <QMessageBox>

int fh;

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_PCIEable_clicked()
{
    unsigned int data;
    char buffer[4];

    fh = open("/dev/AriesPCI0",O_RDWR);
    if(fh < 0){
        QMessageBox msgBox;
        msgBox.setText("cannot open AriesPCI");
        msgBox.exec();
    }

    //ioctl(fh,IOCTL_FPGA_VER_READ,buffer);
    lseek(fh,FPGA_VER_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    QString tempText = QString::number(data,16);
    ui->FPGA_Ver->setText(tempText);

}

void MainWindow::on_PCIDisable_clicked()
{
    //close(fh);
}

void MainWindow::on_LedSet_clicked()
{
    unsigned int data;
    char buffer[4];

    if(ui->led1->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led2->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led3->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led4->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led5->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led6->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led7->checkState() == Qt::Checked){
        data |= 0x1;
    }
    data = data << 1;

    if(ui->led8->checkState() == Qt::Checked){
        data |= 0x1;
    }

    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);


    //ioctl(fh,IOCTL_WRITE_LED_BY_MEM,buffer);
    lseek(fh,LED_BASE,SEEK_SET);
    write(fh,buffer,4);

}

void MainWindow::on_DACSet_clicked()
{
    float val;
    unsigned int data;
    char buffer[4];
    QString tempText;

    tempText = ui->DAC1->text();
    val = tempText.toFloat();
    data = (unsigned int)((val/3.3)*4095);
    if(data > 4095){
        data = 4095;
    }
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);
    //ioctl(fh,IOCTL_DAC1_WRITE,buffer);
    lseek(fh,DAC1_BASE,SEEK_SET);
    write(fh,buffer,4);

    tempText = ui->DAC2->text();
    val = tempText.toFloat();
    data = (unsigned int)((val/3.3)*4095);
    if(data > 4095){
        data = 4095;
    }
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);
    //ioctl(fh,IOCTL_DAC2_WRITE,buffer);
    lseek(fh,DAC2_BASE,SEEK_SET);
    write(fh,buffer,4);

    tempText = ui->DAC3->text();
    val = tempText.toFloat();
    data = (unsigned int)((val/3.3)*4095);
    if(data > 4095){
        data = 4095;
    }
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);
    //ioctl(fh,IOCTL_DAC3_WRITE,buffer);
    lseek(fh,DAC3_BASE,SEEK_SET);
    write(fh,buffer,4);

    tempText = ui->DAC4->text();
    val = tempText.toFloat();
    data = (unsigned int)((val/3.3)*4095);
    if(data > 4095){
        data = 4095;
    }
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);
    //ioctl(fh,IOCTL_DAC4_WRITE,buffer);
    lseek(fh,DAC4_BASE,SEEK_SET);
    write(fh,buffer,4);


    data = 0x1;
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);
    //ioctl(fh,IOCTL_DAC_OUTPUT,buffer);
    lseek(fh,DAC_OUTPUT_BASE,SEEK_SET);
    write(fh,buffer,4);




}

void MainWindow::on_ADCEable_clicked()
{
    unsigned int data;
    char buffer[4];
    data = 0x2;
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);

    //ioctl(fh,IOCTL_ADC_EN_WRITE,buffer);
    lseek(fh,ADC_ENABLE_BASE,SEEK_SET);
    write(fh,buffer,4);
}

void MainWindow::on_ADCGet_clicked()
{
    unsigned int data;
    char buffer[4];
    float val;

    //ioctl(fh,IOCTL_ADC1_READ,buffer);
    lseek(fh,ADC1_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText = QString::number(val);
    ui->ADC1->setText(tempText);


    //ioctl(fh,IOCTL_ADC2_READ,buffer);
    lseek(fh,ADC2_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText2 = QString::number(val);
    ui->ADC2->setText(tempText2);

    //ioctl(fh,IOCTL_ADC3_READ,buffer);
    lseek(fh,ADC3_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText3 = QString::number(val);
    ui->ADC3->setText(tempText3);

    //ioctl(fh,IOCTL_ADC4_READ,buffer);
    lseek(fh,ADC4_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText4 = QString::number(val);
    ui->ADC4->setText(tempText4);

    //ioctl(fh,IOCTL_ADC5_READ,buffer);
    lseek(fh,ADC5_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText5 = QString::number(val);
    ui->ADC5->setText(tempText5);

    //ioctl(fh,IOCTL_ADC6_READ,buffer);
    lseek(fh,ADC6_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText6 = QString::number(val);
    ui->ADC6->setText(tempText6);

    //ioctl(fh,IOCTL_ADC7_READ,buffer);
    lseek(fh,ADC7_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText7 = QString::number(val);
    ui->ADC7->setText(tempText7);

    //ioctl(fh,IOCTL_ADC8_READ,buffer);
    lseek(fh,ADC8_BASE,SEEK_SET);
    read(fh,buffer,4);
    data = (((unsigned int)buffer[0]) & 0x000000ff) |
             ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
             ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
             ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
    val = (((float)data/4095))*3.3;
    QString tempText8 = QString::number(val);
    ui->ADC8->setText(tempText8);

}

void MainWindow::on_ADCDisable_clicked()
{
    unsigned int data;
    char buffer[4];
    data = 0;
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);

    //ioctl(fh,IOCTL_ADC_EN_WRITE,buffer);
    lseek(fh,ADC_ENABLE_BASE,SEEK_SET);
    write(fh,buffer,4);
}

void MainWindow::on_DIOSet_clicked()
{
    unsigned int data;
    char buffer[4];
    QString tempText;

    // set DIO to output mode
    //ioctl(fh,IOCTL_DIO_MODE_WRITE,buffer);
    buffer[0] = 0xff;
    buffer[1] = 0xff;
    buffer[2] = 0xff;
    buffer[3] = 0xff;
    lseek(fh,DIO_MODE_BASE,SEEK_SET);
    write(fh,buffer,4);

    // set DIO data output
    tempText = ui->DIO->text();
    data = tempText.toInt();
    buffer[0] = (char)(data >> 0);
    buffer[1] = (char)(data >> 8);
    buffer[2] = (char)(data >> 16);
    buffer[3] = (char)(data >> 24);
    //ioctl(fh,IOCTL_DIO_WRITE,buffer);
    lseek(fh,DIO_BASE,SEEK_SET);
    write(fh,buffer,4);

}
