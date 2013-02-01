#include "NxpPca9575.h"

interface NxpPca9575 {

//  command void set_address (uint8_t address);

  // set all of the configuration parameters of the chip in one go
  command error_t setup (nxppca9575_config_t* config);


// TODO: implement all of these individual settings:
/*
  command error_t set_polarity (uint8_t port0, uint8_t port1);

  // enable these features for each port
  command error_t enable_bus_hold (uint8_t port0, uint8_t port1);
  command error_t enable_pull_updown (uint8_t port0, uint8_t port1);

  // set whether each bit should have a pull up or pull down
  // automatically enables pull up/down resistor setting
  command error_t set_pull_up_down (uint8_t port0, uint8_t port1);

  command error_t set_direction (uint8_t port0, uint8_t port1);
  command error_t set_interrupt_mask (uint8_t port0, uint8_t port1);
*/


}
