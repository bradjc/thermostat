#ifndef __I2C_H__
#define __I2C_H__

#include <stdint.h>

typedef void i2c_callback (uint8_t* data, uint8_t length);

typedef enum i2c_mode {
	I2C_SLAVE,
	I2C_MASTER,
	I2C_NOTINIT,
} i2c_mode_e;

void i2c_init ();

/*
void i2c_read (uint8_t address,
               uint8_t length,
               uint8_t* data,
               i2c_cb callback);

void i2c_write (uint8_t address,
                uint8_t length,
                uint8_t* data,
                i2c_cb callback);
*/

void i2c_set_slave (uint8_t address, uint8_t* buffer, i2c_callback* cb);

#endif
