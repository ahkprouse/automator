
#Include ..\Rufaydium.ahk
; Closing Chrome because One cannot access Profile folder that has been opened by another Chrome.exe
if msgbox("if Chrome is running with useraccount therefore webdrive session cannot access that useraccount`n`nClose Chrome?", ,'Y/N ?icon') != "Yes"
	ExitApp

while ProcessExist("chromedriver.exe")
{
	ProcessClose("chromedriver.exe")
	Sleep(1000)
}

Chrome := Rufaydium() ; Runs Webdriver
Chrome.Capabilities.setUserProfile('Default') ; user can aslo ger profile by email for chrome and edge
Page := Chrome.NewSession()
Page.Navigate("https://www.google.com")


msgbox "Done"

Chrome.QuitAllSessions()
CHrome.Exit()