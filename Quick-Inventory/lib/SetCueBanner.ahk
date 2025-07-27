/** 
 * @param {Ctrl|String|hwnd} EditCtrl    - Gui.Control, control name, or control hwnd
 * @param {String}           text        - The text to display as the cue banner
 * @param {Boolean}          show_always - If true, the cue banner will be displayed even when the control has focus
 */
SetCueBanner(EditCtrl, text, show_always := false)
{
	Static EM_SETCUEBANNER := 0x1501

	if EditCtrl is Gui.Control
		hwnd := EditCtrl.Hwnd
	else if EditCtrl is String
		hwnd := ControlGetHwnd(EditCtrl)
	else if EditCtrl is Integer
		hwnd := EditCtrl
	else
	{
		msg := 'EditCtrl must be a Gui.Control, a control name, or a control hwnd. Received: ' Type(EditCtrl)
		throw TypeError(msg, A_ThisFunc, 'EditCtrl')
	}

	textBuff := Buffer(StrPut(text, "UTF-16"))
	StrPut(text, textBuff, "UTF-16")
	SendMessage(EM_SETCUEBANNER, show_always, textBuff.Ptr, hwnd)
	return
}