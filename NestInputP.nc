



module NestInputP {
  provides {
    interface NestInput;
    interface Init;
  }

  uses {
    interface HplMsp430GeneralIO as NestFan;
    interface HplMsp430GeneralIO as NestCooling1;
    interface HplMsp430GeneralIO as NestCooling2;
    interface HplMsp430GeneralIO as NestHeating1;
    interface HplMsp430GeneralIO as NestHeating2;
    interface HplMsp430GeneralIO as NestStar;

    interface HplMsp430Interrupt as NestFanIRQ;
    interface HplMsp430Interrupt as NestCooling1IRQ;
    interface HplMsp430Interrupt as NestCooling2IRQ;
    interface HplMsp430Interrupt as NestHeating1IRQ;
    interface HplMsp430Interrupt as NestHeating2IRQ;
    interface HplMsp430Interrupt as NestStarIRQ;
  }
}

implementation {

  command error_t Init.init () {
    call NestFan.selectIOFunc();
    call NestFan.makeInput();
    call NestCooling1.selectIOFunc();
    call NestCooling1.makeInput();
    call NestCooling2.selectIOFunc();
    call NestCooling2.makeInput();
    call NestHeating1.selectIOFunc();
    call NestHeating1.makeInput();
    call NestHeating2.selectIOFunc();
    call NestHeating2.makeInput();
    call NestStar.selectIOFunc();
    call NestStar.makeInput();

    // set pins to the proper interrupt if they are currently high or low
    call NestFanIRQ.edge(!call NestFan.get());
    call NestCooling1IRQ.edge(!call NestCooling1.get());
    call NestCooling2IRQ.edge(!call NestCooling2.get());
    call NestHeating1IRQ.edge(!call NestHeating1.get());
    call NestHeating2IRQ.edge(!call NestHeating2.get());
    call NestStarIRQ.edge(!call NestStar.get());

    // clear any pending
    call NestFanIRQ.clear();
    call NestCooling1IRQ.clear();
    call NestCooling2IRQ.clear();
    call NestHeating1IRQ.clear();
    call NestHeating2IRQ.clear();
    call NestStarIRQ.clear();

    // enable the interrupts
    call NestFanIRQ.enable();
    call NestCooling1IRQ.enable();
    call NestCooling2IRQ.enable();
    call NestHeating1IRQ.enable();
    call NestHeating2IRQ.enable();
    call NestStarIRQ.enable();

    return SUCCESS;
  }

  async event void NestFanIRQ.fired () {
    bool pin_high = call NestFanIRQ.getValue();
    call NestFanIRQ.edge(!pin_high);
    call NestFanIRQ.clear();
    signal NestInput.FanStatus(!pin_high);
  }

  async event void NestCooling1IRQ.fired () {
    bool pin_high = call NestCooling1.get();
    call NestCooling1IRQ.edge(!pin_high);
    call NestCooling1IRQ.clear();
    signal NestInput.Cool1Status(!pin_high);
  }

  async event void NestCooling2IRQ.fired () {
    bool pin_high = call NestCooling2.get();
    call NestCooling2IRQ.edge(!pin_high);
    call NestCooling2IRQ.clear();
    signal NestInput.Cool2Status(!pin_high);
  }

  async event void NestHeating1IRQ.fired () {
    bool pin_high = call NestHeating1.get();
    call NestHeating1IRQ.edge(!pin_high);
    call NestHeating1IRQ.clear();
    signal NestInput.Heat1Status(!pin_high);
  }

  async event void NestHeating2IRQ.fired () {
    bool pin_high = call NestHeating2.get();
    call NestHeating2IRQ.edge(!pin_high);
    call NestHeating2IRQ.clear();
    signal NestInput.Heat2Status(!pin_high);
  }

  async event void NestStarIRQ.fired () {
    bool pin_high = call NestStar.get();
    call NestStarIRQ.edge(!pin_high);
    call NestStarIRQ.clear();
    signal NestInput.StarStatus(!pin_high);
  }

  command void NestInput.FanEnable () {
    call NestFanIRQ.clear();
    call NestFanIRQ.enable();
  }

  command void NestInput.Cool1Enable () {
    call NestCooling1IRQ.clear();
    call NestCooling1IRQ.enable();
  }

  command void NestInput.Cool2Enable () {
    call NestCooling2IRQ.clear();
    call NestCooling2IRQ.enable();
  }

  command void NestInput.Heat1Enable () {
    call NestHeating1IRQ.clear();
    call NestHeating1IRQ.enable();
  }

  command void NestInput.Heat2Enable () {
    call NestHeating2IRQ.clear();
    call NestHeating2IRQ.enable();
  }

  command void NestInput.StarEnable () {
    call NestStarIRQ.clear();
    call NestStarIRQ.enable();
  }

  command void NestInput.FanDisable () {
    call NestFanIRQ.disable();
  }

  command void NestInput.Cool1Disable () {
    call NestCooling1IRQ.disable();
  }

  command void NestInput.Cool2Disable () {
    call NestCooling2IRQ.disable();
  }

  command void NestInput.Heat1Disable () {
    call NestHeating1IRQ.disable();
  }

  command void NestInput.Heat2Disable () {
    call NestHeating2IRQ.disable();
  }

  command void NestInput.StarDisable () {
    call NestStarIRQ.disable();
  }



}

