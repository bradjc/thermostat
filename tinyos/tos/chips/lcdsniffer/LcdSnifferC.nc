

generic configuration LcdSnifferC (uint8_t address) {
  provides {
    interface LcdSniffer;
  }

  uses {
    interface I2CPacket<TI2CBasicAddr>;
    interface Resource as I2CResource;
  }
}

implementation {
  components new LcdSnifferP(address);

  I2CPacket   = LcdSnifferP.I2CPacket;
  I2CResource = LcdSnifferP.I2CResource;

  LcdSniffer  = LcdSnifferP.LcdSniffer;

}
