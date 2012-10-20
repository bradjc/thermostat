#ifndef __LCD_STATE_H__
#define __LCD_STATE_H__

#include <msp430.h>
#include <inttypes.h>

typedef enum tstat_st {
	TSTAT_ON_OFF,
	TSTAT_COOLING,
	TSTAT_ALARMS,
	TSTAT_TEMPERATURE,
	TSTAT_HUMIDITY,
	TSTAT_TEMPERATURE_SETPOINT,
} tstat_st_e;

//                         01234567890123456789012345678901
char lcds_str_off[]     = "Unit is OFF     by I/O key      ";
char lcds_str_status[]  = " ~~~F    ~~ %RH ~~~~~~~~~       ";
char lcds_str_temp_sp[] = "TEMP SETPT";

char lcds_str_cooling[] = "COOLING";
char lcds_str_alarms[]  = "NO ALARMS";

struct {
	uint8_t on;          // 1 if on, 0 if the thermostat is off
	uint8_t cooling;     // 1 if the thermostat is cooling
	uint8_t alarms;      // 1 if the alarm is on
	uint8_t temperature; // room temp
	uint8_t humidity;    // room relative humidity
	uint8_t temp_sp;     // current temperature setting of the room
} lcds_tstat_status_t;

struct {
	// array to hold the current contents of the lcd display
	uint8_t lcd_chars[32];
	uint8_t lcd_idx;
} lcds_lcd_buf;


// Compare len characters of two strings. This is a fancy compare, because
//  it takes in to consideration the fancy formatting this library uses.
bool str_same (char* a, char* b, uint8_t len);

uint8_t str_to_num (char* s, uint8_t len);

void lcds_init ();

// Call this at the start of a new screen write to reset and clear buffers
void lcds_start_new_screen (tstat_e tstat);

// Add a character that was drawn to the lcd to the array. This function will
//  automatically update the index in the correct order.
// char = ascii character
void lcds_add_char (tstat_e tstat, uint8_t char);

void lcds_process_screen (tstat_e tstat);

uint8_t lcds_get_info (tstat_e tstat, tstat_st_e tstat_status);




#endif
