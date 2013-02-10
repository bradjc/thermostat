#ifndef __LCD_STATE_H__
#define __LCD_STATE_H__

#include <msp430.h>
#include <inttypes.h>

#include "utility.h"

#define NUM_OF_LCD_DISPLAYS 2

#define LCD_REQUEST_STATUS 1
#define LCD_REQUEST_DISPLAY 2
#define LCD_REQUEST_LCD_CHARS 3

typedef enum tstat_st {
	TSTAT_ON_OFF = 1,
	TSTAT_COOLING = 2,
	TSTAT_ALARMS = 3,
	TSTAT_TEMPERATURE = 4,
	TSTAT_HUMIDITY = 5,
	TSTAT_TEMPERATURE_SETPOINT = 6,
} tstat_st_e;


typedef struct {
	uint8_t on;          // 1 if on, 0 if the thermostat is off
	uint8_t cooling;     // 1 if the thermostat is cooling
	uint8_t alarms;      // 1 if the alarm is on
	uint8_t temperature; // room temp
	uint8_t humidity;    // room relative humidity
	uint8_t temp_sp;     // current temperature setting of the room
} lcds_tstat_status_t;

typedef struct {
	// array to hold the current contents of the lcd display
	uint8_t lcd_chars[500];
	uint8_t lcd_idx;
} lcds_lcd_buf_t;

typedef enum {
	LCDS_ST_RESET1,
	LCDS_ST_LINE1,
	LCDS_ST_RESET2,
	LCDS_ST_LINE2
} lcds_state_e;


// Compare len characters of two strings. This is a fancy compare, because
//  it takes in to consideration the fancy formatting this library uses.
bool str_same (unsigned char* a, unsigned char* b, uint8_t len);

uint8_t str_to_num (unsigned char* s, uint8_t len);

void lcds_init ();

void lcds_process_buffer (thermostat_e tstat, uint8_t* buf);

void lcds_start_line (thermostat_e tstat);

// Add a character that was drawn to the lcd to the array. This function will
//  automatically update the index in the correct order.
// char = ascii character
void lcds_add_char (thermostat_e tstat, uint8_t character);

void lcds_process_screen (thermostat_e tstat);

uint8_t lcds_get_status (thermostat_e tstat, tstat_st_e tstat_status);

uint8_t lcds_get_current_display (thermostat_e tstat);

uint8_t* lcds_get_lcd (thermostat_e tstat);


#endif
