
interface ThermostatGpio {
  command setButton (button_e b, uint8_t thermostat_id);
  command clearButtons (uint8_t thermostat_id);

  event void buttonDone ();
}

