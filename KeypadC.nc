

configuration KeypadC {
  provides {
    interface Enable;
  }
}

implementation {
  components KeypadP;

  components HplMsp430GeneralIOC as GpIO;
  KeypadP.KeypadEnable_N -> GpIO.Port52;

  Enable = KeypadP.KeypadEnable;
}

