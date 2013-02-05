#ifndef __LCD_SNIFFER_H__
#define __LCD_SNIFFER_H__

#define LCD_I2C_TYPE_STATUS 0x1
#define LCD_I2C_TYPE_DISPLAY 0x2

typedef enum {
  Power = 1,               // 1 if the unit is on, else 0
  Cooling = 2,             // 1 if the unit is cooling
  Alarms = 3,              // 1 if the alarm is on
  Temperature = 4,         // current temperature of the room
  TemperatureSetPoint = 5, // temp the tstat is set to
  Humidity = 6,            // current humidity
} lcd_status_e;

typedef enum {
  Home,                 // Main screen, pretty obvious
  Off,                  // Unit is off
  Menu_Setpoint,        // Menu items
  Menu_Status,
  Menu_ActiveAlarms,
  Menu_AlarmHistory,
  Menu_Time,
  Menu_Date,
  Menu_Setback,
  Menu_SetupOperation,
  Menu_SetptPassword,
  Menu_SetupPassword,
  Menu_CalibrateSensor,
  Menu_AlarmEnable,
  Menu_AlarmTimeDelay,
  Menu_ComAlarmEnable,
  Menu_CustomAlarms,
  Menu_CustomText,
  Menu_Diagnostics,
  Menu_end,
  TempSetPoint,
  Password,
} lcd_display_e;

#endif
