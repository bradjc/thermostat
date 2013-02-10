
#include "lcdsniffer.h"
#include "nib.h"

interface LcdSniffer {
  // Query the lcd sniffer module for the current status of the tstat.
  // It is possible the sniffer hasn't seen the screen that would tell it the
  //  info it needs. In this case the getStatusDone call will return with an
  //  error as the last argument.
  command error_t getStatus (thermostat_e tstat, lcd_status_e status);

  // Uses a callback to return a value representing the current screen the tstat
  //  is on.
  command error_t getCurrentDisplay (thermostat_e tstat);

  command error_t getLcdChars (thermostat_e tstat);

  event void getStatusDone (lcd_status_e status, uint8_t value, error_t e);
  event void getCurrentDisplayDone (lcd_display_e display);
  event void getLcdCharsDone (uint8_t* chars);
}
