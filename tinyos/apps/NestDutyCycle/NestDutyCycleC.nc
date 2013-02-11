
/* Tinyos app for the nib that turns on and off the ac units as the nest directs
 * it to.
 */

configuration NestDutyCycleC { }

implementation {

  // Core, basic functionality
  components MainC;
  components NestDutyCycleP as App;
  components LedsC as Led;
  App -> MainC.Boot;
  App.Leds -> Led;

  components KeypadC;
  App.Keypad -> KeypadC.Enable;

  // Inputs from the NEST thermostat. They signal when the nest thinks heating
  //  or cooling should come on.
  components NestInputC;
  App.NestInput -> NestInputC;

//  components TstatStateC;
//  App.LcdSniffer -> TstatStateC.LcdSniffer;

  components new TstatButtonsInC(TSTAT1) as Tstat1In;
  components new TstatButtonsInC(TSTAT2) as Tstat2In;
  App.Tstat1In -> Tstat1In.TstatButtonsIn;
  App.Tstat2In -> Tstat2In.TstatButtonsIn;
  App.Tstat1InDetect -> Tstat1In.DetectKeypadInput;
  App.Tstat2InDetect -> Tstat2In.DetectKeypadInput;

  components new TstatActionsC(TSTAT1) as TstatActions1;
  App.TstatActions1 -> TstatActions1.TstatActions;

  // Radio
  components IPStackC;
  components new UdpSocketC() as UDPService;
  App.RadioControl -> IPStackC;
  App.UDP -> UDPService;

#ifdef RPL_ROUTING
  components RPLRoutingC;
#endif

#ifdef PRINTFUART_ENABLED
  components PrintfC;
  components SerialStartC;
#endif

  components LcdSnifferTestC;

}
