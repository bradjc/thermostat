
#include "nib.h"

module ThermostatMultiButtonP {
  provides {
    interface ThermostatMultiButton as TStat1MButton;
    interface ThermostatMultiButton as TStat2MButton;
  }
  uses {
    interface TButtonsOutputCond as TStat1ButtonsOut;
    interface TButtonsOutputCond as TStat2ButtonsOut;
  }
}

implementation {

  button_e* button_array;
  uint8_t   button_index;
  uint8_t   button_array_len;
  uint8_t   tstat;

  task void press_next () {
    button_e button;

    if (button_index >= button_array_len) {
      if (tstat == TSTAT1) {
        signal TStat1MButton.pressMultipleButtonsDone();
      } else if (tstat == TSTAT2) {
        signal TStat2MButton.pressMultipleButtonsDone();
      }
      return;
    }

    button = button_array[button_index++];

    if (tstat == TSTAT1) {
      call TStat1ButtonsOut.PressButton(button);
    } else if (tstat == TSTAT2) {
      call TStat2ButtonsOut.PressButton(button);
    }
  }

  command void TStat1MButton.pressMultipleButtons (button_e* b, uint8_t len) {
    if (len > 0) {
      button_array     = b;
      button_index     = 0;
      button_array_len = len;
      tstat            = TSTAT1;

      post press_next();
    }
  }

  command void TStat2MButton.pressMultipleButtons (button_e* b, uint8_t len) {
    if (len > 0) {
      button_array     = b;
      button_index     = 0;
      button_array_len = len;
      tstat            = TSTAT2;

      post press_next();
    }
  }

  event void TStat1ButtonsOut.PressButtonDone (button_e b) {
    post press_next();
  }

  event void TStat2ButtonsOut.PressButtonDone (button_e b) {
    post press_next();
  }

/*
  event void TStat1ButtonsOut.PressOnOffDone () { post press_next(); }
  event void TStat1ButtonsOut.PressMenuDone  () { post press_next(); }
  event void TStat1ButtonsOut.PressUpDone    () { post press_next(); }
  event void TStat1ButtonsOut.PressEscDone   () { post press_next(); }
  event void TStat1ButtonsOut.PressHelpDone  () { post press_next(); }
  event void TStat1ButtonsOut.PressDownDone  () { post press_next(); }
  event void TStat1ButtonsOut.PressEnterDone () { post press_next(); }

  event void TStat2ButtonsOut.PressOnOffDone () { post press_next(); }
  event void TStat2ButtonsOut.PressMenuDone  () { post press_next(); }
  event void TStat2ButtonsOut.PressUpDone    () { post press_next(); }
  event void TStat2ButtonsOut.PressEscDone   () { post press_next(); }
  event void TStat2ButtonsOut.PressHelpDone  () { post press_next(); }
  event void TStat2ButtonsOut.PressDownDone  () { post press_next(); }
  event void TStat2ButtonsOut.PressEnterDone () { post press_next(); }
*/

}

