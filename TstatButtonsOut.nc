#include "nib.h"

interface TstatButtonsOut {
  command void pressButton (button_e b);

  event void pressButtonDone (button_e button_pressed);
}
