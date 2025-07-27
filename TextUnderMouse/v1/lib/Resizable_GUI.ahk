;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses.  They're structured in a way to make learning AHK EASY
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover
;~ https://the-automator.com/ResizableGUI  ;original https://youtu.be/vYawLR5TtJA

;*******************************************************
;~ Resizable_GUI("the dog ran`nhome",900,600,true)
Resizable_GUI(text,x:=900,y:=600,eta:=false){
	static EditWindow ;Set this as static so it is "sticky" 
	static exitTheApp ;Needs to be declared on its own because it runs before variables have values
	
	exitTheApp := eta ;make sure this is done after you've declared it above as a static variable
	Gui,12:Destroy
	Gui,12:Default
	Gui,+Resize
	Gui,Font,s12 cBlue q5, Courier New
	Gui,Add,Edit,w%x% h%y% -Wrap HScroll hwndEditWindow ;,%text%	 ;I used to use this approach however ran into random errror loading the control
	Gui,Show
	GuiControl,,%EditWindow%,%text% ;Populate edit control after creating.  Had weird issue when loading it on edit line above
	return
	
	;********************Resizing***********************************
	12GuiSize:
	GuiControl,12:Move,%EditWindow%,% "w" A_GuiWidth-30 " h" A_GuiHeight-25
	return
	
	;********************Exit /Escape and closing the app***********************************
	12GuiEscape:
	12GuiClose:
	Gui,12:Destroy
	if exitTheApp
		ExitApp
	return
}

