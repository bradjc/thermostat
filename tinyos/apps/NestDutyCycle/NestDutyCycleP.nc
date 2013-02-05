#include "nib.h"
//#include <IPDispatch.h>
//#include <lib6lowpan/lib6lowpan.h>
//#include <lib6lowpan/ip.h>

module NestDutyCycleP {
  uses {
    interface Leds;
    interface Boot;

    interface Enable as Keypad;

    interface NestInput;

    interface TstatButtonsIn as Tstat1In;
    interface TstatButtonsIn as Tstat2In;
    interface Enable as Tstat1InDetect;
    interface Enable as Tstat2InDetect;

    interface TstatActions as TstatActions1;

    interface SplitControl as RadioControl;
    interface UDP;
  }
}

implementation {

  bool unit1_turn_on;

  event void Boot.booted () {
    atomic {

/*     inet_pton6(RECEIVER_ADDR, &dest.sin6_addr);
      dest.sin6_port    = htons(RECEIVER_PORT);
      payload_thl.seqno = 0;
      sample_count      = 0;
*/

      call Leds.led2On();

      call Keypad.disable();
      call Tstat1InDetect.enable();
      call Tstat2InDetect.disable();

      call RadioControl.start();
    }
  }

  task void power_cycle () {
    if (unit1_turn_on) {
      call TstatActions1.turnOn();
    } else {
      call TstatActions1.turnOff();
    }
  }

  async event void NestInput.FanStatus (bool on) { }

  async event void NestInput.Cool1Status (bool on) {
    call Leds.led2Toggle();
    atomic {
      unit1_turn_on = on;
    }
    post power_cycle();
  }

  async event void NestInput.Cool2Status (bool on) { }
  async event void NestInput.Heat1Status (bool on) { }
  async event void NestInput.Heat2Status (bool on) { }
  async event void NestInput.StarStatus (bool on) { }

  event void TstatActions1.actionDone () {
    call Leds.led1Toggle();
  }

  event void Tstat1In.OnOffPressed () {  }
  event void Tstat1In.MenuPressed ()  {  }
  event void Tstat1In.UpPressed ()    {  }
  event void Tstat1In.EscPressed ()   {  }
  event void Tstat1In.HelpPressed ()  {  }
  event void Tstat1In.DownPressed ()  {  }
  event void Tstat1In.EnterPressed () {  }
  event void Tstat2In.OnOffPressed () {  }
  event void Tstat2In.MenuPressed ()  {  }
  event void Tstat2In.UpPressed ()    {  }
  event void Tstat2In.EscPressed ()   {  }
  event void Tstat2In.HelpPressed ()  {  }
  event void Tstat2In.DownPressed ()  {  }
  event void Tstat2In.EnterPressed () {  }

  event void UDP.recvfrom (struct sockaddr_in6 *from,
                           void *data,
                           uint16_t len,
                           struct ip6_metadata *meta) { }
  event void RadioControl.startDone (error_t e) { }
  event void RadioControl.stopDone (error_t e) { }

}
