
#include "nib.h"

interface ThermostatMultiButton {

  command void pressMultipleButtons (button_e* b, uint8_t len);

  event void pressMultipleButtonsDone ();

}
