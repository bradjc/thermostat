#include "nib.h"
#include "NxpPca9575.h"

module TstatGpioP {
  provides {
    interface TstatGpio;
    interface Init;
  }
  uses {
    interface NxpPca9575 as GpioExtender;
    interface SetReply<uint16_t> as SetPins;
  }
}

implementation {

  // bitfield of the values on the gpio extender module
  uint16_t gpio_pins = 0;

  // init for the output gpio extender
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

  // Set the correct pins on the I2C gpio module to push the button
//  void press_buttons () {
//    set_state = SET_ST_NEW;
//    call SetPins.set(gpio_pins);
//  }

  event void SetPins.setDone () {
    signal TstatGpio.buttonDone();
  }

  command error_t Init.init () {
    call GpioExtender.setup(&i2c_extender_config);
    return SUCCESS;
  }

  command void TstatGpio.setButton (button_e b, thermostat_e tid) {
    uint16_t pins;

    if (tid == TSTAT1) {

      switch (b) {
        case OnOff: pins = TSTAT1_BUTTON_ONOFF; break;
        case Menu:  pins = TSTAT1_BUTTON_MENU;  break;
        case Up:    pins = TSTAT1_BUTTON_UP;    break;
        case Esc:   pins = TSTAT1_BUTTON_ESC;   break;
        case Help:  pins = TSTAT1_BUTTON_HELP;  break;
        case Down:  pins = TSTAT1_BUTTON_DOWN;  break;
        case Enter: pins = TSTAT1_BUTTON_ENTER; break;
      }

    } else if (tid == TSTAT2) {

      switch (b) {
        case OnOff: pins = TSTAT2_BUTTON_ONOFF; break;
        case Menu:  pins = TSTAT2_BUTTON_MENU;  break;
        case Up:    pins = TSTAT2_BUTTON_UP;    break;
        case Esc:   pins = TSTAT2_BUTTON_ESC;   break;
        case Help:  pins = TSTAT2_BUTTON_HELP;  break;
        case Down:  pins = TSTAT2_BUTTON_DOWN;  break;
        case Enter: pins = TSTAT2_BUTTON_ENTER; break;
      }
    }

    // add the button press to whatever we have going
    gpio_pins |= pins;

  //  press_buttons();
    call SetPins.set(gpio_pins);
  }

  // Clear the bits of the relevant thermostat
  command void TstatGpio.clearButtons (thermostat_e tid) {
    if (tid == TSTAT1) {
      gpio_pins &= (0xFF << 8);
    } else if (tid == TSTAT2) {
      gpio_pins &= (0xFF);
    }

    call SetPins.set(gpio_pins);
  }

}
