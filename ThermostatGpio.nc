
interface ThermostatGpio {
  command setButton (button_e b, thermostat_e tid);
  command clearButtons (uint8_t thermostat_e);

  event void buttonDone ();
}

