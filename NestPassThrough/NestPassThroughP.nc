#include "nib.h"


module NestPassThroughP {
  uses {
    interface Leds;
    interface Boot;

    interface Enable as Keypad;
  }
}

implementation {

  event void Boot.booted () {
    atomic {

      call Leds.led2On();

      // All we have to do for this application is set the control line for
      // the analog switches low. This causes the keypad buttons to be passed
      // through and work like they always have.

      // Disable the keypad
      call Keypad.enable();

    }
  }

}
