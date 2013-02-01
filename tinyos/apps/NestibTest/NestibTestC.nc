

configuration NestibTestC { }

implementation {

  // Core, basic functionality
  components MainC;
  components NestibTestP;
  components LedsC as Led;
  NestibTestP -> MainC.Boot;
  NestibTestP.Leds -> Led;


//  components HplMsp430InterruptC as Interrupt;
//  components HplMsp430GeneralIOC as GpIO;
//  NestibTestP.KeypadEnable_N -> GpIO.Port52;

  components KeypadC;
  NestibTestP.Keypad -> KeypadC.Enable;

  // Inputs from the NEST thermostat. They signal when the nest thinks heating
  //  or cooling should come on.
  components NestInputC;
  NestibTestP.NestInput -> NestInputC;

  components ThermostatButtonsInputC as ButtonsIn;
  NestibTestP.TStat1ButtonsIn -> ButtonsIn.TStat1Buttons;
  NestibTestP.TStat2ButtonsIn -> ButtonsIn.TStat2Buttons;
  NestibTestP.ButtonsInInit   -> ButtonsIn.Init;
  NestibTestP.ButtonsControl  -> ButtonsIn.ButtonsControl;

//  components ThermostatButtonsOutputC as ButtonsOut;
//  NestibTestP.TStat1ButtonsOut -> ButtonsOut.TStat1Buttons;
//  NestibTestP.TStat2ButtonsOut -> ButtonsOut.TStat2Buttons;
//  NestibTestP.ButtonsOutInit   -> ButtonsOut.Init;

/*
  components new TstatButtonsOutC(TSTAT1) as ButtonsOut1;
  NestibTestP.TstatButtonsOut1 -> ButtonsOut1.TstatButtonsOut;

  components new TstatButtonsOutC(TSTAT2) as ButtonsOut2;
  NestibTestP.TstatButtonsOut2 -> ButtonsOut2.TstatButtonsOut;

  components new TstatMultiButtonC(TSTAT1) as MButton1;
  NestibTestP.TstatMButton1 -> MButton1.TstatMultiButton;

  components new TstatMultiButtonC(TSTAT2) as MButton2;
  NestibTestP.TstatMButton2 -> MButton2.TstatMultiButton;
*/

  components new TstatActionsC(TSTAT1) as TstatActions1;
  NestibTestP.TstatActions1 -> TstatActions1.TstatActions;



  // Temperature/Humidity
//  components new SensirionSht11C() as SensirionSen;
//  HemeraSamplerP.Temp -> SensirionSen.Temperature;
//  HemeraSamplerP.Hum  -> SensirionSen.Humidity;

  // Light
//  components RohmBH17C as LightSen;
//  HemeraSamplerP.LightSensor -> LightSen.Light;

  // Battery ADC
//  components BatteryAdcC as BatterySen;
//  HemeraSamplerP.BatSensor -> BatterySen.ReadSen;

  // Watchdog
//#ifdef USE_WATCHDOG
 // components new TimerMilliC() as TimerWatchdog;
//  HemeraSamplerP.TimerWatchdog -> TimerWatchdog;
//#endif

  // Radio
//  components IPStackC;
//  components new UdpSocketC() as UDPService;
//  NestibTestP.RadioControl -> IPStackC;
//  NestibTestP.UDPService   -> UDPService;

#ifdef RPL_ROUTING
  components RPLRoutingC;
#endif



}
