#include "nib.h"
#include "NxpPca9575.h"

// TODO: make the detectkeypad enable work for individual keypads

module TstatGpioP {
  provides {
    interface TstatGpio;
    interface Enable as DetectKeypadInput[uint8_t tid];
    interface Init;
  }
  uses {
    interface NxpPca9575 as GpioExtenderOut;
    interface SetReply<uint16_t> as SetPins;

    interface NxpPca9575 as GpioExtenderIn;
    interface Read<uint16_t> as ReadInterrupts;

    interface HplMsp430GeneralIO as InterruptPin;
    interface HplMsp430Interrupt as InterruptInt;

    interface Timer<TMilli> as TimerPeriodicSetup;
  }
}

implementation {

  #define RESETUP_PERIOD 61440U

  // track which banks of gpio inputs should trigger interrupts
  bool tstat_int_enabled[NUMBER_OF_THERMOSTATS] = {FALSE};

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
    call InterruptInt.disable();

    call TimerPeriodicSetup.startPeriodic(RESETUP_PERIOD);
    return SUCCESS;
  }

  event void TimerPeriodicSetup.fired () {
    call GpioExtenderOut.setup(&i2c_extender_config_out);
    call GpioExtenderIn.setup(&i2c_extender_config_in);
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

  button_e determine_button_tstat1 (uint16_t buttons) {
    if (buttons & TSTAT1_BUTTON_ONOFF) {
      return OnOff;
    } else if (buttons & TSTAT1_BUTTON_MENU) {
      return Menu;
    } else if (buttons & TSTAT1_BUTTON_UP) {
      return Up;
    } else if (buttons & TSTAT1_BUTTON_ESC) {
      return Esc;
    } else if (buttons & TSTAT1_BUTTON_HELP) {
      return Help;
    } else if (buttons & TSTAT1_BUTTON_DOWN) {
      return Down;
    } else if (buttons & TSTAT1_BUTTON_ENTER) {
      return Enter;
    }
    return 0xff;
  }

  button_e determine_button_tstat2 (uint16_t buttons) {
    if (buttons & TSTAT2_BUTTON_ONOFF) {
      return OnOff;
    } else if (buttons & TSTAT2_BUTTON_MENU) {
      return Menu;
    } else if (buttons & TSTAT2_BUTTON_UP) {
      return Up;
    } else if (buttons & TSTAT2_BUTTON_ESC) {
      return Esc;
    } else if (buttons & TSTAT2_BUTTON_HELP) {
      return Help;
    } else if (buttons & TSTAT2_BUTTON_DOWN) {
      return Down;
    } else if (buttons & TSTAT2_BUTTON_ENTER) {
      return Enter;
    }
    return 0xff;
  }

  event void ReadInterrupts.readDone (error_t e, uint16_t tstat_buttons) {

    button_e b;
    // only signal 1 button was pressed at a time
    bool signaled = FALSE;

    if (tstat_int_enabled[0] == TRUE) {
      b = determine_button_tstat1(tstat_buttons);
      if (b != 0xff) {
        signal TstatGpio.buttonPressed(b, TSTAT1);
        signaled = TRUE;
      }
    }

    if (!signaled && tstat_int_enabled[1] == TRUE) {
      b = determine_button_tstat2(tstat_buttons);
      if (b != 0xff) {
        signal TstatGpio.buttonPressed(b, TSTAT2);
        signaled = TRUE;
      }
    }

    // Clear the interrupt at this point to minimize the chance of another
    //  interrupt while processing which button was pressed
    call InterruptInt.clear();
    call InterruptInt.enable();
  }

  command void DetectKeypadInput.enable[uint8_t tid] () {
    tstat_int_enabled[tid - 1] = TRUE;
    call InterruptInt.enable();
  }

  command void DetectKeypadInput.disable[uint8_t tid] () {
    uint8_t i;

    tstat_int_enabled[tid - 1] = FALSE;

    // loop through all tstats and find if any banks want the interrupt enabled
    for (i=0; i<NUMBER_OF_THERMOSTATS; i++) {
      if (tstat_int_enabled[i] == TRUE) {
        return;
      }
    }

    call InterruptInt.disable();
  }

  default event void TstatGpio.buttonPressed (button_e b, thermostat_e tid) {}
  default event void TstatGpio.buttonDone () {}

}
