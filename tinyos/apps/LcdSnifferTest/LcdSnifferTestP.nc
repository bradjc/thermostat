#include "nib.h"
#include <lib6lowpan/lib6lowpan.h>
#include <lib6lowpan/ip.h>

#define MEM "2001:470:1f10:131c::2"

module LcdSnifferTestP {
  uses {
    interface Leds;
    interface Boot;

    interface LcdSniffer;

    interface Enable as Keypad;

    interface Timer<TMilli> as Timer0;

    interface SplitControl as RadioControl;
    interface UDP;
  }
}

implementation {

  struct sockaddr_in6 dest;

  typedef struct {
    uint8_t lcd_chars[32];
  } packet_data_t;

  packet_data_t pkt;

  event void Boot.booted () {
    atomic {

      inet_pton6(MEM, &dest.sin6_addr);
      dest.sin6_port = htons(3001);

      call Leds.led2On();

      call Keypad.disable();

      call RadioControl.start();
    }
  }

  event void RadioControl.startDone (error_t e) {
    call Timer0.startPeriodic(5000);
  }


  event void Timer0.fired () {
    call LcdSniffer.getLcdChars(TSTAT1);
    //call LcdSniffer.getStatus(TSTAT1, Power);
  }

  event void LcdSniffer.getStatusDone (lcd_status_e status,
                                       uint8_t value,
                                       error_t e) {
  }

  event void LcdSniffer.getCurrentDisplayDone (lcd_display_e display) {}

  event void LcdSniffer.getLcdCharsDone (uint8_t* chars) {
    memcpy(pkt.lcd_chars, chars, 32);
    call UDP.sendto(&dest, &pkt, sizeof(packet_data_t));
  }



  event void UDP.recvfrom (struct sockaddr_in6 *from,
                           void *data,
                           uint16_t len,
                           struct ip6_metadata *meta) { }

  event void RadioControl.stopDone (error_t e) { }

}
