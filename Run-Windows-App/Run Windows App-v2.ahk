;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses.  
;They"re structured in a way to make learning AHK EASY:  https://the-Automator.com/Discover
;*******************************************************
#SingleInstance
#Requires Autohotkey v2.0+

runApp('Spotify') ;this will launch Spotify

runApp(appName) { ; https://www.autohotkey.com/boards/viewtopic.php?p=438517#p438517
	For app in ComObject('Shell.Application').NameSpace('shell:AppsFolder').Items
		(app.Name = appName) && RunWait('explorer shell:appsFolder\' app.Path)
}
