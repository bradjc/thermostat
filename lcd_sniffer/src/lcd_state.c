#include <string.h>

#include "utility.h"
#include "lcd_state.h"

//
// Known issues:
// - no way to note the thermostat is not cooling the room anymore
//


//                                  0123456789abcdef
unsigned char lcds_str_off_1[]   = "Unit is OFF     ";
unsigned char lcds_str_off_2[]   = "by ~/O key      ";
unsigned char lcds_str_status[]  = " ~~~F    ~~ %RH ";

unsigned char lcds_str_temp_sp[] = "TEMP SETPT";
unsigned char lcds_str_cooling[] = "COOLING";
unsigned char lcds_str_alarms[]  = "NO ALARMS";


lcds_tstat_status_t tstat_st[NUM_OF_LCD_DISPLAYS] = {
	{0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}
};

lcds_lcd_buf_t lcd[NUM_OF_LCD_DISPLAYS];


// returns true if the stings are the same.
// use the ~ character for a wildcard (matches anything)
bool str_same (unsigned char* a, unsigned char* b, uint8_t len) {
	uint8_t i;

	for (i=0; i<len; i++) {
		// handle all of the special cases first
		if (a[i] == '~' || b[i] == '~') continue;  // wildcard
	//	if (a[i] == ' ' && b[i] == 0x80) continue; // both spaces
	//	if (a[i] == 0x80 && b[i] == ' ') continue; // both spaces

		if (a[i] != b[i]) {
			return FALSE;
		}
	}
	return TRUE;
}

uint8_t powers_of_ten[3] = {1, 10, 100};

uint8_t str_to_num (unsigned char* s, uint8_t len) {
	uint8_t i;
	uint8_t num = 0;
	for (i=0; i<len; i++) {
		num += (s[i] - 0x30) * powers_of_ten[len - i - 1];
	}
	return num;
}

void lcds_init () {
	int i;
	for (i=0; i<NUM_OF_LCD_DISPLAYS; i++) {
		memset(lcd[i].lcd_chars, 0xFE, 16*sizeof(uint8_t));
		lcd[i].lcd_idx = 0;
	}
}

// Call this when rs==0 to reset the index for a new line.
void lcds_start_line (thermostat_e tstat) {
	lcd[tstat].lcd_idx = 0;
}

// Add a character that was drawn to the lcd to the array. This function will
//  automatically update the index in the correct order.
// char = ascii character
void lcds_add_char (thermostat_e tstat, uint8_t character) {

	lcd[tstat].lcd_chars[lcd[tstat].lcd_idx++] = character;

	if (lcd[tstat].lcd_idx == 16) {
		lcds_process_line(tstat);
	}

}

void lcds_process_line (thermostat_e tstat) {
	uint8_t* c = lcd[tstat].lcd_chars;

	P1OUT ^= 0x80;

	// check if unit is now off
	if (str_same(c, lcds_str_off_1, 16) || str_same(c, lcds_str_off_2, 16)) {
		// unit is off
		tstat_st[tstat].on = FALSE;
		return;
	}

	// if it is not off, it must be on, basically
	tstat_st[tstat].on = TRUE;

	// check for the different screens
	if (str_same(c, lcds_str_status, 16)) {
		// basic status screen
		// get temp and relative humidity
		uint8_t temp, humidity;
		temp     = str_to_num(c+1, 2);
		humidity = str_to_num(c+9, 2);

		tstat_st[tstat].temperature = temp;
		tstat_st[tstat].humidity    = humidity;

	} else if (str_same(c, lcds_str_cooling, 7)) {
		// thermostat is currently cooling the room
		tstat_st[tstat].cooling = TRUE;

	} else if (str_same(c, lcds_str_alarms, 9)) {
		// there are no alarms on in the room
		tstat_st[tstat].alarms = FALSE;

	} else if (str_same(c, lcds_str_temp_sp, 10)) {
		// showing the current temperature set point
		uint8_t tsp = str_to_num(c+12, 2);
		tstat_st[tstat].temp_sp = tsp;

	}

}

uint8_t lcds_get_status (thermostat_e tstat, tstat_st_e tstat_status) {

	switch (tstat_status) {
		case TSTAT_ON_OFF: return tstat_st[tstat].on;
		case TSTAT_COOLING: return tstat_st[tstat].cooling;
		case TSTAT_ALARMS: return tstat_st[tstat].alarms;
		case TSTAT_TEMPERATURE: return tstat_st[tstat].temperature;
		case TSTAT_HUMIDITY: return tstat_st[tstat].humidity;
		case TSTAT_TEMPERATURE_SETPOINT: return tstat_st[tstat].temp_sp;
	}

	return 0xff;

}

uint8_t lcds_get_current_display (thermostat_e tstat) {
	return 0x5;
}


uint8_t* lcds_get_lcd (thermostat_e tstat) {
	memcpy(lcd[tstat].lcd_chars+16, &tstat_st[tstat], 6);
	return lcd[tstat].lcd_chars;
}




