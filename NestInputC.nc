/* Module that wires to the NEST thermostat. Provides events when the nest
 * turns on or off each HVAC circuit.
 */

configuration NestInputC {
  provides {
    interface NestInput;
  }
}

implementation {
  components NestInputP;
  components MainC;

  NestInputP.Init <- MainC;

  components HplMsp430InterruptC as Interrupt;
  components HplMsp430GeneralIOC as GpIO;

  NestInputP.NestFan      -> GpIO.Port15;
  NestInputP.NestCooling1 -> GpIO.Port16;
  NestInputP.NestCooling2 -> GpIO.Port23;
  NestInputP.NestHeating1 -> GpIO.Port17;
  NestInputP.NestHeating2 -> GpIO.Port26;
  NestInputP.NestStar     -> GpIO.Port21;

  NestInputP.NestFanIRQ      -> Interrupt.Port15;
  NestInputP.NestCooling1IRQ -> Interrupt.Port16;
  NestInputP.NestCooling2IRQ -> Interrupt.Port23;
  NestInputP.NestHeating1IRQ -> Interrupt.Port17;
  NestInputP.NestHeating2IRQ -> Interrupt.Port26;
  NestInputP.NestStarIRQ     -> Interrupt.Port21;

  NestInput = NestInputP.NestInput;

}
