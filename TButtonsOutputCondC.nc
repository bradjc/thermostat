
#include "nib.h"

// Thermostat Buttons Output Condensed

configuration TButtonsOutputCondC {
  provides {
    interface TButtonsOutputCond as TStat1Buttons;
    interface TButtonsOutputCond as TStat2Buttons;
    interface Init;
  }
}

implementation {
  components TButtonsOutputCondP;

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
  TButtonsOutputCondP.TimerButtonPress -> TimerButtonPress;

  // Connection to I2C GPIO Extender chip
  TButtonsOutputCondP.GpioExtender -> I2cExtender.GpioExtender;
  TButtonsOutputCondP.SetPins      -> I2cExtender.SetPins;

  // External interfaces
  Init          = TButtonsOutputCondP.Init;
  TStat1Buttons = TButtonsOutputCondP.TStat1Buttons;
  TStat2Buttons = TButtonsOutputCondP.TStat2Buttons;

}
