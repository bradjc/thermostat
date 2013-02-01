/* Pass through module for retreiving the thermostat state from the lcd.
 */

configuration TstatStateC {
  provides {
    interface LcdSniffer;
  }
}

implementation {
  components new LcdSnifferC(LCD_SNIFFER_ADDR);

  // I2C Bus
  components new Msp430I2CC();
  LcdSnifferC.I2CPacket   -> Msp430I2CC.I2CBasicAddr;
  LcdSnifferC.I2CResource -> Msp430I2CC.Resource;

  LcdSniffer = LcdSnifferC.LcdSniffer;
}


