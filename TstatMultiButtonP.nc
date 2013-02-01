
#include "nib.h"

generic module TstatMultiButtonP (thermostat_e tid) {
  provides {
    interface TstatMultiButton;
  }
  uses {
    interface TstatButtonsOut;
  }
}

implementation {

  button_e* button_array;
  uint8_t   button_index;
  uint8_t   button_array_len;

  task void press_next () {
    button_e button;

    if (button_index >= button_array_len) {
      signal TstatMultiButton.pressMultipleButtonsDone();
      return;
    }

    button = button_array[button_index++];
    call TstatButtonsOut.pressButton(button);
  }

  command void TstatMultiButton.pressMultipleButtons (button_e* b, uint8_t len) {
    if (len > 0) {
      button_array     = b;
      button_index     = 0;
      button_array_len = len;

      post press_next();
    }
  }

  event void TstatButtonsOut.pressButtonDone (button_e b) {
    post press_next();
  }

}

