
#include "msp430.h"

#define TSTAT1_LCD_RS_PORT ??
#define TSTAT1_LCD_RS_PIN ??
#define TSTAT1_LCD_E_PORT
#define TSTAT1_LCD_E_PIN
#define TSTAT1_LCD_RW_PORT
#define TSTAT1_LCD_RW_PIN
#define TSTAT1_LCD_DB4_PORT
#define TSTAT1_LCD_DB4_PIN
#define TSTAT1_LCD_DB5_PORT
#define TSTAT1_LCD_DB5_PIN
#define TSTAT1_LCD_DB6_PORT
#define TSTAT1_LCD_DB6_PIN
#define TSTAT1_LCD_DB7_PORT
#define TSTAT1_LCD_DB7_PIN

#define TSTAT2_LCD_RS_PORT ??
#define TSTAT2_LCD_RS_PIN ??
#define TSTAT2_LCD_E_PORT
#define TSTAT2_LCD_E_PIN
#define TSTAT2_LCD_RW_PORT
#define TSTAT2_LCD_RW_PIN
#define TSTAT2_LCD_DB4_PORT
#define TSTAT2_LCD_DB4_PIN
#define TSTAT2_LCD_DB5_PORT
#define TSTAT2_LCD_DB5_PIN
#define TSTAT2_LCD_DB6_PORT
#define TSTAT2_LCD_DB6_PIN
#define TSTAT2_LCD_DB7_PORT
#define TSTAT2_LCD_DB7_PIN

typedef enum tstat {
	TSTAT1 = 0,
	TSTAT2 = 1,
} tstat_e;

// Samples the 4 data wires and returns the values in the lower 4 bits
uint8_t get_raw_tstat_data (tstat_e tstat) {

	uint8_t ret_nib = 0;

	if (tstat == TSTAT1) {
		ret_nib =  gpio_read(TSTAT1_LCD_DB4_PORT, TSTAT1_LCD_DB4_PIN) << 3;
		ret_nib |= gpio_read(TSTAT1_LCD_DB3_PORT, TSTAT1_LCD_DB3_PIN) << 2;
		ret_nib |= gpio_read(TSTAT1_LCD_DB3_PORT, TSTAT1_LCD_DB3_PIN) << 1;
		ret_nib |= gpio_read(TSTAT1_LCD_DB3_PORT, TSTAT1_LCD_DB3_PIN);
	} else if (tstat == TSTAT2) {
		ret_nib =  gpio_read(TSTAT2_LCD_DB4_PORT, TSTAT2_LCD_DB4_PIN) << 3;
		ret_nib |= gpio_read(TSTAT2_LCD_DB3_PORT, TSTAT2_LCD_DB3_PIN) << 2;
		ret_nib |= gpio_read(TSTAT2_LCD_DB3_PORT, TSTAT2_LCD_DB3_PIN) << 1;
		ret_nib |= gpio_read(TSTAT2_LCD_DB3_PORT, TSTAT2_LCD_DB3_PIN);
	}

	return ret_nib;

}




int main () {


	board_init();




	return 0;

}




