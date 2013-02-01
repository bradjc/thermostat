/* Generic module for pressing a sequence of buttons. Probably don't want to
 * wire directly to this, use TstatActionsC instead.
 */

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
