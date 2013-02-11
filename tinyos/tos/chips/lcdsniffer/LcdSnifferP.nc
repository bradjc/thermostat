
#include "lcdsniffer.h"
#include "nib.h"

generic module LcdSnifferP (uint8_t i2c_address) {
  provides {
    interface LcdSniffer;
  }

  uses {
    interface I2CPacket<TI2CBasicAddr>;
    interface Resource as I2CResource;
  }
}

implementation {

  typedef enum {
    I2C_ST_GET_STATUS1,
    I2C_ST_GET_STATUS2,
    I2C_ST_GET_STATUS3,
    I2C_ST_GET_DISPLAY1,
    I2C_ST_GET_DISPLAY2,
    I2C_ST_GET_DISPLAY3,
    I2C_ST_GET_LCD_CHARS1,
    I2C_ST_GET_LCD_CHARS2,
    I2C_ST_GET_LCD_CHARS3,
    I2C_ST_DONE,
  } i2c_state_e;

  static uint8_t request[3]  = {0};

  i2c_state_e i2c_state = I2C_ST_DONE;
  uint8_t     i2c_read_buffer[50];

  lcd_status_e retrieve_status;

  task void next_i2c () {

    if (!call I2CResource.isOwner()) {
      call I2CResource.request();
      return;
    }

    switch (i2c_state) {

      case I2C_ST_GET_STATUS1:
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             3,
                             request);
        i2c_state = I2C_ST_GET_STATUS2;
        break;

      case I2C_ST_GET_STATUS2:
        // read the interrupt mask values
        call I2CPacket.read((I2C_START | I2C_STOP),
                            i2c_address,
                            1,
                            i2c_read_buffer);
        i2c_state = I2C_ST_GET_STATUS3;
        break;

      case I2C_ST_GET_STATUS3:
        // process the pressed button
        call I2CResource.release();
        {
          error_t e = SUCCESS;
          if (i2c_read_buffer[0] == 0xFF) {
            // error
            i2c_read_buffer[0] = 0;
            e = FAIL;
          }
          signal LcdSniffer.getStatusDone(request[2], i2c_read_buffer[0], e);
        }
        i2c_state = I2C_ST_DONE;
        break;

      case I2C_ST_GET_DISPLAY1:
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             2,
                             request);
        i2c_state = I2C_ST_GET_DISPLAY2;
        break;

      case I2C_ST_GET_DISPLAY2:
        // read the interrupt mask values
        call I2CPacket.read((I2C_START | I2C_STOP),
                            i2c_address,
                            1,
                            i2c_read_buffer);
        i2c_state = I2C_ST_GET_DISPLAY3;
        break;

      case I2C_ST_GET_DISPLAY3:
        // process the pressed button
        call I2CResource.release();
        signal LcdSniffer.getCurrentDisplayDone((lcd_display_e) i2c_read_buffer[0]);
        i2c_state = I2C_ST_DONE;
        break;

      case I2C_ST_GET_LCD_CHARS1:
        call I2CPacket.write((I2C_START | I2C_STOP),
                             i2c_address,
                             2,
                             request);
        i2c_state = I2C_ST_GET_LCD_CHARS2;
        break;

      case I2C_ST_GET_LCD_CHARS2:
        call I2CPacket.read((I2C_START | I2C_STOP),
                            i2c_address,
                            32,
                            i2c_read_buffer);
        i2c_state = I2C_ST_GET_LCD_CHARS3;
        break;

      case I2C_ST_GET_LCD_CHARS3:
        call I2CResource.release();
        signal LcdSniffer.getLcdCharsDone(i2c_read_buffer);
        i2c_state = I2C_ST_DONE;
        break;


      case I2C_ST_DONE:
        call I2CResource.release();
        break;

      default:
        break;
    }
  }

  event void I2CResource.granted () {
    post next_i2c();
  }

  async event void I2CPacket.writeDone(error_t error,
                                       uint16_t addr,
                                       uint8_t length,
                                       uint8_t* data) {
    post next_i2c();
  }

  async event void I2CPacket.readDone(error_t error,
                                      uint16_t addr,
                                      uint8_t length,
                                      uint8_t* data) {
    post next_i2c();
  }

  command error_t LcdSniffer.getStatus (thermostat_e tstat,
                                        lcd_status_e status) {
    request[0] = (uint8_t) tstat - 1;
    request[1] = LCD_I2C_TYPE_STATUS;
    request[2] = (uint8_t) status;
    i2c_state = I2C_ST_GET_STATUS1;
    return call I2CResource.request();

/*
    if (status == TemperatureSetPoint) {
      signal LcdSniffer.getStatusDone(TemperatureSetPoint, 70, SUCCESS);
    } else if (status == Power) {
      signal LcdSniffer.getStatusDone(Power, 1, SUCCESS);
    }
    return SUCCESS;
 */
  }

  command error_t LcdSniffer.getCurrentDisplay (thermostat_e tstat) {
    request[0] = (uint8_t) tstat - 1;
    request[1] = LCD_I2C_TYPE_DISPLAY;
    i2c_state = I2C_ST_GET_DISPLAY1;
    return call I2CResource.request();

  //  signal LcdSniffer.getCurrentDisplayDone(Password);
  //  return SUCCESS;
  }

  command error_t LcdSniffer.getLcdChars (thermostat_e tstat) {
    request[0] = (uint8_t) tstat - 1;
    request[1] = LCD_I2C_TYPE_LCD_CHARS;
    i2c_state = I2C_ST_GET_LCD_CHARS1;
    return call I2CResource.request();
  }

}


