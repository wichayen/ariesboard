#include <linux/init.h>
#include <asm/types.h>    /* u8, ... */
#include <linux/errno.h>
#include <linux/ioport.h> /* IORESOURCE_IO, ... */
#include <linux/module.h> /* module 作成には必須 */
#include <linux/kernel.h> /* printk */
#include <linux/pci.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <asm/uaccess.h>
#include <linux/device.h>  
#include <linux/poll.h>
#include <linux/slab.h>   /* kmalloc() */

#include "AriesPCI.h"

MODULE_LICENSE("Dual BSD/GPL");

static char* msg = "hong pci module [pci.o]";

static int AriesPCI_devs = 1;        /* device count */
static int AriesPCI_major = 0;       /* MAJOR: dynamic allocation */
static int AriesPCI_minor = 0;       /* MINOR: static allocation */
static struct cdev AriesPCI_cdev;  
static struct class *AriesPCI_class = NULL;
static dev_t AriesPCI_dev;

void __iomem *ioaddr;
struct pci_dev* device = NULL;

/*
 * PCI バスに接続されているデバイスの情報を表示する。
 */
static int print_pci_information( void )
{
	
		/*
		 * vendor id および device id に PCI_ANY_ID を指定することで
		 * 接続されている全ての PCI デバイスを対象としている。
		 */
		//device = pci_find_device( PCI_ANY_ID, PCI_ANY_ID, device );
		//device = pci_get_device( PCI_ANY_ID, PCI_ANY_ID, device );
		device = pci_get_device( 0x1172, 0x0004, device );

		if ( device == NULL ){
			printk("AriesPCI device == NULL");
			return -1;
		}

		
			#define BASE_ADDRESS_NUM 6

			u16 vendor_id;
			u16 device_id;
			u16 class;
			u16 sub_vendor_id;
			u16 sub_device_id;
			u8  irq;

			unsigned int resource_start;
			unsigned int resource_end;
			unsigned int resource_flag;

			int i;
			
			pci_read_config_word( device, PCI_VENDOR_ID,           &vendor_id );
			pci_read_config_word( device, PCI_DEVICE_ID,           &device_id );
			pci_read_config_word( device, PCI_CLASS_DEVICE,        &class );
			pci_read_config_word( device, PCI_SUBSYSTEM_VENDOR_ID, &sub_vendor_id );
			pci_read_config_word( device, PCI_SUBSYSTEM_ID,        &sub_device_id );
			pci_read_config_byte( device, PCI_INTERRUPT_LINE,      &irq );

			printk( KERN_INFO "%s : vendor id = %x, device id = %x\n",
				msg, vendor_id, device_id );

			printk( KERN_INFO "%s : class = %x\n", msg, class );
			printk( KERN_INFO "%s : subsystem\n", msg );

			printk( KERN_INFO "%s :   vendor id = %x, device id = %x\n",
				msg, sub_vendor_id, sub_device_id );

			printk( KERN_INFO "%s : IRQ = %x\n", msg, irq );
			

			for ( i = 0; i < BASE_ADDRESS_NUM; i ++ ) {
				resource_start = pci_resource_start( device, i );
				resource_end   = pci_resource_end( device, i );
				resource_flag  = pci_resource_flags( device, i );

				if ( resource_start != 0 || resource_end != 0 ) {
					printk( KERN_INFO "%s : BAR%d : Base address 0x%0x - 0x%0x\n", 
						msg, i, resource_start, resource_end );

					if ( resource_flag & IORESOURCE_IO )
						printk( KERN_INFO "%s :   I/O port\n", msg );

					if ( resource_flag & IORESOURCE_MEM )
						printk( KERN_INFO "%s :   Memory\n", msg );

					if ( resource_flag & IORESOURCE_PREFETCH )
						printk( KERN_INFO "%s :   Prefetchable\n", msg );

					if ( resource_flag & IORESOURCE_READONLY )
						printk( KERN_INFO "%s :   Read Only\n", msg );

					printk( KERN_INFO "%s : \n", msg );
				}
			}

			printk( KERN_INFO "%s : \n", msg );
			
			return 0;
		
	
}


//static int bgpio_ioctl (struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
long AriesPCI_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
	unsigned int data32 = 0;
	
	switch(cmd){
		case	IOCTL_READ_LED_BY_MEM		:
			data32 = ioread32(ioaddr + LED_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_WRITE_LED_BY_MEM		:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + LED_BASE);
			return	0;
		case	IOCTL_DAC1_WRITE			:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + 0x200);
			return	0;
		case	IOCTL_DAC2_WRITE			:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + DAC2_BASE);
			return	0;
		case	IOCTL_DAC3_WRITE			:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + DAC3_BASE);
			return	0;
		case	IOCTL_DAC4_WRITE			:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + DAC4_BASE);
			return	0;
		case	IOCTL_DAC_OUTPUT			:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + DAC_OUTPUT_BASE);
			return	0;
		case	IOCTL_ADC1_READ				:
			data32 = ioread32(ioaddr + ADC1_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC2_READ				:
			data32 = ioread32(ioaddr + ADC2_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC3_READ				:
			data32 = ioread32(ioaddr + ADC3_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC4_READ				:
			data32 = ioread32(ioaddr + ADC4_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC5_READ				:
			data32 = ioread32(ioaddr + ADC5_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC6_READ				:
			data32 = ioread32(ioaddr + ADC6_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC7_READ				:
			data32 = ioread32(ioaddr + ADC7_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC8_READ				:
			data32 = ioread32(ioaddr + ADC8_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_ADC_EN_WRITE			:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + ADC_ENABLE_BASE);
			return	0;
		case	IOCTL_FPGA_VER_READ			:
			data32 = ioread32(ioaddr + FPGA_VER_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
		case	IOCTL_DIO_MODE_WRITE		:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + DIO_MODE_BASE);
			return	0;
		case	IOCTL_DIO_WRITE				:
			if (copy_from_user(&data32,(int __user *)arg,sizeof(data32))) {
				return -EFAULT;
			}
			iowrite32(data32, ioaddr + DIO_BASE);
			return	0;
		case	IOCTL_DIO_READ				:
			data32 = ioread32(ioaddr + DIO_BASE);
			if (copy_to_user((int __user *)arg, &data32, sizeof(data32)) ) {
				return -EFAULT;
			}
			return	0;
	}
	return 0;   /* success */
}


loff_t AriesPCI_llseek(struct file *filp, loff_t off, int whence)
{
	switch(whence) {
	  case 0: /* SEEK_SET */
			filp->f_pos = off;
			break;

	  case 1: /* SEEK_CUR */
			filp->f_pos = filp->f_pos + off;
			break;

	  case 2: /* SEEK_END */
			return -EINVAL;
			break;

	  default: /* can't happen */
			return -EINVAL;
	}
	if (filp->f_pos < 0) return -EINVAL;
	return filp->f_pos;
}


ssize_t AriesPCI_read(struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
	int i;
	unsigned char data;
	unsigned int data32 = 0;
	unsigned char *kbuf;
	int retval;
	unsigned int AriesPCI_base;


	AriesPCI_base = (unsigned int)filp->f_pos;
	data32 = ioread32(ioaddr + AriesPCI_base);
	if (copy_to_user(buf,&data32,4)) {
		return -EFAULT;
	}
	return count;   /* success */
}


ssize_t AriesPCI_write(struct file *filp, const char __user *buf, size_t count, loff_t *f_pos)
{
	int i;
	unsigned char data;
	unsigned int data32 = 0;
	int retval;
	unsigned int AriesPCI_base;

	AriesPCI_base = (unsigned int)filp->f_pos;
	if (copy_from_user(&data32,buf,4)) {
		return -EFAULT;
	}
	//printk(KERN_ALERT "write address : %x \n", AriesPCI_base);
	//printk(KERN_ALERT "write data : %x \n", data32);
	iowrite32(data32, ioaddr + AriesPCI_base);
	
	return 0;   /* success */
}


int AriesPCI_close(struct inode *inode, struct file *filp)
{

	return 0;   /* success */
}

int AriesPCI_open(struct inode *inode, struct file *filp)
{

	return 0;   /* success */
	
}



struct file_operations AriesPCI_fops = {
	.owner = THIS_MODULE,
	.open = AriesPCI_open,
	.release = AriesPCI_close,
	.read = AriesPCI_read,
	.write = AriesPCI_write,
	.llseek = AriesPCI_llseek,
	/* BKL(Big Kernel Lock)完全撤廃のため、従来の .ioctl メンバは削除されたため、
	 * .unlocked_ioctl メンバを代替として使う。
	 */
	.unlocked_ioctl = AriesPCI_ioctl,
};



static int pci_init(void)
{
	dev_t dev = MKDEV(AriesPCI_major, 0);
	int alloc_ret = 0;
	int major;
	int cdev_err = 0;
	struct device *class_dev = NULL;

	
	if(print_pci_information() != 0){
		goto error;
	}
	
	alloc_ret = alloc_chrdev_region(&dev, 0, AriesPCI_devs, "AriesPCI");
	if (alloc_ret)
		goto error;
	AriesPCI_major = major = MAJOR(dev);

	cdev_init(&AriesPCI_cdev, &AriesPCI_fops);
	AriesPCI_cdev.owner = THIS_MODULE;
	AriesPCI_cdev.ops = &AriesPCI_fops;
	cdev_err = cdev_add(&AriesPCI_cdev, MKDEV(AriesPCI_major, AriesPCI_minor), 1);
	if (cdev_err) 
		goto error;

	/* register class */
	AriesPCI_class = class_create(THIS_MODULE, "AriesPCI");
	if (IS_ERR(AriesPCI_class)) {
		goto error;
	}
	AriesPCI_dev = MKDEV(AriesPCI_major, AriesPCI_minor);
	class_dev = device_create(
					AriesPCI_class, 
					NULL, 
					AriesPCI_dev,
					NULL, 
					"AriesPCI%d",
					AriesPCI_minor);

	printk(KERN_ALERT "AriesPCI driver(major %d) installed.\n", major);

	ioaddr = pci_iomap(device, 0, pci_resource_len(device,0));
	if (!ioaddr) {
		dev_err(&device->dev, "cannot map MMIO, aborting\n");
		return -EIO;
	}
	printk(KERN_ALERT "pci immap address : %x \n", ioaddr);
	//iowrite32(0xffffffff, ioaddr+0x300);
	return 0;

error:
	if (cdev_err == 0)
		cdev_del(&AriesPCI_cdev);

	if (alloc_ret == 0)
		unregister_chrdev_region(dev, AriesPCI_devs);

	return -1;
	
}

static void pci_exit(void)
{
	dev_t dev = MKDEV(AriesPCI_major, 0);

	iowrite32(0x00000000, ioaddr+0x300);
	pci_iounmap(device,ioaddr);

	/* unregister class */
	device_destroy(AriesPCI_class, AriesPCI_dev);
	class_destroy(AriesPCI_class);

	cdev_del(&AriesPCI_cdev);
	unregister_chrdev_region(dev, AriesPCI_devs);

	printk(KERN_ALERT "AriesPCI driver removed.\n");
	
}

module_init(pci_init);
module_exit(pci_exit);

//		request_irq