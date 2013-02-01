#include "nib.h"

/* Generic top level for receiving events when buttons are pressed.
 * This is what applications should instantiate and wire to.
 */

generic configuration TstatButtonsInC (thermostat_e tid) {
  provides {
    interface TstatButtonsIn;
    interface Enable as DetectKeypadInput;
  }
}

implementation {
  components new TstatButtonsInP(tid);

  // Connect to base gpio module
  components TstatGpioC;
  TstatButtonsInP.TstatGpio -> TstatGpioC.TstatGpio;

  // Extenal interfaces
  TstatButtonsIn    = TstatButtonsInP.TstatButtonsIn;
  DetectKeypadInput = TstatGpioC.DetectKeypadInput;
}
