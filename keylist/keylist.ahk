/*
	Function: keyList
		Creates a list of autohotkey compatible key names ready to be parsed.

		This function will generate a delimited list of key names that can be used in autohotkey commands
		like "hotkey" or "getkeystate" or even for more general purposes like creating a list of keys that will be
		shown on a combobox.
		

	Parameters:
		keyList([inc, exc, sep])

		inc			-	Allows you to include specific keys, ascii characters or mouse keys to the list.
						Although this option is for you to specify your own key/range you can make use
						of some predefine keywords to add common ranges of keys:
						
						+ *all*:        Adds all ascii characters, punctuation, numbers, keyboard and mouse keys. *
						+ *alphanum*:   Adds alphabetic and numeric characters and excludes punctuation signs. *
						+ *lower*:      Adds all alphabetic characters in lowercase.
						+ *upper*:      Adds all alphabetic characters in uppercase.
						+ pay*num*:        Adds only numeric characters.
						+ *punct*:      Adds only punctuation and math operator signs.
						+ --------------------------------------------------------------
						+ *msb*:        Includes mouse buttons.
						+ *mods*:       Includes modifier keys. *
						+ *fkeys*:      Includes all the F keys.
						+ *npad*:       Controls the addition of numpad keys and NumLuck.
						+ *kbd*:        For all the other keys like *Enter*, *Space*, *Backspace* and such.
						+ You can exclude one or more ranges of numbers and letters using the "1-5" or "b-h" format.
						  Ranges should always be positive. "5-1" or "h-b" are not valid.

	Note :
		+ The option "mods" will only return a short version of the modifiers.
		  If you want the more detailed one use a caret "^" right next to it. Ex. "mods^" would bring the long list
		  of modifiers.
		
		+ When using  the options "all" and "alphanum" keyList will assume that you want only
		  lowercase.

		  Adding a "^" to those parameters would force the function to return uppercase characters.
		  ex.:  "alphanum" will return 0-9 and lowercase alpha chars unless you specify
		  "alphanum^".
		
		exc			-	Allows you to exclude specific keys, ascii characters or mouse keys from the list.
						This parameter goes in the same tone of the <Parameter.inc> above so everything
						works similar.

						+ *alphanum*:   Excludes alphabetic and numeric characters.
						+ *lower*:      Excludes all alphabetic characters in lowercase.
						+ *upper*:      Excludes all alphabetic characters in uppercase.
						+ *num*:        Excludes numeric characters.
						+ *punct*:      Excludes punctuation and math operator signs.
						+ --------------------------------------------------------------
						+ *msb*:        Excludes mouse buttons.
						+ *mods*:       Excludes modifier keys.
						+ *fkeys*:      Excludes all the F keys.
						+ *npad*:       Excludes numpad keys and NumLuck.
						+ *kbd*:        Excludes all the other keys like *Enter*, *Space*, *Backspace* and such.
						+ You can exclude one or more ranges of numbers and letters using the "1-5" or "b-h" format.
						  Ranges should always be positive. "5-1" or "h-b" are not valid.

		sep			-	Allows you to specify a custom separator delimiter for the lists.
						Note that the separator itself is not going to be added to the list, so specifying "+" as a 
						delimiter will cause it to be absent from the list.

	Returns:
		keyList		-	List of ascii keys, mouse and keyboard keys and punctuation signs separated by spaces.
		False		-	When you try to input more than 1 character on the separator parameter.

	Examples:
		keyList()
		keyList("msb")
		keyList("msb a-h kbd")
		keyList("all", "msb 0-5 kbd a-h")
*/
keyList(incList:="all", excList:="", delimit:=A_Tab)
{
	static $reRF 	:= "(\s+)?(?P<Start>[a-zA-Z0-9])-(?P<End>[a-zA-Z0-9])(\s+)?"
	static keywords := {all: ""
	                   ,num: "0	1	2	3	4	5	6	7	8	9"
	                   ,msb: "LButton	RButton	MButton	XButton1	XButton2	WheelDown	WheelUp	WheelLeft	WheelRight"
	                   ,kbd: "CapsLock	Space	Tab	Enter	Escape	Esc	Backspace	BS	ScrollLock	Delete	Del	Insert	Ins	Home	End	PgUp	"
	                       . "PgDn	Up	Down	Left	Right	AppsKey	PrintScreen	CtrlBreak	Pause	Help	Sleep"
	                   ,mods: {"#":"Win", "^":"Ctrl", "!":"Alt", "+":"Shift"}
	                   ,npad: "Numpad0	Numpad1 	Numpad2 	Numpad3 	Numpad4 	Numpad5 	Numpad6 	Numpad7 	Numpad8 	Numpad9 	"
	                        . "NumpadDot 	NumpadEnd	NumpadDown	NumpadPgDn	NumpadLeft	NumpadClear	NumpadRight	NumpadHome	NumpadUp	NumpadPgUp	"
	                        . "NumpadDel	NumpadIns	NumLock	NumpadDiv	NumpadMult	NumpadAdd	NumpadSub	NumpadEnter"
	                   ,lower: "a	b	c	d	e	f	g	h	i	j	k	l	m	n	o	p	q	r	s	t	u	v	w	x	y	z"
	                   ,upper: "A	B	C	D	E	F	G	H	I	J	K	L	M	N	O	P	Q	R	S	T	U	V	W	X	Y	Z"
	                   ,punct: "``	""	!	+	^	#	$	%	&	'	(	)	*	,	-	.	/	|	\	:	`;	<	=	>	?	@	[	]	{	}	~"
	                   ,fkeys: "F1	F2	F3	F4	F5	F6	F7	F8	F9	F10	F11	F12	F13	F14	F15	F16	F17	F18	F19	F20	F21	F22	F23	F24"
	                   ,media: "Browser_Back	Browser_Forward	Browser_Refresh	Browser_Stop	Browser_Search	Browser_Favorites	Browser_Home	"
	                         . "Volume_Mute	Volume_Down	Volume_Up	Media_Next	Media_Prev	Media_Stop	Media_Play_Pause	Launch_Mail	Launch_Media	"
	                         . "Launch_App1	Launch_App2"}

	for keyword, keys in keywords
	{
		if (keyword == "all")
			continue
		else if (keyword == "mods")
			for shortMod, longMod in keys	
				keywords.all .= shortMod A_Tab "L" longMod A_Tab "R" longMod A_Tab (longMod != "Win" ? longMod A_Tab : "")
		else
			keywords.all .= keys A_Tab
	}
	keywords.alnum := keywords.num A_Tab keywords.lower

	if (RegExMatch(incList, "all") && !excList)
		return StrReplace(keywords.all, A_Tab, delimit)

	; add keywords lists to working list
	Loop, Parse, incList, % A_Space
	{
		if (keywords.HasKey(A_LoopField))
			workingList .= keywords[A_LoopField] A_Tab
		else if (RegExMatch(A_LoopField, "(#|\^|!|\+)"))
		{
			Loop, Parse, A_LoopField
			{
				if (keywords.mods.HasKey(A_LoopField))
					workingList .= A_LoopField A_Tab keywords.mods[A_LoopField] A_Tab
				else
					workingList .= A_LoopField A_Tab
			}
		}
		else
			workingList .= A_LoopField A_Tab
	}

	Loop, Parse, excList, % A_Space
	{
		; remove excluded based on keywords
		if (keywords.HasKey(A_LoopField))
			workingList := RegExReplace(workingList, keywords[A_LoopField] A_Tab)
		else if (RegExMatch(A_LoopField, "(#|\^|!|\+)"))
		{
			; remove single characters
			Loop, Parse, A_LoopField
			{
				; handle modifier keys
				if (keywords.mods.HasKey(A_LoopField))
					workingList := RegExReplace(workingList, "i)(\Q" A_LoopField A_Tab "\E)?(\Q" keywords.mods[A_LoopField] A_Tab "\E)?")
				else
					workingList := RegExReplace(workingList, "i)\Q" A_LoopField A_Tab "\E")
			}
		}
		else
			workingList := RegExReplace(workingList, "i)\b\Q" A_LoopField A_Tab "\E\b")
	}

	; Advanced including options.
	; This little loop allows excluding ranges like "1-5" or "a-d".
	; The rage should always be positive i. e. ranges like "6-1" or "h-b" are not handled yet.
	While (Regexmatch(incList, $reRF, r))
	{
		Loop % asc(rEnd) - asc(rStart) + 1	; the + 1 is to include the last character in range.
			lst .= chr(a_index + asc(rStart) - 1) A_Tab
		
		incList := RegExReplace(incList, $reRF,"","",1)
		workingList := RegexReplace(workingList, $reRF, lst, "", 1)
	}
	
	; Advanced excluding options.
	; This loop allows excluding ranges like "1-5" or "a-d".
	; The rage should always be positive i. e. ranges like "6-1" or "h-b" are not handled yet.
	While (Regexmatch(excList, $reRF, r))
	{
		Loop % asc(rEnd) - asc(rStart) + 1	; the + 1 is to include the last character in range.
			workingList := RegexReplace(workingList, "i)\b\Q" (var := chr(a_index + asc(rStart) - 1) A_Tab) "\E\b")

		excList := RegExReplace(excList, $reRF, "", "", 1)
	}

	; convert separator
	return StrReplace( Trim(workingList, delimt)
	                 , A_Tab
	                 , delimit)
}