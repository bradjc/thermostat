
#include "nib.h"

configuration ThermostatButtonsOutputC {
  provides {
    interface ThermostatButtonsOutput as TStat1Buttons;
    interface ThermostatButtonsOutput as TStat2Buttons;
    interface Init;
  }
}

implementation {
  components ThermostatButtonsOutputP;

  components new NxpPca9575C(PCA9575_GPIO_OUT_ADDR) as I2cExtender;

  // I2C Bus
  components new Msp430I2CC();
  I2cExtender.I2CPacket -> Msp430I2CC.I2CBasicAddr;
  I2cExtender.I2CResource -> Msp430I2CC.Resource;

  // GPIO for reset line
  components HplMsp430GeneralIOC as GpIO;
  components new Msp430GpioC() as MspGpioPort51;
  MspGpioPort51.HplGeneralIO -> GpIO.Port51;
  I2cExtender.ExtenderReset -> MspGpioPort51.GeneralIO;

  // Button Press Timer
  components new TimerMilliC() as TimerButtonPress;
  ThermostatButtonsOutputP.TimerButtonPress -> TimerButtonPress;

  // Connection to I2C GPIO Extender chip
  ThermostatButtonsOutputP.GpioExtender -> I2cExtender.GpioExtender;
  ThermostatButtonsOutputP.SetPins      -> I2cExtender.SetPins;

  // External interfaces
  Init          = ThermostatButtonsOutputP.Init;
  TStat1Buttons = ThermostatButtonsOutputP.TStat1Buttons;
  TStat2Buttons = ThermostatButtonsOutputP.TStat2Buttons;

}
