#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/ioport.h>
#include <asm/errno.h>
#include <asm/io.h>


MODULE_INFO(intree, "Y");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("");
MODULE_DESCRIPTION("Simple kernel module for SYKOM");
MODULE_VERSION("1");

#define SYKT_GPIO_BASE_ADDR (0x00100000)
#define SYKT_GPIO_SIZE      (0x8000)
#define SYKT_EXIT           (0x3333)
#define SYKT_EXIT_CODE      (0x7F) 

#define SYKT_GPIO_ADDR_SPACE (0x00100000)


#define A1_ADDR (SYKT_GPIO_ADDR_SPACE + 0x108)
#define A2_ADDR (SYKT_GPIO_ADDR_SPACE + 0x110)
#define W_ADDR  (SYKT_GPIO_ADDR_SPACE + 0x118)
#define L_ADDR  (SYKT_GPIO_ADDR_SPACE + 0x120)
#define B_ADDR  (SYKT_GPIO_ADDR_SPACE + 0x128)


#define u32 unsigned long

struct kobject *sykt;
void __iomem *baseptr;

void __iomem *a1;
void __iomem *a2;
void __iomem *w;
void __iomem *b;
void __iomem *l;



// Odczyt danych
static ssize_t dj_read(struct kobject *kobj, struct kobj_attribute *attr, char *buf, u32 *reg){
    return sprintf(buf, "%lx \n", readl(reg));
}

// Odczyt A1
static ssize_t djca1_read(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return dj_read(kobj, attr, buf, a1);
}

// Zapis A1
static ssize_t djca1_write(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count){
    u32 x;
    if (sscanf(buf, "%lx", &x) <= 0) {
        return 0;
    }
    writel(x, a1);
    return count;
}

// Odczyt A2
static ssize_t djca2_read(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return dj_read(kobj, attr, buf, a2);
}

// Zapis A2
static ssize_t djca2_write(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count){
    u32 x;
    if (sscanf(buf, "%lx", &x) <= 0) {
        return 0;
    }
    writel(x, a2);
    return count;
}

// Odczyt wyniku
static ssize_t djcw_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return dj_read(kobj, attr, buf, w);
}

// Odczyt flagi
static ssize_t djcb_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return dj_read(kobj, attr, buf, b);
}

// Odczyt liczby jedynek
static ssize_t djcl_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf){
    return dj_read(kobj, attr, buf, l);
}

struct kobj_attribute djca1_attr = __ATTR(djca1, 0660, djca1_read, djca1_write);
struct kobj_attribute djca2_attr = __ATTR(djca2, 0660, djca2_read, djca2_write);
struct kobj_attribute djcw_attr = __ATTR_RO(djcw);
struct kobj_attribute djcb_attr = __ATTR_RO(djcb);
struct kobj_attribute djcl_attr = __ATTR_RO(djcl);


int my_init_module(void){
    printk(KERN_INFO "Initialize my sykom module.\n");

    baseptr = ioremap(SYKT_GPIO_BASE_ADDR, SYKT_GPIO_SIZE);

    a1 = ioremap(A1_ADDR, SYKT_GPIO_SIZE);
    a2 = ioremap(A2_ADDR, SYKT_GPIO_SIZE);
    w = ioremap(W_ADDR, SYKT_GPIO_SIZE);
    l = ioremap(L_ADDR, SYKT_GPIO_SIZE);
    b = ioremap(B_ADDR, SYKT_GPIO_SIZE);

    sykt = kobject_create_and_add("sykt", kernel_kobj);


    //Obsluga bledow
    int ret;

    ret = sysfs_create_file(sykt, &djca1_attr.attr);
    if (ret) {
        printk(KERN_ERR "Failed to create djca1 file: %d\n", ret);
    }

    ret = sysfs_create_file(sykt, &djca2_attr.attr);
    if (ret) {
        printk(KERN_ERR "Failed to create djca2 file: %d\n", ret);
    }

    ret = sysfs_create_file(sykt, &djcw_attr.attr);
    if (ret) {
        printk(KERN_ERR "Failed to create djcw file: %d\n", ret);
    }

    ret = sysfs_create_file(sykt, &djcb_attr.attr);
    if (ret) {
        printk(KERN_ERR "Failed to create djcb file: %d\n", ret);
    }

    ret = sysfs_create_file(sykt, &djcl_attr.attr);
    if (ret) {
        printk(KERN_ERR "Failed to create djcl file: %d\n", ret);
    }

    return 0;
} 


void my_cleanup_module(void){
    printk(KERN_INFO "Clean up my sykom module.\n");
    writel(SYKT_EXIT | ((SYKT_EXIT_CODE)<<16), baseptr);
    iounmap(baseptr);
    iounmap(a1);
    iounmap(a2);
    iounmap(w);
    iounmap(l);
    iounmap(b);

    kobject_put(sykt);
}

module_init(my_init_module)
module_exit(my_cleanup_module)