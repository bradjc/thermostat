
#include "nib.h"

// Thermostat Buttons Output Condensed

generic configuration TstatButtonsOutC (thermostat_e tid) {
  provides {
    interface TstatButtonsOut;
  }
}

implementation {
  components new TstatButtonsOutP(tid);

  // Button Press Timer
  components new TimerMilliC() as TimerButtonPress;
  TstatButtonsOutP.TimerButtonPress -> TimerButtonPress;

  // Gpio Buttons
  components TstatGpioC;
  TstatButtonsOutP.TstatGpio -> TstatGpioC.TstatGpio;

  // External interfaces
  TstatButtonsOut = TstatButtonsOutP.TstatButtonsOut;

}
