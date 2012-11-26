#include "NxpPca9575.h"
#include "nib.h"

module ThermostatButtonsOutputP {
  provides {
    interface ThermostatButtonsOutput as TStat1Buttons;
    interface ThermostatButtonsOutput as TStat2Buttons;
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

  typedef enum {
    OnOff1,
    Menu1,
    Up1,
    Esc1,
    Help1,
    Down1,
    Enter1,
    OnOff2,
    Menu,
    Up2,
    Esc2,
    Help2,
    Down2,
    Enter,
  } button_e;

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
  button_e    button_pressed;

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
        switch (button_pressed) {
          case OnOff1: signal TStat1Buttons.PressOnOffDone(); break;
          case Menu1:  signal TStat1Buttons.PressMenuDone(); break;
          case Up1:    signal TStat1Buttons.PressUpDone(); break;
          case Esc1:   signal TStat1Buttons.PressEscDone(); break;
          case Help1:  signal TStat1Buttons.PressHelpDone(); break;
          case Down1:  signal TStat1Buttons.PressDownDone(); break;
          case Enter1: signal TStat1Buttons.PressEnterDone(); break;
          case OnOff2: signal TStat2Buttons.PressOnOffDone(); break;
          case Menu2:  signal TStat2Buttons.PressMenuDone(); break;
          case Up2:    signal TStat2Buttons.PressUpDone(); break;
          case Esc2:   signal TStat2Buttons.PressEscDone(); break;
          case Help2:  signal TStat2Buttons.PressHelpDone(); break;
          case Down2:  signal TStat2Buttons.PressDownDone(); break;
          case Enter2: signal TStat2Buttons.PressEnterDone(); break;
        }
        break;
    }
  }

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
 //   call GpioExtender.set_address(PCA9575_GPIO_OUT_ADDR);
    call GpioExtender.setup(&i2c_extender_config);
    return SUCCESS;
  }

  command void TStat1Buttons.PressOnOff () {
    button_pressed = OnOff1;
    press_button(TSTAT1_BUTTON_ONOFF);
  }

  command void TStat1Buttons.PressMenu () {
    button_pressed = Menu1;
    press_button(TSTAT1_BUTTON_MENU);
  }

  command void TStat1Buttons.PressUp () {
    button_pressed = Up1;
    press_button(TSTAT1_BUTTON_UP);
  }

  command void TStat1Buttons.PressEsc () {
    button_pressed = Esc1;
    press_button(TSTAT1_BUTTON_ESC);
  }

  command void TStat1Buttons.PressHelp () {
    button_pressed = Help1;
    press_button(TSTAT1_BUTTON_HELP);
  }

  command void TStat1Buttons.PressDown () {
    button_pressed = Down1;
    press_button(TSTAT1_BUTTON_DOWN);
  }

  command void TStat1Buttons.PressEnter () {
    button_pressed = Enter1;
    press_button(TSTAT1_BUTTON_ENTER);
  }

  command void TStat2Buttons.PressOnOff () {
    button_pressed = OnOff2;
    press_button(TSTAT2_BUTTON_ONOFF);
  }

  command void TStat2Buttons.PressMenu () {
    button_pressed = Menu2;
    press_button(TSTAT2_BUTTON_MENU);
  }

  command void TStat2Buttons.PressUp () {
    button_pressed = Up2;
    press_button(TSTAT2_BUTTON_UP);
  }

  command void TStat2Buttons.PressEsc () {
    button_pressed = Esc2;
    press_button(TSTAT2_BUTTON_ESC);
  }

  command void TStat2Buttons.PressHelp () {
    button_pressed = Help2;
    press_button(TSTAT2_BUTTON_HELP);
  }

  command void TStat2Buttons.PressDown () {
    button_pressed = Down2;
    press_button(TSTAT2_BUTTON_DOWN);
  }

  command void TStat2Buttons.PressEnter () {
    button_pressed = Enter2;
    press_button(TSTAT2_BUTTON_ENTER);
  }

}

