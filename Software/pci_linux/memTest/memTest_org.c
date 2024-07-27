#include <stdlib.h>
#include <string.h>
#include <stdio.h>

main(void)
{
	// hong reg --------------
	unsigned char cmd_buf[32];
	unsigned char reg_addr_str[9];
	unsigned char reg_data_str[9];
	unsigned int reg_addr;
	unsigned int reg_data;
	unsigned int reg_addr_hex;
	unsigned int reg_data_hex;
	unsigned int i;
	unsigned int data_index;
	unsigned char command;

	printf("\r\n////////// memory test //////////");
	printf("\r\nDebug mode");
	printf("\r\nexample");
	printf("\r\nmr 12345678");
	printf("\r\nmw 12345678 9abcdef0");
	printf("\r\n////////// memory test //////////");	
	printf("\r\nInput Command No. ---> ");
	


	for(;;) {
		for (i=0;i<31;i++ )	{
			cmd_buf[i] = 0;
		}
		for (i=0;i<8;i++ ){
			reg_addr_str[i] = 0;
			reg_data_str[i] = 0;
		}
//		getstring(cmd_buf);
		gets(cmd_buf);
		command = cmd_buf[0];
		
		if(cmd_buf[0] == 'm' || cmd_buf[0] == 'w'){
			data_index = 0;
			for (i=0;i<8;i++ ){
				if(cmd_buf[i+3] == ' '){
					break;
				}else{
					reg_addr_str[i] = cmd_buf[i+3];
					data_index++;
				}
			}
			
			for (i=0;i<8;i++ ){
				reg_data_str[i] = cmd_buf[i+3+data_index+1];
			}
			
			reg_addr = my_atoi(reg_addr_str);
			reg_data = my_atoi(reg_data_str);
			reg_addr_hex = my_atoh(reg_addr_str);
			reg_data_hex = my_atoh(reg_data_str);
			if (!strncmp(cmd_buf, "whoru",5)) {
				printf(" \r\n I am pci test memory...... \r\n");
			}else if (!strncmp(cmd_buf, "mfpga",5)) {
				printf(" \r\n fpga version read...... \r\n");
				reg_data_hex = fpga_ver();
				printf("\r\n read reg data : %x",reg_data_hex);
			}else if (!strncmp(cmd_buf, "mledon",6)) {
				printf(" \r\n led on...... \r\n");
				reg_data_hex = ledTestOn();
			}else if (!strncmp(cmd_buf, "mledoff",7)) {
				printf(" \r\n led off...... \r\n");
				reg_data_hex = ledTestOff();
			}else if (!strncmp(cmd_buf, "mw ",3)) {
				reg_write(reg_addr_hex,reg_data_hex);
				//if(reg_write(reg_addr_hex,reg_data_hex)==1){goto		input_cmd;}
				printf("\r\n write reg address : %x",reg_addr_hex);
				printf("\r\n write reg data : %x",reg_data_hex);
			}else if (!strncmp(cmd_buf, "mr ",3)) {
				reg_data_hex = reg_read(reg_addr_hex);
				//if(reg_data_hex = reg_read(reg_addr_hex)==1){goto		input_cmd;}
				printf("\r\n read reg address : %x",reg_addr_hex);
				printf("\r\n read reg data : %x",reg_data_hex);
			}
//input_cmd:
			printf("\r\nInput Command No. ---> ");
		}
	}


/*
	for(;;) {
		puts("\r\n Input Key --> ");
		
		// clear cmd_buffer -------------
		for (i=0;i<31;i++ )	{
			cmd_buf[i] = 0;
		}
		for (i=0;i<8;i++ ){
			reg_addr_str[i] = 0;
			reg_data_str[i] = 0;
		}
		// ------------------------------
		
		getstring(cmd_buf);
		command = cmd_buf[0];
		
		if(cmd_buf[0] == 'm' || cmd_buf[0] == 'w'){
			data_index = 0;
			for (i=0;i<8;i++ ){
				if(cmd_buf[i+3] == ' '){
					break;
				}else{
					reg_addr_str[i] = cmd_buf[i+3];
					data_index++;
				}
			}
			
			for (i=0;i<8;i++ ){
				reg_data_str[i] = cmd_buf[i+3+data_index+1];
			}
			
			reg_addr = my_atoi(reg_addr_str);
			reg_data = my_atoi(reg_data_str);
			reg_addr_hex = atoh(reg_addr_str);
			reg_data_hex = atoh(reg_data_str);
			reg_data_hex16 = (short)atoh(reg_data_str);
			if (!strncmp(cmd_buf, "whoru",5)) {
				puts(" \r\n I am ARIES Board NIOS II...... \r\n");
			}else if (!strncmp(cmd_buf, "mw ",3)) {
				//puts("\r\n write reg address :");	putxval(reg_addr_hex,8);
				//puts("\r\n write reg data :");		putxval(reg_data_hex,8);
				//reg_write(reg_addr_hex,reg_data_hex);
				old_reg_addr_hex = reg_addr_hex;
				puts("\r\naddress :");	putxval(reg_addr_hex,8);
				puts("    write data :");		putxval(reg_data_hex,8);
				reg_write(reg_addr_hex,reg_data_hex);
				
				do{
					for (i=0;i<31;i++ )	{
						cmd_buf[i] = 0;
					}
					for (i=0;i<8;i++ ){
						reg_data_str[i] = 0;
					}
					old_reg_addr_hex = old_reg_addr_hex + 4;
					puts("\r\naddress : ");	putxval(old_reg_addr_hex,8);
					puts(" input write data : ");
					getstring(cmd_buf);
					temp8 = cmd_buf[0];
					if((temp8 != 0x2e) && (temp8 != 0)){
						for (i=0;i<8;i++ ){
							reg_data_str[i] = cmd_buf[i];
						}
						reg_data_hex = (unsigned int)atoh(reg_data_str);
						puts("\raddress :");			putxval(old_reg_addr_hex,8);
						puts("    write data :");		putxval(reg_data_hex,8);
						reg_write(old_reg_addr_hex,reg_data_hex);
					}
				}while (temp8 != 0x2e);
				
			}else if (!strncmp(cmd_buf, "mr ",3)) {
				//reg_data_hex = reg_read(reg_addr_hex);
				//puts("\r\n read reg address :");	putxval(reg_addr_hex,8);
				//puts("\r\n read reg data :");		putxval(reg_data_hex,8);
				old_reg_addr_hex = reg_addr_hex;
				reg_data_hex32 = (unsigned int)reg_read(reg_addr_hex);
				puts("\r\naddress :");			putxval(reg_addr_hex,8);
				puts("    read data :");		putxval((unsigned int)reg_data_hex32,8);
				do{
					//temp8 = inch();
					temp8 = getc();
					//if(temp8 == 0x0d){	//enter key
					if(temp8 == 0x0a){	//enter key
						old_reg_addr_hex = old_reg_addr_hex + 4;
						reg_data_hex32 = (unsigned int)reg_read(old_reg_addr_hex);
						puts("\r\naddress :");			putxval(old_reg_addr_hex,8);
						puts("    read data :");		putxval((unsigned int)reg_data_hex32,8);
					}
					
				}while (temp8 != 0x2e);	//'.'key
				
			}
			puts("\r\nInput Command No. ---> ");
			command = 0;
		}
		
		command = ((command <='z' && command >= 'a')? command- 'a' + 'A':command);
		command = ((command >= 'A' ) ? (command - 'A' + 10) : (command - '0'));
		switch ( command ){
			case 0 :
				//SineCheck1_1();
			break;
			
			case 1 :
				//SineCheck1_2();
			break;
			
			case 10 :		//a
				//NoiseCheck4_1();
			break;
			
			case 35 :		//z
				//return 0;		// leave out for(;;) loop
			break;
			
			default :
				
			break;
			
		}
		
		
	}
*/


	return 0;
	
}


