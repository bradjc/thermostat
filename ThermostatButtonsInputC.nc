
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

  components new Msp430I2CC();
  I2cExtenderIn.I2CPacket -> Msp430I2CC.I2CBasicAddr;
  I2cExtenderIn.I2CResource -> Msp430I2CC.Resource;

  components HplMsp430InterruptC as Interrupt;
  components HplMsp430GeneralIOC as GpIO;

  components new Msp430GpioC() as MspGpioPort50;
  MspGpioPort50.HplGeneralIO -> GpIO.Port50;

  I2cExtenderIn.ExtenderReset -> MspGpioPort50.GeneralIO;

  ThermostatButtonsInputP.GpioExtender -> I2cExtenderIn.GpioExtender;
  ThermostatButtonsInputP.ReadInterrupts -> I2cExtenderIn.ReadInterrupts;
  ThermostatButtonsInputP.InterruptPin -> GpIO.Port27;
  ThermostatButtonsInputP.InterruptInt -> Interrupt.Port27;

  Init          = ThermostatButtonsInputP.Init;
  TStat1Buttons = ThermostatButtonsInputP.TStat1Buttons;
  TStat2Buttons = ThermostatButtonsInputP.TStat2Buttons;



/*
  components new NxpPca9575C() as I2cExtenderIn2;

  components new Msp430I2CC() as mspi2c;
  I2cExtenderIn2.I2CPacket -> mspi2c.I2CBasicAddr;
  I2cExtenderIn2.I2CResource -> mspi2c.Resource;

  components HplMsp430InterruptC as Interrupt2;
  components HplMsp430GeneralIOC as GpIO2;

  components new Msp430GpioC() as MspGpioPort51;
  MspGpioPort51.HplGeneralIO -> GpIO2.Port51;

  I2cExtenderIn2.ExtenderReset -> MspGpioPort51.GeneralIO;
*/



//  ThermostatButtonsInputP.GpioExtender -> I2cExtenderIn.GpioExtender;
//  ThermostatButtonsInputP.ReadInterrupts -> I2cExtenderIn.ReadInterrupts;
//  ThermostatButtonsInputP.InterruptPin -> GpIO.Port27;
//  ThermostatButtonsInputP.InterruptInt -> Interrupt.Port27;

//  Init          = ThermostatButtonsInputP.Init;
//  TStat1Buttons = ThermostatButtonsInputP.TStat1Buttons;
//  TStat2Buttons = ThermostatButtonsInputP.TStat2Buttons;




}

