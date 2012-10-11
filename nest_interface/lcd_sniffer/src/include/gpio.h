#ifndef __GPIO_H__
#define __GPIO_H__

#include <msp430.h>
#include <inttypes.h>

typedef enum gpio_dir {
	GPIO_IN,
	GPIO_OUT,
} gpio_dir_e;

typedef enum gpio_int_dir {
	GPIO_INT_RISING_EDGE,
	GPIO_INT_FALLING_EDGE,
} gpio_int_dir_e;

typedef void gpio_int_cb (void);

void gpio_init (uint8_t port, uint8_t pin, gpio_dir_e dir);
void gpio_interrupt (uint8_t port, uint8_t pin, gpio_int_dir_e int_dir, gpio_int_cb cb);
void gpio_set_clear (uint8_t port, uint8_t pin, uint8_t set);
void gpio_set (uint8_t port, uint8_t pin);
void gpio_clear (uint8_t port, uint8_t pin);
void gpio_toggle(uint8_t port, uint8_t pin);
uint8_t gpio_read(uint8_t port, uint8_t pin);

#endif


