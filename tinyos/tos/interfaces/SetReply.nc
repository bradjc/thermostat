
// Set interface that also includes a call back to let the caller know it's
//  done.
interface SetReply<val_t> {
	command error_t set (val_t val);
	event void setDone ();
}

