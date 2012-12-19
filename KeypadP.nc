
module KeypadP {
  provides {
    interface Enable as KeypadEnable;
  }
  uses {
    interface HplMsp430GeneralIO as KeypadEnable_N;
  }
}

implementation {

  command void KeypadEnable.enable () {
    call KeypadEnable_N.clr();
  }

  command void KeypadEnable.disable () {
    call KeypadEnable_N.set();
  }

}
