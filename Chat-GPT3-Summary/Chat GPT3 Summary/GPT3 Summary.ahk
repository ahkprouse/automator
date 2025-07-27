;~ #Warn
#Requires Autohotkey v1.1.36+

#SingleInstance force
SetTitleMatchMode, 2
SetBatchLines, -1

; Recepient email
email := "Joe@the-Automator.com"

#include <UIA_Interface> ; Uncomment if you have moved UIA_Interface.ahk to your main Lib folder
return

^g::
WinMaximize, ahk_exe chrome.exe
UIA := UIA_Interface() ; Initialize UIA interface
chrome := UIA.ElementFromHandle("ahk_exe chrome.exe")
url := chrome.FindFirstBy("Name='Address and search bar'").value

if (!navigation := chrome.FindFirstBy("LocalizedControlType='navigation'"))
|| (!InStr(url, "chat.openai.com/chat"))
{
	MsgBox, % 0x10
          , % "Error"
          , % "CHAT-GPT3 Navigation panel not found.`nhttps://chat.openai.com should be the selected tab for this tool to work"
	return
}

; FileDelete, summary.txt
FormatTime, current_date,, yyyy-MM-dd@HH:mm:ss
; FileAppend, -------------------`n%current_date%`n-------------------`n, summary.txt
Data := "Here's how I've used CHAT-GPT3 up to " current_date ":`n`n"
for each,link in navigation.FindAllBy("LocalizedControlType=link")
{
	
	if (link.name = "New chat")
		continue
	else if (link.name = "Clear conversations")
		break
	; FileAppend, % link.Name "`n", summary.txt
	Data.=Link.name "`n"
}
data := uriEncode(Trim(Clipboard:=data, "`n"))
run mailto:%email%?subject=ChatGPTUsage&body=%data%
ExitApp, 0

uriencode(str, encode := true, component := true) {
	static Doc, JS
	if !Doc
	{
		Doc := ComObjCreate("htmlfile")
		Doc.write("about:<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">")
		JS := Doc.parentWindow
		( Doc.documentMode < 9 && JS.execScript() )
	}

	Return JS[ (encode ? "en" : "de") "codeURI" (component ? "Component" : "") ](str)
}
