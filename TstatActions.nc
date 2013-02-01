
/* Interface for top level actions on the thermostat.
 * This is not completed yet, but will be expanded as necessary.
 */

interface TstatActions {
	command void setTemperature (uint8_t temp);
	command void turnOn ();
	command void turnOff ();

	event void actionDone ();
}
