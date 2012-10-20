#ifndef __UTILITY_H__
#define __UTILITY_H__

#include <msp430.h>
#include <inttypes.h>

#define FALSE 0
#define TRUE  0

#define TSTAT1_LCD_RS_PORT  1
#define TSTAT1_LCD_RS_PIN   5
#define TSTAT1_LCD_E_PORT   1
#define TSTAT1_LCD_E_PIN    3
#define TSTAT1_LCD_RW_PORT  1
#define TSTAT1_LCD_RW_PIN   4
#define TSTAT1_LCD_DB4_PORT 4
#define TSTAT1_LCD_DB4_PIN  0
#define TSTAT1_LCD_DB5_PORT 4
#define TSTAT1_LCD_DB5_PIN  1
#define TSTAT1_LCD_DB6_PORT 4
#define TSTAT1_LCD_DB6_PIN  2
#define TSTAT1_LCD_DB7_PORT 4
#define TSTAT1_LCD_DB7_PIN  3

#define TSTAT2_LCD_RS_PORT  1
#define TSTAT2_LCD_RS_PIN   0
#define TSTAT2_LCD_E_PORT   1
#define TSTAT2_LCD_E_PIN    2
#define TSTAT2_LCD_RW_PORT  1
#define TSTAT2_LCD_RW_PIN   1
#define TSTAT2_LCD_DB4_PORT 4
#define TSTAT2_LCD_DB4_PIN  4
#define TSTAT2_LCD_DB5_PORT 4
#define TSTAT2_LCD_DB5_PIN  5
#define TSTAT2_LCD_DB6_PORT 4
#define TSTAT2_LCD_DB6_PIN  6
#define TSTAT2_LCD_DB7_PORT 4
#define TSTAT2_LCD_DB7_PIN  7

typdef bool uint8_t;

#define LCD_SNIFF_I2C_ADDR 0x44;

typedef enum tstat {
	TSTAT1 = 0,
	TSTAT2 = 1,
} tstat_e;


#endif
