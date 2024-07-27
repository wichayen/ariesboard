#include "myLib.h"
#include "AriesPCI.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

//---------------------------------------------------//
// Hong debug function
//---------------------------------------------------//
int getstring(unsigned char *buf)
{
  int i = 0;
  unsigned char c;
  do {
//    c = getc();
//    putc(c);
	
  /*
    if (c == '\r')
      c = '\0';
    buf[i++] = c;
  */
  if (c == '\r')
  {
    buf[i] = '\0';
    c = '\0';
  }else if(c == 0x08)
  {
    buf[i] = 0;
  if(i == 0)
  {
    i = 0;
  }
  else
  {
    i--;
  }
  }else
  {
    buf[i] = c;
    i++;
  }
  } while (c);

  return i - 1;
}


int my_atoi( char* pStr ) 
{
  int iRetVal = 0; 
 
  if ( pStr )
  {
    while ( *pStr && *pStr <= '9' && *pStr >= '0' ) 
    {
      iRetVal = (iRetVal * 10) + (*pStr - '0');
      pStr++;
    }
  } 
  return iRetVal; 
} 


int my_atoh (char *String)
{
    int Value = 0, Digit;
    char c;

    while ((c = *String++) != '\0') {
        if (c >= '0' && c <= '9')
            Digit = (int) (c - '0');
        else if (c >= 'a' && c <= 'f')
            Digit = (int) (c - 'a') + 10;
        else if (c >= 'A' && c <= 'F')
            Digit = (int) (c - 'A') + 10;
        else
            break;
        Value = (Value << 4) + Digit;
    }
    return Value;
}

int reg_write(unsigned int addr, int data)
{
  int *p_addr;
  char buffer[4];
  int fh;
  
  //printf("open mypci\n");
  fh = open("/dev/AriesPCI0",O_RDWR);
  if(fh < 0){
   printf("Cannot open \n");
   return 1;
  }
  buffer[0] = (char)(data >> 0);
  buffer[1] = (char)(data >> 8);
  buffer[2] = (char)(data >> 16);
  buffer[3] = (char)(data >> 24);
  lseek(fh,addr,SEEK_SET);
  write(fh,buffer,4);	//write 4 byte
  close(fh);
  return 0;
}

int reg_read(unsigned int addr)
{
  int data;
  int *p_addr;
  char buffer[4];
  int fh;
  
  fh = open("/dev/AriesPCI0",O_RDONLY);
  if(fh < 0){
   printf("Cannot open \n");
   return 1;
  }
  printf("open mypci\n");
  lseek(fh,addr,SEEK_SET);
  read(fh,buffer,4);	//read 4 byte
  close(fh);
  data = (((unsigned int)buffer[0]) & 0x000000ff) | 
         ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
         ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
         ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
  return (data);
}



int fpga_ver(void)
{
  int data;
  int *p_addr;
  char buffer[4];
  int fh;
  
  fh = open("/dev/AriesPCI0",O_RDONLY);
  if(fh < 0){
   printf("Cannot open \n");
   return 1;
  }
  //printf("open AriesPCI\n");
  ioctl(fh,IOCTL_FPGA_VER_READ,buffer);
  close(fh);
  data = (((unsigned int)buffer[0]) & 0x000000ff) | 
         ((((unsigned int)buffer[1]) << 8 ) & 0x0000ff00) |
         ((((unsigned int)buffer[2]) << 16 ) & 0x00ff0000) |
         ((((unsigned int)buffer[3]) << 24 ) & 0xff000000 );
  return (data);
}

int ledTestOn(void)
{
  int data;
  int *p_addr;
  char buffer[4];
  int fh;
  
  data = 0xffffffff;
  fh = open("/dev/AriesPCI0",O_RDONLY);
  if(fh < 0){
   printf("Cannot open \n");
   return 1;
  }
  buffer[0] = (char)(data >> 0);
  buffer[1] = (char)(data >> 8);
  buffer[2] = (char)(data >> 16);
  buffer[3] = (char)(data >> 24);
  //printf("open AriesPCI\n");
  ioctl(fh,IOCTL_WRITE_LED_BY_MEM,buffer);
  close(fh);
  return (data);
}

int ledTestOff(void)
{
  int data;
  int *p_addr;
  char buffer[4];
  int fh;
  
  data = 0;
  fh = open("/dev/AriesPCI0",O_RDONLY);
  if(fh < 0){
   printf("Cannot open \n");
   return 1;
  }
  buffer[0] = (char)(data >> 0);
  buffer[1] = (char)(data >> 8);
  buffer[2] = (char)(data >> 16);
  buffer[3] = (char)(data >> 24);
  //printf("open AriesPCI\n");
  ioctl(fh,IOCTL_WRITE_LED_BY_MEM,buffer);
  close(fh);
  return (data);
}





