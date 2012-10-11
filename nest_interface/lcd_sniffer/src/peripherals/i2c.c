


i2c_mode_e 12c_mode_current = NOTINIT;


void i2c_init (i2c_mode_e mode) {

	// select i2c mode
	// disable i2c module
	// configure
	// reenable i2c module

	//if slave, clear i2ctrx


}

void i2c_read (uint8_t address,
               uint8_t length,
               uint8_t* data,
               i2c_cb callback) {
da

}

void i2c_write (uint8_t address,
                uint8_t length,
                uint8_t* data,
                i2c_cb callback) {

	if (callback == NULL) {
		// spin till done
	} else {

	}
}







