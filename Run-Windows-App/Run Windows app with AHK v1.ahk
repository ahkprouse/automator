;*******************************************************
; Want a clear path for Discovering AutoHotkey; Take a look at our AutoHotkey courses.  
;They"re structured in a way to make learning AHK EASY:  https://the-Automator.com/Discover
;*******************************************************
; #Include <default_Settings> 
#Requires AutoHotkey v1.1.33+
;**************************************
runApp("Paint") ;this calls the below function and will launch the named app
runApp("WordPad") ;this calls the below function and will launch the named app
return
runApp(appName) {
	;~ obj:={}
	For app in ComObjCreate("Shell.Application").NameSpace("shell:AppsFolder").Items { ;Create a COM object and For-loop over them
		;~ myApps.=App.Name "`r`n"
		If (app.Name = appName) ;If the app.name matches what you provided
			RunWait % "explorer shell:appsFolder\" app.Path ;Run it
	}
	;~ OutputWindow(myApps,1)
}