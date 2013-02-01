

configuration NestPassThroughC { }

implementation {

  // Core, basic functionality
  components MainC;
  components NestPassThroughP;
  components LedsC as Led;
  NestPassThroughP -> MainC.Boot;
  NestPassThroughP.Leds -> Led;

  components KeypadC;
  NestPassThroughP.Keypad -> KeypadC.Enable;

}
