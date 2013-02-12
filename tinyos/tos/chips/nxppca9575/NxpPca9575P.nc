
#include "NxpPca9575.h"

generic module NxpPca9575P(uint8_t i2c_address) {
  provides {
    interface NxpPca9575 as GpioExtender;
    interface Read<uint16_t> as ReadPins;
    interface Read<uint16_t> as ReadInterrupts;
    interface SetReply<uint16_t> as SetPins;

    interface Init;
  }

  uses {
    interface I2CPacket<TI2CBasicAddr>;
    interface Resource as I2CResource;
    interface GeneralIO as ExtenderReset;
  }
}

implementation {

  typedef enum {
    I2C_ST_INIT,
    I2C_ST_READ_INT,
    I2C_ST_READ_INT2,
    I2C_ST_READ_INT3,
    I2C_ST_READ_PIN,
    I2C_ST_READ_PIN2,
    I2C_ST_READ_PIN3,
    I2C_ST_SET_PIN,
    I2C_ST_SET_PIN2,
    I2C_ST_DONE,
  } i2c_state_e;

  static uint8_t extender_setup[13] = {0};

  static uint8_t gpio_int_read[1] = {
    0x8e, // register address 14, auto-increment
  };

  static uint8_t gpio_pin_read[1] = {
    0x80, // register address 0, auto-increment
  };

  static uint8_t gpio_pin_set[3] = {
    0x8a, // register address 0, auto-increment
    0x00, // place holder
    0x00,
  };

  i2c_state_e i2c_state = I2C_ST_DONE;
  uint8_t     i2c_read_buffer[25];

  task void i2c_NXPTASK () {

    if (!call I2CResource.isOwner()) {
      call I2CResource.request();
      return;
    }

    switch (i2c_state) {
      case I2C_ST_INIT:

        // initialize the gpio extender for the inputs
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             13,
                             extender_setup);
        i2c_state = I2C_ST_DONE;
        break;


      case I2C_ST_READ_INT:
        // do the first half of the read, set the command register to the
        // correct register number
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             1,
                             gpio_int_read);
        i2c_state = I2C_ST_READ_INT2;
        break;

      case I2C_ST_READ_INT2:
        // read the interrupt mask values
        call I2CPacket.read((I2C_START | I2C_STOP),
                            i2c_address,
                            1,
                            i2c_read_buffer);
        i2c_state = I2C_ST_READ_INT3;
        break;

      case I2C_ST_READ_INT3:
        // process the pressed button
        call I2CResource.release();
        {
          uint16_t int_val = i2c_read_buffer[0] | (i2c_read_buffer[1] << 8);
          signal ReadInterrupts.readDone(SUCCESS, int_val);
        }
        i2c_state = I2C_ST_DONE;
        break;


      case I2C_ST_READ_PIN:
        // do the first half of the read, set the command register to the
        // correct register number
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             1,
                             gpio_pin_read);
        i2c_state = I2C_ST_READ_PIN2;
        break;

      case I2C_ST_READ_PIN2:
        // read the interrupt mask values
        call I2CPacket.read((I2C_START | I2C_STOP),
                            i2c_address,
                            1,
                            i2c_read_buffer);
        i2c_state = I2C_ST_READ_PIN3;
        break;

      case I2C_ST_READ_PIN3:
        // process the pressed button
        call I2CResource.release();
        {
          uint16_t pin_val = i2c_read_buffer[0] | (i2c_read_buffer[1] << 8);
          signal ReadPins.readDone(SUCCESS, pin_val);
        }
        i2c_state = I2C_ST_DONE;
        break;


      case I2C_ST_SET_PIN:
        // write the command register and the 2 registers for pin values
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             3,
                             gpio_pin_set);
        i2c_state = I2C_ST_SET_PIN2;
        break;

      case I2C_ST_SET_PIN2:
        i2c_state = I2C_ST_DONE;
        // after the write release the I2C bus and send the callback
        call I2CResource.release();
        signal SetPins.setDone();
        break;


      case I2C_ST_DONE:
        call I2CResource.release();
        break;

      default:
        break;
    }
  }

  event void I2CResource.granted () {
    post i2c_NXPTASK();
  }

  async event void I2CPacket.writeDone(error_t error,
                                       uint16_t addr,
                                       uint8_t length,
                                       uint8_t* data) {
    post i2c_NXPTASK();
  }

  async event void I2CPacket.readDone(error_t error,
                                      uint16_t addr,
                                      uint8_t length,
                                      uint8_t* data) {
    post i2c_NXPTASK();
  }

  command error_t Init.init () {
    call ExtenderReset.makeInput();
    call ExtenderReset.clr();
    call ExtenderReset.set();
    return SUCCESS;
  }

  command error_t GpioExtender.setup (nxppca9575_config_t* config) {
    i2c_state   = I2C_ST_INIT;

    // copy the config into an array we can i2c away
    extender_setup[0] = 0x82; // start at the second register and
                              //  set the auto-increment bit
    extender_setup[1] = config->polarity_inversion_port0;
    extender_setup[2] = config->polarity_inversion_port1;
    extender_setup[3] = config->bushold_pullupdown_port0;
    extender_setup[4] = config->bushold_pullupdown_port1;
    extender_setup[5] = config->enable_pullupdown_port0;
    extender_setup[6] = config->enable_pullupdown_port1;
    extender_setup[7] = config->pin_direction_port0;
    extender_setup[8] = config->pin_direction_port1;
    extender_setup[11] = config->interrupt_mask_port0;
    extender_setup[12] = config->interrupt_mask_port1;

    return call I2CResource.request();
  }

  command error_t ReadPins.read () {
    i2c_state = I2C_ST_READ_PIN;
    return call I2CResource.request();
  }

  command error_t ReadInterrupts.read () {
    i2c_state = I2C_ST_READ_INT;
    return call I2CResource.request();
  }

  command error_t SetPins.set (uint16_t val) {
    i2c_state = I2C_ST_SET_PIN;

    gpio_pin_set[1] = val & 0xFF;
    gpio_pin_set[2] = (val >> 8) & 0xFF;

    return call I2CResource.request();
  }


  default event void ReadPins.readDone (error_t result, uint16_t val) { }
  default event void ReadInterrupts.readDone (error_t result, uint16_t val) { }
  default event void SetPins.setDone () { }

}


