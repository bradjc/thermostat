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
    interface Set<uint16_t> as SetPins;
    interface Timer<TMilli> as TimerButtonPress;
  }
}

implementation {

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

  void press_button (uint16_t pins) {
    call SetPins.set(pins);
    call TimerButtonPress.startOneShot(BUTTON_PRESS_DURATION);
  }

  event void TimerButtonPress.fired () {
    // After a period of time, clear the output again.
    // This simulates a button press.
    call SetPins.set(0);
  }

  command error_t Init.init () {
 //   call GpioExtender.set_address(PCA9575_GPIO_OUT_ADDR);
    call GpioExtender.setup(&i2c_extender_config);
    return SUCCESS;
  }

  command void TStat1Buttons.PressOnOff () {
    press_button(TSTAT1_BUTTON_ONOFF);
  }

  command void TStat1Buttons.PressMenu () {
    press_button(TSTAT1_BUTTON_MENU);
  }

  command void TStat1Buttons.PressUp () {
    press_button(TSTAT1_BUTTON_UP);
  }

  command void TStat1Buttons.PressEsc () {
    press_button(TSTAT1_BUTTON_ESC);
  }

  command void TStat1Buttons.PressHelp () {
    press_button(TSTAT1_BUTTON_HELP);
  }

  command void TStat1Buttons.PressDown () {
    press_button(TSTAT1_BUTTON_DOWN);
  }

  command void TStat1Buttons.PressEnter () {
    press_button(TSTAT1_BUTTON_ENTER);
  }

  command void TStat2Buttons.PressOnOff () {
    press_button(TSTAT2_BUTTON_ONOFF);
  }

  command void TStat2Buttons.PressMenu () {
    press_button(TSTAT2_BUTTON_MENU);
  }

  command void TStat2Buttons.PressUp () {
    press_button(TSTAT2_BUTTON_UP);
  }

  command void TStat2Buttons.PressEsc () {
    press_button(TSTAT2_BUTTON_ESC);
  }

  command void TStat2Buttons.PressHelp () {
    press_button(TSTAT2_BUTTON_HELP);
  }

  command void TStat2Buttons.PressDown () {
    press_button(TSTAT2_BUTTON_DOWN);
  }

  command void TStat2Buttons.PressEnter () {
    press_button(TSTAT2_BUTTON_ENTER);
  }

}

