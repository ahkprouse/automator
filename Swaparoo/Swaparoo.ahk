;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
;Get this code here: the-Automator.com/Swaparoo
;**************************************
#Persistent
#SingleInstance,Force
#NoEnv
;~ #NoTrayIcon

OnClipboardChange("ClipChanged")
return

ClipChanged(Type) {
	if (type=1){ ;0=clipboard is empty 1=clipboard is text  2=clipboard contains non-text 
		Swapparoo("https://www.the-automator.com","https://the-Automator.com",1) ;remove www and change A
		Swapparoo("the-automator.com","the-Automator.com",1) ;change capitalization
	}
}

Swapparoo(Srch,Rep,CaseSensitive){
	if(InStr(Clipboard,Srch,CaseSensitive)) ;Note I added case sensitivty as a parmeter
		clipboard:=StrReplace(clipboard,Srch,Rep) ;Do search and replacing	
}