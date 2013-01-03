#include "nib.h"

/* Simple interface for pressing buttons.
 */

interface TstatButtonsOut {
  command void pressButton (button_e b);

  event void pressButtonDone (button_e button_pressed);
}
