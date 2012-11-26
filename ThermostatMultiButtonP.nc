
module ThermostatMultiButtonP {
  provides {
    interface ThermostatMultiButton as TStat1MButton;
    interface ThermostatMultiButton as TStat2MButton;
  }
  uses {
    interface ThermostatButtonsOutput as TStat1ButtonsOut;
    interface ThermostatButtonsOutput as TStat2ButtonsOut;
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
      if (tstat == 1) {
        signal TStat1MButton.pressMultipleButtonsDone();
      } else if (tstat == 2) {
        signal TStat2MButton.pressMultipleButtonsDone();
      }
      return;
    }

    button = button_array[button_index++];

    if (tstat == 1) {
      switch (button) {
        case OnOff: call TStat1ButtonsOut.PressOnOff(); break;
        case Menu:  call TStat1ButtonsOut.PressMenu(); break;
        case Up:    call TStat1ButtonsOut.PressUp(); break;
        case Esc:   call TStat1ButtonsOut.PressEsc(); break;
        case Help:  call TStat1ButtonsOut.PressHelp(); break;
        case Down:  call TStat1ButtonsOut.PressDown(); break;
        case Enter: call TStat1ButtonsOut.PressEnter(); break;
      }
    } else if (tstat == 2) {
      switch (button) {
        case OnOff: call TStat2ButtonsOut.PressOnOff(); break;
        case Menu:  call TStat2ButtonsOut.PressMenu(); break;
        case Up:    call TStat2ButtonsOut.PressUp(); break;
        case Esc:   call TStat2ButtonsOut.PressEsc(); break;
        case Help:  call TStat2ButtonsOut.PressHelp(); break;
        case Down:  call TStat2ButtonsOut.PressDown(); break;
        case Enter: call TStat2ButtonsOut.PressEnter(); break;
      }
    }
  }

  command void TStat1MButton.pressMultipleButtons (button_e* b, uint8_t len) {
    if (len > 0) {
      button_array     = b;
      button_index     = 0;
      button_array_len = len;
      tstat            = 1;

      post press_next();
    }
  }

  command void TStat2MButton.pressMultipleButtons (button_e* b, uint8_t len) {
    if (len > 0) {
      button_array     = b;
      button_index     = 0;
      button_array_len = len;
      tstat            = 2;

      post press_next();
    }
  }

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


}

