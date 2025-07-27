;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses.  They're structured in a way to make learning AHK EASY
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover
;*******************************************************
;https://www.the-Automator.com/Obj2String
Obj2String(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
		String:=FullPath:=Blank:=""
	if(IsObject(Obj)&&!Obj.XML){
		for a,b in Obj{
			if(IsObject(b)&&b.OuterHtml)
				String.=FullPath "." a " = " b.OuterHtml
			else if(IsObject(b)&&!b.XML)
				Obj2String(b,FullPath "." a,BottomBlank)
			else{
				if(BottomBlank=0)
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else if(b!="")
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
		}
	}else if(Obj.XML)
		String.=FullPath Obj.XML "`n"
	return String Blank
}