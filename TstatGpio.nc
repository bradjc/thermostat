
#include "nib.h"

interface TstatGpio {
  command void setButton (button_e b, thermostat_e tid);
  command void clearButtons (thermostat_e tid);

  event void buttonDone ();
}

