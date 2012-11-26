#include "NxpPca9575.h"
#include "nib.h"

module ThermostatButtonsInputP {
  provides {
    interface ThermostatButtonsInput as TStat1Buttons;
    interface ThermostatButtonsInput as TStat2Buttons;
    interface Init;
  }
  uses {
    interface NxpPca9575 as GpioExtender;
    interface Read<uint16_t> as ReadInterrupts;
    interface HplMsp430GeneralIO as InterruptPin;
    interface HplMsp430Interrupt as InterruptInt;
  }
}

implementation {

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

  task void read_interrupts () {

    call ReadInterrupts.read();
  }

  command error_t Init.init () {
   // call GpioExtender.set_address(PCA9575_GPIO_IN_ADDR);
    call GpioExtender.setup(&i2c_extender_config_in);
    call InterruptPin.selectIOFunc();
    call InterruptPin.makeInput();
    call InterruptInt.edge(FALSE); // falling edge interrupt
    call InterruptInt.clear();
    call InterruptInt.enable();
    return SUCCESS;
  }

  async event void InterruptInt.fired () {
    call InterruptInt.disable();

    // read the interrupt vector to find which button was pressed
    post read_interrupts();
  }

  event void ReadInterrupts.readDone (error_t e, uint16_t tstat_buttons) {

    if (tstat_buttons & TSTAT1_BUTTON_ONOFF) {
      signal TStat1Buttons.OnOffPressed();
    } else if (tstat_buttons & TSTAT1_BUTTON_MENU) {
      signal TStat1Buttons.MenuPressed();
    } else if (tstat_buttons & TSTAT1_BUTTON_UP) {
      signal TStat1Buttons.UpPressed();
    } else if (tstat_buttons & TSTAT1_BUTTON_ESC) {
      signal TStat1Buttons.EscPressed();
    } else if (tstat_buttons & TSTAT1_BUTTON_HELP) {
      signal TStat1Buttons.HelpPressed();
    } else if (tstat_buttons & TSTAT1_BUTTON_DOWN) {
      signal TStat1Buttons.DownPressed();
    } else if (tstat_buttons & TSTAT1_BUTTON_ENTER) {
      signal TStat1Buttons.EnterPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_ONOFF) {
      signal TStat2Buttons.OnOffPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_MENU) {
      signal TStat2Buttons.MenuPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_UP) {
      signal TStat2Buttons.UpPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_ESC) {
      signal TStat2Buttons.EscPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_HELP) {
      signal TStat2Buttons.HelpPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_DOWN) {
      signal TStat2Buttons.DownPressed();
    } else if (tstat_buttons & TSTAT2_BUTTON_ENTER) {
      signal TStat2Buttons.EnterPressed();
    }

    // Clear the interrupt at this point to minimize the chance of another
    //  interrupt while processing which button was pressed
    call InterruptInt.clear();
    call InterruptInt.enable();

  }

  default async event void TStat1Buttons.OnOffPressed () {}
  default async event void TStat1Buttons.MenuPressed () {}
  default async event void TStat1Buttons.UpPressed () {}
  default async event void TStat1Buttons.EscPressed () {}
  default async event void TStat1Buttons.HelpPressed () {}
  default async event void TStat1Buttons.DownPressed () {}
  default async event void TStat1Buttons.EnterPressed () {}
  default async event void TStat2Buttons.OnOffPressed () {}
  default async event void TStat2Buttons.MenuPressed () {}
  default async event void TStat2Buttons.UpPressed () {}
  default async event void TStat2Buttons.EscPressed () {}
  default async event void TStat2Buttons.HelpPressed () {}
  default async event void TStat2Buttons.DownPressed () {}
  default async event void TStat2Buttons.EnterPressed () {}


}

