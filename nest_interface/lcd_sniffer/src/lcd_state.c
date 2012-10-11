
//                     01234567890123456789012345678901
char lcds_str_off[] = "Unit is OFF     by I/O key      "

struct {
	uint8_t on;      // 1 if on, 0 if the thermostat is off
	uint8_t cooling; // 1 if the thermostat is cooling
	uint8_t alarms;  // 1 if the alarm is on
} lcds_tstat_status_t;

struct {
	// array to hold the current contents of the lcd display
	uint8_t lcd_chars[32];
	uint8_t lcd_idx;
} lcds_lcd_buf;

lcds_tstat_status_t tstat_st[2];

lcds_lcd_buf lcd[2];

void lcds_init () {

}

// Call this at the start of a new screen write to reset and clear buffers
void lcds_start_new_screen (tstat_e tstat) {
	memclr(lcd[tstat].lcd_chars, 16*sizeof(uint8_t));
	lcd[tstat].lcd_idx = 16;
}

// Add a character that was drawn to the lcd to the array. This function will
//  automatically update the index in the correct order.
// char = ascii character
void lcds_add_char (tstat_e tstat, uint8_t char) {

	lcd[tstat].lcd_chars[lcd[tstat].lcd_idx++] = char;
	
	// The lcd driver on the thermostats write the bottom line first and then
	//  the top line. We'll just put it in the buffer in a more logical way,
	//  however.
	if (lcd[tstat].lcd_idx == 32) {
		lcd[tstat].lcd_idx = 0;
	}

}

void lcds_process_screen (tstat_e tstat) {

	// check if unit is now off
	if (memcmp(lcd[tstat].lcd_chars, lcds_str_off, 32) == 0) {
		// unit is off
		tstat_st[tstat].on = 0;
	} else {
		// if it is not off, it must be on, basically
		tstat_st[tstat].on = 1;
	}



}







