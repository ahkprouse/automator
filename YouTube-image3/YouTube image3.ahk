RunWith(32) ;force to start in 32 bit mode
#Include <default_Settings>  ;https://stackoverflow.com/questions/67615278/get-video-info-youtube-endpoint-suddenly-returning-404-not-found
;~ clipboard:="https://youtu.be/VCEYKVczHs0"
clipboard:=""
Send ^c
ClipWait, 2
If InStr(Clipboard,"youtu",0) ;Just making sure it has a chance...
	VidID:=YouTubeVideoID(Clipboard)

Endpoint:="https://youtubei.googleapis.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"
Payload={"context":{"client":{"hl":"en","clientName":"WEB","clientVersion":"2.20210721.00.00","mainAppWebInfo":{"graftUrl":"/watch?v=%VidID%"}}},"videoId":"%VidID%"}

if (VidID){
	HTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1") ;Create COM Object
	HTTP.Open("POST", Endpoint) ;GET & POST are most frequent, Make sure you UPPERCASE
	HTTP.Send(Payload) ;If POST request put data in "Payload" variable
	oAHK:=ParseJSON(HTTP.ResponseText) ;Make sure the ParseJSON function is in your library
	Title:=oAHK.microformat.playerMicroformatRenderer.title.simpleText
	TwoWords:=StrSplit(Title," ").1 " " Strsplit(Title," ").2
	html=<a href="https://www.youtube.com/watch?v=%VidID%" target="_blank" rel="noopener">`n<img src="https://img.youtube.com/vi/%VidID%/0.jpg" alt="%title%" width="250" /></a><hr>
	DebugWindow(clipboard:=html,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
	Notify().AddWindow("Ready to paste: " TwoWords,{Time:3000,Icon:300,Background:"0x1100AA",Title:"We got it:",TitleSize:16,size:14})
	DisplayHTML(HTML,275,230)
	sleep, 2000
	reload
}
GetSelectedText(){
	ClipboardBackup:=ClipboardAll ;backup clipboard
	clipboard = ; Empty the clipboard
	Send, ^c ;Send Copy
	ClipWait, 1 ;wait 1 second for clipboard to be populated
	If ErrorLevel { ;Added errorLevel checking		
		Clipboard:=ClipBack ;Restore Clipboard
		MsgBox, No text was sent to clipboard ;let know something went wrong
		Return  ;stop moving forward
	}
	return
}
return
+Esc::ExitApp
