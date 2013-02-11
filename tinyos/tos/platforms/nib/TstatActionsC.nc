#include "nib.h"

/* Generic module for performing interesting actions on a given thermostat.
 * Wire to this to do top level things like set the temperature or turn the
 * unit on and off.
 */

generic configuration TstatActionsC (thermostat_e tid) {
  provides {
    interface TstatActions;
  }
}

implementation {
  components new TstatActionsP(tid);

  components new TstatMultiButtonC(tid) as MButton;
  TstatActionsP.TstatMultiButton -> MButton.TstatMultiButton;

  components new TstatStateC();
  TstatActionsP.TstatState -> TstatStateC.LcdSniffer;

  TstatActions = TstatActionsP.TstatActions;
}
