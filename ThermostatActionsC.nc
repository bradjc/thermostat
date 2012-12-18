


configuration ThermostatActionsC {
  provides {
    interface ThermostatActions as TActions;
  }
}

implementation {
  components ThermostatActionsP;

  components ThermostatMultiButtonC as MButton;
  ThermostatActionsP.MultiButton -> MButton.TStatMButton;
}

