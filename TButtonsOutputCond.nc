#include "nib.h"

interface TButtonsOutputCond {
  command void PressButton (button_e b);

  event void PressButtonDone (button_e button_pressed);
}
