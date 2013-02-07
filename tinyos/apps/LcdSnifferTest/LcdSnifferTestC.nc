
configuration LcdSnifferTestC { }

implementation {

  // Core, basic functionality
  components MainC;
  components LcdSnifferTestP as App;
  components LedsC as Led;
  App -> MainC.Boot;
  App.Leds -> Led;

  components KeypadC;
  App.Keypad -> KeypadC.Enable;

  components new TimerMilliC() as Timer0;
  App.Timer0 -> Timer0;

  components TstatStateC;
  App.LcdSniffer -> TstatStateC.LcdSniffer;

  components TstatGpioC;

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

}
