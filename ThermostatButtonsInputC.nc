
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

  components new NxpPca9575C(PCA9575_GPIO_IN_ADDR) as I2cExtender;

  components new Msp430I2CC();
  I2cExtender.I2CPacket -> Msp430I2CC.I2CBasicAddr;
  I2cExtender.I2CResource -> Msp430I2CC.Resource;

  components HplMsp430InterruptC as Interrupt;
  components HplMsp430GeneralIOC as GpIO;

  components new Msp430GpioC() as MspGpioPort50;
  MspGpioPort50.HplGeneralIO -> GpIO.Port50;

  I2cExtender.ExtenderReset -> MspGpioPort50.GeneralIO;

  ThermostatButtonsInputP.GpioExtender -> I2cExtender.GpioExtender;
  ThermostatButtonsInputP.ReadInterrupts -> I2cExtender.ReadInterrupts;
  ThermostatButtonsInputP.InterruptPin -> GpIO.Port27;
  ThermostatButtonsInputP.InterruptInt -> Interrupt.Port27;

  Init          = ThermostatButtonsInputP.Init;
  TStat1Buttons = ThermostatButtonsInputP.TStat1Buttons;
  TStat2Buttons = ThermostatButtonsInputP.TStat2Buttons;




}

