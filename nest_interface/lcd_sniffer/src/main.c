#include <stdint.h>

#include "msp430.h"
#include "utility.h"
#include "gpio.h"
#include "i2c.h"

#include "lcd_state.h"

uint8_t i2c_buf[100];

volatile uint8_t a = 0;

// Samples the 4 data wires and returns the values in the lower 4 bits
uint8_t get_raw_tstat_data (thermostat_e tstat) {

	uint8_t ret_nib = 0;

	if (tstat == TSTAT1) {
		ret_nib =  gpio_read(TSTAT1_LCD_DB4_PORT, TSTAT1_LCD_DB4_PIN) << 3;
		ret_nib |= gpio_read(TSTAT1_LCD_DB5_PORT, TSTAT1_LCD_DB5_PIN) << 2;
		ret_nib |= gpio_read(TSTAT1_LCD_DB6_PORT, TSTAT1_LCD_DB6_PIN) << 1;
		ret_nib |= gpio_read(TSTAT1_LCD_DB7_PORT, TSTAT1_LCD_DB7_PIN);
	} else if (tstat == TSTAT2) {
		ret_nib =  gpio_read(TSTAT2_LCD_DB4_PORT, TSTAT2_LCD_DB4_PIN) << 3;
		ret_nib |= gpio_read(TSTAT2_LCD_DB5_PORT, TSTAT2_LCD_DB5_PIN) << 2;
		ret_nib |= gpio_read(TSTAT2_LCD_DB6_PORT, TSTAT2_LCD_DB6_PIN) << 1;
		ret_nib |= gpio_read(TSTAT2_LCD_DB7_PORT, TSTAT2_LCD_DB7_PIN);
	}

	return ret_nib;

}


void handle_i2c_req (uint8_t* buf, uint8_t len) {
//	uint8_t data;

//	data = lcds_get_info(addr);

//	i2c_send(data);

//	gpio_clear(2, 1);

	a = 5;

}

uint8_t char_idx[2]  = {0}; // counter of half words, so one screen is 64 counts
char    char_last[2] = {0};


void handle_tstat_int (thermostat_e tstat) {
	uint8_t rs;
//	uint8_t rw;
	uint8_t raw_data;

	if (tstat == TSTAT1) {
		rs = gpio_read(TSTAT1_LCD_RS_PORT, TSTAT1_LCD_RS_PIN);
//		rw = gpio_read(TSTAT1_LCD_RW_PORT, TSTAT1_LCD_RW_PIN);
	} else {
		rs = gpio_read(TSTAT2_LCD_RS_PORT, TSTAT2_LCD_RS_PIN);
//		rw = gpio_read(TSTAT2_LCD_RW_PORT, TSTAT2_LCD_RW_PIN);
	}

	if (rs == 0) {
		char_idx[tstat] = 0;
		lcds_start_new_screen(tstat);

	} else {
		raw_data = get_raw_tstat_data(tstat);

		if (char_idx[tstat] & 0x1) {
			// if we are on an odd char_idx, then we need to add the four
			//  new bits and save the character to the lcd_state
			char_last[tstat] = (char_last[tstat] << 4) | raw_data;
			lcds_add_char(tstat, char_last[tstat]);

		} else {
			// save these bits for later
			char_last[tstat] = raw_data;
		}

		char_idx[tstat]++;
	}

}

void handle_tstat1_int () {
	handle_tstat_int(TSTAT1);
}

void handle_tstat2_int () {
	handle_tstat_int(TSTAT2);
}


int main () {

	util_disableWatchdog();
	util_boardInit();
	util_enableInterrupt();

	i2c_init();
	i2c_set_slave(LCD_SNIFF_I2C_ADDR, i2c_buf, handle_i2c_req);
//	i2c_set_slave(0x44, i2c_buf, handle_i2c_req);
//	i2c_set_receive_callback(handle_i2c_req);

	gpio_init(2, 0, GPIO_OUT);
	gpio_set(2, 0);
	gpio_clear(2, 0);

	gpio_init(2, 1, GPIO_OUT);
	gpio_set(2, 1);
//	gpio_clear(2, 1);
/*
	gpio_init(TSTAT1_LCD_RS_PORT,  TSTAT1_LCD_RS_PIN,  GPIO_IN);
	gpio_init(TSTAT1_LCD_E_PORT,   TSTAT1_LCD_E_PIN,   GPIO_IN);
	gpio_init(TSTAT1_LCD_RW_PORT,  TSTAT1_LCD_RW_PIN,  GPIO_IN);
	gpio_init(TSTAT1_LCD_DB4_PORT, TSTAT1_LCD_DB4_PIN, GPIO_IN);
	gpio_init(TSTAT1_LCD_DB5_PORT, TSTAT1_LCD_DB5_PIN, GPIO_IN);
	gpio_init(TSTAT1_LCD_DB6_PORT, TSTAT1_LCD_DB6_PIN, GPIO_IN);
	gpio_init(TSTAT1_LCD_DB7_PORT, TSTAT1_LCD_DB7_PIN, GPIO_IN);
	gpio_interrupt(TSTAT1_LCD_E_PORT,
	               TSTAT1_LCD_E_PIN,
	               GPIO_INT_FALLING_EDGE,
	               handle_tstat1_int);

	gpio_init(TSTAT2_LCD_RS_PORT,  TSTAT2_LCD_RS_PIN,  GPIO_IN);
	gpio_init(TSTAT2_LCD_E_PORT,   TSTAT2_LCD_E_PIN,   GPIO_IN);
	gpio_init(TSTAT2_LCD_RW_PORT,  TSTAT2_LCD_RW_PIN,  GPIO_IN);
	gpio_init(TSTAT2_LCD_DB4_PORT, TSTAT2_LCD_DB4_PIN, GPIO_IN);
	gpio_init(TSTAT2_LCD_DB5_PORT, TSTAT2_LCD_DB5_PIN, GPIO_IN);
	gpio_init(TSTAT2_LCD_DB6_PORT, TSTAT2_LCD_DB6_PIN, GPIO_IN);
	gpio_init(TSTAT2_LCD_DB7_PORT, TSTAT2_LCD_DB7_PIN, GPIO_IN);
	gpio_interrupt(TSTAT2_LCD_E_PORT,
	               TSTAT2_LCD_E_PIN,
	               GPIO_INT_FALLING_EDGE,
	               handle_tstat2_int);

*/


	while (1) {
		if (a == 5) {
			gpio_set(2, 0);
		}
	}

	return 0;

}




