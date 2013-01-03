#include "nib.h"
#include "NxpPca9575.h"

// TODO: make the detectkeypad enable work for individual keypads

module TstatGpioP {
  provides {
    interface TstatGpio;
    interface Enable as DetectKeypadInput;
    interface Init;
  }
  uses {
    interface NxpPca9575 as GpioExtenderOut;
    interface SetReply<uint16_t> as SetPins;

    interface NxpPca9575 as GpioExtenderIn;
    interface Read<uint16_t> as ReadInterrupts;
  }
}

implementation {

  // bitfield of the values on the gpio extender module
  uint16_t gpio_pins = 0;

  // init for the output gpio extender
  nxppca9575_config_t i2c_extender_config_out = {
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

  nxppca9575_config_t i2c_extender_config_in = {
    0x00, // REG2, polarity inversion port 0 register, no inversion
    0x00, // REG3, polarity inversion port 1 register, no inversion
    0x02, // REG4, pullup/pulldown bank 0, allow pull up/down to be enabled
    0x02, // REG5, pullup/pulldown bank 1, allow pull up/down to be enabled
    0x00, // REG6, enable pull up/down bank 0, enable pull downs
    0x00, // REG7, enable pull up/down bank 0, enable pull downs
    0xFF, // REG8, set pin direction bank 0, set all pins as inputs
    0xFF, // REG9, set pin direction bank 1, set all pins as inputs
    0x80, // REG12, interrupt mask bank 0, enable all 7 input pins as interrupt
    0x80, // REG13, interrupt mask bank 1, enable all 7 input pins as interrupt
  };

  event void SetPins.setDone () {
    signal TstatGpio.buttonDone();
  }

  command error_t Init.init () {
    call GpioExtenderOut.setup(&i2c_extender_config_out);

    call GpioExtenderIn.setup(&i2c_extender_config_in);
    call InterruptPin.selectIOFunc();
    call InterruptPin.makeInput();
    call InterruptInt.edge(FALSE); // falling edge interrupt
    call InterruptInt.clear();
    call InterruptInt.enable();
    return SUCCESS;
  }

  //
  // Output
  //

  command void TstatGpio.setButton (button_e b, thermostat_e tid) {
    uint16_t pins = 0;

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

  //
  // Input
  //

  // read the interrupt vector to find which button was pressed
  task void read_interrupts () {
    call ReadInterrupts.read();
  }

  async event void InterruptInt.fired () {
    call InterruptInt.disable();
    post read_interrupts();
  }

  event void ReadInterrupts.readDone (error_t e, uint16_t tstat_buttons) {

    if (tstat_buttons & TSTAT1_BUTTON_ONOFF) {
      signal TstatGpio.buttonPressed(OnOff, TSTAT1);
    } else if (tstat_buttons & TSTAT1_BUTTON_MENU) {
      signal TstatGpio.buttonPressed(Menu, TSTAT1);
    } else if (tstat_buttons & TSTAT1_BUTTON_UP) {
      signal TstatGpio.buttonPressed(Up, TSTAT1);
    } else if (tstat_buttons & TSTAT1_BUTTON_ESC) {
      signal TstatGpio.buttonPressed(Esc, TSTAT1);
    } else if (tstat_buttons & TSTAT1_BUTTON_HELP) {
      signal TstatGpio.buttonPressed(Help, TSTAT1);
    } else if (tstat_buttons & TSTAT1_BUTTON_DOWN) {
      signal TstatGpio.buttonPressed(Down, TSTAT1);
    } else if (tstat_buttons & TSTAT1_BUTTON_ENTER) {
      signal TstatGpio.buttonPressed(Enter, TSTAT1);
    } else if (tstat_buttons & TSTAT2_BUTTON_ONOFF) {
      signal TstatGpio.buttonPressed(OnOff, TSTAT2);
    } else if (tstat_buttons & TSTAT2_BUTTON_MENU) {
      signal TstatGpio.buttonPressed(Menu, TSTAT2);
    } else if (tstat_buttons & TSTAT2_BUTTON_UP) {
      signal TstatGpio.buttonPressed(Up, TSTAT2);
    } else if (tstat_buttons & TSTAT2_BUTTON_ESC) {
      signal TstatGpio.buttonPressed(Esc, TSTAT2);
    } else if (tstat_buttons & TSTAT2_BUTTON_HELP) {
      signal TstatGpio.buttonPressed(Help, TSTAT2);
    } else if (tstat_buttons & TSTAT2_BUTTON_DOWN) {
      signal TstatGpio.buttonPressed(Down, TSTAT2);
    } else if (tstat_buttons & TSTAT2_BUTTON_ENTER) {
      signal TstatGpio.buttonPressed(Enter, TSTAT2);
    }

    // Clear the interrupt at this point to minimize the chance of another
    //  interrupt while processing which button was pressed
    call InterruptInt.clear();
    call InterruptInt.enable();
  }

  command void DetectKeypadInput.enable () {
    call InterruptInt.enable();
  }

  command void DetectKeypadInput.disable () {
    call InterruptInt.disable();
  }

}
