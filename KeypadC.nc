
/* Keypad control on the nest board.
 * This module controls whether or not the buttons on the thermostat keypad
 * should work.
 */

configuration KeypadC {
  provides {
    interface Enable;
  }
}

implementation {
  components KeypadP;
  components MainC;

  KeypadP.Init <- MainC;

  components HplMsp430GeneralIOC as GpIO;
  KeypadP.KeypadEnable_N -> GpIO.Port52;

  Enable = KeypadP.KeypadEnable;
}

