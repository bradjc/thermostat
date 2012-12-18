
#include "nib.h"

interface TstatMultiButton {

  command void pressMultipleButtons (button_e* b, uint8_t len);

  event void pressMultipleButtonsDone ();

}
