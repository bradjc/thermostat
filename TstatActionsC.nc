
#include "nib.h"

generic configuration ThermostatActionsC (thermostat_e tid) {
  provides {
    interface TstatActions;
  }
}

implementation {
  components new TstatActionsP(tid);

  components new TstatMultiButtonC(tid) as MButton;
  TstatActionsP.MultiButton -> MButton.TstatMultiButton;
}

