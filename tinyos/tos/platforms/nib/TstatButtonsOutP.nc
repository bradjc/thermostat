#include "nib.h"

// This module handles pressing a button for the correct duration of time

generic module TstatButtonsOutP (thermostat_e tid) {
  provides {
    interface TstatButtonsOut;
  }
  uses {
    interface TstatGpio;
    interface Timer<TMilli> as TimerButtonPress;
  }
}

implementation {

  typedef enum {
    SET_ST_NEW,
    SET_ST_CLEAR,
    SET_ST_WAIT,
    SET_ST_DONE,
    SET_ST_NULL,
  } set_state_e;

  set_state_e set_state = SET_ST_NULL;
  button_e    button_pressed; // which button

  task void next_set () {
    switch (set_state) {
      case SET_ST_NEW:
        call TimerButtonPress.startOneShot(BUTTON_PRESS_DURATION);
        set_state = SET_ST_CLEAR;
        break;

      case SET_ST_CLEAR:
        // After a period of time, clear the output again.
        // This simulates a button press.
        call TstatGpio.clearButtons(tid);
        set_state = SET_ST_WAIT;
        break;

      case SET_ST_WAIT:
        // Pause after pressing a button
        call TimerButtonPress.startOneShot(BUTTON_WAIT_DURATION);
        set_state = SET_ST_DONE;
        break;

      case SET_ST_DONE:
        set_state = SET_ST_NULL;
        signal TstatButtonsOut.pressButtonDone(button_pressed);
        break;

      case SET_ST_NULL:
        break;
    }
  }

  event void TimerButtonPress.fired () {
    post next_set();
  }

  event void TstatGpio.buttonDone () {
    post next_set();
  }

  command void TstatButtonsOut.pressButton (button_e b) {
    button_pressed = b;
    set_state      = SET_ST_NEW;
    call TstatGpio.setButton(b, tid);
  }

  event void TstatGpio.buttonPressed (button_e b, thermostat_e thermid) { }

}
