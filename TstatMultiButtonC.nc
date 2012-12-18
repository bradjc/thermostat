

generic configuration TstatMultiButtonC (thermostat_e tid) {
  provides {
    interface TstatMultiButton;
  }
}

implementation {
  components new TstatMultiButtonP(tid);

  components new TstatButtonsOutC(tid) as ButtonsOut;
  TstatMultiButtonP.TstatButtonsOut -> ButtonsOut.TstatButtonsOut;

  TstatMultiButton = TstatMultiButtonP.TstatMultiButton;

}

