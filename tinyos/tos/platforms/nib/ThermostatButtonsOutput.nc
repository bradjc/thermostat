

interface ThermostatButtonsOutput {

  command void PressOnOff ();
  command void PressMenu ();
  command void PressUp ();
  command void PressEsc ();
  command void PressHelp ();
  command void PressDown ();
  command void PressEnter ();

  event void PressOnOffDone ();
  event void PressMenuDone ();
  event void PressUpDone ();
  event void PressEscDone ();
  event void PressHelpDone ();
  event void PressDownDone ();
  event void PressEnterDone ();

}
