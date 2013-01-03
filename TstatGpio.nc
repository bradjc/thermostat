#include "nib.h"

/* Basic generic interface for pushing buttons and being notified of
 * button presses. Can handle any number of thermostats.
 */

interface TstatGpio {
  command void setButton (button_e b, thermostat_e tid);
  command void clearButtons (thermostat_e tid);

  event void buttonDone ();

  // Event when a button is pressed on the keypad
  event void buttonPressed (button_e b, thermostat_e tid);
}
