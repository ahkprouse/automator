#SingleInstance, force
#Requires Autohotkey v1.1.33+

;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.
; They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
;~ https://www.autohotkey.com/boards/viewtopic.php?t=86495 ;original Function by iseahound

Gui, add, Text,, % "Paste your character:"
Gui, add, edit, w150 vChar
Gui, add, Text,, % "Select a hotkey for your character:"
Gui, add, hotkey, w150 vHotK
Gui, add, checkbox, x+m yp+3, % "Win"
Gui, add, button, xm w75, Okay
Gui show
return

ButtonOkay(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="")
{
	for each,ctrl in ["Char", "HotK"]
		GuiControlGet, %ctrl%

	if !Char
	{
		MsgBox, % "You must paste a character to be looked up"
		Return
	}

	Gui, Submit
	if !(database := FileOpen("UnicodeCharacters.txt", "r`n", "UTF-8"))
		throw Exception("Unicode data not found.")

	; Binary Search.
	i := 0               ; min bound
	k := database.length ; max bound
	Loop {
		n := Floor((i + k) / 2)                               ; Value to test.
		database.Seek(n)                                      ; Move file pointer to middle of file.
		(database.Pos != 0) ? database.ReadLine() : ""        ; Advance file pointer to the end of line.
		save := database.ReadLine()                           ; Read a full line of text.
		codepoint := RegExReplace(save, "^(.*?);.*$", "0x$1") ; Extract and convert the unicode hex to decimal.
		(Ord(Char) < codepoint) ? (k := n) : (i := n)            ; Advance min or max bound per binary search.
	} until (Ord(Char) = codepoint)                             ; Exit when the test value is the search value.
	database.Close()
	r := StrSplit(save, ";")                                 ; Split row into an array.
	q := (r[2] = "<control>") ? r[11] : r[2]                 ; Retrieve alternate description if control character.
	MsgBox,, % A_Space Chr(Ord(Char)), % "AHK code copied to the clipboard`n`n"
	                                   . Clipboard := HotK "`:`:Send {U+" Format("{:X}", Ord(Char)) "} `;" q
	return
}