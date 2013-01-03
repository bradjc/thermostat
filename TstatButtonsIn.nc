/* Interface for button press events.
 */

interface TstatButtonsIn {

  async event void OnOffPressed ();
  async event void MenuPressed ();
  async event void UpPressed ();
  async event void EscPressed ();
  async event void HelpPressed ();
  async event void DownPressed ();
  async event void EnterPressed ();

}
