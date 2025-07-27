#Include <default_Settings>
; See regex example of this here  https://regexr.com/6buqd
;**************************************
FileRead,URLs,B:\Progs\AutoHotkey_L\AHK Work\AHK_Functionality\RegEx\YouTubeID\urls.txt
;*********Use For loop over URLs going line by line*********************
for i, row in Loopobj:=StrSplit(URLs,"`n","`r`n") { ;Parse Var on each new line
	text.= YouTubeVideoID(Row) a_tab Row "`n"
}
DebugWindow(Text,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)

YouTubeVideoID(URL){
	RegExMatch(URL,"(\/|%3D|vi=|v=)(?P<ID>[0-9A-z-_]{11})([%#?&/]|$)",YouTube_) 
	If youtube_ID
		return youtube_ID
	else
		return "ID not found"
}