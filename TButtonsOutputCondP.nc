#include "NxpPca9575.h"
#include "nib.h"

module TButtonsOutputCondP {
  provides {
    interface TButtonsOutputCond as TStat1Buttons;
    interface TButtonsOutputCond as TStat2Buttons;
    interface Init;
  }
  uses {
    interface NxpPca9575 as GpioExtender;
    interface SetReply<uint16_t> as SetPins;
    interface Timer<TMilli> as TimerButtonPress;
  }
}

implementation {

  typedef enum {
    SET_ST_NEW,
    SET_ST_CLEAR,
    SET_ST_DONE,
  } set_state_e;

  nxppca9575_config_t i2c_extender_config = {
    0x00, // REG2, polarity inversion port 0 register, no inversion
    0x00, // REG3, polarity inversion port 1 register, no inversion
    0x00, // REG4, pullup/pulldown bank 0, no pull up/down
    0x00, // REG5, pullup/pulldown bank 1, no pull up/down
    0x00, // REG6, enable pull up/down bank 0, no effect
    0x00, // REG7, enable pull up/down bank 0, no effect
    0x00, // REG8, set pin direction bank 0, set all pins as outputs
    0x00, // REG9, set pin direction bank 1, set all pins as outputs
    0x00, // REG12, interrupt mask bank 0, no interrupts, all inputs
    0x00, // REG13, interrupt mask bank 1, no interrupts, all inputs
  };

  set_state_e set_state;
  uint8_t     tstat_bank;     // which thermostat the button was pressed on
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
        call SetPins.set(0);
        set_state = SET_ST_DONE;
        break;

      case SET_ST_DONE:
        if (tstat_bank == TSTAT1) {
          signal TStat1Buttons.PressButtonDone(button_pressed);
        } else if (tstat_bank == TSTAT2) {
          signal TStat2Buttons.PressButtonDone(button_pressed);
        }
        break;
    }
  }

  // Set the correct pins on the I2C gpio module to push the button
  void press_button (uint16_t pins) {
    set_state = SET_ST_NEW;
    call SetPins.set(pins);
  }

  event void SetPins.setDone () {
    post next_set();
  }

  event void TimerButtonPress.fired () {
    post next_set();
  }

  command error_t Init.init () {
    call GpioExtender.setup(&i2c_extender_config);
    return SUCCESS;
  }

  command void TStat1Buttons.PressButton (button_e b) {
    uint16_t pins;

    button_pressed = b;
    tstat_bank     = TSTAT1;

    switch (b) {
      case OnOff: pins = TSTAT1_BUTTON_ONOFF; break;
      case Menu:  pins = TSTAT1_BUTTON_MENU;  break;
      case Up:    pins = TSTAT1_BUTTON_UP;    break;
      case Esc:   pins = TSTAT1_BUTTON_ESC;   break;
      case Help:  pins = TSTAT1_BUTTON_HELP;  break;
      case Down:  pins = TSTAT1_BUTTON_DOWN;  break;
      case Enter: pins = TSTAT1_BUTTON_ENTER; break;
    }

    press_button(pins);
  }

  command void TStat2Buttons.PressButton (button_e b) {
    uint16_t pins;

    button_pressed = b;
    tstat_bank     = TSTAT2;

    switch (b) {
      case OnOff: pins = TSTAT2_BUTTON_ONOFF; break;
      case Menu:  pins = TSTAT2_BUTTON_MENU;  break;
      case Up:    pins = TSTAT2_BUTTON_UP;    break;
      case Esc:   pins = TSTAT2_BUTTON_ESC;   break;
      case Help:  pins = TSTAT2_BUTTON_HELP;  break;
      case Down:  pins = TSTAT2_BUTTON_DOWN;  break;
      case Enter: pins = TSTAT2_BUTTON_ENTER; break;
    }

    press_button(pins);
  }

}
