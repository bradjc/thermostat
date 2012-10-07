#include <msp430.h>
#include <inttypes.h>

#include "gpio.h"


void gpio_init (uint8_t port, uint8_t pin, gpio_dir_e dir) {
	uint8_t set, clear;

	clear = ~(1 << pin);

	if (dir == GPIO_OUT) {
		set = 1 << pin;
	} else if (dir == GPIO_IN) {
		set = 0;
	}

	switch (port) {
		case 1: P1DIR = (P1DIR & clear) | set; break;
		case 2: P2DIR = (P2DIR & clear) | set; break;
		case 3: P3DIR = (P3DIR & clear) | set; break;
		case 4: P4DIR = (P4DIR & clear) | set; break;
	}
}

void gpio_set_clear (uint8_t port, uint8_t pin, uint8_t set) {
	uint8_t clear;

	set = (set & 0x01) << pin;
	clear = ~(1 << pin);
	switch (port) {
		case 1: P1OUT = (P1OUT & clear) | set; break;
		case 2: P2OUT = (P2OUT & clear) | set; break;
		case 3: P3OUT = (P3OUT & clear) | set; break;
		case 4: P4OUT = (P4OUT & clear) | set; break;
	}
}

void gpio_set (uint8_t port, uint8_t pin) {
	gpio_set_clear(port, pin, 1);
}

void gpio_clear (uint8_t port, uint8_t pin) {
	gpio_set_clear(port, pin, 0);
}

void gpio_toggle(uint8_t port, uint8_t pin) {
	if (gpio_read(port, pin)) {
		gpio_clear(port, pin);
	} else {
		gpio_set(port, pin);
	}
}

uint8_t gpio_read(uint8_t port, uint8_t pin) {
	switch (port) {
		case 1:
			return (P1IN >> pin) & 0x01;
		case 2:
			return (P2IN >> pin) & 0x01;
		case 3:
			return (P3IN >> pin) & 0x01;
		case 4:
			return (P4IN >> pin) & 0x01;
	}
	return 0;
}






