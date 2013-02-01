
module KeypadP {
  provides {
    interface Enable as KeypadEnable;
    interface Init;
  }
  uses {
    interface HplMsp430GeneralIO as KeypadEnable_N;
  }
}

implementation {

  command error_t Init.init () {
    call KeypadEnable_N.selectIOFunc();
    call KeypadEnable_N.makeOutput();
    return SUCCESS;
  }

  command void KeypadEnable.enable () {
    call KeypadEnable_N.clr();
  }

  command void KeypadEnable.disable () {
    call KeypadEnable_N.set();
  }

}
