#ifndef __NIB_H__
#define __NIB_H__

#define NEST_FAN_ID   0
#define NEST_COOL1_ID 1
#define NEST_COOL2_ID 2
#define NEST_HEAT1_ID 3
#define NEST_HEAT2_ID 4
#define NEST_STAR_ID  5

#define PCA9575_GPIO_IN_ADDR 0x27
#define PCA9575_GPIO_OUT_ADDR 0x23

#define LCD_SNIFFER_ADDR 0x11

//#define TSTAT1 1
//#define TSTAT2 2

#define TSTAT1_BUTTON_ONOFF (1 << 6)
#define TSTAT1_BUTTON_MENU  (1 << 5)
#define TSTAT1_BUTTON_UP    (1 << 4)
#define TSTAT1_BUTTON_ESC   (1 << 3)
#define TSTAT1_BUTTON_HELP  (1 << 2)
#define TSTAT1_BUTTON_DOWN  (1 << 1)
#define TSTAT1_BUTTON_ENTER (1)

#define TSTAT2_BUTTON_ONOFF (1 << 8)
#define TSTAT2_BUTTON_MENU  (1 << 9)
#define TSTAT2_BUTTON_UP    (1 << 10)
#define TSTAT2_BUTTON_ESC   (1 << 11)
#define TSTAT2_BUTTON_HELP  (1 << 12)
#define TSTAT2_BUTTON_DOWN  (1 << 13)
#define TSTAT2_BUTTON_ENTER (1 << 14)

#define BUTTON_PRESS_DURATION 200 // ms

typedef enum thermostat {
  TSTAT1,
  TSTAT2,
} thermostat_e;

typedef enum button {
  OnOff,
  Menu,
  Up,
  Esc,
  Help,
  Down,
  Enter
} button_e;

#endif
