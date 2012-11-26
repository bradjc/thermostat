
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

  command void TStat1MButton.PressMultipleButtons (button_e* b, uint8_t len) {
    button_e button;
    uint8_t i;

    for (i=0; i<len; i++) {
      button = b[i];
      switch (button) {
        case OnOff: call TStat1ButtonsOut.PressOnOff(); break;
        case Menu: call TStat1ButtonsOut.PressMenu(); break;
        case Up: call TStat1ButtonsOut.PressUp(); break;
        case Esc: call TStat1ButtonsOut.PressEsc(); break;
        case Help: call TStat1ButtonsOut.PressHelp(); break;
        case Down: call TStat1ButtonsOut.PressDown(); break;
        case Enter: call TStat1ButtonsOut.PressEnter(); break;
      }

    }
  }

  command void TStat2MButton.PressMultipleButtons (button_e* b, uint8_t len) {
    button_e button;
    uint8_t i;

    for (i=0; i<len; i++) {
      button = b[i];
      switch (button) {
        case OnOff: call TStat2ButtonsOut.PressOnOff(); break;
        case Menu: call TStat2ButtonsOut.PressMenu(); break;
        case Up: call TStat2ButtonsOut.PressUp(); break;
        case Esc: call TStat2ButtonsOut.PressEsc(); break;
        case Help: call TStat2ButtonsOut.PressHelp(); break;
        case Down: call TStat2ButtonsOut.PressDown(); break;
        case Enter: call TStat2ButtonsOut.PressEnter(); break;
      }

    }
  }


}

