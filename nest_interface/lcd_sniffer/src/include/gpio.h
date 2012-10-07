#ifndef __GPIO_H__
#define __GPIO_H__

#include <msp430.h>
#include <inttypes.h>

typedef enum gpio_dir {
	GPIO_IN,
	GPIO_OUT,
} gpio_dir_e;

void gpio_init (uint8_t port, uint8_t pin, gpio_dir_e dir);
void gpio_set_clear (uint8_t port, uint8_t pin, uint8_t set);
void gpio_set (uint8_t port, uint8_t pin);
void gpio_clear (uint8_t port, uint8_t pin);
void gpio_toggle(uint8_t port, uint8_t pin);
uint8_t gpio_read(uint8_t port, uint8_t pin);

#endif

