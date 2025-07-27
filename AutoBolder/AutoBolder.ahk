;*****************************************************************************************
; Want a clear path for learning AutoHotkey; Take a look
; at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn

;Thanks for the idea Curt Jaimungal!  Check out his channel here: https://www.youtube.com/channel/UCdWIQh9DGG6uhJk8eyIFl1w
;*****************************************************************************************
#SingleInstance force
SetTitleMatchMode, 2

;~ #IfWinActive Google Docs ;remove if you don't care what program you're in
f9:: ;F9 toggles the tool on / off
boldToggle := !boldToggle

if (boldToggle)
	ToolTip, % "AutoBold On!"
else
	ToolTip, % "AutoBold Off!"

SetTimer, ttOff, -3000
return
;  Note the hotkeys trigger the same code
~LButton::
~LButton Up::
makeBold(){
		global boldToggle
		static clickCount, doubleClickTime := 300 

		if (!boldToggle)
			return

		if (A_ThisHotkey == "~LButton Up")	{
			clickCount++ ;incremement counter
			if (clickCount == 1) ;if 1 click
				Timer := A_TickCount ;set timer
		}

		if ((A_TimeSincePriorHotkey != -1 && A_ThisHotkey == "~LButton Up" && A_TimeSincePriorHotkey > 300)
		|| (clickCount >= 2 && A_TickCount - Timer < doubleClickTime)) ;compare and check how long it's been between clicks / realease of mouse button
		{
			clickCount := 0 ;start counter
			clipold := ClipboardAll ;backup clipboard

			BlockInput, on ;ddon't let person interrupt you
			send, ^c ;copy text
			ClipWait, 0 ;Wait for clipboard to have text
			if (!Clipboard) ;Don't go forward if there is no clipboard
				return
			else
			{
				sleep 50
				send ^b ;**********************Change this to the action you want*******************
			}
			BlockInput, off ;allow people to interup
			Clipboard := clipold ;restore clipboard
		}
		else if (A_TickCount - Timer > doubleClickTime)
			clickCount := 0 ;reset counter if it gets too long
		return
	}
#IfWinActive

ttOff: ;Turn off tooltip
	ToolTip
return