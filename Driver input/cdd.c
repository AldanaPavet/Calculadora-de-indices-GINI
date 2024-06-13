#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/io.h>
#include <linux/gpio.h>
#include <linux/timer.h>

#define DEVICE_NAME "CDD_GPIO_BUTTON"
#define GPIO_SIGNAL1 22
#define GPIO_SIGNAL2 27
#define BCM2837_GPIO_ADDRESS 0x3F200000

// Function prototypes
static int device_open(struct inode *inode, struct file *file);
static int device_release(struct inode *inode, struct file *file);
static ssize_t device_read(struct file *file, char *buffer, size_t len, loff_t *offset);
static ssize_t device_write(struct file *file, const char *buffer, size_t len, loff_t *offset);
static int __init gpio_signal_init(void);
static void __exit gpio_signal_exit(void);
static void sample_signal(struct timer_list *timer);
static void gpio_pin_input(unsigned int pin);

// Global variables
static int major_number = 0;
static void __iomem *gpio_base = NULL;
static int selected_signal = GPIO_SIGNAL1;
static int signal_value = 0;
static struct timer_list signal_timer;

// File operations structure (needed for character device)
static const struct file_operations fops = {
    .open = device_open,
    .release = device_release,
    .read = device_read,
    .write = device_write,
};

// Timer callback function to sample the selected signal
static void sample_signal(struct timer_list *timer)
{
    int new_signal_value = gpio_get_value(selected_signal);
    if (new_signal_value != signal_value) {
        signal_value = new_signal_value;
        printk(KERN_INFO "GPIO SIGNAL: Detected value %d on GPIO %d.\n", signal_value, selected_signal);
    }
    mod_timer(&signal_timer, jiffies + HZ);
}

// Device read function
static ssize_t device_read(struct file *file, char *buffer, size_t len, loff_t *offset)
{
    char value_str[3];
    size_t value_str_len;

    // Read the value of the GPIO pin
    int gpio_value = gpio_get_value(selected_signal);

    // Convert the GPIO value to a string ("0\n" or "1\n")
    snprintf(value_str, sizeof(value_str), "%d\n", gpio_value);
    value_str_len = strlen(value_str);

    // Check if the offset is beyond the string length
    if (*offset >= value_str_len)
        return 0;

    // Adjust len to ensure it doesn't read beyond the end of the string
    if (len > value_str_len - *offset)
        len = value_str_len - *offset;

    // Copy the data to the user buffer
    if (copy_to_user(buffer, value_str + *offset, len))
        return -EFAULT;

    // Number of bytes read
    *offset += len;

    printk(KERN_INFO "GPIO SIGNAL: Value read %d.\n", gpio_value);

    return len;
}

// Device write function to select the signal
static ssize_t device_write(struct file *file, const char *buffer, size_t len, loff_t *offset)
{
    char kbuf[2];

    if (len > 1)
        len = 1;

    if (copy_from_user(kbuf, buffer, len))
        return -EFAULT;

    if (kbuf[0] == '1') {
        selected_signal = GPIO_SIGNAL1;
        printk(KERN_INFO "GPIO SIGNAL: Selected GPIO %d.\n", GPIO_SIGNAL1);
    } else if (kbuf[0] == '2') {
        selected_signal = GPIO_SIGNAL2;
        printk(KERN_INFO "GPIO SIGNAL: Selected GPIO %d.\n", GPIO_SIGNAL2);
    }

    return len;
}

// Device open function
static int device_open(struct inode *inode, struct file *file)
{
    printk(KERN_INFO "GPIO SIGNAL: Device opened.\n");
    return 0;
}

// Device release function
static int device_release(struct inode *inode, struct file *file)
{
    printk(KERN_INFO "GPIO SIGNAL: Device closed.\n");
    return 0;
}

static void gpio_pin_input(unsigned int pin)
{
    unsigned int fsel_index = pin / 10;
    unsigned int fsel_bitpos = (pin % 10) * 3;
    unsigned int *gpio_fsel = (unsigned int *)gpio_base + fsel_index;

    printk(KERN_INFO "GPIO SIGNAL: Setting up pin %d as input.\n", pin);

    *gpio_fsel &= ~(7 << fsel_bitpos); // Clear the bits for the pin
    *gpio_fsel |= (0 << fsel_bitpos);  // Set the pin as input

    printk(KERN_INFO "GPIO SIGNAL: Pin %d set up as input.\n", pin);
}

// Module initialization function
static int __init gpio_signal_init(void)
{
    int result;

    printk(KERN_INFO "GPIO SIGNAL: Initializing.\n");

    gpio_base = ioremap(BCM2837_GPIO_ADDRESS, PAGE_SIZE);
    if (!gpio_base)
    {
        printk(KERN_ALERT "GPIO SIGNAL: Failed to map GPIO memory.\n");
        return -ENOMEM;
    }

    printk(KERN_INFO "GPIO SIGNAL: Successfully mapped GPIO memory.\n");

    if (!gpio_is_valid(GPIO_SIGNAL1) || !gpio_is_valid(GPIO_SIGNAL2))
    {
        printk(KERN_ALERT "GPIO SIGNAL: Invalid GPIO pin.\n");
        iounmap(gpio_base);
        return -ENODEV;
    }

    gpio_pin_input(GPIO_SIGNAL1);
    gpio_pin_input(GPIO_SIGNAL2);

    // Register character device
    major_number = register_chrdev(0, DEVICE_NAME, &fops);
    if (major_number < 0)
    {
        printk(KERN_ALERT "GPIO SIGNAL: Failed to register a major number.\n");
        iounmap(gpio_base);
        return major_number;
    }

    // Initialize timer for signal sampling
    timer_setup(&signal_timer, sample_signal, 0);
    mod_timer(&signal_timer, jiffies + HZ);

    printk(KERN_INFO "GPIO SIGNAL: Registered correctly with major number %d.\n", major_number);
    return 0;
}

// Module exit function
static void __exit gpio_signal_exit(void)
{
    del_timer(&signal_timer);
    iounmap(gpio_base);
    unregister_chrdev(major_number, DEVICE_NAME);
    printk(KERN_INFO "GPIO SIGNAL: Module unloaded.\n");
}

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Aldana Pavet, David Trujillo, Fernando Zarate");
MODULE_DESCRIPTION("GPIO INPUT driver for Raspberry Pi3");
MODULE_VERSION("2.0");

module_init(gpio_signal_init);
module_exit(gpio_signal_exit);
