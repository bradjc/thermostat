#include <stdint.h>

#include "msp430.h"
#include "utility.h"
#include "gpio.h"
#include "i2c.h"

#include "lcd_state.h"

uint8_t i2c_buf[100];

volatile uint8_t a = 0;

uint8_t request_tstat;
// whether the main processor wants to know whats on the display or some
//  status value
uint8_t request_type;
// if the processor wants to know the status, what status does it want
uint8_t request_val;


void handle_i2c_receive (uint8_t* buf, uint8_t len) {
	request_tstat = buf[0];

	if (len == 2) {
		// set only the req type
		request_type = buf[1];
	} else if (len == 3) {
		request_type = buf[1];
		request_val  = buf[2];
	}

}

uint8_t transmit_storage;

uint8_t index;
uint8_t characters[500];

uint8_t* handle_i2c_transmit () {


	if (request_type == LCD_REQUEST_DISPLAY) {
		transmit_storage = lcds_get_current_display(request_tstat);
	} else if (request_type == LCD_REQUEST_STATUS) {
		transmit_storage = lcds_get_status(request_tstat, request_val);
		//return 1;
	} else if (request_type == LCD_REQUEST_LCD_CHARS) {
		return lcds_get_lcd(request_tstat);
	} else {
		transmit_storage = 0xff;
	}

	// if nothing better to do return the error code
	return &transmit_storage;


}


int main () {

	util_disableWatchdog();
	util_boardInit();
	util_enableInterrupt();

	i2c_init();
	i2c_set_slave(LCD_SNIFF_I2C_ADDR,
		          i2c_buf,
		          handle_i2c_receive,
		          handle_i2c_transmit);



//	i2c_set_slave(0x44, i2c_buf, handle_i2c_req);
//	i2c_set_receive_callback(handle_i2c_req);

	gpio_init(2, 0, GPIO_OUT);
	gpio_set(2, 0);


	gpio_init(2, 1, GPIO_OUT);
	gpio_set(2, 1);
//	gpio_clear(2, 1);

//	lcds_start_new_screen(TSTAT1);
//	lcds_start_new_screen(TSTAT2);

	lcds_init();
	memset(characters, 0xE5, 500);

	index = 0;

	gpio_init(TSTAT1_LCD_RS_PORT,  TSTAT1_LCD_RS_PIN,  GPIO_IN);
	gpio_init(TSTAT1_LCD_E_PORT,   TSTAT1_LCD_E_PIN,   GPIO_IN);
	gpio_init(TSTAT1_LCD_RW_PORT,  TSTAT1_LCD_RW_PIN,  GPIO_IN);
	gpio_init(TSTAT1_LCD_DB4_PORT, TSTAT1_LCD_DB4_PIN, GPIO_IN);
	gpio_init(TSTAT1_LCD_DB5_PORT, TSTAT1_LCD_DB5_PIN, GPIO_IN);
	gpio_init(TSTAT1_LCD_DB6_PORT, TSTAT1_LCD_DB6_PIN, GPIO_IN);
	gpio_init(TSTAT1_LCD_DB7_PORT, TSTAT1_LCD_DB7_PIN, GPIO_IN);
	gpio_init(2, 4, GPIO_OUT);
	gpio_clear(2,4);
	gpio_init(1, 7, GPIO_OUT);
	gpio_clear(1,7);
	gpio_interrupt(TSTAT1_LCD_E_PORT,
	               TSTAT1_LCD_E_PIN,
	               GPIO_INT_FALLING_EDGE,
	               NULL);

	gpio_init(TSTAT2_LCD_RS_PORT,  TSTAT2_LCD_RS_PIN,  GPIO_IN);
	gpio_init(TSTAT2_LCD_E_PORT,   TSTAT2_LCD_E_PIN,   GPIO_IN);
	gpio_init(TSTAT2_LCD_RW_PORT,  TSTAT2_LCD_RW_PIN,  GPIO_IN);
	gpio_init(TSTAT2_LCD_DB4_PORT, TSTAT2_LCD_DB4_PIN, GPIO_IN);
	gpio_init(TSTAT2_LCD_DB5_PORT, TSTAT2_LCD_DB5_PIN, GPIO_IN);
	gpio_init(TSTAT2_LCD_DB6_PORT, TSTAT2_LCD_DB6_PIN, GPIO_IN);
	gpio_init(TSTAT2_LCD_DB7_PORT, TSTAT2_LCD_DB7_PIN, GPIO_IN);
/*	gpio_interrupt(TSTAT2_LCD_E_PORT,
	               TSTAT2_LCD_E_PIN,
	               GPIO_INT_FALLING_EDGE,
	               handle_tstat2_int);

*/


	while (1) {
	//	_BIS_SR(LPM3_bits + GIE);
	}

	return 0;

}

uint8_t char_tstat1, char_tstat2;
uint8_t nib_ctr_tstat1=0, nib_ctr_tstat2;

#pragma vector=PORT1_VECTOR
__interrupt void Port_1(void) {
	uint8_t int_pin;
	uint8_t p1, p4;

	// get and clear interrupt
	int_pin = P1IFG;
	P1IFG = 0;

	p1 = P1IN;
	p4 = P4IN;

	if (int_pin & 0x08) {
		// tstat 1
		if (!((p1 >> TSTAT1_LCD_RS_PIN) & 0x01)) {
			// rs is low, start a new line
			lcds_start_line(TSTAT1);
			nib_ctr_tstat1 = 0;
		} else {

			if (nib_ctr_tstat1 & 0x1) {
				char_tstat1 |= (p4 & 0x0f);
				lcds_add_char(TSTAT1, char_tstat1);
			} else {
				char_tstat1 = p4 << 4;
			}

			nib_ctr_tstat1 ^= 0x1;
		}

	} else if (int_pin & 0x04) {
		// tstat 2
/*		if (!(p1 & 0x01)) {
			// rs line is low, clear things
			lcds_start_line(TSTAT2);
			nib_ctr_tstat2 = 0;
			return;
		} else {

			if (nib_ctr_tstat2) {
				char_tstat2 |= (p4 >> 4);
				lcds_add_char(TSTAT2, char_tstat2);
			} else {
				char_tstat2 = p4 & 0xf0;
			}

			nib_ctr_tstat2 ^= 0x1;
		}*/
	}


//	util_enableInterrupt();

}




