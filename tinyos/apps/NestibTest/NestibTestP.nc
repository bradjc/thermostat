#include <Timer.h>
#include <I2C.h>
#include "nib.h"
#include "multi_button.h"
//#include <IPDispatch.h>
//#include <lib6lowpan/lib6lowpan.h>
//#include <lib6lowpan/ip.h>

module NestibTestP {
  uses {
    interface Leds;
    interface Boot;

  //  interface HplMsp430GeneralIO as KeypadEnable_N; // active low
    interface Enable as Keypad;

    interface NestInput;

    interface ThermostatButtonsInput as TStat1ButtonsIn;
    interface ThermostatButtonsInput as TStat2ButtonsIn;
    interface Init as ButtonsInInit;
    interface Enable as ButtonsControl;

//    interface TstatButtonsOut as TstatButtonsOut1;
//    interface TstatButtonsOut as TstatButtonsOut2;

//    interface TstatMultiButton as TstatMButton1;
//    interface TstatMultiButton as TstatMButton2;

    interface TstatActions as TstatActions1;


//    interface SplitControl as RadioControl;
//    interface UDP as UDPService;

//    interface Read<uint16_t> as Temp;
//    interface Read<uint16_t> as Hum;
 //   interface Read<uint16_t> as LightSensor;

    //interface Read<uint16_t> as BatSensor;
  }
}





implementation {


  bool processing_button;
  button_e buttons[25];



  event void Boot.booted () {
    atomic {

      // This makes sure we only have 1 button press at a time being processed
      // by the system. Other button presses will be ignored.
      processing_button = FALSE;





      // Turn on second voltage regulator
//      TOSH_SET_VOLTAGE_REG_PIN();

/*     inet_pton6(RECEIVER_ADDR, &dest.sin6_addr);
      dest.sin6_port    = htons(RECEIVER_PORT);
      payload_thl.seqno = 0;
      sample_count      = 0;
*/
  //    call Leds.led1On();
      call Leds.led2On();

      // Disable the keypad
      call Keypad.enable();

    //
      call ButtonsInInit.init();
    //  call ButtonsOutInit.init();

      call ButtonsControl.disable();

   //   call TstatActions1.setTemperature(78);



//      call RadioControl.start();
    }
  }







  async event void NestInput.FanStatus (bool on) {
  }

  async event void NestInput.Cool1Status (bool on) {
    if (on) call Leds.led0On();
    else call Leds.led0Off();
  }

  async event void NestInput.Cool2Status (bool on) {
  }

  async event void NestInput.Heat1Status (bool on) {
  }

  async event void NestInput.Heat2Status (bool on) {
  }

  async event void NestInput.StarStatus (bool on) {
  }



  task void press_onoff1 () {
 //   call ButtonsControl.disable();
 //   call Keypad.enable();
 //   call TstatActions1.setTemperature(78);
  }
  task void press_menu1 ()  { }
  task void press_up1 ()    { }
  task void press_esc1 ()   { }
  task void press_help1 ()  { }
  task void press_down1 ()  { }
  task void press_enter1 () { }

  task void press_onoff2 () { }
  task void press_menu2 ()  { }
  task void press_up2 ()    { }
  task void press_esc2 ()   { }
  task void press_help2 ()  { }
  task void press_down2 ()  { }
  task void press_enter2 () { }

  event void TstatActions1.actionDone () {
 //   call ButtonsControl.enable();
 //   call Keypad.disable();
  }

/*
  event void TstatMButton1.pressMultipleButtonsDone () {
    call ButtonsControl.enable();
  }

  event void TstatMButton2.pressMultipleButtonsDone () {

  }
*/

/*
  task void press_onoff1 () {
    call ButtonsControl.disable();
    buttons[0] = Esc;
    buttons[1] = Menu;
    call TstatMButton1.pressMultipleButtons(buttons, 2);
  }
  task void press_menu1 ()  { call TstatButtonsOut1.pressButton(Menu); }
  task void press_up1 ()    { call TstatButtonsOut1.pressButton(Up); }
  task void press_esc1 ()   { call Leds.led1Toggle();
    call TstatButtonsOut1.pressButton(Esc); }
  task void press_help1 ()  { call TstatButtonsOut1.pressButton(Help); }
  task void press_down1 ()  { call TstatButtonsOut1.pressButton(Down); }
  task void press_enter1 () { call TstatButtonsOut1.pressButton(Enter); }

  task void press_onoff2 () { call TstatButtonsOut2.pressButton(OnOff); }
  task void press_menu2 ()  { call TstatButtonsOut2.pressButton(Menu); }
  task void press_up2 ()    { call TstatButtonsOut2.pressButton(Up); }
  task void press_esc2 ()   { call TstatButtonsOut2.pressButton(Esc); }
  task void press_help2 ()  { call TstatButtonsOut2.pressButton(Help); }
  task void press_down2 ()  { call TstatButtonsOut2.pressButton(Down); }
  task void press_enter2 () {
    call ButtonsControl.disable();
    call TstatButtonsOut2.pressButton(Enter);
  }

  event void TstatMButton1.pressMultipleButtonsDone () {
    call ButtonsControl.enable();
  }

  event void TstatMButton2.pressMultipleButtonsDone () {

  }
*/

  async event void TStat1ButtonsIn.OnOffPressed () { post press_onoff1(); }
  async event void TStat1ButtonsIn.MenuPressed ()  { post press_menu1(); }
  async event void TStat1ButtonsIn.UpPressed ()    { post press_up1(); }
  async event void TStat1ButtonsIn.EscPressed ()   { post press_esc1(); }
  async event void TStat1ButtonsIn.HelpPressed ()  { post press_help1(); }
  async event void TStat1ButtonsIn.DownPressed ()  { post press_down1(); }
  async event void TStat1ButtonsIn.EnterPressed () { post press_enter1(); }
  async event void TStat2ButtonsIn.OnOffPressed () { post press_onoff2(); }
  async event void TStat2ButtonsIn.MenuPressed ()  { post press_menu2(); }
  async event void TStat2ButtonsIn.UpPressed ()    { post press_up2(); }
  async event void TStat2ButtonsIn.EscPressed ()   { post press_esc2(); }
  async event void TStat2ButtonsIn.HelpPressed ()  { post press_help2(); }
  async event void TStat2ButtonsIn.DownPressed ()  { post press_down2(); }
  async event void TStat2ButtonsIn.EnterPressed () { post press_enter2(); }
/*
  event void TstatButtonsOut1.pressButtonDone (button_e b) { }

  event void TstatButtonsOut2.pressButtonDone (button_e b) {
    if (b == Enter) {
      call ButtonsControl.enable();
    }
  }
*/


//  event void RadioControl.startDone (error_t e) {
//    if (e == SUCCESS) {

//    } else {
//      call RadioControl.start();
//    }
//  }

//  event void UDPService.recvfrom (struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) { }
//  event void RadioControl.stopDone (error_t e) { }

}
