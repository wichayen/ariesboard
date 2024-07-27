
#CFLAGS += -Wall
CFILES = AriesPCI.c 

obj-m += AriesPCI_mod.o
AriesPCI_mod-objs := $(CFILES:.c=.o)

all:
		make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
		make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean


