/* This layer sits above the GPIO extender module. It is essentially a HAL.
 * This module provides the general setOutputButtons function that the generic
 * thermostat modules call to set the output buttons. This module handles the
 * bit combining of multiple thermostat upper layers setting the same 16 bit
 * output register.
 *
 * If you wanted to add more physical thermostats and GPIO extenders, here is
 * where you would add them.
 */

configuration TstatGpioC {
  provides {
    interface TstatGpio;
    interface Enable as DetectKeypadInput;
    interface Init;
  }
}

implementation {
  components TstatGpioP;

  components new NxpPca9575C(PCA9575_GPIO_OUT_ADDR) as I2cExtenderOut;
  components new NxpPca9575C(PCA9575_GPIO_IN_ADDR) as I2cExtenderIn;

  // I2C Bus for Output
  components new Msp430I2CC() as I2COut;
  I2cExtenderOut.I2CPacket   -> I2COut.I2CBasicAddr;
  I2cExtenderOut.I2CResource -> I2COut.Resource;

  // I2C Bus for Input
  components new Msp430I2CC() as I2CIn;
  I2cExtenderIn.I2CPacket   -> I2CIn.I2CBasicAddr;
  I2cExtenderIn.I2CResource -> I2CIn.Resource;

  // GPIO for output reset line
  components HplMsp430GeneralIOC as GpIO;
  components new Msp430GpioC() as MspGpioPort51;
  MspGpioPort51.HplGeneralIO   -> GpIO.Port51;
  I2cExtenderOut.ExtenderReset -> MspGpioPort51.GeneralIO;

  // GPIO for input reset and interrupt line
  components HplMsp430InterruptC as Interrupt;
  components new Msp430GpioC() as MspGpioPort50;
  MspGpioPort50.HplGeneralIO  -> GpIO.Port50;
  I2cExtenderIn.ExtenderReset -> MspGpioPort50.GeneralIO;
  TstatGpioP.InterruptPin     -> GpIO.Port27;
  TstatGpioP.InterruptInt     -> Interrupt.Port27;

  // Connection to I2C GPIO Extender chip out
  TstatGpioP.GpioExtenderOut -> I2cExtenderOut.GpioExtender;
  TstatGpioP.SetPins         -> I2cExtenderOut.SetPins;

  // Connection to I2C GPIO Extender chip in
  TstatGpioP.GpioExtenderIn -> I2cExtenderIn.GpioExtender;
  TstatGpioP.ReadInterrupts -> I2cExtenderIn.ReadInterrupts;

  // External interfaces
  Init              = TstatGpioP.Init;
  TstatGpio         = TstatGpioP.TstatGpio;
  DetectKeypadInput = TstatGpioP.DetectKeypadInput;
}
