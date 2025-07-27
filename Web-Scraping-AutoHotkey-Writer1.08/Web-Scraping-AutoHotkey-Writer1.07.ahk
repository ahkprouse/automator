#SingleInstance, Force
#NoEnv
; Want a clear path for learning AutoHotkey, Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK Easy
; You can always get a coupon code here:https://the-Automator.com/Learn

Menu, tray, icon, %A_WinDir%\system32\SHELL32.dll, 14
;***********************tray items********************************.
Menu, Tray, NoStandard ;removes default options
Menu, Tray, Add, Helpful Links, Helpful_Links
Menu, Tray, Add, About this program, About
Menu, Tray, Add,
Menu, Tray, Add, Reload
Menu, Tray, Add, Edit
Menu, Tray, Add, Exit
;******************************

;~ https://diymediahome.org/windows-icons-reference-list-with-details-locations-images/
;******************************
;***********Pointer*******************
;******************************
Menu,WebScraping_Pointer,Add,Create IE Object, WebScraping_Pointer_Create_IE
Menu,WebScraping_Pointer,Add,Get pointer to IE window, WebScraping_Pointer_wbGet
Menu,WebScraping_Pointer,Add,Get pointer to IE window***Function***, WebScraping_Pointer_wbGet_Function
Menu,WebScraping_Pointer,Add,Get pointer to IE window with Title and URL, WebScraping_Pointer_Get_IE_Title_URL
Menu,WebScraping_Pointer,Add,Get pointer ***Function***, WebScraping_Pointer_Get_IE_Title_URL_Function


;~ Menu,WebScraping_Pointer,Icon,Create IE Object,         %A_WinDir%\system32\wpdshext.dll,25 ;not in Win10
Menu,WebScraping_Pointer,Icon,Get pointer to IE window, %A_WinDir%\system32\shell32.dll,92

Menu,Webscraping, Add, Pointer, :WebScraping_Pointer ;***********pointer*******************
Menu,Webscraping,Icon,Pointer, %A_WinDir%\system32\imageres.dll, 78

;******************************
;***********Page*******************
;******************************
Menu,Webscraping_Page,Add,Retrieve Current URL, WebScraping_Page_Location_URL
Menu,Webscraping_Page,Add,Scroll to Element on Page, WebScraping_Page_Scroll_to_Element_on_Page
Menu,Webscraping_Page,Add,Retrieve Current Name / Title, WebScraping_Page_Location_Name
Menu,Webscraping_Page,Add,Navigate to Page, WebScraping_Page_Navigate
Menu,Webscraping_Page,Add,Wait for page to load, WebScraping_Page_Wait_Page_Load
Menu,Webscraping_Page,Add,Wait for page to load w/break, WebScraping_Page_Wait_Page_Load_with_Break
Menu,Webscraping_Page,Add,Refresh / Reload, WebScraping_Page_Reload
Menu,Webscraping_Page,Add,Length of History,WebScraping_Page_History_Count
Menu,Webscraping_Page,Add,Navigate Backward in History,WebScraping_Page_Backward
Menu,Webscraping_Page,Add,Navigate Forward in History,WebScraping_Page_Forward
Menu,Webscraping_Page,Add,,
Menu,Webscraping_Page,Add,Navigate over Loop,WebScraping_Page_Loop


Menu,Webscraping,Add ,Page / Navigation, :Webscraping_Page ;***********Page*******************
Menu,Webscraping,Icon,Page / Navigation,     %A_WinDir%\system32\compstui.dll,55

Menu,Webscraping_Page,Icon,Wait for page to load, %A_WinDir%\system32\shell32.dll,200
Menu,Webscraping_Page,Icon,Wait for page to load, %A_WinDir%\system32\shell32.dll,240


Menu,Webscraping_Page,Icon,Navigate to Page, %A_WinDir%\system32\comres.dll,5
Menu,Webscraping_Page,Icon,Refresh / Reload, %A_WinDir%\system32\mmcndmgr.dll,47
;~ Menu,Webscraping_Page,Icon,Navigate Backward in History,%A_WinDir%\system32\wmploc.dll,202 ;not in Win 10
;~ Menu,Webscraping_Page,Icon,Navigate Forward in History ,%A_WinDir%\system32\wmploc.dll,201 ;Not in Win 1
Menu,WebScraping_Pointer,Add
Menu,WebScraping_Pointer,Add



Menu,WebScraping,Add, ;***********spacer*******************




;*******************************************************
;********************Exists_Present***********************************
;********************Wait for exist / visible**************Exist_Numbered_Item_Present*

Menu,Webscraping_Exist,Add,Wait for Element to be Exist ,WebScraping_Exist_Present
Menu,Webscraping_Exist,Add,Wait for specific # to be present,WebScraping_Exist_Numbered_Item_Present
Menu,Webscraping_Exist,Add,Wait for Element to be Visible ,WebScraping_Exist_Is_Visible

Menu,Webscraping,Add ,Element Exists / Visible, :Webscraping_Exist ;***********Page*******************
Menu,Webscraping_Exist,Icon,Wait for specific # to be present, %A_WinDir%\system32\shell32.dll,241
Menu,WebScraping,Add, ;***********spacer*******************



;******************************
;***********GET*******************
;******************************
;~  Menu,WebScraping_Get,Add,Get ID,      WebScraping_Get_ID_Unique
Menu,WebScraping_Get,Add,Get ID, WebScraping_Get_ID_Unique_Dashes
Menu,WebScraping_Get,Add,Get Name-Array,     WebScraping_Get_Name_Array
Menu,WebScraping_Get,Add,Get ClassName-Array,WebScraping_Get_ClassName
Menu,WebScraping_Get,Add,Get TagName-Array,  WebScraping_Get_TagName
Menu,WebScraping_Get,Add,Get DropDown-Array, WebScraping_Get_DropDowns
Menu,WebScraping_Get,Add,Get Check Boxes,    WebScraping_Get_CheckBoxes ;radio buttons
Menu,WebScraping_Get,Add ;***********spacer*******************
Menu,WebScraping_Get,Add,Get attributes,     WebScraping_Get_Attributes ;
Menu,WebScraping_Get,Add,Get all Text on page, WebScraping_Get_All_Text_on_Page
Menu,WebScraping_Get,Add,Get entire HTML from page, WebScraping_Get_All_HTML_on_Page
Menu,WebScraping_Get,Add,Get all Links on page,WebScraping_Get_Links_on_Page

;~  Menu,WebScraping_Get,Icon,Get ID,              %A_WinDir%\system32\compstui.dll,32
Menu,WebScraping_Get,Icon,Get ID,              %A_WinDir%\system32\compstui.dll,32
Menu,WebScraping_Get,Icon,Get Name-Array,      %A_WinDir%\system32\compstui.dll,33
Menu,WebScraping_Get,Icon,Get DropDown-Array,  %A_WinDir%\system32\imageres.dll,157
Menu,WebScraping_Get,Icon,Get Check Boxes,     %A_WinDir%\system32\compstui.dll,5
Menu,WebScraping_Get,Icon,Get all Text on page,%A_WinDir%\system32\imageres.dll,98

Menu,WebScraping_Get_Misc,Add,Get -loop over examples,WebScraping_Get_Misc_Loop
Menu,WebScraping_Get_Misc,Add,Get -loop over Table ,  WebScraping_Get_Misc_Loop_over_Table
Menu,WebScraping_Get_Misc,Add,Get Parameter after ?,  WebScraping_Get_Misc_Search
Menu,WebScraping_Get_Misc,Add,Get Path,               WebScraping_Get_Misc_Path
Menu,WebScraping_Get_Misc,Add,Get Host,               WebScraping_Get_Misc_Host
Menu,WebScraping_Get_Misc,Add,Get Hash,               WebScraping_Get_Misc_Hash
Menu,WebScraping_Get_Misc,Add,Get User Agent,         WebScraping_Get_Misc_UserAgent
Menu,WebScraping_Get_Misc,Add,Get Protocol,           WebScraping_Get_Misc_Protocol
Menu,Webscraping_Get,Add, Miscellenaous , :WebScraping_Get_Misc ;***********Miscellaneous*******************

Menu,Webscraping,Add, Get from page, :Webscraping_Get ;***********Get values*******************
Menu,WebScraping,Icon,Get from page,     %A_WinDir%\system32\mmcndmgr.dll,49

;******************************
;***********SET*******************
;******************************
Menu,WebScraping_Set,Add,Set ID,             WebScraping_Set_ID_Unique_Dashes
Menu,WebScraping_Set,Add,Set Name-Array,     WebScraping_Set_Name_Array
Menu,WebScraping_Set,Add,Set Classname-Array,WebScraping_Set_ClassName_Array
Menu,WebScraping_Set,Add,Set TagName-Array,  WebScraping_Set_TagName
Menu,WebScraping_Set,Add,Set DropDown-Array, WebScraping_Set_DropDowns
Menu,WebScraping_Set,Add,Set Check Boxes,    WebScraping_Set_CheckBoxes
Menu,WebScraping_Set,Add,
Menu,WebScraping_Set,Add,Set attributes,     WebScraping_Set_Attributes ;
Menu,WebScraping_Set_Misc,Add,Set UserAgent,    WebScraping_Set_Misc_UserAgent

Menu,WebScraping_Set,Icon,Set ID,              %A_WinDir%\system32\compstui.dll,32
Menu,WebScraping_Set,Icon,Set Name-Array,      %A_WinDir%\system32\compstui.dll,33
Menu,WebScraping_Set,Icon,Set DropDown-Array,  %A_WinDir%\system32\imageres.dll,157
Menu,WebScraping_Set,Icon,Set Check Boxes,     %A_WinDir%\system32\compstui.dll,5

Menu,WebScraping_Set,Add,Miscellenaous, :WebScraping_Set_Misc ;***********Set Miscellaneous*******************

Menu,WebScraping,Add,Set on page, :WebScraping_Set ;***********Set values*******************
Menu,WebScraping,Icon,Set on page,     %A_WinDir%\system32\mmcndmgr.dll,58

;******************************
;***********Click*******************
;******************************
Menu,WebScraping_Trigger_No_EventListener,Add,Click Link,          	 WebScraping_Click_Click
Menu,WebScraping_Trigger_No_EventListener,Add,Click text on page,  	 WebScraping_Click_Click_Link_Specific_Text
Menu,WebScraping_Trigger_No_EventListener,Add,Fire Event-Change,    	 WebScraping_Click_Fire_Event_Change
Menu,WebScraping_Trigger_No_EventListener,Add,Fire Event-Click,   	 WebScraping_Click_Fire_Event_Click
Menu,WebScraping_Trigger_No_EventListener,Add,Focus (place cursor),	 WebScraping_Click_Focus
Menu,WebScraping_Trigger_No_EventListener,Add,Focus and send Enter Key,WebScraping_Send_EnterKey_to_Element

Menu,WebScraping_Trigger,Add,No Event Listeners,:WebScraping_Trigger_No_EventListener
Menu,WebScraping_Trigger,Add
;~ Menu,WebScraping_Trigger,Icon,Click Link,           %A_WinDir%\system32\wpdshext.dll,25 ;Not in Win 10
Menu,WebScraping_Trigger_No_EventListener,Icon,Click text on page,   %A_WinDir%\system32\wpdshext.dll,22
Menu,WebScraping_Trigger_No_EventListener,Icon,Focus (place cursor), %A_WinDir%\system32\wmploc.dll,28

;********************Mouse Events***********************************
Menu,WebScraping_Trigger_Mouse,Add,mouse Mouse Over,  		WebScraping_Trigger_Mouse_MouseOver
Menu,WebScraping_Trigger_Mouse,Add,mouse Down,      	 	WebScraping_Trigger_Mouse_Down
Menu,WebScraping_Trigger_Mouse,Add,mouse Up,         		WebScraping_Trigger_Mouse_Up
Menu,WebScraping_Trigger_Mouse,Add,mouse Click,      		WebScraping_Trigger_Mouse_Click
Menu,WebScraping_Trigger_Mouse,Add,mouse Double Click,  		WebScraping_Trigger_Mouse_DoubleClick
Menu,WebScraping_Trigger,Add,Mouse Events,:WebScraping_Trigger_Mouse
Menu,WebScraping_Trigger,Add

;********************Keyboard Events***********************************

menu,WebScraping_Trigger_Keyboard,Add, Keyboard Up, 		WebScraping_Trigger_Keyboard_Up
menu,WebScraping_Trigger_Keyboard,Add, Keyboard Down, 		WebScraping_Trigger_Keyboard_Down
menu,WebScraping_Trigger_Keyboard,Add, Key Press, 		WebScraping_Trigger_KeyboardPress
Menu,WebScraping_Trigger,Add,Keyboard Events,:WebScraping_Trigger_Keyboard
Menu,WebScraping_Trigger,Add

;********************Miscellaneous Events***********************************

;~Menu,WebScraping_Trigger_Misc,Add,Cut, 					WebScraping_Trigger_Misc_Cut
;~Menu,WebScraping_Trigger_Misc,Add,Copy,					WebScraping_Trigger_Misc_Copy
;~Menu,WebScraping_Trigger_Misc,Add,Paste,				WebScraping_Trigger_Misc_Paste
Menu,WebScraping_Trigger_Misc,Add,Input,				WebScraping_Trigger_Misc_Input
Menu,WebScraping_Trigger_Misc,Add,Change,				WebScraping_Trigger_Misc_Change
Menu,WebScraping_Trigger_Misc,Add,Focus,				WebScraping_Trigger_Misc_Focus
Menu,WebScraping_Trigger_Misc,Add,Focusin,				WebScraping_Trigger_Misc_Focus_In
Menu,WebScraping_Trigger,Add,Miscellaneous Events,:WebScraping_Trigger_Misc



Menu,WebScraping,Add,Trigger Action, :WebScraping_Trigger ;***********click *******************
Menu,WebScraping,Icon,Trigger Action,     %A_WinDir%\system32\mmcndmgr.dll,51

Menu,WebScraping,Add, ;***********spacer*******************

;******************************
;***********Advanced*******************
;******************************
;***********Frames*******************
;******************************
;***********Single level frames*******************
Menu,Frames_One_Level,Add, Get Length of Frames, Advanced_Frame_One_level_Length
Menu,Frames_One_Level,Add, Frame has Name or ID- Get URL,  Advanced_Frame_One_level_Name_or_ID_URL
Menu,Frames_One_Level,Add, Frame has Name or ID- Get Text, Advanced_Frame_One_level_Name_or_ID_Get_Text
Menu,Frames_One_Level,Add,
Menu,Frames_One_Level,Add, Frame NO Name or ID- Get URL,  Advanced_Frame_One_level_NO_Name_or_ID_URL
Menu,Frames_One_Level,Add, Frame NO Name or ID- Get Text, Advanced_Frame_One_level_NO_Name_or_ID_Get_Text
Menu,Frames_One_Level,Add, Frame NO Name or ID- 'Access Denied' issue, Advanced_Frame_One_level_NO_Name_or_ID_Access_Denied
Menu,WebScraping_Advanced,Add, Frames-One Level, :Frames_One_Level ;***********Advanced*******************

;***********multi level frames*******************
Menu,Frames_Multi_Level,Add, Frame has Name or ID- Get URL, Advanced_Frame_Multi_level_Name_or_ID_URL
Menu,Frames_Multi_Level,Add, Frame has Name or ID- Get Text, Advanced_Frame_Multi_level_Name_or_ID_Get_Text
Menu,Frames_Multi_Level,Add,
Menu,Frames_Multi_Level,Add, Frame NO Name or ID- Get URL, Advanced_Frame_Multi_level_NO_Name_or_ID_URL
Menu,Frames_Multi_Level,Add, Frame NO Name or ID- Get Text, Advanced_Frame_Multi_level_NO_Name_or_ID_Get_Text

Menu,WebScraping_Advanced,Add, Frames-Multi-Level, :Frames_Multi_Level ;***********Advanced*******************


Menu,WebScraping,Add, Advanced, :WebScraping_Advanced ;***********Advanced*******************

;******************************
;***********Misc*******************
;******************************
Menu,WebScraping_Misc,Add,Get IE Cookies   ,  WebScraping_Misc_Get_Cookies
Menu,WebScraping_Misc,Add,Maximize Set IE Cookies,  WebScraping_Misc_Set_Cookies

Menu,WebScraping_Misc,Add,Maximize IE Window   ,  WebScraping_Misc_Maximize_IE_Window
Menu,WebScraping_Misc,Add,Hide Toolbars, WebScraping_Misc_Hide_Toolbars
Menu,WebScraping_Misc,Add,Show Toolbars, WebScraping_Misc_Show_Toolbars
Menu,WebScraping_Misc,Add,Read HTML File & Load to DOM, WebScraping_Misc_Read_File_Load_to_DOM

Menu,WebScraping_Misc,Icon,Get IE Cookies , 		  	  %A_WinDir%\system32\mmcndmgr.dll,1
Menu,WebScraping_Misc,Icon,Hide Toolbars,     		  %A_WinDir%\system32\mmcndmgr.dll,40
Menu,WebScraping_Misc,Icon,Show Toolbars,                %A_WinDir%\system32\mmcndmgr.dll,7
Menu,WebScraping_Misc,Icon,Read HTML File & Load to DOM, %A_WinDir%\system32\mmcndmgr.dll,20

Menu,WebScraping,Add, Miscellaneous, :WebScraping_Misc ;***********Miscellaneous*******************

;******************************
;***********Help*******************
;******************************

Menu,WebScraping,Add, ;***********spacer*******************
Menu,Webscraping,Add, Helpful links, Helpful_Links
return


;******************************
^Lbutton::Menu, WebScraping, Show  ; right mouse and windows
;~ Browser_Forward::Reload
;******************************




;******************************
;***********Pointer*******************
;******************************
;Pointer***********create IE com*******************
WebScraping_Pointer_Create_IE:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb := ComObjCreate(""InternetExplorer.Application"") `;create IE Object`r`npwb.visible:=true  `; Set the IE object to visible"
Gosub Paste_and_Restore_Stored_Clipboard
return

;Pointer***********pointer wbGet*******************
WebScraping_Pointer_wbGet:
Store:=ClipboardAll  ;****Store clipboard ****
clipboard := "pwb := WBGet()"
Gosub Paste_and_Restore_Stored_Clipboard
return
;******************Function*************************************
WebScraping_Pointer_wbGet_FUNCTION:
Clipboard=
(  Join`r`n
;************Pointer to Open IE Window******************
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) {               ;// based on ComObjQuery docs
   static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
        , IID := "{0002DF05-0000-0000-C000-000000000046}"   ;// IID_IWebBrowserApp
;//     , IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"   ;// IID_IHTMLWindow2
   SendMessage msg, 0, 0, Internet Explorer_Server`%Svr#`%, `%WinTitle`%

   if (ErrorLevel != "FAIL") {
      lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
      if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
         DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
         return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
      }
   }
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;Pointer***********Title and URL*******************
WebScraping_Pointer_Get_IE_Title_URL:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard = pwb:=setWbCom("LinkedIn", "www.linkedin.com") ;get pointer to specific window title and domain
Gosub Paste_and_Restore_Stored_Clipboard
return

WebScraping_Pointer_Get_IE_Title_URL_FUNCTION:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
`;***********Function*******************
setWbCom(name=false, url=false) {
    ;   Set web browser COM pointer        ;   eserv_flag sets this.wb_eserv
    if (!name AND !url) {
        ;    Clear COM object
        return false
    }
    ;   Set defaults.  No promises.
    wb:=false
    For wb in ComObjCreate( "Shell.Application" ).Windows {
        Try {
            If ((InStr(wb.locationName, name) AND name) OR (InStr(wb.locationURL, url) AND url)) && InStr(wb.FullName, "iexplore.exe") {
                return wb
            }
        } Catch, e {
            if (e AND this.debug) {
                FileAppend, `% "``r``nCOM Error: " . e, `% this.debug_file
            }
        }
    }
    if (debug) {
        this.errorWindow("Failed to find web browser.``r``nName:``t" . name . "``r``nURL:``t" . url)
    }
    return false
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;******************************
;***********page / URL*******************
;******************************
;page***********Location url*******************
WebScraping_Page_Location_URL:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="var:=pwb.LocationURL `;grab current url"
Gosub Paste_and_Restore_Stored_Clipboard
return

WebScraping_Page_Scroll_to_Element_on_Page:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.getElementByID(""XXXXX"").scrollIntoView(1) `;Scroll to element on page"
Gosub Paste_and_Restore_Stored_Clipboard
return

WebScraping_Page_Location_Name:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="var:=pwb.LocationName `;grab page Title"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********Navigate*******************
WebScraping_Page_Navigate:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.Navigate(""www.google.com"") `;Navigate to URL"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********wait until page loads*******************
WebScraping_Page_Wait_Page_Load:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="while pwb.busy or pwb.ReadyState != 4 `;Wait for page to load`n`tSleep, 100"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********wait for page to load, but have break in case the page never reports finish loading********************************************
WebScraping_Page_Wait_Page_Load_with_Break:
Clipboard:="while(pwb.busy or pwb.ReadyState != 4){ `;Wait for page to load`n`tSleep, 100`nif(A_Index=80) `;Adjust this for how many times you wish to wait`n	Break`n}"
Gosub Paste_and_Restore_Stored_Clipboard
return


;*******************************************************
;********************Exists_Present***********************************
;*******************************************************;*******************************************************
WebScraping_Exist_Present:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
while (! Element:=pwb.document.getElementByID("XXXXXXXXXXXXXXXXXXXXX")) ;Make sure element exists before moving forward
	Sleep, 50
)
Gosub Paste_and_Restore_Stored_Clipboard
Return
;page;**********Wait for # item to be present before moving forward****
WebScraping_Exist_Numbered_Item_Present:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
while (pwb.document.getElementsByClassName("XXXXXXXXXX").length<3) ;change number to your item in the array
	Sleep, 200
)
Gosub Paste_and_Restore_Stored_Clipboard
Return

;********************Element is Visible***********************************
WebScraping_Exist_Is_Visible:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
while (! Element:=pwb.document.getElementByID("XXXXXXXXXXXXXXXXXXXXX")) ;This makes sure it exists before going forward
	Sleep, 50

While (Element.offsetWidth=0) AND (Element.offsetHeight=0) ;if height=0 & Width=0 then not visible
	Sleep, 50		
)
Gosub Paste_and_Restore_Stored_Clipboard
Return






;page***********refresh page*******************
WebScraping_Page_Reload:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.refresh `;Reload page"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********History count*******************
WebScraping_Page_History_Count:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="History_CT:=pwb.document.parentWindow.history.length `;Count of History"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********Go backward in history*******************
WebScraping_Page_Backward:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.parentWindow.history.go(-1) `;Go Backward one page"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********Go forward in history*******************
WebScraping_Page_Forward:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.parentWindow.history.go(1) `;Go Forward one page"
Gosub Paste_and_Restore_Stored_Clipboard
return

;page***********Navigate over loop*******************
WebScraping_Page_Loop:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
var=
`(
89147

94947
30606
75019
73112
22315
97520

94134
94931
91711
91106
95665
28203
`)

;***********loop over vars*******************
Loop, parse, Var, ``n, ``r ;loop over Var line by line
{
IfEqual, A_LoopField,,continue ;Skip loop if blank
IfEqual, A_index,5,break ;Break if index =value
;~ MsgBox,,Loop index and values, `% A_index a_tab A_LoopField

pwb := WBGet()  ;included in loop just in case gets dissconnected
URL:="http://zipwho.com/?mode=zip&zip=" . A_LoopField ; concatenate url and current row

;***********Navigate to a page*******************
pwb.Navigate(URL) ;Navigate to URL
while pwb.busy or pwb.ReadyState != 4 ;Wait for page to load
	Sleep, 100

;***********Grab a data point*******************
Value:=pwb.document.all.details_table.all.tags("TD").item[1].InnerTEXT  ;Unique ID -no dashes
Agg_Values.=A_LoopField a_tab Value "``r``n"  ;Store in new Aggregate variable
}

;***********Now display extracted data*******************
gui, font, s12 cBlue q5, Book Antiqua
Gui,Add,Edit,w900 h600 -Wrap, `%Agg_Values`%
gui,show
return

;************Pointer to Open IE Window******************
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) {               ;// based on ComObjQuery docs
   static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
        , IID := "{0002DF05-0000-0000-C000-000000000046}"   ;// IID_IWebBrowserApp
;//     , IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"   ;// IID_IHTMLWindow2
   SendMessage msg, 0, 0, Internet Explorer_Server`%Svr#`%, `%WinTitle`%

   if (ErrorLevel != "FAIL") {
      lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
      if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
         DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
         return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
      }
   }
}
return
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;***********wait until exists*******************
;~ WebScraping_Wait_Until_Exists:
;~ Store:=ClipboardAll  ;****Store clipboard ****
;~ Clipboard=
;~ (  Join`r`n
;~ )
;~ Gosub Paste_and_Restore_Stored_Clipboard
;~ return

;******************************
;***********GET*******************
;GET*********Get Unique ID on page*********************
WebScraping_Get_ID_Unique:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.all.XXXXXXX.Value `;Unique ID -no dashes"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get ID with dashes in name*******************
WebScraping_Get_ID_Unique_Dashes:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.getElementByID(""XXX"").Value `;Unique ID"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get Name (returns array)*******************
WebScraping_Get_Name_Array:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.GetElementsByName(""XXXX"").item[0].Value `;Object Name- Get array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get by Class name (returns array)*******************
WebScraping_Get_ClassName:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.getElementsByClassName(""classnameXXX"").item[0].Value `;Get classname and Array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get by Tag name (returns array)*******************
WebScraping_Get_TagName:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.GetElementsByTagName(""tagnameXXX"").item[0].Value `;Get Tagname and Array value"
Gosub Paste_and_Restore_Stored_Clipboard
return


;GET***********Get dropdowns*******************
WebScraping_Get_DropDowns:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Var:=pwb.document.GetElementsByTagName("tagnameXXX").item[0].selectedIndex ;Set Tagname and Array value
Var:=pwb.document.GetElementsByTagName("tagnameXXX").item[0].Value ;Set Tagname and Array value
)
Gosub Paste_and_Restore_Stored_Clipboard
return


;GET***********Get check boxes*******************
WebScraping_Get_CheckBoxes:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.GetElementsByTagName(""tagnameXXX"").item[0].checked  `;Set Tagname and Array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get Attributes*******************
WebScraping_Get_Attributes:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.GetElementsByTagName(""Input"").item[0].getAttribute(""type"") `;gets the value of an attribute"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get all text on page*******************
WebScraping_Get_All_Text_on_Page:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Var:=pwb.document.documentElement.innerText `;Get All text on page"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get all HTML from page*******************
WebScraping_Get_All_HTML_on_Page:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="clipboard:=pwb.document.documentElement.outerhtml `;Get HTML from page (great for supporting people)"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET***********Get links and text on page*******************
WebScraping_Get_Links_on_Page:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Links := pwb.Document.Links ; collection of hyperlinks on the page
Loop `% Links.Length ; Loop through links
If ((Link := Links[A_Index-1].InnerText) != "") { ; if the link is not blank
   (OuterHTML := Links[A_Index-1].OuterHTML)  ; Grab outerHTML for each link
      Link:=StrReplace(Link,"``n")
      Link:=StrReplace(Link,"``r")
      Link:=StrReplace(Link,"``t")
      OuterHTML:=StrReplace(OuterHTML,"``n")
      OuterHTML:=StrReplace(OuterHTML,"``r")
      OuterHTML:=StrReplace(OuterHTML,"``t")

Msg .= A_Index-1 A_Space A_Space A_Space Link A_Tab OuterHTML "``r``n" ; add items to the msg list
}
gui, font, s12 cBlue q5, Book Antiqua
Gui,Add,Edit,w1000 h600 -Wrap, `%msg`%
gui,show
return
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;******************************
;***********Get MISC*******************
;******************************
;GET-Loop***********Get loop count and begin looping *******************
WebScraping_Get_Misc_Loop:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
loop `% (elements := pwb.document.getElementByID("results").childnodes).length ;stores elements for looping and gets length in same line
	MsgBox `% elements[a_index-1].InnerTEXT

;***********second example*******************
loop `% (elements := pwb.document.getElementsByTagName("address")).length  ;Stores elements for loop and gets length in same line
      if (elements[A_index-1].getAttribute("data-test-id") = "prospect.address")
         Address := elements[A_index-1].innertext
	 
;******Third example with While loop***Note a_index-1 is in first row, not each individual one*	 
While(ele:=pwb.document.getElementsByClassName("")[a_index-1]){ ;store reference to element in ele While looping over elements
	:=ele.getElementByID("").InnerTEXT ;ID
	:=ele.getElementsByClassName("").item[0].InnerTEXT ;Class Name
	:=ele.getElementsByName("").item[0].InnerText ;Name
	:=ele.getElementsByTagName("").item[0].InnerTEXT ;TagName
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return

WebScraping_Get_Misc_Loop_over_Table:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
;*********** loop over table*****Maestrith helped significantly with the listview portion*******
pwb := WBGet() ;connect to current IE window (Make sure WBGet function is in your library or this script)
Gui,DD:destroy
loop, `% Pwb.Document.All.Tags("TABLE").length ;get count of all tables on page
    Table_List.=A_index-1 "|" ;prep for dropdown list

gui,DD:add, dropdownlist,w200 r10 vTable_Nb gSubmit_All, `%Table_List`%
gui,DD:show
return

Submit_all:
Gui,DD:Submit
Gui,DD:destroy

;***********now extract data*******************
Data:=[]
loop, `% Pwb.Document.All.Tags("TABLE")[Table_Nb].Rows.Length-1 {
	Row:=Pwb.Document.All.Tags("TABLE")[Table_Nb].Rows[A_Index-1]
	rows:="" ;clear out rows
	loop, `% row.cells.length{
		rows.= row.cells[A_Index-1].innerTEXT a_tab
	}
	if(A_Index=1)
		Headers:=RegExReplace(rows,"\t","|")
	else
		Data.Push(StrSplit(rows,"`t")) ;add rows to data object
}

Gui,Add,ListView,h900 w1200,`%Headers`%
for a,b in Data
	LV_Add("",b*) ;use variadic function to add columns
Loop,`% LV_GetCount("Column")
	LV_ModifyCol(A_Index,"AutoHDR") ;adjust column width based on data
gui, show
Table_List:=""
return
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET-Misc***********Get text of URL after question mark*******************
WebScraping_Get_Misc_Search:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Search:=pwb.document.location.Search `;gets substring of URL following question mark"
Gosub Paste_and_Restore_Stored_Clipboard
Return

;GET-Misc***********Get Path*******************
WebScraping_Get_Misc_Path:
Clipboard:="Path:=pwb.document.location.pathname `;returns pathname"
Gosub Paste_and_Restore_Stored_Clipboard
Return

;GET-Misc***********Get Host*******************
WebScraping_Get_Misc_Host:
Clipboard:="Host:=pwb.document.location.hostname `;returns host"
Gosub Paste_and_Restore_Stored_Clipboard
Return

;GET-Misc***********Get After hash*******************
WebScraping_Get_Misc_Hash:
Clipboard:="Hash:=pwb.document.location.hash `;retreives everyting from the # on"
Gosub Paste_and_Restore_Stored_Clipboard
Return

;GET-Misc***********Get User Agent*******************
WebScraping_Get_Misc_UserAgent:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="User_Agent := pwb.document.parentWindow.navigator.userAgent `;Get User Agent"
Gosub Paste_and_Restore_Stored_Clipboard
return

;GET-Misc***********Get Protocol*******************
WebScraping_Get_Misc_Protocol:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Protocol:=pwb.document.location.protocol `;retreives the protocol (http, https, etc)"
Gosub Paste_and_Restore_Stored_Clipboard
return

;******************************
;***********Set*******************
;******************************
;SET***********Set Unique ID*******************
WebScraping_Set_ID_Unique:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.all.XXXXXXX.Value :=""XXX"" `;Unique ID -no dashes"
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Set Unique ID with dashes in name *******************
WebScraping_Set_ID_Unique_Dashes:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.getElementByID(""XXX"").Value :=""XXX"" `;Unique ID-with dashes"
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Set Name (Need to set array value)*******************
WebScraping_Set_Name_Array:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.GetElementsByName(""XXXX"").item[0].Value :=""XXX"" `;Object Name- Set array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Set value using ClassName (set array Value) *******************
WebScraping_Set_ClassName_Array:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.getElementsByClassName(""classnameXXX"").item[0].Value :=""XXX"" `;Set Classname and Array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Set value using tag name (set array Value) *******************
WebScraping_Set_TagName:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.GetElementsByTagName(""tagnameXXX"").item[0].Value :=""XXX"" `;Set Tag name and Array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Set value of Dropdown *******************
WebScraping_Set_DropDowns:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
pwb.document.GetElementsByTagName("tagnameXXX").item[0].selectedIndex :=0 ;Set Tagname and Array value
pwb.document.GetElementsByTagName("tagnameXXX").item[0].Value :="XXX" ;Set Tagname and Array value
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Select check box *******************
WebScraping_Set_CheckBoxes:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
pwb.document.GetElementsByTagName("tagnameXXX").item[0].checked :=1 ;Set Tagname and Array value
pwb.document.GetElementsByTagName("tagnameXXX").item[0].checked :=0 ;Set Tagname and Array value
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET***********Set Attributes*******************
WebScraping_Set_Attributes:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.GetElementsByTagName(""Input"").item[0].SetAttribute(""size"") := 50 `;sets an attribute value for an element"
Gosub Paste_and_Restore_Stored_Clipboard
return

;SET-Misc***********Set User Agent *******************
WebScraping_Set_Misc_UserAgent:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.Navigate(""http://whatsmyuseragent.com"",0,0,0,""User-Agent: Mozilla/5.0 (Joe's Agent; Test) AppleWebKit/536.26 (KHTML, like Gecko)"") `;set UserAgent"
Gosub Paste_and_Restore_Stored_Clipboard
return

;******************************
;***********Trigger*******************
;******************************
;********************Mouse***********************************
WebScraping_Trigger_Mouse_Down:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
MouseDown:= pwb.document.createEvent("MouseEvent") ;Create Mouse Down Event
MouseDown.initMouseEvent("mousedown",true,false,,,,,,,,,,,,0) ;Initialize the Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(MouseDown) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return
WebScraping_Trigger_Mouse_Up:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
MouseUp  := pwb.document.createEvent("MouseEvent")  ;Mouse Up
MouseUp.initMouseEvent("mouseup",true,false,,,,,,,,,,,,,0) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(MouseUp) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return

WebScraping_Trigger_Mouse_Click:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
MouseClick  := pwb.document.createEvent("MouseEvent")  ;Mouse Click
MouseClick.initMouseEvent("click",true,false,,,,,,,,,,,,,0) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(MouseClick) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return

;********************Mouse over***********************************
WebScraping_Trigger_Mouse_MouseOver:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
MouseOver  := pwb.document.createEvent("MouseEvent")  ;Mouse Over
MouseOver.initMouseEvent("mouseover",true,false,,,,,,,,,,,,,0) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(MouseOver) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return

;********************Double click***********************************
WebScraping_Trigger_Mouse_DoubleClick:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
MouseDblClick  := pwb.document.createEvent("MouseEvent")  ;Mouse Double Click
MouseDblClick.initMouseEvent("dblclick",true,false,,,,,,,,,,,,,0) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(MouseDblClick) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return


;********************keyboard Down***********************************
WebScraping_Trigger_Keyboard_Down:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
KeyboardDown  := pwb.document.createEvent("KeyboardEvent")  ;Create Keydown event
KeyboardDown.initKeyboardEvent("keydown", true, true, pwb.document.defaultView, false, false, false, false, k, k) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(KeyboardDown) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return
;********************keyboard up***********************************
WebScraping_Trigger_Keyboard_Up:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
KeyboardUp  := pwb.document.createEvent("KeyboardEvent")  ;Create Keydown eventdsddsdsd
KeyboardUp.initKeyboardEvent("keyup", true, true, pwb.document.defaultView, false, false, false, false, k, k) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(KeyboardUp) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return


;********************keyboard Press***********************************
WebScraping_Trigger_KeyboardPress:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
KeyboardPress  := pwb.document.createEvent("KeyboardEvent")  ;Create Keydown eventdsddsdsd
KeyboardPress.initKeyboardEvent("keypress", true, true, pwb.document.defaultView, false, ele, false, false, k, k) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(KeyboardPress) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return


;********************Miscellaneous***********************************
;********************Cut***********************************
WebScraping_Trigger_Misc_Cut:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Cut := pwb.document.createEvent("ClipboardEvent")  ;Create KeyboardPress Event
Cut.initMouseEvent("cut",true,false,,,,,,,,,,,,0) ;Initialize the event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(Cut) ;Replace "**YOUR_Element_HERE**" with pointer to your Element
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;********************Copy***********************************
WebScraping_Trigger_Misc_Copy:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;********************Paste***********************************
WebScraping_Trigger_Misc_Paste:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Paste := pwb.document.createEvent("ClipboardEvent")  ;Create KeyboardPress Event
Paste.initMouseEvent("cut",true,false,,,,,,,,,,,,0) ;Initialize the event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(Paste) ;Replace "**YOUR_Element_HERE**" with pointer to your Element
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;********************Input***********************************
WebScraping_Trigger_Misc_Input:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Input := pwb.document.createEvent("Event")  ;Create Keydown eventdsddsdsd
Input.initEvent("input", true, true) ;Initialize Event

**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(Input) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return
;********************Change***********************************
WebScraping_Trigger_Misc_Change:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Change := pwb.document.createEvent("Event")  ;Create Keydown eventdsddsdsd
Change.initEvent("change", true, true) ;Initialize Event

;**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(Change) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return
;********************Focus***********************************
WebScraping_Trigger_Misc_Focus:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
Focus := pwb.document.createEvent("FocusEvent")  ;Create Keydown eventdsddsdsd
Focus.initEvent("focus", true, true) ;Initialize Event
;**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(Focus) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return

;*********************Focus in**********************************
WebScraping_Trigger_Misc_Focus_In:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
FocusIn := pwb.document.createEvent("FocusEvent")  ;Create Keydown eventdsddsdsd
FocusIn.initEvent("focusin", true, true) ;Initialize Event
;**Set your element here**
**YOUR_Element_HERE**.dispatchEvent(FocusIn) ;Replace "**YOUR_Element_HERE**" with pointer to your Element

)
Gosub Paste_and_Restore_Stored_Clipboard
return







;CLICK***********Click link*******************
WebScraping_Click_Click:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.all.tags(""tagnameXXX"")[8].click() `; Acts like clicking the link"
Gosub Paste_and_Restore_Stored_Clipboard
return

;CLICK***********click link with specific text*******************
WebScraping_Click_Click_Link_Specific_Text:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
ClickLink(pwb,Text:="text to click")

ClickLink(PXL,Text=""){
ComObjError(false)
Links := PXL.Document.Links
Loop `% Links.Length
   If (Links[A_Index-1].InnerText = Text ) { ; search for Text
      Links[A_Index-1].Click() ;click it when you find it
      break
   }
ComObjError(True)
}
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;CLICK***********Fire event after clicking*******************
WebScraping_Click_Fire_Event_Change:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.all.tags(""tagnameXXX"").item[8].fireEvent(""onchange"")  `; Sometimes needed in conjunction with changing value"
Gosub Paste_and_Restore_Stored_Clipboard
return

WebScraping_Click_Fire_Event_Click:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.all.tags(""tagnameXXX"").item[8].fireEvent(""onclick"")  `; Sometimes needed in conjunction with click()"
Gosub Paste_and_Restore_Stored_Clipboard
return

;CLICK***********Focus in Input field*******************
WebScraping_Click_Focus:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="pwb.document.all.tags(""tagnameXXX"").item[8].focus() `; Acts like clicking the link"
Gosub Paste_and_Restore_Stored_Clipboard
return
;*******************************************************


WebScraping_Send_EnterKey_to_Element:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
pwb.document.getElementsByClassName("tagnameXXX").item[0].focus()
Sleep, 100
pwb.document.ExecCommand("paste") ; paste - triggers DOM/javascript events
Sleep, 100
ControlSend, Internet Explorer_Server1, {Enter}, `% "Ahk_id " pwb.hwnd ;hit enter
)
Gosub Paste_and_Restore_Stored_Clipboard
return








;******************************
;***********Advanced*******************
;******************************
;***********Frames- One level*******************
Advanced_Frame_One_level_Length:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames.length `; Returns count of main frames"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_One_level_Name_or_ID_URL:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames(""XXX_Name_or_ID_XXXX"").document.location.href `; Use if one level & has Name or ID"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_One_level_Name_or_ID_Get_Text:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames(""XXX_Name_or_ID_XXXX"").document.all.tags(""BODY"").item[0].InnerText `;Use if One level & has Name or ID"
Gosub Paste_and_Restore_Stored_Clipboard
return


Advanced_Frame_One_level_NO_Name_or_ID_URL:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames[0].document.location.href `; Use if one level & does NOT have a Name or ID"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_One_level_NO_Name_or_ID_Get_Text:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames[0].document.all.tags(""BODY"").item[0].InnerText `;Use if One level & does NOT have a Name or ID"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_One_level_NO_Name_or_ID_Access_Denied:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
;****** access denied means you need to query the object for the document first****
;****** Read more here:  https://autohotkey.com/board/topic/91443-comie-error-0x80070005-access-is-denied-with-paypal/  *****
Frame_NB:=0 ;determine what frame you want (but note IWB2 learner tool may be wrong.  :(

pwb := WBGet()
frame:= ComObjActive(9,ComObjQuery(pwb.document.parentwindow.frames[Frame_NB],"{332C4427-26CB-11D0-B483-00C04FD90119}","{332C4427-26CB-11D0-B483-00C04FD90119}"),1).document.documentElement ;Get pointer to pointer similar to pwb.document.  ;querying the Comobject of the iframe's contentWindow one gets a pointer to its interface. This pointer needs to be wrapped with ComObjectActive()
SciTE_Output(frm.OuterHTML) ;Show all html from frame
MsgBox `% frame.GetElementsByTagName("Body")[0].innertext ;get Text from first Body tag on 4th frame
MsgBox `% frame.GetElementsByTagName("Body")[0].InnerHTML ;get InnerHTML from first body tag on 4th frame
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;******************************
;***********Frames- Multi Level*******************
;******************************
Advanced_Frame_Multi_level_Name_or_ID_URL:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames(""XXX_Name_or_ID_XXXX"")[0].document.location.href `; Use for multi-level & change array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_Multi_level_Name_or_ID_Get_Text:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames(""XXX_Name_or_ID_XXXX"")[0].document.all.tags(""BODY"")[0].InnerText `; Use for multi-level & change array value"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_Multi_level_NO_Name_or_ID_URL:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames[2][0].document.location.href `; Use for Multi-level & NO name or ID"
Gosub Paste_and_Restore_Stored_Clipboard
return

Advanced_Frame_Multi_level_NO_Name_or_ID_Get_Text:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="MsgBox % pwb.document.parentWindow.frames[2][0].document.all.tags(""BODY"").item[0].InnerText `; Use for Multi-level & NO name or ID"
Gosub Paste_and_Restore_Stored_Clipboard
return


;~ MsgBox % Pwb.document.parentWindow.frames("view")[0].document.location.href

;******************************
;***********Miscellaneous*******************
;******************************
;********************Get cookies***********************************
WebScraping_Misc_Get_Cookies:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard:="Cookies:=pwb.document.cookie"
Gosub Paste_and_Restore_Stored_Clipboard
Return

WebScraping_Misc_Set_Cookies:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=pwb.document.cookie:="msdn=JoeGlines"
Gosub Paste_and_Restore_Stored_Clipboard
Return

;************Maximize IE WIndow******************
WebScraping_Misc_Maximize_IE_Window:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=WinMaximize, `% "ahk_id " pwb.HWND
Gosub Paste_and_Restore_Stored_Clipboard
Return

;MISC***********Hide toolbars*******************
WebScraping_Misc_Hide_Toolbars:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
pwb.addressbar:=0 ;Hide Addressbar
pwb.Toolbar:=0    ;Hide Toolbar
pwb.Statusbar:=0  ;Hide Statusbar
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;MISC***********Show toolbars*******************
WebScraping_Misc_Show_Toolbars:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
pwb.addressbar:=1 ;Show Addressbar
pwb.Toolbar:=1    ;Show Toolbar
pwb.Statusbar:=1  ;Show Statusbar
)
Gosub Paste_and_Restore_Stored_Clipboard
return

;MISC***********Load HTML file to DOM*******************
WebScraping_Misc_Read_File_Load_to_DOM:
Store:=ClipboardAll  ;****Store clipboard ****
Clipboard=
(  Join`r`n
FileRead,html,*P65001 B:\Progs\AutoHotkey_L\AHK Work\RealEstate\Probate\Denton\Search.html
document := ComObjCreate("HTMLfile")
document.write(html)
document.getElementsByClassName("test").item[0].Value
)
Gosub Paste_and_Restore_Stored_Clipboard
return
;******************************
;***********Advanced*******************
;***********to do*******************
;~ 1) example getting using ID first, then getTag name-  in one line
;~ 2) Example get pointer to ID, then refernce pointer later
;~ 4) Wait for exist
;***********Wait for exists*******************
;~ Wait_for_Exist:
;~ while Pwb.document.parentWindow.frames[1].document.all =  ;wait for DOM to exist
;~ Sleep, 100

;******************************
;***********Subroutines*******************
;******************************
;*******Store Clipboard- ****************
Store_Clipboard_Copy_Selected_Text:
Store:=ClipboardAll  ;Store full version of Clipboard
clipboard :="" ; Empty the clipboard
Send, ^c  ;Depending on your OS and Admin level- you might want to check this
ClipWait, 1
return

;***********Restore clipboard*******************
Paste_and_Restore_Stored_Clipboard:  ;~ MsgBox % clipboard
Sleep, 50
Send, ^v ;Depending on your OS and Admin level- you might want to check this
Sleep, 50
Clipboard:=Store  ;Restore clipboard to original contents
return

Helpful_Links:
Gui, Helpful:Destroy
;~ Gui, Help:Add, Text,x10 y10, This program allows computers that share a mutual folder to share the clipboard.
;~ Gui, Help:Add, Text,x10 y+15, After launching the script on both computers FROM THE SAME DIRECTORY, Copy/paste as you would normally however use the Windows Key INSTEAD of the Control Key.
;~ Gui, Help:Add, Text,x10 y+15, To Copy hold down the windows key and press C (Alternatively you can press Alt and F1)
;~ Gui, Help:Add, Text,x10 y+15, To Paste hold down the windows key and press V (Alternatively you can press Alt and F2)
Gui, Helpful:Font,CBlue Underline
Gui, Helpful:Add,Text,y+5 GWebsite_Jethrow, Jethrow Tutorial
Gui, Helpful:Add,Text,y+10 GWebsite_Mickers, Mickers Tutorial
;******************************
Gui, Helpful:Font,Bold cBlack Norm
Gui, Helpful:Add,Text,y+20, Other Resources
Gui, Helpful:Font,CBlue Underline
Gui, Helpful:Add,Text,y+10 GWebsite_W3Schools, W3 Schools
Gui, Helpful:Add,Text,y+10 GWebsite_DottorO, DottorO
Gui, Helpful:Add,Text,y+10 GWebsite_iWebBrowswer2, iWeb2 Browser
Gui, Helpful:Add,Text,y+10 GWebsite_YouTube, YouTube Demos
Gui, Helpful:Add,Text,y+10 GWebsite_AHK_Tutorial, Webscraping tutorials

hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
onMessage(0x200, "MsgHandler")

Gui, Helpful:Show,w150 , Helpful links
return

;***********About me*******************
About:
Gui,About:Destroy
Gui,About:Font,Bold
Gui,About:Add,Text,x10 y10,WebScraping Menu  v1.0
Gui,About:Font,Norm
Gui,About:Add,Text,x10 y30,To activate menu, Hold down a control key and click the left mouse button

Gui,About:Font
Gui,About:Font,CBlue Underline
Gui,About:Add,Text,y+10 GWebsite_LinkedIN, Joe Glines on LinkedIN
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
onMessage(0x200, "MsgHandler")
Gui,About:Font
Gui,About:Show,, About
return

Website_Jethrow:
Run,http://www.autohotkey.com/board/topic/47052-basic-webpage-controls-with-javascript-com-tutorial
gosub GuiClose
Return

Website_Mickers:
Run,http://www.autohotkey.com/board/topic/64563-basic-ahk-v11-com-tutorial-for-webpages/
gosub GuiClose
Return

Website_W3Schools:
Run, http://www.w3schools.com/jsref/dom_obj_document.asp
gosub GuiClose
Return

Website_DottorO:
Run, http://help.dottoro.com/ljhrmrfb.php
gosub GuiClose
Return

Website_LinkedIN:
Run,http://www.linkedin.com/in/joeglines/
Return

Website_iWebBrowswer2:
Run, http://www.autohotkey.com/board/topic/84258-iwb2-learner-iwebbrowser2/
Return

Website_YouTube:
Run, https://youtu.be/UfqumFBUrwI
Return

Website_AHK_Tutorial:
Run, http://the-automator.com/web-scraping-with-autohotkey/
return

Exit:
ExitApp
Return

Reload:
Reload
Return

Edit:
Edit
Return

GuiClose:
Gui,About:Destroy
OnMessage(0x200,"")
DllCall("DestroyCursor","Uint",hCur)
Return