

interface TstatActions {
	command void setTemperature (uint8_t temp);
	command void turnOn ();
	command void turnOff ();

	event void actionDone ();
}

