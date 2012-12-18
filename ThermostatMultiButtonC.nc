

configuration ThermostatMultiButtonC {
  provides {
    interface ThermostatMultiButton as TStat1MButton;
    interface ThermostatMultiButton as TStat2MButton;
  }
}

implementation {
  components ThermostatMultiButtonP;

  components TButtonsOutputCondC as ButtonsOut;
  ThermostatMultiButtonP.TStat1ButtonsOut -> ButtonsOut.TStat1Buttons;
  ThermostatMultiButtonP.TStat2ButtonsOut -> ButtonsOut.TStat2Buttons;

  TStat1MButton = ThermostatMultiButtonP.TStat1MButton;
  TStat2MButton = ThermostatMultiButtonP.TStat2MButton;

}

