

interface NestInput {
  async event void FanStatus (bool on);
  async event void Cool1Status (bool on);
  async event void Cool2Status (bool on);
  async event void Heat1Status (bool on);
  async event void Heat2Status (bool on);
  async event void StarStatus (bool on);

  command void FanEnable ();
  command void FanDisable ();
  command void Cool1Enable ();
  command void Cool1Disable ();
  command void Cool2Enable ();
  command void Cool2Disable ();
  command void Heat1Enable ();
  command void Heat1Disable ();
  command void Heat2Enable ();
  command void Heat2Disable ();
  command void StarEnable ();
  command void StarDisable ();

}
