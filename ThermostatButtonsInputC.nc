
#include "nib.h"

configuration ThermostatButtonsInputC {
  provides {
    interface ThermostatButtonsInput as TStat1Buttons;
    interface ThermostatButtonsInput as TStat2Buttons;
    interface Init;
  }
}

implementation {
  components ThermostatButtonsInputP;

  components new NxpPca9575C(PCA9575_GPIO_IN_ADDR) as I2cExtenderIn;

  // I2C Bus
  components new Msp430I2CC();
  I2cExtenderIn.I2CPacket -> Msp430I2CC.I2CBasicAddr;
  I2cExtenderIn.I2CResource -> Msp430I2CC.Resource;

  // GPIO for reset and interrupt line
  components HplMsp430InterruptC as Interrupt;
  components HplMsp430GeneralIOC as GpIO;

  components new Msp430GpioC() as MspGpioPort50;
  MspGpioPort50.HplGeneralIO -> GpIO.Port50;

  I2cExtenderIn.ExtenderReset -> MspGpioPort50.GeneralIO;

  ThermostatButtonsInputP.InterruptPin -> GpIO.Port27;
  ThermostatButtonsInputP.InterruptInt -> Interrupt.Port27;

  // Connection to I2C GPIO Extender chip
  ThermostatButtonsInputP.GpioExtender -> I2cExtenderIn.GpioExtender;
  ThermostatButtonsInputP.ReadInterrupts -> I2cExtenderIn.ReadInterrupts;

  // External interfaces
  Init          = ThermostatButtonsInputP.Init;
  TStat1Buttons = ThermostatButtonsInputP.TStat1Buttons;
  TStat2Buttons = ThermostatButtonsInputP.TStat2Buttons;


}

