
#include "nib.h"

generic configuration TstatActionsC (thermostat_e tid) {
  provides {
    interface TstatActions;
  }
}

implementation {
  components new TstatActionsP(tid);

  components new TstatMultiButtonC(tid) as MButton;
  TstatActionsP.TstatMultiButton -> MButton.TstatMultiButton;

  components TstatStateC;
  TstatActionsP.TstatState -> TstatStateC;

  TstatActions = TstatActionsP.TstatActions;
}

