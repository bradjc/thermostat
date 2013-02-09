#include "msp430.h"

#include "i2c.h"
#include "gpio.h"
#include <stdint.h>
#include <stddef.h>


//i2c_mode_e 12c_mode_current = NOTINIT;

uint8_t* receive_buffer;
uint8_t receive_buffer_idx;

uint8_t* transmit_buffer = NULL;
uint8_t transmit_buffer_idx = 0;

i2c_callback_r* i2c_receive_cb;
i2c_callback_t* i2c_transmit_cb;

uint8_t ret = 10;

void i2c_init (i2c_mode_e mode) {

	// Select Port 3 Pins 1 & 3 as i2c pins
	P3SEL |= 0x0A;

	// Set I2C Mode
	U0CTL = I2C + SYNC + MST;

	// Disable I2C
	U0CTL &= ~I2CEN;

	// Set clock source to SMCLK
	I2CTCTL = I2CSSEL_2;

//	I2CSCLL = 10;
//	I2CSCLH = 0;

	// Enable I2C
	U0CTL |= I2CEN;


	// select i2c mode
	//U0CTL = MST +
	// disable i2c module
	// configure
	// reenable i2c module

	//if slave, clear i2ctrx


}

void i2c_set_slave (uint8_t address,
	                uint8_t* buffer,
	                i2c_callback_r* rcb,
	                i2c_callback_t* tcb) {
	receive_buffer = buffer;
	receive_buffer_idx = 0;
	i2c_receive_cb = rcb;
	i2c_transmit_cb = tcb;

	// disable peripheral
	U0CTL &= ~I2CEN;

	// Set our address
	I2COA = address;

	// Enable some interrupts
//	I2CIE = TXRDYIE+RXRDYIE;
//	I2CIE = RXRDYIE;
	I2CIE = RXRDYIE | TXRDYIE | OAIE;
//	I2CIE = TXRDYIE;

	// set as slave
	U0CTL &= (~MST);
	// enable
	U0CTL |= I2CEN;
}
/*
void i2c_read (uint8_t address,
               uint8_t length,
               uint8_t* data,
               i2c_cb callback) {
da

}
*/
/*
void i2c_write (uint8_t address,
                uint8_t length,
                uint8_t* data,
                i2c_cb callback) {

	if (callback == NULL) {
		// spin till done
	} else {

	}
}
*/

// Common ISR for I2C Module
#pragma vector=USART0TX_VECTOR
__interrupt void I2C_ISR(void) {
	uint8_t t;
	switch (I2CIV) {
	  case  2: break;                          // Arbitration lost
	  case  4: break;                          // No Acknowledge
	  case  6:
		transmit_buffer = NULL;
		transmit_buffer_idx = 0;
	    break;                          // Own Address
	  case  8: break;                          // Register Access Ready
	  case 10:
	  	receive_buffer[receive_buffer_idx++] = I2CDRB;
	//  	receive_buffer[0] = I2CDRB;
  	//	t = I2CDRB;
	//  	gpio_set(2, 1);
//		if (I2CTCTL & I2CSTP) {
//	  	util_delayMs(1);
	  	if (!(I2CDCTL & I2CBB)) {
			uint8_t len = receive_buffer_idx;
			receive_buffer_idx = 0;
		//	I2CIE = TXRDYIE;
		//	_BIC_SR_IRQ(CPUOFF);
		//	gpio_clear(2, 1);
		//	util_delayCycles(50);
			i2c_receive_cb(receive_buffer, len);
		}
	  	break;                                 // Receive Ready
	  case 12:                                 // Transmit Ready
	//	I2CDRB = TXData++;                     // Load I2CDRB and increment
	//  	I2CDRB = receive_buffer[0];
	  	if (transmit_buffer == NULL) {
	  		transmit_buffer = i2c_transmit_cb();
	  	}
		I2CDRB = transmit_buffer[transmit_buffer_idx++];
		if (!(I2CDCTL & I2CBB)) {
		//	I2CIE = RXRDYIE;
		//	i2c_receive_cb(receive_buffer, 0);
		//	U0CTL = 0;
		//	U0CTL = I2C + SYNC + I2CEN;
			transmit_buffer = NULL;
			transmit_buffer_idx = 0;
		}
		break;
	  case 14: break;                          // General Call
	  case 16: break;                          // Start Condition
	}
}







