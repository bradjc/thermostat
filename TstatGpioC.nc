
// This layer sits above the GPIO extender module. It is essentially a HAL.
// This module provides the general setOutputButtons function that the generic
// thermostat modules call to set the output buttons. This module handles the
// bit combining of multiple thermostat upper layers setting the same 16 bit
// output register.

// If you wanted to add more physical thermostats and GPIO extenders, here is
// where you would add them.


configuration TstatGpioC {
  provides {
    interface TstatGpio;
    interface Init;
  }
}

implementation {
  components TstatGpioP;

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

  // Connection to I2C GPIO Extender chip
  TstatGpioP.GpioExtender -> I2cExtender.GpioExtender;
  TstatGpioP.SetPins      -> I2cExtender.SetPins;

  // External interfaces
  Init           = TstatGpioP.Init;
  ThermostatGpio = TstatGpioP.ThermostatGpio;
}
