#SingleInstance
#Requires Autohotkey v2.0+
/*
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover          *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
*/

;************************Ctrl+Alt+I Shows IP address*******************************.
^!i::    ; change your Hotkey here 
{
	
	addresses := SysGetIPAddresses()
	PrivateIPs := "Private IP addresses:`n"
	for n, address in addresses
		PrivateIPs .= address "`n"
	
	;********************Get public IP Address***********************************
	PublicIP:="Public ip is: " GetIP("http://www.netikus.net/show_ip.html") 
	
	;********************Now display addresses***********************************
	A_Clipboard:=PrivateIPs "`n`n" PublicIP
	MsgBox A_Clipboard ,"IP Addresses",64
	
	GetIP(URL){
		http:=ComObject("WinHttp.WinHttpRequest.5.1")
		http.Open("GET",URL,1)
		http.Send()
		http.WaitForResponse
		If (http.ResponseText="Error"){
			MsgBox "Sorry, your public IP address could not be detected","IP Address", 16
			Return
		}
		return http.ResponseText
	}
}