

generic configuration NxpPca9575C (uint8_t address) {
  provides {
    interface NxpPca9575 as GpioExtender;
    interface Read<uint16_t> as ReadPins;
    interface Read<uint16_t> as ReadInterrupts;
    interface SetReply<uint16_t> as SetPins;
  }

  uses {
    interface I2CPacket<TI2CBasicAddr>;
    interface Resource as I2CResource;
    interface GeneralIO as ExtenderReset;
  }
}

implementation {
  components new NxpPca9575P(address);
  components MainC;

  NxpPca9575P.Init <- MainC;

  I2CPacket      = NxpPca9575P.I2CPacket;
  I2CResource    = NxpPca9575P.I2CResource;
  ExtenderReset  = NxpPca9575P.ExtenderReset;

  GpioExtender   = NxpPca9575P.GpioExtender;
  SetPins        = NxpPca9575P.SetPins;
  ReadPins       = NxpPca9575P.ReadPins;
  ReadInterrupts = NxpPca9575P.ReadInterrupts;

}
