/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     YYYY-DD-MM                                                     *
 * @modified    YYYY-DD-MM                                                     *
 * @description                                                                *
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.
 */
;@Ahk2Exe-SetVersion     "0.0.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName 
;@Ahk2Exe-SetDescription 
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <Rufaydium>
#Include <ScriptObject>

script := {
	base 	     : ScriptObj(),
	version      : "1.1.0",
	hwnd     	 : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "",
	moddate      : "",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' ,
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "Amazon Invoice Downloader",
	homepagelink : "the-automator.com/AmazonInvoiceDownloader?src=app",
	donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

tray := A_TrayMenu
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)

; Closing Chrome because One cannot access Profile folder that has been opened by another Chrome.exe
if msgbox("Close Chrome?", ,'Y/N icon?') != "Yes"
	ExitApp

while ProcessExist("chrome.exe")
{
	ProcessClose("chrome.exe")
	Sleep(1000)
}

Chrome := Rufaydium()
if a_username = 'irfan'
	Chrome.Capabilities.setUserProfile('arbabirfan@gmail.com')
else
	Chrome.Capabilities.setUserProfile('joe.glines@gmail.com')
page := Chrome.NewSession()
Page.url := 'https://www.amazon.com/gp/your-account/order-history/ref=ppx_yo_dt_b_pagination_1_2?ie=UTF8&orderFilter=months-3&search=&startIndex=10'
Page.NewTab()
;msgbox 'press f1 while hover link'
; ^f2::
; {
; 	if page.GetTabs().Length != 1
; 		page.ActiveTab()
; 	msgbox page.url
; }

Browser_Forward::Send "^w"
^f1::
Browser_Back::
{
	attrib := GetAttributeUnderMouse(Page)
	 if attrib.has('href')
	{
		url := 'www.amazon.com' attrib['href']
			if RegExMatch(url, 'www.amazon.com[\/\w\.=\?\&]+orderID=(?<order>[\d\-]+)',&out)
		{

			Page.SwitchTab(Page.NewTab())
			Page.url := url
			pdfpath := A_ScriptDir '\invoices\Amazon-' out['order'] '.pdf'
			Page.PrintPdf(pdfpath)
			Page.close()
			run pdfpath
			Notify.show({HDText:'Amazon Invoice',BDText:'Invoice printed to ' pdfpath})
		}
		else
			Notify.show({HDText:'Amazon Invoice',BDText:'Unable to find orderID in URL`n' url})
	}
	else
		Notify.show({HDText:'Amazon Invoice',BDText:'No link found'})
}
; https://www.amazon.com/gp/css/summary/print.html?orderID=114-1235135-7063466&ref=ppx_yo2ov_dt_b_fed_ppx_yo2ov_dt_b_invoice
; OnClipboardChange(printpdf,1)

; printpdf(info)
; {
; 	if info = 1
; 	&& RegExMatch(A_Clipboard, 'www.amazon.com[\/\w\.=\?]+\&orderID=(?<order>[\d\-]+)',&out)
; 	{
; 		Page.url := A_Clipboard
; 		pdfpath := A_ScriptDir '\invoices\Amazon-' out['order'] '.pdf'
; 		Page.PrintPdf(pdfpath)
; 		Notify.show({HDText:'Amazon Invoice',BDText:'Invoice printed to ' pdfpath})

; 	}
; }

GetAttributeUnderMouse(Page)
{
	if type(Page) != 'Session'
		return Map()
	if page.GetTabs().Length != 1
		page.ActiveTab() 
	Page.ExecuteSync("document.onmousemove=function(e){x=e.pageX;y=e.pageY};")
	Page.CDPCall("DOM.getDocument",map("depth", 0))
	x := page.ExecuteSync('return x')
	y := page.ExecuteSync('return y')
	
	if Type(x) != "Integer" || Type(y) != "Integer"
		return Map()
	r := Page.CDPCall("DOM.getNodeForLocation", map("x",x,"y",y))
	if r.has('error')
		return  Map()
	if r.has("backendNodeId")
		Nodeid := r['backendNodeId']
	if r.has("nodeId")
		Nodeid := r['nodeId']
	if !IsSet(Nodeid)
		return Map()
	attrib := getAttributes(Page.CDPCall('DOM.getAttributes',map("nodeId",Nodeid)))
	if !attrib.has('href')
	{
		r := Page.CDPCall('DOM.querySelector',map("nodeId",Nodeid,'selector','a'))
		if r.has('error')
			return  Map()
		if r.has("backendNodeId")
			Nodeid := r['backendNodeId']
		if r.has("nodeId")
			Nodeid := r['nodeId']
		if !IsSet(Nodeid)
			return Map()
		if Nodeid = 0
			return Map()
		return attrib := getAttributes(Page.CDPCall('DOM.getAttributes',map("nodeId",Nodeid)))
	}
	return attrib
	getAttributes(input)
	{
		result := map()
		for k, v in input['attributes']
		{
			if( mod(a_index, 2) != 1)
			{
				result[key] := v
			}
			key := V
		}
		return result
	}
}
; https://www.amazon.com/gp/css/summary/print.html/ref=ppx_yo_dt_b_invoice_o00?ie=UTF8&orderID=113-5441940-3669031