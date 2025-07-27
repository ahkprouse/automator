;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#SingleInstance,Force
; To add new content add the pipe ¦ at the begning of a new line for what you want to have in here and reload
Text=
(
¦Are you ready for a mind-blowing discussion?
¦Where have you been?`rUp for a chat?
¦Did you miss me like I missed you?
¦Have I got a story for you!
¦Where are you?
¦That is all you have to do!
)
sort,text ;If you'd like it alphabatized

^+l::  ;when hit Control+Shift+L the menu will appear.  Arrow up/down to select one and hit enter
TextMenu(Text) ;Trigger TextMenu function with text
return

TextMenu(TextOptions){
	for k, MenuItems in StrSplit(TextOptions,"¦")  ;parse the data on the weird pipe charachter
		Menu, MyMenu,Add,% trim(MenuItems),Action ;Add each item to the Menu
	
	Menu, MyMenu, Show ;Display the GUI and wait for action
	Menu, MyMenu, DeleteAll ;Delete all the menu items
}

Action:
ClipboardBackup:=ClipboardAll ;backup clipboard
Clipboard:=""
Clipboard:=A_ThisMenuItem ;Shove what was selected into the clipboard
ClipWait,1
Send, ^v ;paste the text
sleep, 100 ;Remember to sleep before restoring clipboard or it will restore the clipboard before pasting
Clipboard:=ClipboardBackup ;Restore clipboard
return


