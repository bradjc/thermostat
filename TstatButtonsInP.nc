#include "nib.h"

generic module TstatButtonsInP (thermostat_e tid) {
  provides{
    interface TstatButtonsIn;
  }
  uses {
    interface TstatGpio;
  }
}

implementation {

  event void TstatGpio.buttonPressed (button_e b, thermostat_e bp_tid) {
    // Check if the button pressed happened on the same thermostat.
    if (bp_tid == tid) {
      switch (b) {
        case OnOff: signal TstatButtonsIn.OnOffPressed(); break;
        case Menu:  signal TstatButtonsIn.MenuPressed(); break;
        case Up:    signal TstatButtonsIn.UpPressed(); break;
        case Esc:   signal TstatButtonsIn.EscPressed(); break;
        case Help:  signal TstatButtonsIn.HelpPressed(); break;
        case Down:  signal TstatButtonsIn.DownPressed(); break;
        case Enter: signal TstatButtonsIn.EnterPressed(); break;
      }
    }
  }

}
