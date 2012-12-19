
#include "nib.h"

generic module TstatActionsP (thermostat_e tid) {
  provides {
    interface TstatActions;
  }
  uses {
    interface TstatMultiButton;
  }
}

implementation {

  button_e turn_on[]   = {OnOff};
  button_e set_temp1[] = {Menu, Enter, Enter};
  button_e escapes[]   = {Esc, Esc, Esc, Esc, Esc, Esc, Esc, Esc, Esc, Esc};
  button_e password[]  = {Up, Enter, Up, Up, Enter, Up, Up, Up, Enter, Enter};
  button_e set_temp2[20];

  uint8_t current_temperature;
  uint8_t desired_temperature;

  typedef enum {
    SET_TEMP1,
    SET_TEMP2,
    SET_TEMP3,
    SET_TEMP4,
    SET_TEMP5,
    GOTO_MAIN_MENU1,
    GOTO_MAIN_MENU2,
    ENTER_PASSWORD1,
    ENTER_PASSWORD2,
    DONE,
  } action_state_e;


  action_state_e state;
  // the state to go back to when running a "subroutine" event series
  action_state_e ret_state;

  task void action_next () {

    switch (state) {
      case SET_TEMP1:
        state     = GOTO_MAIN_MENU1;
        ret_state = SET_TEMP2;
        // start by getting to a known state
        post action_next();
        break;

      case SET_TEMP2:
        state = SET_TEMP3;
        // navigate first menu until possible password prompt
        call TstatMultiButton.pressMultipleButtons(set_temp1, 3);
        break;

      case SET_TEMP3:
        // enter the password
        // if no password needed the ENTER_PASSWORD part will detect that
        state = ENTER_PASSWORD1;
        ret_state = SET_TEMP4;
        post action_next();
        break;

      case SET_TEMP4:
        // get the current temperature so we know how much to adjust it
        state = SET_TEMP5;
//        call TstatStatus.getTemperature();
post action_next();
        break;

      case SET_TEMP5:
        state = DONE;
        // now actually set the temperature
        {
          uint8_t diff;
          uint8_t up_down = 0;
          uint8_t i;
          current_temperature = 70;
          if (desired_temperature > current_temperature) {
            diff    = desired_temperature - current_temperature;
            up_down = 1;
          } else if (current_temperature > desired_temperature) {
            diff    = current_temperature - desired_temperature;
            up_down = 0;
          } else {
            diff = 0;
          }

          if (diff > 17) {
            // limit the max temp swing to 18 degrees to prevent buff overflow
            diff = 17;
          }
          for (i=0; i<diff; i++) {
            set_temp2[i] = (up_down) ? Up : Down;
          }
          set_temp2[diff]   = Enter;
          set_temp2[diff+1] = Menu;
          set_temp2[diff+2] = Esc;

          call TstatMultiButton.pressMultipleButtons(set_temp2, diff+3);
        }
        break;


      case GOTO_MAIN_MENU1:
        state = GOTO_MAIN_MENU2;
        // get on/off state
  //    call TstatStatus.getStatus(statusType_Power)
post action_next();
        break;

      case GOTO_MAIN_MENU2:
        // Check if the unit is on. If so, we are at the main menu, if not,
        // hit escape a bunch of times
        state = ret_state;
//        if (tstat_status == status_On) {
          // If we are on, just hammer the escape button to get back to the
          // home screen.
//          call TstatMultiButton.pressMultipleButtons(escapes, 10);
//        } else {
          // Turning the unit on automatically resets it to the home screen
//          call TstatMultiButton.pressMultipleButtons(turn_on, 1);
//        }
post action_next();
        break;

      case ENTER_PASSWORD1:
        state = ENTER_PASSWORD2;
        // get current screen
  //    call TstatStatus.getCurrentDisplay()
post action_next();
        break;

      case ENTER_PASSWORD2:
        state = ret_state;
//        if (current_display == lcd_password) {
//          call TstatMultiButton.pressMultipleButtons(password, 10);
//        } else {
//          post action_next();
//        }
post action_next();
        break;

      case DONE:
        signal TstatActions.actionDone();
        break;
    }
  }


  event void TstatMultiButton.pressMultipleButtonsDone () {
    post action_next();
  }

//  event void TstatStatus.status (tstatus_e stat, uint8_t result) {
//    tstat_status = result;
//    post action_next();
//  }

//  event void TstatStatus.getTemperatureDone (uint8_t temp) {
//    current_temperature = temp;
//  }


  command void TstatActions.setTemperature (uint8_t temp) {
    desired_temperature = temp;
    state = SET_TEMP1;
    post action_next();
  }

}

